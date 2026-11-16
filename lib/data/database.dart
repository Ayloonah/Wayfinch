import 'package:drift/drift.dart';

import '../domain/item_enums.dart';
import 'tables.dart';

export 'tables.dart' show newId;

part 'database.g.dart';

/// The Wayfinch local database.
///
/// Open it through `openWayfinchDatabase` (see `database_opener.dart`), which
/// handles the file location and SQLCipher encryption.
///
/// Every schema change must bump [schemaVersion], add a step in [migration],
/// export the schema (`dart run drift_dev make-migrations`) and come with a
/// migration test.
@DriftDatabase(tables: [Items, Tags, ItemTags, Reminders])
class WayfinchDatabase extends _$WayfinchDatabase {
  /// Creates the database on top of an already opened [executor].
  WayfinchDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
