import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'database.dart';
import 'database_opener.dart';
import 'encryption/key_vault.dart';
import 'import_repository.dart';
import 'settings_repository.dart';

/// How many daily backups are kept.
const maxDailyBackups = 7;

/// One daily backup file.
class DailyBackup {
  /// Creates the info.
  const DailyBackup({
    required this.file,
    required this.day,
    required this.size,
    required this.hasVault,
  });

  /// The backup's database file.
  final File file;

  /// The day it was taken.
  final DateTime day;

  /// File size in bytes.
  final int size;

  /// Whether it was encrypted (a copy of that day's key vault sits next to
  /// it, so it can still be opened after a password change).
  final bool hasVault;

  /// The key vault copy (exists when [hasVault]).
  File get vaultFile => File(_vaultPathFor(file.path));
}

/// How restoring a daily backup went.
enum DailyRestoreResult {
  /// The list was replaced by the backup.
  restored,

  /// The backup was made with a different password: ask for it (or the
  /// recovery code from back then) and try again.
  needsPassword,

  /// The password or code given didn't unlock it.
  wrongPassword,

  /// The file couldn't be read.
  unreadable,
}

/// Runs slow work off the UI thread.
typedef BackupRunner = Future<T> Function<T>(Future<T> Function() work);

Future<T> _isolate<T>(Future<T> Function() work) => Isolate.run(work);

/// Daily automatic backups of the whole database, in a folder the user can
/// change (by default a `backups` folder next to the database).
///
/// A backup is a copy of the database file, encrypted with the same key as
/// the database (or plain when no password is set), plus a copy of the key
/// vault when there is one. The last [maxDailyBackups] are kept.
class DailyBackupService extends ChangeNotifier {
  /// Creates the service for [db].
  DailyBackupService({
    required this.db,
    required this.settings,
    required this.imports,
    required this.defaultFolder,
    this.key,
    this.vaultFile,
    this.shouldRun,
    BackupRunner? runInBackground,
    DateTime Function()? clock,
  }) : _run = runInBackground ?? _isolate,
       _clock = clock ?? DateTime.now;

  /// The live database.
  final WayfinchDatabase db;

  /// Settings (folder choice, last backup day).
  final SettingsRepository settings;

  /// Restores go through here, so they can be undone from Import history.
  final ImportRepository imports;

  /// Where backups go unless the user picked another folder.
  final Directory defaultFolder;

  /// The database's SQLCipher key (null when no password is set).
  final Uint8List? key;

  /// The current key vault (copied next to each encrypted backup).
  final File? vaultFile;

  /// Whether the scheduled backup may run now (e.g. not during setup).
  final bool Function()? shouldRun;

  final BackupRunner _run;
  final DateTime Function() _clock;
  Timer? _timer;
  Timer? _firstRun;
  bool _disposed = false;
  List<DailyBackup> _backups = const [];
  Directory? _folder;
  bool _busy = false;

  static const _folderKey = 'backup.folder';
  static const _lastKey = 'backup.last';

  /// Backups found in the folder, newest first (after [refresh]).
  List<DailyBackup> get backups => _backups;

  /// The backup folder (after [refresh]).
  Directory get folder => _folder ?? defaultFolder;

  /// Whether the backups are in the default folder.
  bool get usesDefaultFolder => folder.path == defaultFolder.path;

