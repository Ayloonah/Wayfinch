import '../item.dart';
import '../item_enums.dart';
import '../item_tree.dart';
import 'exchange_model.dart';
import 'exchange_parser.dart';

/// How an import is applied.
enum ImportMode {
  /// Only new items are added. Nothing is changed or removed.
  add,

  /// The list becomes the AI's version: matching items (by id) are updated,
  /// keeping their history; open items missing from the reply are removed.
  /// Done items are never touched.
  replace,
}

/// One field that changes on an existing item.
sealed class FieldChange {
  const FieldChange();
}

/// New title.
class TitleChange extends FieldChange {
  /// Creates the change.
  const TitleChange(this.from, this.to);

  /// Old title.
  final String from;

  /// New title.
  final String to;
}

/// Due date (task), start or end (event) changed.
class DateChange extends FieldChange {
  /// Creates the change.
  const DateChange(this.field, this.from, this.to);

  /// Which date.
  final DateField field;

  /// Old value (null = none).
  final ExchangeDate? from;

  /// New value (null = cleared).
  final ExchangeDate? to;
}

/// The dates a [DateChange] can be about.
enum DateField {
  /// Task due date.
  due,

  /// Event start.
  start,

  /// Event end.
  end,
}

/// New priority.
class PriorityChange extends FieldChange {
  /// Creates the change.
  const PriorityChange(this.from, this.to);

  /// Old priority.
  final Priority from;

  /// New priority.
  final Priority to;
}

/// Tags added and/or removed (by name).
class TagsChange extends FieldChange {
  /// Creates the change.
  const TagsChange({required this.added, required this.removed});

  /// Tag names added.
  final List<String> added;

  /// Tag names removed.
  final List<String> removed;
}

/// Notes edited, added or cleared.
class NotesChange extends FieldChange {
  /// Creates the change.
  const NotesChange();
}

/// Repeat rule changed.
class RecurrenceChange extends FieldChange {
  /// Creates the change.
  const RecurrenceChange(this.from, this.to);

  /// Old rule.
  final String? from;

  /// New rule.
  final String? to;
}

/// Marked done or reopened.
class DoneChange extends FieldChange {
  /// Creates the change.
  const DoneChange({required this.done});

  /// True when it gets marked done, false when reopened.
  final bool done;
}

/// Switched between task and event.
class TypeChange extends FieldChange {
  /// Creates the change.
  const TypeChange(this.to);

  /// The new type.
  final ItemType to;
}

/// Moved under another parent (or to the top level).
class MoveChange extends FieldChange {
  /// Creates the change.
  const MoveChange(this.newParentTitle);

  /// Title of the new parent, or null for the top level.
  final String? newParentTitle;
}

/// What happens to one item, for the preview list.
sealed class PlannedChange {
  const PlannedChange(this.title, this.depth);

  /// Title to show.
  final String title;

  /// Nesting depth in the preview.
  final int depth;
}

/// A new item.
class AddedItem extends PlannedChange {
  /// Creates the entry.
  const AddedItem(super.title, super.depth, {required this.source});

  /// What the AI sent.
  final ExchangeItem source;
}

/// An existing item that changes.
class ChangedItem extends PlannedChange {
  /// Creates the entry.
  const ChangedItem(
    super.title,
    super.depth, {
    required this.before,
    required this.fields,
  });

  /// The item now.
  final Item before;

  /// What changes.
  final List<FieldChange> fields;
}

/// An open item missing from the reply (Replace only).
class RemovedItem extends PlannedChange {
  /// Creates the entry.
  const RemovedItem(super.title, super.depth, {required this.item});

  /// The item that would be removed.
  final Item item;
}

/// What applying a plan does to the database.
class ImportChanges {
  /// Creates the change set.
  const ImportChanges({
    required this.updated,
    required this.created,
    required this.deletedIds,
  });

  /// Existing items in their new state.
  final List<Item> updated;

  /// New items (fresh ids).
  final List<Item> created;

  /// Items to delete.
  final List<String> deletedIds;

  /// Number of items touched.
  int get total => updated.length + created.length + deletedIds.length;
}

/// The preview of an import, and how to apply it.
class ImportPlan {
  ImportPlan._(
    this._materializer, {
    required this.mode,
    required this.changes,
    required this.unchangedCount,
    required this.doneUntouched,
    required this.errors,
    required this.newTagNames,
  });

  /// The mode this plan is for.
  final ImportMode mode;

  /// Preview entries: new, changed, then removed.
  final List<PlannedChange> changes;

  /// Matching items with nothing to change.
  final int unchangedCount;

  /// Done items that stay as they are.
  final int doneUntouched;

  /// Problems that only show up against the current list (e.g. an unknown
  /// id without a title). When non-empty the import can't be applied.
  final List<ExchangeError> errors;

