import 'package:wayfinch/domain/item.dart';
import 'package:wayfinch/domain/item_enums.dart';

/// Builds an item for tests with sensible defaults.
Item task(
  String id, {
  String? parent,
  DateTime? due,
  bool hasTime = true,
  DateTime? doneAt,
  String? rrule,
  Priority priority = Priority.none,
  int order = 0,
  DateTime? created,
}) => Item(
  id: id,
  type: ItemType.task,
  title: id,
  parentId: parent,
  due: due,
  dueHasTime: due != null && hasTime,
  doneAt: doneAt,
  recurrence: rrule,
  priority: priority,
  sortOrder: order,
  createdAt: created ?? DateTime(2026, 1, 1),
  updatedAt: created ?? DateTime(2026, 1, 1),
);

/// Builds an event for tests.
Item event(
  String id, {
  required DateTime start,
  required DateTime end,
  String? parent,
  String? rrule,
}) => Item(
  id: id,
  type: ItemType.event,
  title: id,
  parentId: parent,
  start: start,
  end: end,
  recurrence: rrule,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);
