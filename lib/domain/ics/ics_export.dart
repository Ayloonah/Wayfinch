import 'dart:convert';

import '../dates.dart';
import '../item.dart';
import 'ics_import.dart' show wayfinchUidSuffix;

/// How long a task lasts when exported as an event.
const exportedTaskLength = Duration(minutes: 30);

/// Writes [items] as an iCalendar file.
///
/// Events go out as VEVENTs; one that runs from midnight to midnight is
/// written as an all-day event. With [includeTasks], open tasks with a due
/// date go out as short events at their due time (all-day when the due date
/// has no time), since calendars like Google ignore to-dos.
///
/// One-off times are written in UTC. Repeating events are written in local
/// "floating" time so "every Monday at 9" stays at 9 across daylight-saving
/// changes.
String exportIcs({
  required Iterable<Item> items,
  required bool includeTasks,
  required DateTime now,
}) {
  final out = <String>[
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Wayfinch//Wayfinch//EN',
    'CALSCALE:GREGORIAN',
  ];
  final stamp = _utc(now);
  for (final item in items) {
    DateTime start;
    DateTime end;
    bool allDay;
    if (item.isEvent) {
      if (item.start == null || item.end == null) continue;
      start = item.start!;
      end = item.end!;
      allDay = _isAllDay(start, end);
    } else {
      if (!includeTasks || item.isDone || item.due == null) continue;
      allDay = !item.dueHasTime;
      start = allDay ? startOfDay(item.due!) : item.due!;
      end = allDay ? addDays(start, 1) : start.add(exportedTaskLength);
    }
    final repeats = item.recurrence != null && item.recurrence!.isNotEmpty;
    String when(String name, DateTime dt) {
      if (allDay) return '$name;VALUE=DATE:${_date(dt)}';
      return repeats ? '$name:${_floating(dt)}' : '$name:${_utc(dt)}';
    }

    out
      ..add('BEGIN:VEVENT')
      ..add('UID:${_text(item.icsUid ?? '${item.id}$wayfinchUidSuffix')}')
      ..add('DTSTAMP:$stamp')
      ..add(when('DTSTART', start))
      ..add(when('DTEND', end))
      ..add('SUMMARY:${_text(item.title)}');
    final notes = item.notes;
    if (notes != null && notes.trim().isNotEmpty) {
      out.add('DESCRIPTION:${_text(notes)}');
    }
    if (repeats) out.add('RRULE:${_rrule(item.recurrence!)}');
    out.add('END:VEVENT');
  }
  out.add('END:VCALENDAR');
  return '${out.map(_fold).join('\r\n')}\r\n';
}

bool _isAllDay(DateTime start, DateTime end) {
  bool midnight(DateTime d) =>
      d.hour == 0 && d.minute == 0 && d.second == 0 && d.millisecond == 0;
  return midnight(start) && midnight(end) && end.isAfter(start);
}

String _two(int n) => n.toString().padLeft(2, '0');

String _date(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}${_two(d.month)}${_two(d.day)}';

String _clock(DateTime d) =>
    '${_two(d.hour)}${_two(d.minute)}${_two(d.second)}';

String _utc(DateTime d) {
  final u = d.toUtc();
  return '${_date(u)}T${_clock(u)}Z';
}

String _floating(DateTime d) {
  final l = d.toLocal();
  return '${_date(l)}T${_clock(l)}';
}

String _rrule(String rule) {
  final t = rule.trim();
  return t.toUpperCase().startsWith('RRULE:') ? t.substring(6) : t;
}

/// Escapes TEXT values.
String _text(String s) => s
    .replaceAll(r'\', r'\\')
    .replaceAll(';', r'\;')
    .replaceAll(',', r'\,')
    .replaceAll('\r\n', r'\n')
    .replaceAll('\n', r'\n');

/// Folds a content line at 75 bytes (UTF-8), never splitting a character.
String _fold(String line) {
  if (utf8.encode(line).length <= 75) return line;
  final parts = <String>[];
  final buf = StringBuffer();
  var bytes = 0;
  var limit = 75;
  for (final rune in line.runes) {
    final char = String.fromCharCode(rune);
    final size = utf8.encode(char).length;
    if (bytes + size > limit) {
      parts.add(buf.toString());
      buf.clear();
      bytes = 0;
      limit = 74; // continuation lines start with a space
    }
    buf.write(char);
    bytes += size;
  }
  parts.add(buf.toString());
  return parts.join('\r\n ');
}
