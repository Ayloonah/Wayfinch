import 'dates.dart';
import 'item_enums.dart';

/// What quick add understood from a line of text.
class QuickAddResult {
  /// Creates a result.
  const QuickAddResult({
    required this.title,
    this.due,
    this.dueHasTime = false,
    this.priority = Priority.none,
    this.tags = const [],
  });

  /// The text left after removing dates, times, tags and priority.
  final String title;

  /// Due date, if one was found.
  final DateTime? due;

  /// Whether [due] has a time of day.
  final bool dueHasTime;

  /// Priority from `!high`, `!med`, `!low` (or French `!haute`, `!moyenne`,
  /// `!basse`).
  final Priority priority;

  /// Tag names from `#tag`, in order, without duplicates.
  final List<String> tags;
}

/// Parses quick-add text such as `Lab report Friday 5pm #school !high` or
/// `Rapport de labo vendredi 17h #école !haute`.
///
/// Both English and French are always understood, whatever the app language.
///
/// - Dates: today/tomorrow/day after tomorrow, weekday names (the next one,
///   today included; "next friday"/"vendredi prochain" skips today), and
///   month + day ("Dec 5", "December 5th", "5 déc", "1er décembre"), with an
///   optional year; a month-day already past means next year.
/// - Times: `5pm`, `5:30 pm`, `17:00`, `17h`, `17h30`, optionally after
///   "at"/"à". A time without a date means today.
/// - `#tag` and `!priority` anywhere.
QuickAddResult parseQuickAdd(String input, {required DateTime now}) {
  var text = ' $input ';
  final today = startOfDay(now);

  // Tags.
  final tags = <String>[];
  text = text.replaceAllMapped(_tagPattern, (m) {
    final name = m.group(1)!;
    if (!tags.any((t) => t.toLowerCase() == name.toLowerCase())) {
      tags.add(name);
    }
    return ' ';
  });

  // Priority (last one wins).
  var priority = Priority.none;
  text = text.replaceAllMapped(_priorityPattern, (m) {
    priority = _priorityWords[m.group(1)!.toLowerCase()]!;
    return ' ';
  });

  // Time.
  int? hour;
  int? minute;
  for (final pattern in _timePatterns) {
    final match = pattern.regex.firstMatch(text);
    if (match == null) continue;
    final parsed = pattern.read(match);
    if (parsed == null) continue;
    (hour, minute) = parsed;
    text = text.replaceRange(match.start, match.end, ' ');
    break;
  }

  // Date.
  DateTime? day;
  for (final pattern in _datePatterns) {
    final match = pattern.regex.firstMatch(text);
    if (match == null) continue;
    final parsed = pattern.read(match, today);
    if (parsed == null) continue;
    day = parsed;
    text = text.replaceRange(match.start, match.end, ' ');
    break;
  }

  final title = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  DateTime? due;
  if (hour != null) {
    final base = day ?? today;
    due = DateTime(base.year, base.month, base.day, hour, minute ?? 0);
  } else if (day != null) {
    due = day;
  }
  return QuickAddResult(
    title: title.isEmpty ? input.trim() : title,
    due: due,
    dueHasTime: hour != null,
    priority: priority,
    tags: tags,
  );
}

// Letter/digit boundaries that also work for accented letters.
const _b = r'(?<![\p{L}\p{N}])';
const _e = r'(?![\p{L}\p{N}])';

RegExp _re(String pattern) =>
    RegExp(pattern, caseSensitive: false, unicode: true);

final _tagPattern = _re(r'(?<=\s)#([\p{L}\p{N}_-]+)');

final _priorityPattern = _re(
  r'(?<=\s)!(high|haute|medium|med|moyenne|moy|low|basse)' + _e,
);

const _priorityWords = {
  'high': Priority.high,
  'haute': Priority.high,
  'medium': Priority.medium,
  'med': Priority.medium,
  'moyenne': Priority.medium,
  'moy': Priority.medium,
  'low': Priority.low,
  'basse': Priority.low,
};

class _TimePattern {
  const _TimePattern(this.regex, this.read);

  final RegExp regex;
  final (int, int)? Function(Match) read;
}

final _timePatterns = [
  // 5pm, 5:30 pm, at 11am
  _TimePattern(
    _re('$_b(?:at\\s+|à\\s+)?(\\d{1,2})(?::([0-5]\\d))?\\s*(am|pm)$_e'),
    (m) {
      final h = int.parse(m.group(1)!);
      if (h < 1 || h > 12) return null;
      final pm = m.group(3)!.toLowerCase() == 'pm';
      return ((h % 12) + (pm ? 12 : 0), int.parse(m.group(2) ?? '0'));
    },
  ),
  // 17:00, à 9:30
  _TimePattern(
    _re('$_b(?:at\\s+|à\\s+)?([01]?\\d|2[0-3]):([0-5]\\d)$_e'),
    (m) => (int.parse(m.group(1)!), int.parse(m.group(2)!)),
  ),
  // 17h, 17h30, 17 h 30
  _TimePattern(
    _re('$_b(?:à\\s+|at\\s+)?([01]?\\d|2[0-3])\\s*h(?:\\s*([0-5]\\d))?$_e'),
    (m) => (int.parse(m.group(1)!), int.parse(m.group(2) ?? '0')),
  ),
];

