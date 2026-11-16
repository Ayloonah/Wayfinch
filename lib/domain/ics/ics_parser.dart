import '../dates.dart';
import '../recurrence.dart';
import 'ics_zones.dart';

/// One event read from an .ics file.
class IcsEvent {
  /// Creates an event.
  const IcsEvent({
    required this.uid,
    required this.title,
    required this.start,
    required this.end,
    this.allDay = false,
    this.description,
    this.rrule,
  });

  /// The calendar's id for the event (`UID`), used to match re-imports.
  final String uid;

  /// Title (`SUMMARY`), possibly empty.
  final String title;

  /// Notes (`DESCRIPTION`).
  final String? description;

  /// Start, in local time (midnight for all-day events).
  final DateTime start;

  /// End, in local time (the next midnight for a one-day all-day event).
  final DateTime end;

  /// Whether this is an all-day event.
  final bool allDay;

  /// Repeat rule (without the `RRULE:` prefix), if any and understood.
  final String? rrule;
}

/// What came out of reading an .ics file.
class IcsReadResult {
  /// Creates the result.
  const IcsReadResult({
    required this.isCalendar,
    required this.events,
    this.skipped = 0,
  });

  /// Whether the text was an iCalendar file at all.
  final bool isCalendar;

  /// Events found (one per UID).
  final List<IcsEvent> events;

  /// Events left out: cancelled ones, changed single occurrences of a
  /// repeating event, and ones without a usable start.
  final int skipped;
}

/// Reads the events (`VEVENT`) of an iCalendar file.
///
/// Times in UTC or in a named zone are converted to local time; times
/// without a zone are taken as local. Repeating events keep their RRULE;
/// exceptions to them (`EXDATE`, changed single occurrences) are not
/// carried over. To-dos and other components are ignored.
IcsReadResult readIcs(String text) {
  final lines = _unfold(text);
  if (!lines.any((l) => l.toUpperCase() == 'BEGIN:VCALENDAR')) {
    return const IcsReadResult(isCalendar: false, events: []);
  }
  final events = <IcsEvent>[];
  final seen = <String>{};
  var skipped = 0;
  List<_Property>? current; // properties of the event being read
  var nested = 0; // components inside it (e.g. VALARM)
  for (final line in lines) {
    final upper = line.toUpperCase();
    if (upper.startsWith('BEGIN:')) {
      if (current == null) {
        if (upper == 'BEGIN:VEVENT') {
          current = [];
          nested = 0;
        }
      } else {
        nested++;
      }
      continue;
    }
    if (upper.startsWith('END:')) {
      if (current == null) continue;
      if (nested > 0) {
        nested--;
      } else if (upper == 'END:VEVENT') {
        final event = _toEvent(current);
        if (event == null || !seen.add(event.uid)) {
          skipped++;
        } else {
          events.add(event);
        }
        current = null;
      }
      continue;
    }
    // Only the event's own properties (not those of a nested VALARM).
    if (current != null && nested == 0) {
      final p = _Property.parse(line);
      if (p != null) current.add(p);
    }
  }
  return IcsReadResult(isCalendar: true, events: events, skipped: skipped);
}

IcsEvent? _toEvent(List<_Property> props) {
  _Property? get(String name) => props.where((p) => p.name == name).firstOrNull;
  if (get('RECURRENCE-ID') != null) return null; // a changed occurrence
  if ((get('STATUS')?.value ?? '').toUpperCase() == 'CANCELLED') return null;
  final dtStart = get('DTSTART');
  if (dtStart == null) return null;
  final start = _dateValue(dtStart);
  if (start == null) return null;

  DateTime end;
  final dtEnd = get('DTEND');
  final duration = get('DURATION');
  final parsedEnd = dtEnd == null ? null : _dateValue(dtEnd);
  final parsedDuration = duration == null ? null : _duration(duration.value);
  if (parsedEnd != null && !parsedEnd.value.isBefore(start.value)) {
    end = parsedEnd.value;
  } else if (parsedDuration != null) {
    end = start.allDay && parsedDuration.inHours % 24 == 0
        ? addDays(start.value, parsedDuration.inDays)
        : start.value.add(parsedDuration);
  } else {
    end = start.allDay ? addDays(start.value, 1) : start.value;
  }

  final rruleText = get('RRULE')?.value;
  final rrule = rruleText != null && isValidRrule(rruleText) ? rruleText : null;
  final uid = get('UID')?.value.trim() ?? '';
  final title = _unescape(get('SUMMARY')?.value ?? '').trim();
  final description = get('DESCRIPTION')?.value;
  return IcsEvent(
    // Files without UIDs still import; they just can't be matched later.
    uid: uid.isEmpty
        ? 'nouid-${start.value.toIso8601String()}-${title.hashCode}'
        : uid,
    title: title,
    description: description == null || description.trim().isEmpty
        ? null
        : _unescape(description).trim(),
    start: start.value,
    end: end,
    allDay: start.allDay,
    rrule: rrule,
  );
}