  /// Tag names that don't exist yet and will be created.
  final List<String> newTagNames;

  final _Materializer _materializer;

  /// New items.
  Iterable<AddedItem> get added => changes.whereType<AddedItem>();

  /// Changed items.
  Iterable<ChangedItem> get changed => changes.whereType<ChangedItem>();

  /// Removed items.
  Iterable<RemovedItem> get removed => changes.whereType<RemovedItem>();

  /// Number of changes applied, given the removals the user keeps.
  int countFor(Set<String> keep) =>
      added.length +
      changed.length +
      removed.where((r) => !keep.contains(r.item.id)).length;

  /// Builds the database changes. [tagIdsByName] maps lowercase tag names
  /// (including newly created ones) to ids; [keep] holds ids of removals
  /// the user chose to keep.
  ImportChanges build({
    required Map<String, String> tagIdsByName,
    Set<String> keep = const {},
  }) => _materializer(tagIdsByName, keep);
}

typedef _Materializer = ImportChanges Function(
  Map<String, String> tagIdsByName,
  Set<String> keep,
);

/// Compares [doc] with the current list and plans the import.
///
/// - Items are matched by id. An id the app doesn't know is treated as a new
///   item (with a fresh id: ids from an AI are never trusted to be new).
/// - For existing items, a field missing from the reply stays as it is.
/// - The reply's nesting decides parents. A top-level item whose current
///   parent is kept but isn't in the reply (e.g. a done parent that wasn't
///   exported) stays under that parent.
/// - Replace removes open items missing from the reply; done items (and
///   ended events) are never removed. Survivors under a removed item move up
///   to the nearest surviving ancestor.
ImportPlan planImport({
  required ItemTree tree,
  required Map<String, Tag> tagsById,
  required ExchangeDocument doc,
  required ImportMode mode,
  required DateTime now,
  required String Function() newId,
}) {
  final replyIds = <String>{
    for (final x in doc.allItems)
      if (x.id != null && tree[x.id] != null) x.id!,
  };
  final errors = <ExchangeError>[];
  final changes = <PlannedChange>[];
  var unchanged = 0;

  // Resolve ids: existing ones stay, everything else gets a fresh id.
  final resolvedId = <ExchangeItem, String>{};
  for (final x in doc.allItems) {
    final existing = x.id != null && tree[x.id] != null;
    resolvedId[x] = existing ? x.id! : newId();
    if (!existing) {
      if (!x.has('type')) {
        errors.add(
          ExchangeError(
            ExchangeErrorCode.missingField,
            path: x.path,
            detail: 'type',
          ),
        );
      }
      if (!x.has('title')) {
        errors.add(
          ExchangeError(
            ExchangeErrorCode.missingField,
            path: x.path,
            detail: 'title',
          ),
        );
      }
    }
  }

  bool isFinished(Item i) => i.isDone || i.isEnded(now);

  // Which current items survive (before "keep" choices).
  bool removable(Item i) =>
      mode == ImportMode.replace && !isFinished(i) && !replyIds.contains(i.id);

  final tagNameById = {for (final t in tagsById.values) t.id: t.name};
  final knownTagNames = {for (final t in tagsById.values) t.name.toLowerCase()};
  final newTagNames = <String>[];
  void noteTags(List<String> names) {
    for (final n in names) {
      final lower = n.toLowerCase();
      if (!knownTagNames.contains(lower) &&
          !newTagNames.any((x) => x.toLowerCase() == lower)) {
        newTagNames.add(n);
      }
    }
  }

  // Plan entries in reply order, with depth.
  final plannedParent = <ExchangeItem, String?>{};
  void walk(List<ExchangeItem> list, ExchangeItem? parent, int depth) {
    for (final x in list) {
      plannedParent[x] = parent == null ? null : resolvedId[parent];
      final existing = tree[resolvedId[x]];
      if (existing == null) {
        // In Add mode, a new item under an existing one that isn't being
        // added is still fine: it goes under that existing item.
        changes.add(AddedItem(x.title, depth, source: x));
        noteTags(x.tags);
      } else if (mode == ImportMode.replace) {
        final fields = _fieldChanges(
          existing,
          x,
          newParentId: _finalParent(
            existing,
            x,
            parent,
            resolvedId,
            tree,
            replyIds,
            removable,
          ),
          tree: tree,
          tagNameById: tagNameById,
          titleOfNewParent: (id) =>
              tree[id]?.title ??
              doc.allItems.where((i) => resolvedId[i] == id).firstOrNull?.title,
        );
        if (x.has('type') &&
            x.type == ItemType.event &&
            existing.type == ItemType.task &&
            !(x.has('start') && x.has('end'))) {
          errors.add(
            ExchangeError(
              ExchangeErrorCode.eventNeedsTimes,
              path: x.path,
              detail: 'start',
            ),
          );
        }
        if (fields.isEmpty) {
          unchanged++;
        } else {
          changes.add(
            ChangedItem(
              x.has('title') ? x.title : existing.title,
              depth,
              before: existing,
              fields: fields,
            ),
          );
        }
        if (x.has('tags')) noteTags(x.tags);
      }
      walk(x.children, x, depth + 1);
    }
  }

  walk(doc.items, null, 0);

  if (mode == ImportMode.replace) {
    for (final item in tree.all) {
      if (removable(item)) {
        changes.add(RemovedItem(item.title, 0, item: item));
      }
    }
  }

  final doneUntouched = tree.all
      .where((i) => isFinished(i) && !replyIds.contains(i.id))
      .length;

  ImportChanges materialize(Map<String, String> tagIds, Set<String> keep) {
    List<String> ids(List<String> names) => [
      for (final n in names)
        if (tagIds[n.toLowerCase()] != null) tagIds[n.toLowerCase()]!,
    ];

    final updated = <String, Item>{};
    final created = <Item>[];
    final deleted = <String>{
      for (final r in changes.whereType<RemovedItem>())
        if (!keep.contains(r.item.id)) r.item.id,
    };

    // Sibling order from the reply.
    final orderOf = <ExchangeItem, int>{};
    void order(List<ExchangeItem> list) {
      for (var i = 0; i < list.length; i++) {
        orderOf[list[i]] = i;
        order(list[i].children);
      }
    }

    order(doc.items);

    final parentOf = <ExchangeItem, ExchangeItem?>{};
    void parents(List<ExchangeItem> list, ExchangeItem? parent) {
      for (final x in list) {
        parentOf[x] = parent;
        parents(x.children, x);
      }
    }

    parents(doc.items, null);

    bool survives(Item i) =>
        !deleted.contains(i.id) && !(removable(i) && !keep.contains(i.id));

    for (final x in doc.allItems) {
      final id = resolvedId[x]!;
      final existing = tree[id];
      final replyParent = parentOf[x];
      if (existing == null) {
        created.add(
          _newItem(
            x,
            id: id,
            parentId: replyParent == null ? null : resolvedId[replyParent],
            sortOrder: orderOf[x] ?? 0,
            tagIds: ids(x.tags),
            now: now,
          ),
        );
      } else if (mode == ImportMode.replace) {
        final parentId = _finalParent(
          existing,
          x,
          replyParent,
          resolvedId,
          tree,
          replyIds,
          (i) => !survives(i),
        );
        updated[id] = _apply(
          existing,
          x,
          parentId: parentId,
          sortOrder: orderOf[x] ?? existing.sortOrder,
          tagIds: x.has('tags') ? ids(x.tags) : existing.tagIds,
          now: now,
        );
      }
    }

    // Anything left under a deleted item moves up to the nearest survivor.
    if (deleted.isNotEmpty) {
      String? survivingAncestor(String? id) {
        var current = id;
        while (current != null && deleted.contains(current)) {
          current = updated[current]?.parentId ?? tree[current]?.parentId;
        }
        return current;
      }

      for (final item in tree.all) {
        if (deleted.contains(item.id)) continue;
        final current = updated[item.id] ?? item;
        if (current.parentId != null && deleted.contains(current.parentId)) {
          updated[item.id] = current.copyWith(
            parentId: survivingAncestor(current.parentId),
          );
        }
      }
    }

    return ImportChanges(
      updated: updated.values.toList(),
      created: created,
      deletedIds: deleted.toList(),
    );
  }

  return ImportPlan._(
    materialize,
    mode: mode,
    changes: [
      ...changes.whereType<AddedItem>(),
      ...changes.whereType<ChangedItem>(),
      ...changes.whereType<RemovedItem>(),
    ],
    unchangedCount: unchanged,
    doneUntouched: doneUntouched,
    errors: errors,
    newTagNames: newTagNames,
  );
}