class _DatePattern {
  const _DatePattern(this.regex, this.read);

  final RegExp regex;
  final DateTime? Function(Match, DateTime today) read;
}

const _weekdays = {
  'monday': DateTime.monday,
  'tuesday': DateTime.tuesday,
  'wednesday': DateTime.wednesday,
  'thursday': DateTime.thursday,
  'friday': DateTime.friday,
  'saturday': DateTime.saturday,
  'sunday': DateTime.sunday,
  'lundi': DateTime.monday,
  'mardi': DateTime.tuesday,
  'mercredi': DateTime.wednesday,
  'jeudi': DateTime.thursday,
  'vendredi': DateTime.friday,
  'samedi': DateTime.saturday,
  'dimanche': DateTime.sunday,
};

const _months = {
  'jan': 1,
  'january': 1,
  'janv': 1,
  'janvier': 1,
  'feb': 2,
  'february': 2,
  'févr': 2,
  'fevr': 2,
  'février': 2,
  'fevrier': 2,
  'mar': 3,
  'march': 3,
  'mars': 3,
  'apr': 4,
  'april': 4,
  'avr': 4,
  'avril': 4,
  'may': 5,
  'mai': 5,
  'jun': 6,
  'june': 6,
  'juin': 6,
  'jul': 7,
  'july': 7,
  'juil': 7,
  'juillet': 7,
  'aug': 8,
  'august': 8,
  'août': 8,
  'aout': 8,
  'sep': 9,
  'sept': 9,
  'september': 9,
  'septembre': 9,
  'oct': 10,
  'october': 10,
  'octobre': 10,
  'nov': 11,
  'november': 11,
  'novembre': 11,
  'dec': 12,
  'december': 12,
  'déc': 12,
  'décembre': 12,
  'decembre': 12,
};

String _alternation(Iterable<String> words) {
  final sorted = words.toList()..sort((a, b) => b.length.compareTo(a.length));
  return sorted.map(RegExp.escape).join('|');
}

final _weekdayAlt = _alternation(_weekdays.keys);
final _monthAlt = _alternation(_months.keys);

DateTime? _monthDay(DateTime today, int month, int day, String? year) {
  final y = year == null ? today.year : int.parse(year);
  final date = DateTime(y, month, day);
  if (date.month != month) return null; // e.g. Feb 30
  if (year == null && date.isBefore(today)) {
    return DateTime(y + 1, month, day);
  }
  return date;
}

DateTime _nextWeekday(DateTime today, int weekday, {required bool skipToday}) {
  var delta = (weekday - today.weekday) % 7;
  if (delta == 0 && skipToday) delta = 7;
  return addDays(today, delta);
}

final _datePatterns = [
  _DatePattern(
    _re('$_b(?:day after tomorrow|après-demain|apres-demain)$_e'),
    (m, today) => addDays(today, 2),
  ),
  _DatePattern(_re("$_b(?:today|aujourd['’]hui)$_e"), (m, today) => today),
  _DatePattern(
    _re('$_b(?:tomorrow|demain)$_e'),
    (m, today) => addDays(today, 1),
  ),
  // next friday / vendredi prochain
  _DatePattern(
    _re('$_b(?:next\\s+($_weekdayAlt)|($_weekdayAlt)\\s+prochain)$_e'),
    (m, today) => _nextWeekday(
      today,
      _weekdays[(m.group(1) ?? m.group(2))!.toLowerCase()]!,
      skipToday: true,
    ),
  ),
  // (on) friday / (le) vendredi
  _DatePattern(
    _re('$_b(?:on\\s+|le\\s+)?($_weekdayAlt)$_e'),
    (m, today) => _nextWeekday(
      today,
      _weekdays[m.group(1)!.toLowerCase()]!,
      skipToday: false,
    ),
  ),
  // Dec 5, December 5th, Dec. 5 2027
  _DatePattern(
    _re(
      '$_b(?:on\\s+)?($_monthAlt)\\.?\\s+(\\d{1,2})(?:st|nd|rd|th)?'
      '(?:,?\\s+(\\d{4}))?$_e',
    ),
    (m, today) => _monthDay(
      today,
      _months[m.group(1)!.toLowerCase()]!,
      int.parse(m.group(2)!),
      m.group(3),
    ),
  ),
  // 5 déc, 1er décembre, 5th of December, le 5 décembre 2027
  _DatePattern(
    _re(
      '$_b(?:le\\s+|on\\s+(?:the\\s+)?)?(\\d{1,2})(?:er|st|nd|rd|th)?'
      '\\s+(?:of\\s+)?($_monthAlt)\\.?(?:\\s+(\\d{4}))?$_e',
    ),
    (m, today) => _monthDay(
      today,
      _months[m.group(2)!.toLowerCase()]!,
      int.parse(m.group(1)!),
      m.group(3),
    ),
  ),
];