/// One content line: `NAME;PARAM=x;PARAM2="y":value`.
class _Property {
  const _Property(this.name, this.params, this.value);

  final String name;
  final Map<String, String> params;
  final String value;

  static _Property? parse(String line) {
    var inQuotes = false;
    var colon = -1;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') inQuotes = !inQuotes;
      if (c == ':' && !inQuotes) {
        colon = i;
        break;
      }
    }
    if (colon <= 0) return null;
    final head = line.substring(0, colon);
    final value = line.substring(colon + 1);
    final parts = <String>[];
    final buf = StringBuffer();
    inQuotes = false;
    for (var i = 0; i < head.length; i++) {
      final c = head[i];
      if (c == '"') inQuotes = !inQuotes;
      if (c == ';' && !inQuotes) {
        parts.add(buf.toString());
        buf.clear();
      } else {
        buf.write(c);
      }
    }
    parts.add(buf.toString());
    final params = <String, String>{};
    for (final p in parts.skip(1)) {
      final eq = p.indexOf('=');
      if (eq <= 0) continue;
      var v = p.substring(eq + 1);
      if (v.length > 1 && v.startsWith('"') && v.endsWith('"')) {
        v = v.substring(1, v.length - 1);
      }
      params[p.substring(0, eq).toUpperCase()] = v;
    }
    return _Property(parts.first.toUpperCase(), params, value);
  }
}

/// Joins folded lines (a line starting with a space or tab continues the
/// previous one).
List<String> _unfold(String text) {
  final out = <String>[];
  for (final raw in text.split(RegExp(r'\r\n|\n|\r'))) {
    if (raw.isEmpty) continue;
    if ((raw.startsWith(' ') || raw.startsWith('\t')) && out.isNotEmpty) {
      out[out.length - 1] += raw.substring(1);
    } else {
      out.add(raw);
    }
  }
  return out;
}

String _unescape(String s) {
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (c == r'\' && i + 1 < s.length) {
      final n = s[++i];
      out.write(switch (n) {
        'n' || 'N' => '\n',
        _ => n, // \, \; \\
      });
    } else {
      out.write(c);
    }
  }
  return out.toString();
}

final _dateRe = RegExp(r'^(\d{4})(\d{2})(\d{2})$');
final _dateTimeRe = RegExp(
  r'^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})(Z?)$',
);

({DateTime value, bool allDay})? _dateValue(_Property p) {
  final v = p.value.trim().toUpperCase();
  final d = _dateRe.firstMatch(v);
  if (d != null) {
    return (
      value: DateTime(int.parse(d[1]!), int.parse(d[2]!), int.parse(d[3]!)),
      allDay: true,
    );
  }
  final t = _dateTimeRe.firstMatch(v);
  if (t == null) return null;
  final fields = [for (var i = 1; i <= 6; i++) int.parse(t[i]!)];
  if (t[7] == 'Z') {
    return (
      value: DateTime.utc(
        fields[0],
        fields[1],
        fields[2],
        fields[3],
        fields[4],
        fields[5],
      ).toLocal(),
      allDay: false,
    );
  }
  final wall = DateTime(
    fields[0],
    fields[1],
    fields[2],
    fields[3],
    fields[4],
    fields[5],
  );
  final tzid = p.params['TZID'];
  final local = tzid == null ? null : IcsZones.toLocal(wall, tzid);
  // No zone (or an unknown one): taken as local time.
  return (value: local ?? wall, allDay: false);
}

final _durationRe = RegExp(
  r'^([+-])?P(?:(\d+)W)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?)?$',
);

Duration? _duration(String text) {
  final m = _durationRe.firstMatch(text.trim().toUpperCase());
  if (m == null) return null;
  int n(int i) => int.tryParse(m[i] ?? '') ?? 0;
  final d = Duration(
    days: n(2) * 7 + n(3),
    hours: n(4),
    minutes: n(5),
    seconds: n(6),
  );
  return m[1] == '-' ? -d : d;
}
