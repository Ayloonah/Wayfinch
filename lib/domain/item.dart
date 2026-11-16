import 'item_enums.dart';

const Object _unset = Object();

/// A task or event, as domain logic sees it (independent of the database).
class Item {
  /// Creates an item.
  const Item({
    required this.id,
    required this.type,
    required this.title,
    this.notes,
    this.due,
    this.dueHasTime = false,
    this.start,
    this.end,
    this.priority = Priority.none,
    this.recurrence,
    this.parentId,
    this.sortOrder = 0,
    this.doneAt,
    this.source = ItemSource.manual,
    this.icsUid,
    required this.createdAt,
    required this.updatedAt,
    this.tagIds = const [],
  });

  /// Stable UUID.
  final String id;

  /// Task or event.
  final ItemType type;

  /// Title shown in lists.
  final String title;

  /// Optional free-text notes.
  final String? notes;

  /// Task due date (and time when [dueHasTime]).
  final DateTime? due;

  /// Whether [due] includes a time of day.
  final bool dueHasTime;

  /// Event start.
  final DateTime? start;

  /// Event end.
  final DateTime? end;

  /// Importance.
  final Priority priority;

  /// iCal RRULE (without or with the `RRULE:` prefix), or null.
  final String? recurrence;

  /// Parent id, or null at the top level.
  final String? parentId;

  /// Manual order among siblings.
  final int sortOrder;

  /// When a task was completed, or null while open.
  final DateTime? doneAt;

  /// Where the item came from.
  final ItemSource source;

  /// VEVENT UID for .ics imports.
  final String? icsUid;

  /// Creation time.
  final DateTime createdAt;

  /// Last change time.
  final DateTime updatedAt;

  /// Ids of the tags on this item.
  final List<String> tagIds;

  /// Whether this is a task.
  bool get isTask => type == ItemType.task;

  /// Whether this is an event.
  bool get isEvent => type == ItemType.event;

  /// Whether this is a completed task.
  bool get isDone => isTask && doneAt != null;

  /// Whether this item repeats.
  bool get isRecurring => recurrence != null && recurrence!.trim().isNotEmpty;

  /// Whether this is an event whose end has passed (it then lives in Done).
  bool isEnded(DateTime now) => isEvent && end != null && !end!.isAfter(now);

  /// Whether the item shows in the normal views at [now]: open tasks and
  /// events that haven't ended.
  bool isVisible(DateTime now) => isTask ? doneAt == null : !isEnded(now);

  /// Returns a copy with the given fields replaced. Pass `null` to clear a
  /// nullable field.
  Item copyWith({
    String? id,
    ItemType? type,
    String? title,
    Object? notes = _unset,
    Object? due = _unset,
    bool? dueHasTime,
    Object? start = _unset,
    Object? end = _unset,
    Priority? priority,
    Object? recurrence = _unset,
    Object? parentId = _unset,
    int? sortOrder,
    Object? doneAt = _unset,
    ItemSource? source,
    Object? icsUid = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tagIds,
  }) {
    return Item(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      notes: identical(notes, _unset) ? this.notes : notes as String?,
      due: identical(due, _unset) ? this.due : due as DateTime?,
      dueHasTime: dueHasTime ?? this.dueHasTime,
      start: identical(start, _unset) ? this.start : start as DateTime?,
      end: identical(end, _unset) ? this.end : end as DateTime?,
      priority: priority ?? this.priority,
      recurrence: identical(recurrence, _unset)
          ? this.recurrence
          : recurrence as String?,
      parentId: identical(parentId, _unset)
          ? this.parentId
          : parentId as String?,
      sortOrder: sortOrder ?? this.sortOrder,
      doneAt: identical(doneAt, _unset) ? this.doneAt : doneAt as DateTime?,
      source: source ?? this.source,
      icsUid: identical(icsUid, _unset) ? this.icsUid : icsUid as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tagIds: tagIds ?? this.tagIds,
    );
  }

  @override
  String toString() => 'Item($id, $type, "$title")';
}

/// A user tag.
class Tag {
  /// Creates a tag.
  const Tag({required this.id, required this.name, required this.color});

  /// Stable UUID.
  final String id;

  /// Display name.
  final String name;

  /// 32-bit ARGB color.
  final int color;
}