/// The parent an existing item ends up with after Replace.
String? _finalParent(
  Item existing,
  ExchangeItem x,
  ExchangeItem? replyParent,
  Map<ExchangeItem, String> resolvedId,
  ItemTree tree,
  Set<String> replyIds,
  bool Function(Item) goesAway,
) {
  if (replyParent != null) return resolvedId[replyParent];
  // Top level in the reply: keep a current parent that isn't in the reply
  // and stays (e.g. a done parent that wasn't exported).
  final current = tree[existing.parentId];
  if (current != null && !replyIds.contains(current.id) && !goesAway(current)) {
    return current.id;
  }
  return null;
}

List<FieldChange> _fieldChanges(
  Item before,
  ExchangeItem x, {
  required String? newParentId,
  required ItemTree tree,
  required Map<String, String> tagNameById,
  required String? Function(String id) titleOfNewParent,
}) {
  final out = <FieldChange>[];
  final type = x.has('type') ? x.type : before.type;
  if (type != before.type) out.add(TypeChange(type));
  if (x.has('title') && x.title != before.title) {
    out.add(TitleChange(before.title, x.title));
  }
  ExchangeDate? current(DateTime? dt, bool hasTime) =>
      dt == null ? null : ExchangeDate(dt, hasTime: hasTime);
  if (type == ItemType.task) {
    final old = current(before.due, before.dueHasTime);
    final changedType = before.type != type;
    final next = x.has('due')
        ? x.due
        : (changedType ? current(before.start, true) : old);
    if (next != old) out.add(DateChange(DateField.due, old, next));
  } else {
    final oldStart = current(before.start, true);
    final oldEnd = current(before.end, true);
    if (x.has('start') && x.start != oldStart) {
      out.add(DateChange(DateField.start, oldStart, x.start));
    }
    if (x.has('end') && x.end != oldEnd) {
      out.add(DateChange(DateField.end, oldEnd, x.end));
    }
  }
  if (x.has('priority') && x.priority != before.priority) {
    out.add(PriorityChange(before.priority, x.priority));
  }
  if (x.has('tags')) {
    final oldNames = [
      for (final id in before.tagIds)
        if (tagNameById[id] != null) tagNameById[id]!,
    ];
    final oldLower = oldNames.map((n) => n.toLowerCase()).toSet();
    final newLower = x.tags.map((n) => n.toLowerCase()).toSet();
    final added = x.tags
        .where((n) => !oldLower.contains(n.toLowerCase()))
        .toList();
    final removed = oldNames
        .where((n) => !newLower.contains(n.toLowerCase()))
        .toList();
    if (added.isNotEmpty || removed.isNotEmpty) {
      out.add(TagsChange(added: added, removed: removed));
    }
  }
  if (x.has('notes') && (x.notes ?? '') != (before.notes ?? '')) {
    out.add(const NotesChange());
  }
  if (x.has('recurrence') &&
      (x.recurrence ?? '').toUpperCase() !=
          (before.recurrence ?? '').toUpperCase()) {
    out.add(RecurrenceChange(before.recurrence, x.recurrence));
  }
  if (type == ItemType.task && x.done != null && x.done != before.isDone) {
    out.add(DoneChange(done: x.done!));
  }
  if (newParentId != before.parentId) {
    out.add(
      MoveChange(newParentId == null ? null : titleOfNewParent(newParentId)),
    );
  }
  return out;
}

