import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:wayfinch/data/daily_backups.dart';
import 'package:wayfinch/data/database.dart';
import 'package:wayfinch/data/database_opener.dart';
import 'package:wayfinch/data/encryption/key_vault.dart';
import 'package:wayfinch/data/import_repository.dart';
import 'package:wayfinch/data/items_repository.dart';
import 'package:wayfinch/data/settings_repository.dart';
import 'package:wayfinch/domain/item_enums.dart';

const _fastKdf = KdfParams(memoryKib: 64, iterations: 1, parallelism: 1);

Future<T> _inline<T>(Future<T> Function() work) => work();

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory dir;
  late DateTime now;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('wayfinch_daily_');
    now = DateTime(2026, 11, 16, 9);
  });

  tearDown(() {
    try {
      dir.deleteSync(recursive: true);
    } on FileSystemException {
      // Windows may still hold a handle for a moment.
    }
  });

  WayfinchDatabase open(File file, Uint8List? key) => WayfinchDatabase(
    NativeDatabase(file, setup: (db) => applyEncryptionKey(db, key)),
  );

  ({
    WayfinchDatabase db,
    ItemsRepository items,
    ImportRepository imports,
    DailyBackupService service,
  })
  setUpDb({Uint8List? key, File? vault}) {
    final db = open(File(p.join(dir.path, 'wayfinch.db')), key);
    final items = ItemsRepository(db, clock: () => now);
    final imports = ImportRepository(db, items, clock: () => now);
    final service = DailyBackupService(
      db: db,
      settings: SettingsRepository(db),
      imports: imports,
      defaultFolder: Directory(p.join(dir.path, 'backups')),
      key: key,
      vaultFile: vault,
      runInBackground: _inline,
      clock: () => now,
    );
    addTearDown(() async {
      service.dispose();
      await db.close();
    });
    return (db: db, items: items, imports: imports, service: service);
  }

  test('backs up once a day and keeps the last 7', () async {
    final s = setUpDb();
    await s.items.create(type: ItemType.task, title: 'Milk');

    expect(await s.service.runIfDue(), isTrue);
    expect(await s.service.runIfDue(), isFalse); // same day
    expect(s.service.backups.single.day, DateTime(2026, 11, 16));
    expect(
      File(p.join(dir.path, 'backups', 'wayfinch-backup-2026-11-16.db'))
          .existsSync(),
      isTrue,
    );

    for (var i = 1; i <= 9; i++) {
      now = DateTime(2026, 11, 16 + i, 9);
      expect(await s.service.runIfDue(), isTrue);
    }
    expect(s.service.backups, hasLength(maxDailyBackups));
    expect(s.service.backups.first.day, DateTime(2026, 11, 25));
    expect(s.service.backups.last.day, DateTime(2026, 11, 19));
  });

  test('restore replaces the list and can be undone', () async {
    final s = setUpDb();
    await s.items.create(type: ItemType.task, title: 'From backup day');
    await s.service.backUpNow();

    final later = await s.items.loadAll();
    await s.items.deleteWithSubtasks(later.single.id);
    await s.items.create(type: ItemType.task, title: 'Added later');

    final result = await s.service.restore(s.service.backups.single);
    expect(result, DailyRestoreResult.restored);
    expect((await s.items.loadAll()).map((i) => i.title), ['From backup day']);

    // The list from before the restore is in Import history.
    expect(await s.imports.undoLatest(), isTrue);
    expect((await s.items.loadAll()).map((i) => i.title), ['Added later']);
  });

  test('a custom folder is used from then on, and can be reset', () async {
    final s = setUpDb();
    final custom = Directory(p.join(dir.path, 'usb'));
    await s.service.setFolder(custom.path);
    expect(s.service.usesDefaultFolder, isFalse);
    await s.service.backUpNow();
    expect(custom.listSync().whereType<File>(), hasLength(1));

    await s.service.setFolder(null);
    expect(s.service.usesDefaultFolder, isTrue);
    expect(s.service.backups, isEmpty); // nothing in the default folder yet
  });

  test('encrypted backups need the key; after a password change, the old '
      'password opens them', () async {
    final service = KeyVaultService();
    final first = await service.create(password: 'old-pass', kdf: _fastKdf);
    final vaultFile = File(p.join(dir.path, 'wayfinch.vault.json'));
    await first.vault.save(vaultFile);
    final s = setUpDb(key: first.dbKey, vault: vaultFile);
    await s.items.create(type: ItemType.task, title: 'Secret');
    final backup = (await s.service.backUpNow())!;
    expect(backup.hasVault, isTrue);

    // Unreadable without a key, readable with it.
    expect(await readBackupSnapshot(backup.file), isNull);
    expect(await readBackupSnapshot(backup.file, key: first.dbKey), isNotNull);

    // A database with a different key (password turned off and on again).
    await s.db.close();
    final second = await service.create(password: 'new-pass', kdf: _fastKdf);
    final otherDb = open(File(p.join(dir.path, 'other.db')), second.dbKey);
    addTearDown(otherDb.close);
    final otherItems = ItemsRepository(otherDb, clock: () => now);
    final other = DailyBackupService(
      db: otherDb,
      settings: SettingsRepository(otherDb),
      imports: ImportRepository(otherDb, otherItems, clock: () => now),
      defaultFolder: Directory(p.join(dir.path, 'backups')),
      key: second.dbKey,
      runInBackground: _inline,
      clock: () => now,
    );
    addTearDown(other.dispose);
    await other.refresh();

    final b = other.backups.single;
    expect(await other.restore(b), DailyRestoreResult.needsPassword);
    expect(
      await other.restore(b, secret: 'nope'),
      DailyRestoreResult.wrongPassword,
    );
    expect(
      await other.restore(b, secret: 'old-pass'),
      DailyRestoreResult.restored,
    );
    expect((await otherItems.loadAll()).single.title, 'Secret');
    // The recovery code from back then works too.
    expect(
      await other.restore(b, secret: first.recoveryCode),
      DailyRestoreResult.restored,
    );
  });
}
