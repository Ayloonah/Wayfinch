import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../data/daily_backups.dart';
import '../data/database.dart';
import '../data/database_opener.dart';
import '../data/encryption/db_conversion.dart';
import '../data/encryption/key_vault.dart';
import '../data/import_repository.dart';
import '../data/items_repository.dart';
import '../data/settings_repository.dart';
import '../data/tags_repository.dart';
import '../ui/home/home_controller.dart';
import '../ui/theme/appearance_controller.dart';

/// Where the app is in its startup.
enum SessionPhase {
  /// Working out what to show.
  starting,

  /// A password is set: waiting for it (or the recovery code).
  locked,

  /// The database is open.
  ready,
}

/// Runs slow work (the Argon2id key derivation) off the UI thread.
typedef BackgroundRunner = Future<T> Function<T>(Future<T> Function() work);

/// Opens the database file (with an optional SQLCipher key).
typedef DatabaseOpener = WayfinchDatabase Function(File file, Uint8List? key);

WayfinchDatabase _defaultOpener(File file, Uint8List? key) =>
    openWayfinchDatabase(file: file, key: key);

Future<T> _isolateRunner<T>(Future<T> Function() work) => Isolate.run(work);

/// Settings key: onboarding finished.
const onboardingDoneKey = 'onboarding.done';

/// Owns the database and the controllers built on it, and everything about
/// the password: unlocking, turning encryption on or off, changing the
/// password and the recovery code.
///
/// Turning encryption on or off has to close the database, convert the file
/// and reopen it, so the controllers are rebuilt; widgets read them from
/// here and rebuild when this notifies.
class AppSession extends ChangeNotifier {
  /// Creates a session for the files in [dataDir].
  AppSession({
    required this.dataDir,
    this.kdf = KdfParams.standard,
    BackgroundRunner? runInBackground,
    this.clock,
    DatabaseOpener? openDatabase,
    this.enableDailyBackups = true,
  }) : _run = runInBackground ?? _isolateRunner,
       _openDb = openDatabase ?? _defaultOpener;

  /// Folder holding the database and the key vault.
  final Directory dataDir;

  /// Key-derivation cost (cheaper in tests).
  final KdfParams kdf;

  /// Clock for timestamps (injectable for tests).
  final DateTime Function()? clock;

  /// Whether to run daily backups (off in tests that don't need them).
  final bool enableDailyBackups;
  final BackgroundRunner _run;
  final DatabaseOpener _openDb;

  /// The database file.
  File get databaseFile => File(p.join(dataDir.path, databaseFileName));

  /// The key vault (exists only while a password is set).
  File get vaultFile => File(p.join(dataDir.path, vaultFileName));

  SessionPhase _phase = SessionPhase.starting;

  /// Current phase.
  SessionPhase get phase => _phase;

  WayfinchDatabase? _db;
  DailyBackupService? _backups;
  HomeController? _home;
  AppearanceController? _appearance;
  bool _needsOnboarding = false;
  Uint8List? _recoveryKey;

  /// Main-screen state (null until ready).
  HomeController? get home => _home;

  /// Theme settings (null until ready).
  AppearanceController? get appearance => _appearance;

  /// Settings storage (null until ready).
  SettingsRepository? get settings => _home?.settings;

  /// Whether setup still needs to run.
  bool get needsOnboarding => _needsOnboarding;

  /// Whether the user unlocked with the recovery code and should choose a
  /// new password.
  bool get mustChooseNewPassword => _recoveryKey != null;

  /// Whether a password is set.
  bool get hasPassword => vaultFile.existsSync();

  /// Decides what to show: unlock screen, or open the database.
  Future<void> start() async {
    await dataDir.create(recursive: true);
    if (hasPassword) {
      _phase = SessionPhase.locked;
      notifyListeners();
    } else {
      await _open(null);
    }
  }

  /// Unlocks with [password]. Returns false if it's wrong.
  Future<bool> unlockWithPassword(String password) async {
    final key = await _unwrap((s, v) => s.unlockWithPassword(v, password));
    if (key == null) return false;
    await _open(key);
    return true;
  }

  /// Unlocks with the recovery [code]. Returns false if it's wrong. After
  /// this, [mustChooseNewPassword] is true.
  Future<bool> unlockWithRecoveryCode(String code) async {
    final key = await _unwrap((s, v) => s.unlockWithRecoveryCode(v, code));
    if (key == null) return false;
    _recoveryKey = key;
    await _open(key);
    return true;
  }

  /// After a recovery-code unlock: sets a new password ([password] null
  /// keeps the old one).
  Future<void> finishRecovery(String? password) async {
    final key = _recoveryKey;
    _recoveryKey = null;
    if (key != null && password != null) {
      final vault = (await KeyVault.load(vaultFile))!;
      final kdf = vault.kdf;
      final next = await _run(
        () => KeyVaultService().changePassword(
          KeyVault(
            kdf: kdf,
            passwordWrap: vault.passwordWrap,
            recoveryWrap: vault.recoveryWrap,
          ),
          dbKey: key,
          newPassword: password,
        ),
      );
      await next.save(vaultFile);
    }
    notifyListeners();
  }