Item _apply(
  Item before,
  ExchangeItem x, {
  required String? parentId,
  required int sortOrder,
  required List<String> tagIds,
  required DateTime now,
}) {
  final type = x.has('type') ? x.type : before.type;
  var item = before.copyWith(
    type: type,
    title: x.has('title') ? x.title : null,
    parentId: parentId,
    sortOrder: sortOrder,
    tagIds: tagIds,
  );
  if (x.has('notes')) item = item.copyWith(notes: x.notes);
  if (x.has('priority')) item = item.copyWith(priority: x.priority);
  if (x.has('recurrence')) item = item.copyWith(recurrence: x.recurrence);
  if (type == ItemType.task) {
    if (x.has('due')) {
      item = item.copyWith(
        due: x.due?.value,
        dueHasTime: x.due?.hasTime ?? false,
      );
    } else if (before.type == ItemType.event) {
      item = item.copyWith(due: before.start, dueHasTime: before.start != null);
    }
    item = item.copyWith(start: null, end: null);
    if (x.done == true && !before.isDone) item = item.copyWith(doneAt: now);
    if (x.done == false && before.isDone) item = item.copyWith(doneAt: null);
  } else {
    if (x.has('start')) item = item.copyWith(start: x.start?.value);
    if (x.has('end')) item = item.copyWith(end: x.end?.value);
    item = item.copyWith(due: null, dueHasTime: false, doneAt: null);
  }
  return item;
}

Item _newItem(
  ExchangeItem x, {
  required String id,
  required String? parentId,
  required int sortOrder,
  required List<String> tagIds,
  required DateTime now,
}) {
  final isTask = x.type == ItemType.task;
  return Item(
    id: id,
    type: x.type,
    title: x.title,
    notes: x.notes,
    due: isTask ? x.due?.value : null,
    dueHasTime: isTask && (x.due?.hasTime ?? false),
    start: isTask ? null : x.start?.value,
    end: isTask ? null : x.end?.value,
    priority: x.priority,
    recurrence: x.recurrence,
    parentId: parentId,
    sortOrder: sortOrder,
    doneAt: isTask && x.done == true ? now : null,
    source: ItemSource.aiImport,
    createdAt: now,
    updatedAt: now,
    tagIds: tagIds,
  );
}
