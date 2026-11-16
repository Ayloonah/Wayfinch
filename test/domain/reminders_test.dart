import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/domain/reminders.dart';

import 'test_items.dart';

void main() {
  const defaults = ReminderDefaults();

  group('effectiveReminders', () {
    test('defaults by type, custom overrides, 0 means none', () {
      expect(effectiveReminders(task('t'), defaults), [60]);
      expect(
        effectiveReminders(
          event('e', start: DateTime(2026), end: DateTime(2026)),
          defaults,
        ),
        [15],
      );
      expect(
        effectiveReminders(
          task('c')
              .copyWith(customReminders: true, reminderOffsets: [1440, 30]),
          defaults,
        ),
        [30, 1440],
      );
      expect(
        effectiveReminders(task('n').copyWith(customReminders: true), defaults),
        isEmpty,
      );
      expect(
        effectiveReminders(task('t'), const ReminderDefaults(taskMinutes: 0)),
        isEmpty,
      );
    });
  });

  group('remindersBetween', () {
    final from = DateTime(2026, 11, 16, 15, 0);
    final to = DateTime(2026, 11, 16, 15, 30);

    test('timed task: 1 hour before its due time', () {
      final alerts = remindersBetween(
        [task('a', due: DateTime(2026, 11, 16, 16, 15))],
        defaults,
        from,
        to,
      );
      expect(alerts.single.fireAt, DateTime(2026, 11, 16, 15, 15));
    });

    test('window is (from, to]: exactly "from" is excluded, "to" included', () {
      List<ReminderAlert> at(DateTime due) =>
          remindersBetween([task('a', due: due)], defaults, from, to);
      expect(at(DateTime(2026, 11, 16, 16, 0)), isEmpty); // fires at 15:00
      expect(at(DateTime(2026, 11, 16, 16, 30)), hasLength(1)); // at 15:30
    });

    test('date-only tasks, done tasks and ended events never remind', () {
      final alerts = remindersBetween(
        [
          task('date only', due: DateTime(2026, 11, 16), hasTime: false),
          task(
            'done',
            due: DateTime(2026, 11, 16, 16, 15),
            doneAt: DateTime(2026, 11, 16, 9),
          ),
          event(
            'ended',
            start: DateTime(2026, 11, 16, 14),
            end: DateTime(2026, 11, 16, 15),
          ),
        ],
        defaults,
        from,
        to,
      );
      expect(alerts, isEmpty);
    });

    test('events: 15 minutes before start; several custom reminders', () {
      final alerts = remindersBetween(
        [
          event(
            'meeting',
            start: DateTime(2026, 11, 16, 15, 40),
            end: DateTime(2026, 11, 16, 16, 40),
          ),
          task(
            'multi',
            due: DateTime(2026, 11, 16, 15, 20),
          ).copyWith(customReminders: true, reminderOffsets: [5, 10, 120]),
        ],
        defaults,
        from,
        to,
      );
      expect(alerts.map((a) => (a.itemId, a.fireAt)), [
        ('multi', DateTime(2026, 11, 16, 15, 10)),
        ('multi', DateTime(2026, 11, 16, 15, 15)),
        ('meeting', DateTime(2026, 11, 16, 15, 25)),
      ]);
    });
  });

  group('QuietHours', () {
    const night = QuietHours(startMinutes: 22 * 60, endMinutes: 7 * 60);
    const lunch = QuietHours(startMinutes: 12 * 60, endMinutes: 13 * 60);

    test('windows across midnight and within a day', () {
      expect(night.contains(DateTime(2026, 11, 16, 23)), isTrue);
      expect(night.contains(DateTime(2026, 11, 17, 6, 59)), isTrue);
      expect(night.contains(DateTime(2026, 11, 17, 7)), isFalse);
      expect(night.contains(DateTime(2026, 11, 16, 12)), isFalse);
      expect(lunch.contains(DateTime(2026, 11, 16, 12, 30)), isTrue);
      expect(lunch.contains(DateTime(2026, 11, 16, 13)), isFalse);
    });

    test('endAfter finds the right morning', () {
      expect(
        night.endAfter(DateTime(2026, 11, 16, 23)),
        DateTime(2026, 11, 17, 7),
      );
      expect(
        night.endAfter(DateTime(2026, 11, 17, 3)),
        DateTime(2026, 11, 17, 7),
      );
    });
  });

  test('digestDue: once a day, after its time, only when on', () {
    bool due(DateTime now, {DateTime? last, bool on = true}) =>
        digestDue(now: now, enabled: on, hour: 8, minute: 0, lastShown: last);
    expect(due(DateTime(2026, 11, 16, 7, 59)), isFalse);
    expect(due(DateTime(2026, 11, 16, 8)), isTrue);
    expect(due(DateTime(2026, 11, 16, 14)), isTrue); // late start still shows
    expect(
      due(DateTime(2026, 11, 16, 14), last: DateTime(2026, 11, 16, 8)),
      isFalse,
    );
    expect(
      due(DateTime(2026, 11, 17, 8, 1), last: DateTime(2026, 11, 16, 8)),
      isTrue,
    );
    expect(due(DateTime(2026, 11, 16, 9), on: false), isFalse);
  });

  test('snoozeUntil', () {
    final now = DateTime(2026, 11, 16, 15);
    expect(
      snoozeUntil(now, SnoozeChoice.tenMinutes),
      DateTime(2026, 11, 16, 15, 10),
    );
    expect(snoozeUntil(now, SnoozeChoice.oneHour), DateTime(2026, 11, 16, 16));
    expect(snoozeUntil(now, SnoozeChoice.tomorrow), DateTime(2026, 11, 17, 15));
  });
}
