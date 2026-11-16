import 'item.dart';
import 'overdue.dart';

/// The moment an item sorts by: a task's due (end of day when date-only) or
/// an event's start. Null when it has neither.
DateTime? sortMoment(Item item) {
  if (item.isEvent) return item.start;
  final due = item.due;
  if (due == null) return null;
  return effectiveDueMoment(due: due, dueHasTime: item.dueHasTime);
}

/// Default order in every view: due date (items without one last), then
/// priority (highest first), then manual order, then creation time.
int compareItems(Item a, Item b) {
  final ma = sortMoment(a);
  final mb = sortMoment(b);
  if (ma != mb) {
    if (ma == null) return 1;
    if (mb == null) return -1;
    final byDate = ma.compareTo(mb);
    if (byDate != 0) return byDate;
  }
  final byPriority = b.priority.index.compareTo(a.priority.index);
  if (byPriority != 0) return byPriority;
  final byOrder = a.sortOrder.compareTo(b.sortOrder);
  if (byOrder != 0) return byOrder;
  return a.createdAt.compareTo(b.createdAt);
}
