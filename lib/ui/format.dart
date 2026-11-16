import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../domain/dates.dart';
import '../domain/item.dart';
import '../domain/item_enums.dart';
import '../domain/recurrence.dart';
import '../l10n/app_localizations.dart';

/// Formats dates and item labels for the current locale.
class Formats {
  /// Creates formatters for [context]'s locale.
  Formats.of(BuildContext context)
    : l10n = AppLocalizations.of(context),
      _locale = Localizations.localeOf(context).toLanguageTag();

  /// Localized strings.
  final AppLocalizations l10n;
  final String _locale;

  /// "5:00 PM" / "17:00".
  String time(DateTime dt) => DateFormat.jm(_locale).format(dt.toLocal());

  /// "Fri, Nov 13" / "ven. 13 nov.".
  String shortDate(DateTime dt) =>
      DateFormat.MMMEd(_locale).format(dt.toLocal());

  /// "Sunday, November 15" / "dimanche 15 novembre".
  String longDate(DateTime dt) =>
      DateFormat.MMMMEEEEd(_locale).format(dt.toLocal());

  /// A day relative to [now]: Today, Tomorrow, Yesterday, else a short date.
  String relativeDay(DateTime dt, DateTime now) {
    switch (calendarDaysBetween(now, dt)) {
      case 0:
        return l10n.labelToday;
      case 1:
        return l10n.labelTomorrow;
      case -1:
        return l10n.labelYesterday;
      default:
        return shortDate(dt);
    }
  }

  /// A task's due label ("5:00 PM" today, "Tomorrow, 9:00 AM", "Fri, Nov 13"),
  /// or an event's time range. Empty when there's nothing to show.
  String whenLabel(Item item, DateTime now) {
    if (item.isEvent) return eventLabel(item, now);
    final due = item.due;
    if (due == null) return '';
    if (!item.dueHasTime) return relativeDay(due, now);
    if (isSameDay(due, now)) return time(due);
    return l10n.dateWithTime(relativeDay(due, now), time(due));
  }

  /// "2:00 – 3:30 PM" today, "Fri, Nov 20 · 2:00 PM – 3:30 PM" otherwise.
  String eventLabel(Item item, DateTime now) {
    final start = item.start;
    final end = item.end;
    if (start == null) return '';
    if (end == null) {
      return l10n.dateWithTime(relativeDay(start, now), time(start));
    }
    if (isSameDay(start, end)) {
      final range = l10n.timeRange(time(start), time(end));
      return isSameDay(start, now)
          ? range
          : l10n.dateDotTime(relativeDay(start, now), range);
    }
    return l10n.timeRange(
      l10n.dateWithTime(relativeDay(start, now), time(start)),
      l10n.dateWithTime(relativeDay(end, now), time(end)),
    );
  }

  /// Label for a priority.
  String priority(Priority priority) => switch (priority) {
    Priority.none => l10n.priorityNone,
    Priority.low => l10n.priorityLow,
    Priority.medium => l10n.priorityMedium,
    Priority.high => l10n.priorityHigh,
  };

  /// Label for a repeat rule (presets by name, anything else "Custom").
  String repeat(String? rrule) {
    if (rrule == null || rrule.trim().isEmpty) return l10n.repeatNone;
    return switch (RepeatPreset.fromRrule(rrule)) {
      RepeatPreset.daily => l10n.repeatDaily,
      RepeatPreset.weekdays => l10n.repeatWeekdays,
      RepeatPreset.weekly => l10n.repeatWeekly,
      RepeatPreset.biweekly => l10n.repeatBiweekly,
      RepeatPreset.monthly => l10n.repeatMonthly,
      RepeatPreset.yearly => l10n.repeatYearly,
      null => l10n.repeatCustom,
    };
  }
}
