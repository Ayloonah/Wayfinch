/// Small local-calendar helpers.
library;

/// Midnight at the start of [dt]'s local day.
DateTime startOfDay(DateTime dt) {
  final local = dt.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// [day] moved by [days] calendar days, keeping the time of day (safe across
/// daylight-saving changes, unlike adding a Duration).
DateTime addDays(DateTime day, int days) {
  final l = day.toLocal();
  return DateTime(
    l.year,
    l.month,
    l.day + days,
    l.hour,
    l.minute,
    l.second,
    l.millisecond,
  );
}

/// Whether [a] and [b] fall on the same local day.
bool isSameDay(DateTime a, DateTime b) => startOfDay(a) == startOfDay(b);

/// Number of calendar days from [from]'s day to [to]'s day.
int calendarDaysBetween(DateTime from, DateTime to) {
  final a = startOfDay(from);
  final b = startOfDay(to);
  // Use UTC dates so DST shifts don't make a "day" 23 or 25 hours long.
  return DateTime.utc(
    b.year,
    b.month,
    b.day,
  ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
}

/// Monday 00:00 of [dt]'s local week.
DateTime startOfWeek(DateTime dt) {
  final day = startOfDay(dt);
  return addDays(day, -(day.weekday - DateTime.monday));
}
