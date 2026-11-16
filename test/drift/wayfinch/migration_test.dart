import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/data/database.dart';

import 'generated/schema.dart';

/// Migration tests. Each new schema version adds a `verifier.migrateAndValidate`
/// test from the previous one (run `dart run drift_dev make-migrations`).
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('a fresh database matches the exported v1 schema', () async {
    final connection = await verifier.startAt(1);
    final db = WayfinchDatabase(connection);
    addTearDown(db.close);

    await verifier.migrateAndValidate(db, 1);
  });

  test('schemaVersion matches the latest exported schema', () {
    final db = WayfinchDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    expect(db.schemaVersion, GeneratedHelper.versions.last);
  });
}
