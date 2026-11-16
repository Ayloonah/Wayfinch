import 'package:drift/drift.dart';

import '../domain/item.dart';
import '../domain/item_enums.dart';
import '../domain/item_rules.dart';
import '../domain/item_tree.dart';
import 'database.dart';

/// Reads and writes items (with their tags), keeping ids and timestamps
/// consistent:
///
/// - new items get a fresh UUID (unless one is given, e.g. by an import) and
///   `createdAt == updatedAt`;
/// - saves never change `id` or `createdAt` and always bump `updatedAt`.
class ItemsRepository {
  /// Creates a repository over [db]. [clock] is injectable for tests.
  ItemsRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final WayfinchDatabase _db;
  final DateTime Function() _clock;

  /// Creates an item and returns it.
  Future<Item> create({
    required ItemType type,
    required String title,
    String? id,
    String? notes,
    DateTime? due,
    bool dueHasTime = false,
    DateTime? start,
    DateTime? end,
    Priority priority = Priority.none,
    String? recurrence,
    String? parentId,
    int? sortOrder,
    ItemSource source = ItemSource.manual,
    List<String> tagIds = const [],
  }) async {
    final now = _clock();
    final item = Item(
      id: id ?? newId(),
      type: type,
      title: title,
      notes: notes,
      due: due,
      dueHasTime: due != null && dueHasTime,
      start: start,
      end: end,
      priority: priority,
      recurrence: recurrence,
      parentId: parentId,
      sortOrder: sortOrder ?? await _nextSortOrder(parentId),
      source: source,
      createdAt: now,
      updatedAt: now,
      tagIds: tagIds,
    );
    await _db.transaction(() => _insert(item));
    return item;
  }

  /// Saves [item]'s current fields (not its id or creation time).
  Future<void> save(Item item) =>
      _db.transaction(() => _update(item.copyWith(updatedAt: _clock())));

  /// Applies a rule's [changes] in one transaction.
  Future<void> apply(ItemChanges changes) async {
    if (changes.isEmpty) return;
    final now = _clock();
    await _db.transaction(() async {
      for (final item in changes.updated) {
        await _update(item.copyWith(updatedAt: now));
      }
      for (final item in changes.created) {
        await _insert(item.copyWith(createdAt: now, updatedAt: now));
      }
    });
  }

  /// Deletes [id] and all its subtasks.
  Future<void> deleteWithSubtasks(String id) async {
    await _db.transaction(() async {
      final tree = ItemTree(await loadAll());
      final ids = [id, ...tree.descendantsOf(id).map((d) => d.id)];
      // Children first, so the parent foreign key is never violated.
      for (final itemId in ids.reversed) {
        await (_db.delete(_db.items)..where((t) => t.id.equals(itemId))).go();
      }
    });
  }

  /// The item with [id], or null.
  Future<Item?> getById(String id) async {
    final all = await loadAll();
    return all.where((i) => i.id == id).firstOrNull;
  }

  /// All items with their tags.
  Future<List<Item>> loadAll() => _allQuery().get().then(_group);

  /// All items with their tags, updated live.
  Stream<List<Item>> watchAll() => _allQuery().watch().map(_group);

  JoinedSelectStatement<HasResultSet, dynamic> _allQuery() =>
      _db.select(_db.items).join([
        leftOuterJoin(
          _db.itemTags,
          _db.itemTags.itemId.equalsExp(_db.items.id),
        ),
      ]);

  List<Item> _group(List<TypedResult> rows) {
    final items = <String, ItemRow>{};
    final tags = <String, List<String>>{};
    for (final row in rows) {
      final item = row.readTable(_db.items);
      items[item.id] = item;
      final link = row.readTableOrNull(_db.itemTags);
      final list = tags[item.id] ??= [];
      if (link != null) list.add(link.tagId);
    }
    return [
      for (final row in items.values) _toItem(row, tags[row.id] ?? const []),
    ];
  }

  Future<int> _nextSortOrder(String? parentId) async {
    final max = _db.items.sortOrder.max();
    final query = _db.selectOnly(_db.items)
      ..addColumns([max])
      ..where(
        parentId == null
            ? _db.items.parentId.isNull()
            : _db.items.parentId.equals(parentId),
      );
    final value = await query.map((r) => r.read(max)).getSingle();
    return (value ?? -1) + 1;
  }

  Future<void> _insert(Item item) async {
    await _db.into(_db.items).insert(_toCompanion(item, withId: true));
    await _writeTags(item);
  }

  Future<void> _update(Item item) async {
    final count =
        await (_db.update(_db.items)..where((t) => t.id.equals(item.id))).write(
          _toCompanion(item, withId: false),
        );
    if (count == 0) throw StateError('No item with id ${item.id}');
    await _writeTags(item);
  }

  Future<void> _writeTags(Item item) async {
    await (_db.delete(
      _db.itemTags,
    )..where((t) => t.itemId.equals(item.id))).go();
    for (final tagId in item.tagIds.toSet()) {
      await _db
          .into(_db.itemTags)
          .insert(ItemTagsCompanion.insert(itemId: item.id, tagId: tagId));
    }
  }

  ItemsCompanion _toCompanion(Item item, {required bool withId}) {
    return ItemsCompanion(
      id: withId ? Value(item.id) : const Value.absent(),
      type: Value(item.type),
      title: Value(item.title),
      notes: Value(item.notes),
      due: Value(item.due),
      dueHasTime: Value(item.due != null && item.dueHasTime),
      start: Value(item.start),
      end: Value(item.end),
      priority: Value(item.priority),
      recurrence: Value(item.recurrence),
      parentId: Value(item.parentId),
      sortOrder: Value(item.sortOrder),
      doneAt: Value(item.doneAt),
      source: Value(item.source),
      icsUid: Value(item.icsUid),
      createdAt: withId ? Value(item.createdAt) : const Value.absent(),
      updatedAt: Value(item.updatedAt),
    );
  }

  Item _toItem(ItemRow row, List<String> tagIds) => Item(
    id: row.id,
    type: row.type,
    title: row.title,
    notes: row.notes,
    due: row.due,
    dueHasTime: row.dueHasTime,
    start: row.start,
    end: row.end,
    priority: row.priority,
    recurrence: row.recurrence,
    parentId: row.parentId,
    sortOrder: row.sortOrder,
    doneAt: row.doneAt,
    source: row.source,
    icsUid: row.icsUid,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    tagIds: tagIds,
  );
}
