import 'package:drift/drift.dart';

import 'database.dart';

/// Reads and writes items, keeping ids and timestamps consistent.
///
/// - New items get a fresh UUID (unless one is given, e.g. from an import
///   that already carries it) and `createdAt == updatedAt`.
/// - Updates never touch `id` or `createdAt` and always bump `updatedAt`.
class ItemsRepository {
  /// Creates a repository over [db]. [clock] is injectable for tests.
  ItemsRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final WayfinchDatabase _db;
  final DateTime Function() _clock;

  /// Inserts [item] and returns the stored row.
  Future<ItemRow> create(ItemsCompanion item) {
    final now = _clock();
    return _db
        .into(_db.items)
        .insertReturning(
          item.copyWith(
            id: item.id.present ? item.id : Value(newId()),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  /// Applies [changes] to the item with [id] and returns the updated row.
  ///
  /// Throws a [StateError] if there is no such item.
  Future<ItemRow> update(String id, ItemsCompanion changes) async {
    final rows = await (_db.update(_db.items)..where((t) => t.id.equals(id)))
        .writeReturning(
          changes.copyWith(
            id: const Value.absent(),
            createdAt: const Value.absent(),
            updatedAt: Value(_clock()),
          ),
        );
    if (rows.isEmpty) throw StateError('No item with id $id');
    return rows.single;
  }

  /// The item with [id], or null.
  Future<ItemRow?> getById(String id) =>
      (_db.select(_db.items)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Direct children of [parentId] (or top-level items when null), in manual
  /// order.
  Future<List<ItemRow>> children(String? parentId) {
    final query = _db.select(_db.items)
      ..where(
        (t) => parentId == null
            ? t.parentId.isNull()
            : t.parentId.equals(parentId),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.get();
  }

  /// Live count of all items.
  Stream<int> watchCount() {
    final count = _db.items.id.count();
    final query = _db.selectOnly(_db.items)..addColumns([count]);
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }
}
