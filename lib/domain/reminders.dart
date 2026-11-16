import 'dates.dart';
import 'item.dart';

/// Global default reminders (minutes before; 0 = none).
class ReminderDefaults {
  /// Creates defaults (spec: 1 hour for tasks, 15 minutes for events).
  const ReminderDefaults({this.taskMinutes = 60, this.eventMinutes = 15});

  /// Before a task is due.
  final int taskMinutes;

  /// Before an event starts.
  final int eventMinutes;
}

/// The reminders that apply to [item]: its own when it has custom ones,
/// otherwise the default for its type. Empty means none.
List<int> effectiveReminders(Item item, ReminderDefaults defaults) {
  if (item.customReminders) return [...item.reminderOffsets]..sort();
  final d = item.isEvent ? defaults.eventMinutes : defaults.taskMinutes;
  return d > 0 ? [d] : const [];
}

/// Whether timed reminders can apply to [item] at all: tasks need a due
/// time (date-only tasks are covered by the morning digest), events need a
/// start.
bool canRemind(Item item) =>
    item.isEvent ? item.start != null : item.due != null && item.dueHasTime;

/// One reminder to show.
class ReminderAlert {
  /// Creates an alert.
  const ReminderAlert({
    required this.itemId,
    required this.fireAt,
    this.snoozed = false,
  });

  /// The item.
  final String itemId;

  /// When it's due to show.
  final DateTime fireAt;

  /// Whether it comes from a snooze.
  final bool snoozed;
}

/// Reminders whose time falls in `(from, to]`, oldest first. Done tasks and
/// ended events never remind.
List<ReminderAlert> remindersBetween(
  Iterable<Item> items,
  ReminderDefaults defaults,
  DateTime from,
  DateTime to,
) {
  final alerts = <ReminderAlert>[];
  for (final item in items) {
    if (item.isDone || item.isEnded(to) || !canRemind(item)) continue;
    final anchor = item.isEvent ? item.start! : item.due!;
    for (final minutes in effectiveReminders(item, defaults)) {
      final at = anchor.subtract(Duration(minutes: minutes));
      if (at.isAfter(from) && !at.isAfter(to)) {
        alerts.add(ReminderAlert(itemId: item.id, fireAt: at));
      }
    }
  }
  alerts.sort((a, b) => a.fireAt.compareTo(b.fireAt));
  return alerts;
}

/// A daily quiet window, e.g. 22:00 to 07:00 (may cross midnight).
class QuietHours {
  /// Creates a window from [startMinutes] to [endMinutes] (minutes after
  /// midnight).
  const QuietHours({required this.startMinutes, required this.endMinutes});

  /// Start, in minutes after midnight.
  final int startMinutes;

  /// End, in minutes after midnight.
  final int endMinutes;

  int _minutes(DateTime t) => t.hour * 60 + t.minute;

  /// Whether [time] is inside the window.
  bool contains(DateTime time) {
    final m = _minutes(time);
    if (startMinutes == endMinutes) return false;
    return startMinutes < endMinutes
        ? m >= startMinutes && m < endMinutes
        : m >= startMinutes || m < endMinutes;
  }

  /// When the window that [time] is in ends.
  DateTime endAfter(DateTime time) {
    final day = startOfDay(time);
    var end = day.add(Duration(minutes: endMinutes));
    if (!end.isAfter(time)) end = addDays(end, 1);
    return end;
  }
}

/// Whether the morning digest should show at [now]: it's on, today's digest
/// time has passed, and it hasn't shown today ([lastShown] is the day it
/// last showed).
bool digestDue({
  required DateTime now,
  required bool enabled,
  required int hour,
  required int minute,
  required DateTime? lastShown,
}) {
  if (!enabled) return false;
  final today = startOfDay(now);
  if (lastShown != null && !startOfDay(lastShown).isBefore(today)) return false;
  final at = DateTime(today.year, today.month, today.day, hour, minute);
  return !now.isBefore(at);
}

/// How a snooze button pushes a reminder back.
enum SnoozeChoice {
  /// 10 minutes.
  tenMinutes,

  /// 1 hour.
  oneHour,

  /// Same time tomorrow.
  tomorrow,
}

/// When a reminder snoozed at [now] with [choice] comes back.
DateTime snoozeUntil(DateTime now, SnoozeChoice choice) => switch (choice) {
  SnoozeChoice.tenMinutes => now.add(const Duration(minutes: 10)),
  SnoozeChoice.oneHour => now.add(const Duration(hours: 1)),
  SnoozeChoice.tomorrow => addDays(now, 1),
};
