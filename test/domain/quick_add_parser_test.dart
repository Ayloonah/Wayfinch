import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/domain/item_enums.dart';
import 'package:wayfinch/domain/quick_add_parser.dart';

void main() {
  // Sunday, Nov 15, 2026.
  final now = DateTime(2026, 11, 15, 12);
  QuickAddResult parse(String text) => parseQuickAdd(text, now: now);

  test('the mockup example', () {
    final r = parse('Lab report Friday 5pm #school !high');
    expect(r.title, 'Lab report');
    expect(r.due, DateTime(2026, 11, 20, 17));
    expect(r.dueHasTime, isTrue);
    expect(r.tags, ['school']);
    expect(r.priority, Priority.high);
  });

  test('the French example', () {
    final r = parse('Rapport de labo vendredi 17h #école !haute');
    expect(r.title, 'Rapport de labo');
    expect(r.due, DateTime(2026, 11, 20, 17));
    expect(r.tags, ['école']);
    expect(r.priority, Priority.high);
  });

  test('plain text stays plain', () {
    final r = parse('Buy milk');
    expect(r.title, 'Buy milk');
    expect(r.due, isNull);
    expect(r.priority, Priority.none);
    expect(r.tags, isEmpty);
  });

  group('dates', () {
    test('today, tomorrow and the day after (EN + FR)', () {
      expect(parse('a today').due, DateTime(2026, 11, 15));
      expect(parse('a tomorrow').due, DateTime(2026, 11, 16));
      expect(parse('a demain').due, DateTime(2026, 11, 16));
      expect(parse("a aujourd'hui").due, DateTime(2026, 11, 15));
      expect(parse('a aujourd’hui').due, DateTime(2026, 11, 15));
      expect(parse('a day after tomorrow').due, DateTime(2026, 11, 17));
      expect(parse('a après-demain').due, DateTime(2026, 11, 17));
      expect(parse('a tomorrow').dueHasTime, isFalse);
    });

    test('weekday names: today counts, "next" skips it', () {
      expect(parse('a sunday').due, DateTime(2026, 11, 15));
      expect(parse('a next sunday').due, DateTime(2026, 11, 22));
      expect(parse('a dimanche prochain').due, DateTime(2026, 11, 22));
      expect(parse('a on Monday').due, DateTime(2026, 11, 16));
      expect(parse('a le mardi').due, DateTime(2026, 11, 17));
      expect(parse('Call mom on Monday').title, 'Call mom');
    });

    test('month and day, with year rollover', () {
      expect(parse('a Dec 5').due, DateTime(2026, 12, 5));
      expect(parse('a December 5th').due, DateTime(2026, 12, 5));
      expect(parse('a 5 déc').due, DateTime(2026, 12, 5));
      expect(parse('a 1er décembre').due, DateTime(2026, 12, 1));
      expect(parse('a Jan 3').due, DateTime(2027, 1, 3));
      expect(parse('a Nov 15').due, DateTime(2026, 11, 15));
      expect(parse('a March 2 2028').due, DateTime(2028, 3, 2));
      expect(parse('a 5th of december').due, DateTime(2026, 12, 5));
    });

    test('impossible dates are left as text', () {
      final r = parse('a Feb 30');
      expect(r.due, isNull);
      expect(r.title, 'a Feb 30');
    });
  });

  group('times', () {
    test('12-hour', () {
      expect(parse('a 5pm').due, DateTime(2026, 11, 15, 17));
      expect(parse('a 5:30 pm').due, DateTime(2026, 11, 15, 17, 30));
      expect(parse('a at 12am').due, DateTime(2026, 11, 15, 0));
      expect(parse('a 12pm').due, DateTime(2026, 11, 15, 12));
    });

    test('24-hour and French', () {
      expect(parse('a 17:45').due, DateTime(2026, 11, 15, 17, 45));
      expect(parse('a 17h').due, DateTime(2026, 11, 15, 17));
      expect(parse('a à 9h30').due, DateTime(2026, 11, 15, 9, 30));
    });

    test('time with a date', () {
      final r = parse('Dentist tomorrow at 9:15am');
      expect(r.title, 'Dentist');
      expect(r.due, DateTime(2026, 11, 16, 9, 15));
      expect(r.dueHasTime, isTrue);
    });

    test('numbers that are not times stay in the title', () {
      expect(parse('Read 30 pages').title, 'Read 30 pages');
      expect(parse('Read 30 pages').due, isNull);
    });
  });

  group('tags and priority', () {
    test('several tags, no duplicates, any position', () {
      final r = parse('#work Plan sprint #team #Work');
      expect(r.title, 'Plan sprint');
      expect(r.tags, ['work', 'team']);
    });

    test('priorities in both languages', () {
      expect(parse('a !low').priority, Priority.low);
      expect(parse('a !med').priority, Priority.medium);
      expect(parse('a !moyenne').priority, Priority.medium);
      expect(parse('a !basse').priority, Priority.low);
      expect(parse('a !urgent').priority, Priority.none);
    });

    test('a # inside a word is not a tag', () {
      final r = parse('Fix issue C#');
      expect(r.tags, isEmpty);
      expect(r.title, 'Fix issue C#');
    });
  });

  test('only tokens: the original text becomes the title', () {
    final r = parse('tomorrow');
    expect(r.title, 'tomorrow');
    expect(r.due, DateTime(2026, 11, 16));
  });
}
