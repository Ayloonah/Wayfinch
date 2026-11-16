import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/domain/recurrence.dart';

void main() {
  group('nextOccurrence', () {
    test('daily keeps the time of day', () {
      final next = nextOccurrence('FREQ=DAILY', DateTime(2026, 11, 15, 9, 30));
      expect(next!.anchor, DateTime(2026, 11, 16, 9, 30));
      expect(next.rrule, 'FREQ=DAILY');
    });

    test('accepts the RRULE: prefix', () {
      final next = nextOccurrence('RRULE:FREQ=WEEKLY', DateTime(2026, 11, 15));
      expect(next!.anchor, DateTime(2026, 11, 22));
    });

    test('weekdays skips the weekend', () {
      // Friday Nov 20, 2026 -> Monday Nov 23.
      final next = nextOccurrence(
        RepeatPreset.weekdays.rrule,
        DateTime(2026, 11, 20, 8),
      );
      expect(next!.anchor, DateTime(2026, 11, 23, 8));
    });

    test('every 2 weeks', () {
      final next = nextOccurrence(
        RepeatPreset.biweekly.rrule,
        DateTime(2026, 11, 15),
      );
      expect(next!.anchor, DateTime(2026, 11, 29));
    });

    test('monthly and yearly', () {
      expect(
        nextOccurrence('FREQ=MONTHLY', DateTime(2026, 11, 15))!.anchor,
        DateTime(2026, 12, 15),
      );
      expect(
        nextOccurrence('FREQ=YEARLY', DateTime(2026, 11, 15))!.anchor,
        DateTime(2027, 11, 15),
      );
    });

    test('COUNT counts down and runs out', () {
      final next = nextOccurrence('FREQ=DAILY;COUNT=3', DateTime(2026, 1, 1));
      expect(next!.rrule, contains('COUNT=2'));
      final last = nextOccurrence(next.rrule, next.anchor);
      expect(last!.rrule, contains('COUNT=1'));
      expect(nextOccurrence(last.rrule, last.anchor), isNull);
    });

    test('UNTIL stops the series', () {
      expect(
        nextOccurrence(
          'FREQ=DAILY;UNTIL=20260102T000000Z',
          DateTime(2026, 1, 2),
        ),
        isNull,
      );
    });

    test('daily across a daylight-saving change keeps 9:00', () {
      // Daylight saving ends in North America on Nov 1, 2026.
      final next = nextOccurrence('FREQ=DAILY', DateTime(2026, 10, 31, 9));
      expect(next!.anchor.hour, 9);
      expect(next.anchor.day, 1);
    });

    test('invalid rules give null', () {
      expect(nextOccurrence('nonsense', DateTime(2026)), isNull);
      expect(nextOccurrence('', DateTime(2026)), isNull);
      expect(isValidRrule('FREQ=WEEKLY'), isTrue);
      expect(isValidRrule('FREQ=SOMETIMES'), isFalse);
    });
  });

  test('nextOccurrenceEndingAfter skips missed occurrences', () {
    final next = nextOccurrenceEndingAfter(
      'FREQ=DAILY',
      DateTime(2026, 11, 1, 10),
      const Duration(hours: 1),
      DateTime(2026, 11, 15, 10, 30),
    );
    // Nov 15 10:00-11:00 hasn't ended at 10:30.
    expect(next!.anchor, DateTime(2026, 11, 15, 10));
  });

  test('presets map to and from RRULEs', () {
    for (final preset in RepeatPreset.values) {
      expect(RepeatPreset.fromRrule(preset.rrule), preset);
      expect(isValidRrule(preset.rrule), isTrue);
    }
    expect(RepeatPreset.fromRrule('rrule:freq=daily'), RepeatPreset.daily);
    expect(RepeatPreset.fromRrule('FREQ=DAILY;INTERVAL=3'), isNull);
    expect(RepeatPreset.fromRrule(null), isNull);
  });

  test('shiftLike moves by calendar days and keeps the time', () {
    expect(
      shiftLike(
        DateTime(2026, 1, 30, 14),
        DateTime(2026, 1, 31),
        DateTime(2026, 3, 31),
      ),
      DateTime(2026, 3, 30, 14),
    );
  });
}
