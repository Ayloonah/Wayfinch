import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/data/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;

/// Migration tests: every schema version must upgrade cleanly from each
/// earlier one, keep its data, and match the exported schema.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('from each version to the latest', () {
    const versions = GeneratedHelper.versions;
    final latest = versions.last;
    for (final from in versions) {
      test('v$from -> v$latest matches the exported schema', () async {
        final connection = await verifier.startAt(from);
        final db = WayfinchDatabase(connection);
        addTearDown(db.close);
        await verifier.migrateAndValidate(db, latest);
      });
    }
  });

  test('v3 -> v4 keeps items, which follow the default reminders', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: WayfinchDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(
          oldDb.items,
          v3.ItemsCompanion.insert(
            id: 'a1b2',
            type: 'task',
            title: 'Still here',
            createdAt: '2026-11-15T09:00:00.000',
            updatedAt: '2026-11-15T09:00:00.000',
          ),
        );
      },
      validateItems: (newDb) async {
        final item = (await newDb.select(newDb.items).get()).single;
        expect(item.id, 'a1b2');
        expect(item.customReminders, 0); // stored false
      },
    );
  });

  test('v2 -> v3 keeps items and settings, and adds import backups', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: WayfinchDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(
          oldDb.items,
          v2.ItemsCompanion.insert(
            id: 'a1b2',
            type: 'task',
            title: 'Still here',
            createdAt: '2026-11-15T09:00:00.000',
            updatedAt: '2026-11-15T09:00:00.000',
          ),
        );
        batch.insert(
          oldDb.settings,
          v2.SettingsCompanion.insert(key: 'theme.mode', value: 'dark'),
        );
      },
      validateItems: (newDb) async {
        expect((await newDb.select(newDb.items).get()).single.id, 'a1b2');
        expect((await newDb.select(newDb.settings).get()).single.value, 'dark');
        expect(await newDb.select(newDb.importBackups).get(), isEmpty);
      },
    );
  });

  test('v1 -> v2 keeps items, tags and links, and adds settings', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: WayfinchDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(
          oldDb.items,
          v1.ItemsCompanion.insert(
            id: 'a1b2',
            type: 'task',
            title: 'Kept through the upgrade',
            createdAt: '2026-11-15T09:00:00.000',
            updatedAt: '2026-11-15T09:00:00.000',
          ),
        );
        batch.insert(
          oldDb.tags,
          v1.TagsCompanion.insert(
            id: 't1',
            name: 'school',
            color: 0xFF7950F2,
            createdAt: '2026-11-15T09:00:00.000',
            updatedAt: '2026-11-15T09:00:00.000',
          ),
        );
        batch.insert(
          oldDb.itemTags,
          v1.ItemTagsCompanion.insert(itemId: 'a1b2', tagId: 't1'),
        );
      },
      validateItems: (newDb) async {
        final items = await newDb.select(newDb.items).get();
        expect(items.single.id, 'a1b2');
        expect(items.single.title, 'Kept through the upgrade');
        expect(await newDb.select(newDb.itemTags).get(), hasLength(1));
        expect(await newDb.select(newDb.settings).get(), isEmpty);
      },
    );
  });

  test('schemaVersion matches the latest exported schema', () {
    final db = WayfinchDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, GeneratedHelper.versions.last);
  });
}
