import 'package:rrule/rrule.dart';

import 'dates.dart';

/// Repeat presets offered by the Repeat picker, with their RRULEs.
enum RepeatPreset {
  /// Every day.
  daily('FREQ=DAILY'),

  /// Monday to Friday.
  weekdays('FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR'),

  /// Every week.
  weekly('FREQ=WEEKLY'),

  /// Every two weeks.
  biweekly('FREQ=WEEKLY;INTERVAL=2'),

  /// Every month.
  monthly('FREQ=MONTHLY'),

  /// Every year.
  yearly('FREQ=YEARLY');

  const RepeatPreset(this.rrule);

  /// The RRULE stored for this preset.
  final String rrule;

  /// The preset matching [rrule], or null for none/custom rules.
  static RepeatPreset? fromRrule(String? rrule) {
    if (rrule == null) return null;
    final normalized = _stripPrefix(rrule).toUpperCase();
    for (final preset in values) {
      if (preset.rrule == normalized) return preset;
    }
    return null;
  }
}

/// The next occurrence of a repeating item.
class NextOccurrence {
  /// Creates the result.
  const NextOccurrence({required this.anchor, required this.rrule});

  /// The new due (task) or start (event).
  final DateTime anchor;

  /// The RRULE the new occurrence carries (COUNT decremented, if any).
  final String rrule;
}

/// Whether [rrule] is a valid RRULE this app can evaluate.
bool isValidRrule(String rrule) => _parse(rrule) != null;

/// Computes the occurrence after [anchor] for [rrule], or null when the rule
/// has run out (COUNT reached, past UNTIL) or can't be parsed.
///
/// Times are treated as local wall-clock times: "every day at 9" stays at 9
/// across daylight-saving changes.
NextOccurrence? nextOccurrence(String rrule, DateTime anchor) {
  final rule = _parse(rrule);
  if (rule == null) return null;

  final count = rule.count;
  if (count != null && count <= 1) return null;

  final evaluated = count == null ? rule : rule.copyWith(clearCount: true);
  final start = _floating(anchor);
  final next = evaluated.getInstances(start: start, after: start).firstOrNull;
  if (next == null) return null;

  final carried = count == null ? rule : rule.copyWith(count: count - 1);
  return NextOccurrence(
    anchor: next.copyWith(isUtc: false),
    rrule: _stripPrefix(carried.toString()),
  );
}

/// The first occurrence of [rrule] after [anchor] whose end (start + the
/// item's duration) is after [now]; used to roll ended recurring events
/// forward without creating every missed one. Returns null when the rule
/// ends first.
NextOccurrence? nextOccurrenceEndingAfter(
  String rrule,
  DateTime anchor,
  Duration duration,
  DateTime now,
) {
  var current = NextOccurrence(anchor: anchor, rrule: rrule);
  // A generous cap keeps a broken rule from looping forever.
  for (var i = 0; i < 100000; i++) {
    final next = nextOccurrence(current.rrule, current.anchor);
    if (next == null) return null;
    if (next.anchor.add(duration).isAfter(now)) return next;
    current = next;
  }
  return null;
}

/// Shifts [dt] by the calendar-day distance from [from] to [to], keeping its
/// own time of day. Used to move subtasks along with their parent.
DateTime shiftLike(DateTime dt, DateTime from, DateTime to) =>
    addDays(dt, calendarDaysBetween(from, to));

RecurrenceRule? _parse(String rrule) {
  final text = rrule.trim();
  if (text.isEmpty) return null;
  try {
    return RecurrenceRule.fromString(
      text.toUpperCase().startsWith('RRULE:') ? text : 'RRULE:$text',
    );
  } on FormatException {
    return null;
  } on Object {
    return null;
  }
}

String _stripPrefix(String rrule) {
  final text = rrule.trim();
  return text.toUpperCase().startsWith('RRULE:') ? text.substring(6) : text;
}

DateTime _floating(DateTime dt) {
  final l = dt.toLocal();
  return DateTime.utc(l.year, l.month, l.day, l.hour, l.minute, l.second);
}
