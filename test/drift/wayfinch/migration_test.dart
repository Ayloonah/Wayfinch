import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/data/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

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