  /// Creates a new key, vault and recovery code for [password]. Slow (a few
  /// seconds); nothing is changed until [enablePassword].
  Future<VaultSetup> preparePassword(String password) {
    final kdf = this.kdf;
    return _run(() => KeyVaultService().create(password: password, kdf: kdf));
  }

  /// Turns encryption on with [setup] (from [preparePassword]): the database
  /// file is encrypted in place and the vault saved.
  Future<void> enablePassword(VaultSetup setup) async {
    if (hasPassword) throw StateError('A password is already set');
    final returnTo = _home?.destination;
    await _close();
    DatabaseConversion.encrypt(databaseFile, setup.dbKey);
    await setup.vault.save(vaultFile);
    await _open(setup.dbKey, returnTo: returnTo);
  }

  /// Turns encryption off (needs the current [password]). Returns false if
  /// the password is wrong.
  Future<bool> disablePassword(String password) async {
    final key = await _unwrap((s, v) => s.unlockWithPassword(v, password));
    if (key == null) return false;
    final returnTo = _home?.destination;
    await _close();
    DatabaseConversion.decrypt(databaseFile, key);
    await vaultFile.delete();
    await _open(null, returnTo: returnTo);
    return true;
  }

  /// Changes the password. Returns false if [current] is wrong.
  Future<bool> changePassword(String current, String next) async {
    final vault = await KeyVault.load(vaultFile);
    if (vault == null) return false;
    final updated = await _run(() async {
      final service = KeyVaultService();
      try {
        final key = await service.unlockWithPassword(vault, current);
        return await service.changePassword(
          vault,
          dbKey: key,
          newPassword: next,
        );
      } on WrongSecretException {
        return null;
      }
    });
    if (updated == null) return false;
    await updated.save(vaultFile);
    return true;
  }

  /// Makes a new recovery code (the old one stops working). Returns null if
  /// [password] is wrong.
  Future<String?> newRecoveryCode(String password) async {
    final vault = await KeyVault.load(vaultFile);
    if (vault == null) return null;
    final result = await _run(() async {
      final service = KeyVaultService();
      try {
        final key = await service.unlockWithPassword(vault, password);
        return await service.newRecoveryCode(vault, dbKey: key);
      } on WrongSecretException {
        return null;
      }
    });
    if (result == null) return null;
    await result.$1.save(vaultFile);
    return result.$2;
  }

  /// Marks setup as done.
  Future<void> completeOnboarding() async {
    await settings?.setValue(onboardingDoneKey, 'true');
    _needsOnboarding = false;
    notifyListeners();
  }

  Future<Uint8List?> _unwrap(
    Future<Uint8List> Function(KeyVaultService, KeyVault) unlock,
  ) async {
    final vault = await KeyVault.load(vaultFile);
    if (vault == null) return null;
    return _run(() async {
      try {
        return await unlock(KeyVaultService(), vault);
      } on WrongSecretException {
        return null;
      }
    });
  }

  Future<void> _open(Uint8List? key, {Destination? returnTo}) async {
    final db = _openDb(databaseFile, key);
    final clock = this.clock;
    final items = ItemsRepository(db, clock: clock);
    final settings = SettingsRepository(db);
    final imports = ImportRepository(db, items, clock: clock);
    _db = db;
    _needsOnboarding = await settings.getValue(onboardingDoneKey) != 'true';
    final backups = enableDailyBackups
        ? DailyBackupService(
            db: db,
            settings: settings,
            imports: imports,
            defaultFolder: Directory(p.join(dataDir.path, 'backups')),
            key: key,
            vaultFile: key == null ? null : vaultFile,
            shouldRun: () => !_needsOnboarding,
            runInBackground: _run,
            clock: clock,
          )
        : null;
    _backups = backups;
    backups?.start();
    _home = HomeController(
      items: items,
      tags: TagsRepository(db, clock: clock),
      settings: settings,
      imports: imports,
      dailyBackups: backups,
      clock: clock,
    );
    if (returnTo != null) _home!.go(returnTo);
    _appearance = AppearanceController(settings);
    _phase = SessionPhase.ready;
    notifyListeners();
  }

  Future<void> _close() async {
    final home = _home;
    final appearance = _appearance;
    final db = _db;
    final backups = _backups;
    _backups = null;
    _home = null;
    _appearance = null;
    _db = null;
    _phase = SessionPhase.starting;
    notifyListeners();
    // Let widgets drop the old controllers before disposing them.
    await Future<void>.delayed(Duration.zero);
    home?.dispose();
    appearance?.dispose();
    backups?.dispose();
    await db?.close();
  }

  /// Closes the database and controllers (tests; the app just exits).
  Future<void> shutdown() => _close();

  @override
  void dispose() {
    _backups?.dispose();
    _home?.dispose();
    _appearance?.dispose();
    _db?.close();
    super.dispose();
  }
}