  /// Starts the daily schedule: checks now (after [delay]) and then every
  /// [every]; backs up once per day.
  void start({
    Duration delay = const Duration(seconds: 10),
    Duration every = const Duration(minutes: 30),
  }) {
    _timer?.cancel();
    _firstRun?.cancel();
    unawaited(refresh());
    _firstRun = Timer(delay, () => unawaited(runIfDue()));
    _timer = Timer.periodic(every, (_) => unawaited(runIfDue()));
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _firstRun?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  /// Rereads the folder setting and the list of backups.
  Future<void> refresh() async {
    final saved = await settings.getValue(_folderKey);
    _folder = saved == null || saved.isEmpty ? defaultFolder : Directory(saved);
    _backups = _scan(folder);
    notifyListeners();
  }

  /// Moves future backups to [path] (null goes back to the default folder).
  /// Existing backups stay where they are.
  Future<void> setFolder(String? path) async {
    await settings.setValue(_folderKey, path);
    await refresh();
  }

  /// Backs up if there's no backup for today yet. Returns whether it did.
  Future<bool> runIfDue() async {
    if (_disposed || (shouldRun != null && !shouldRun!())) return false;
    final today = _day(_clock());
    if (await settings.getValue(_lastKey) == today) return false;
    await backUpNow();
    return true;
  }

  /// Backs up now (replacing today's backup, if any) and drops the oldest
  /// beyond [maxDailyBackups].
  Future<DailyBackup?> backUpNow() async {
    if (_busy) return null;
    _busy = true;
    try {
      await refresh();
      final dir = folder;
      await dir.create(recursive: true);
      final now = _clock();
      final target = File(p.join(dir.path, _fileName(now)));
      final temp = File('${target.path}.writing');
      if (temp.existsSync()) temp.deleteSync();
      final version =
          (await db.customSelect('PRAGMA user_version').getSingle())
                  .data
                  .values
                  .first
              as int;
      final keyClause = key == null ? "''" : '"x\'${_hex(key!)}\'"';
      await db.customStatement(
        "ATTACH DATABASE '${temp.path.replaceAll("'", "''")}' "
        'AS daily_backup KEY $keyClause',
      );
      try {
        await db.customSelect("SELECT sqlcipher_export('daily_backup')").get();
        await db.customStatement('PRAGMA daily_backup.user_version = $version');
      } finally {
        await db.customStatement('DETACH DATABASE daily_backup');
      }
      if (target.existsSync()) target.deleteSync();
      temp.renameSync(target.path);
      final vaultCopy = File(_vaultPathFor(target.path));
      final vault = vaultFile;
      if (key != null && vault != null && vault.existsSync()) {
        vault.copySync(vaultCopy.path);
      } else if (vaultCopy.existsSync()) {
        vaultCopy.deleteSync();
      }
      await settings.setValue(_lastKey, _day(now));
      _prune(dir);
      _backups = _scan(dir);
      notifyListeners();
      return _backups.where((b) => b.file.path == target.path).firstOrNull;
    } finally {
      _busy = false;
    }
  }

  /// Replaces the list with [backup]'s. The current list is backed up first
  /// (in Import history), so this can be undone.
  ///
  /// When the backup was made with a different password, returns
  /// [DailyRestoreResult.needsPassword]; call again with [secret] (that
  /// password, or the recovery code from back then).
  Future<DailyRestoreResult> restore(
    DailyBackup backup, {
    String? secret,
  }) async {
    final file = backup.file;
    if (!file.existsSync()) return DailyRestoreResult.unreadable;
    final keys = <Uint8List?>[key, if (key != null) null];
    if (secret != null) {
      final vault = await KeyVault.load(backup.vaultFile);
      if (vault == null) return DailyRestoreResult.wrongPassword;
      final unlocked = await _run(() async {
        final service = KeyVaultService();
        try {
          return await service.unlockWithPassword(vault, secret);
        } on WrongSecretException {
          try {
            return await service.unlockWithRecoveryCode(vault, secret);
          } on WrongSecretException {
            return null;
          }
        }
      });
      if (unlocked == null) return DailyRestoreResult.wrongPassword;
      keys
        ..clear()
        ..add(unlocked);
    }
    for (final k in keys) {
      final payload = await readBackupSnapshot(file, key: k);
      if (payload != null) {
        await imports.restoreSnapshot(payload);
        return DailyRestoreResult.restored;
      }
    }
    if (secret == null && backup.hasVault) {
      return DailyRestoreResult.needsPassword;
    }
    return DailyRestoreResult.unreadable;
  }

  void _prune(Directory dir) {
    final all = _scan(dir);
    for (final old in all.skip(maxDailyBackups)) {
      try {
        old.file.deleteSync();
        if (old.vaultFile.existsSync()) old.vaultFile.deleteSync();
      } on FileSystemException {
        // Leave it; try again next time.
      }
    }
  }
}

/// Reads the list stored in backup [file] (opened with [key], or as a plain
/// file when null) as a snapshot, or null if it can't be opened with that
/// key. Works on a temporary copy, which is brought up to the current schema.
Future<String?> readBackupSnapshot(File file, {Uint8List? key}) async {
  final temp = Directory.systemTemp.createTempSync('wayfinch_restore_');
  final copy = file.copySync(p.join(temp.path, 'backup.db'));
  WayfinchDatabase? db;
  try {
    db = WayfinchDatabase(
      NativeDatabase(copy, setup: (raw) => applyEncryptionKey(raw, key)),
    );
    return await snapshotDatabase(db);
  } on SqliteException {
    // Wrong key, or not a database file.
    return null;
  } finally {
    await db?.close();
    try {
      temp.deleteSync(recursive: true);
    } on FileSystemException {
      // Temp files get cleaned up by Windows eventually.
    }
  }
}

final _nameRe = RegExp(r'^wayfinch-backup-(\d{4})-(\d{2})-(\d{2})\.db$');

String _fileName(DateTime now) => 'wayfinch-backup-${_day(now)}.db';

String _vaultPathFor(String dbPath) =>
    '${dbPath.substring(0, dbPath.length - 3)}.vault.json';

String _day(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

List<DailyBackup> _scan(Directory dir) {
  if (!dir.existsSync()) return const [];
  final out = <DailyBackup>[];
  for (final entity in dir.listSync()) {
    if (entity is! File) continue;
    final m = _nameRe.firstMatch(p.basename(entity.path));
    if (m == null) continue;
    out.add(
      DailyBackup(
        file: entity,
        day: DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!)),
        size: entity.lengthSync(),
        hasVault: File(_vaultPathFor(entity.path)).existsSync(),
      ),
    );
  }
  out.sort((a, b) => b.day.compareTo(a.day));
  return out;
}

String _hex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
