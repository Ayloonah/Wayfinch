import 'item_enums.dart';

/// Whether an item is overdue at [now].
///
/// Overdue is always computed, never stored: an open task whose due moment
/// has passed. Events are never overdue (they move to Done on their own).
///
/// When [dueHasTime] is false the task is due at the end of its due day, so
/// it only becomes overdue once that day is over (in local time).
bool isOverdue({
  required ItemType type,
  required DateTime? due,
  required bool dueHasTime,
  required DateTime? doneAt,
  required DateTime now,
}) {
  if (type != ItemType.task || due == null || doneAt != null) return false;
  return now.isAfter(effectiveDueMoment(due: due, dueHasTime: dueHasTime));
}

/// The moment a task is actually due.
///
/// For a date-only due (`dueHasTime == false`) that is the start of the next
/// local day, i.e. the whole due day still counts as on time.
DateTime effectiveDueMoment({required DateTime due, required bool dueHasTime}) {
  if (dueHasTime) return due;
  final local = due.toLocal();
  return DateTime(local.year, local.month, local.day + 1);
}
