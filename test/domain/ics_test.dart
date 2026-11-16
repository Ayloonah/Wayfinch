import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/domain/ics/ics_export.dart';
import 'package:wayfinch/domain/ics/ics_import.dart';
import 'package:wayfinch/domain/ics/ics_parser.dart';
import 'package:wayfinch/domain/item.dart';
import 'package:wayfinch/domain/item_enums.dart';
import 'package:wayfinch/domain/item_tree.dart';

import 'test_items.dart';

String _cal(String body) =>
    'BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Test//EN\r\n$body'
    'END:VCALENDAR\r\n';

void main() {
  group('readIcs', () {
    test('UTC, named zones (IANA and Windows) and floating times', () {
      final read = readIcs(
        _cal(
          'BEGIN:VEVENT\r\nUID:a\r\nSUMMARY:UTC\r\n'
          'DTSTART:20261120T150000Z\r\nDTEND:20261120T160000Z\r\nEND:VEVENT\r\n'
          'BEGIN:VEVENT\r\nUID:b\r\nSUMMARY:Toronto\r\n'
          'DTSTART;TZID=America/Toronto:20261120T090000\r\n'
          'DTEND;TZID=America/Toronto:20261120T100000\r\nEND:VEVENT\r\n'
          'BEGIN:VEVENT\r\nUID:c\r\nSUMMARY:Outlook\r\n'
          'DTSTART;TZID="Romance Standard Time":20260715T090000\r\n'
          'DTEND;TZID="Romance Standard Time":20260715T100000\r\nEND:VEVENT\r\n'
          'BEGIN:VEVENT\r\nUID:d\r\nSUMMARY:Floating\r\n'
          'DTSTART:20261120T090000\r\nDTEND:20261120T093000\r\nEND:VEVENT\r\n',
        ),
      );
      expect(read.isCalendar, isTrue);
      final byUid = {for (final e in read.events) e.uid: e};
      expect(byUid['a']!.start.toUtc(), DateTime.utc(2026, 11, 20, 15));
      // Toronto is UTC-5 in November.
      expect(byUid['b']!.start.toUtc(), DateTime.utc(2026, 11, 20, 14));
      // Paris is UTC+2 in July.
      expect(byUid['c']!.start.toUtc(), DateTime.utc(2026, 7, 15, 7));
      expect(byUid['d']!.start, DateTime(2026, 11, 20, 9));
      expect(byUid['d']!.end, DateTime(2026, 11, 20, 9, 30));
    });

    test('all-day events run midnight to midnight', () {
      final read = readIcs(
        _cal(
          'BEGIN:VEVENT\r\nUID:one\r\nSUMMARY:Birthday\r\n'
          'DTSTART;VALUE=DATE:20261205\r\nEND:VEVENT\r\n'
          'BEGIN:VEVENT\r\nUID:trip\r\nSUMMARY:Trip\r\n'
          'DTSTART;VALUE=DATE:20261210\r\nDTEND;VALUE=DATE:20261213\r\n'
          'END:VEVENT\r\n',
        ),
      );
      final one = read.events.first;
      expect(one.allDay, isTrue);
      expect(one.start, DateTime(2026, 12, 5));
      expect(one.end, DateTime(2026, 12, 6));
      expect(read.events.last.end, DateTime(2026, 12, 13));
    });

    test('folded lines, escapes, DURATION, RRULE; alarms are ignored', () {
      final read = readIcs(
        _cal(
          'BEGIN:VEVENT\r\nUID:x\r\n'
          'SUMMARY:Lab\\, room 4\\; bring goggles\r\n'
          'DESCRIPTION:Line one\\nLine \r\n two\r\n'
          'DTSTART:20261116T140000\r\nDURATION:PT1H30M\r\n'
          'RRULE:FREQ=WEEKLY;BYDAY=MO\r\n'
          'BEGIN:VALARM\r\nACTION:DISPLAY\r\nDESCRIPTION:Alarm text\r\n'
          'TRIGGER:-PT15M\r\nEND:VALARM\r\nEND:VEVENT\r\n',
        ),
      );
      final e = read.events.single;
      expect(e.title, 'Lab, room 4; bring goggles');
      expect(e.description, 'Line one\nLine two');
      expect(e.end, DateTime(2026, 11, 16, 15, 30));
      expect(e.rrule, 'FREQ=WEEKLY;BYDAY=MO');
    });

    test('skips cancelled events, changed occurrences and duplicates', () {
      final read = readIcs(
        _cal(
          'BEGIN:VEVENT\r\nUID:keep\r\nDTSTART:20261116T140000Z\r\nEND:VEVENT\r\n'
          'BEGIN:VEVENT\r\nUID:keep\r\nRECURRENCE-ID:20261123T140000Z\r\n'
          'DTSTART:20261123T150000Z\r\nEND:VEVENT\r\n'
          'BEGIN:VEVENT\r\nUID:gone\r\nSTATUS:CANCELLED\r\n'
          'DTSTART:20261116T140000Z\r\nEND:VEVENT\r\n'
          'BEGIN:VEVENT\r\nUID:keep\r\nDTSTART:20261117T140000Z\r\nEND:VEVENT\r\n'
          'BEGIN:VTODO\r\nUID:todo\r\nSUMMARY:Ignored\r\nEND:VTODO\r\n',
        ),
      );
      expect(read.events.map((e) => e.uid), ['keep']);
      expect(read.skipped, 3);
    });

    test('anything else is not a calendar', () {
      expect(readIcs('{"format":"wayfinch"}').isCalendar, isFalse);
    });
  });

  group('planIcsImport', () {
    final now = DateTime(2026, 11, 16, 10);
    var n = 0;
    String newId() => 'new${n++}';
    IcsEvent ev(
      String uid, {
      String title = 'Event',
      DateTime? start,
      DateTime? end,
      String? rrule,
    }) => IcsEvent(
      uid: uid,
      title: title,
      start: start ?? DateTime(2026, 11, 20, 9),
      end: end ?? DateTime(2026, 11, 20, 10),
      rrule: rrule,
    );

    IcsImportPlan plan(
      List<Item> items,
      List<IcsEvent> events, {
      bool includePast = false,
    }) => planIcsImport(
      tree: ItemTree(items),
      events: events,
      now: now,
      includePast: includePast,
      untitled: 'Untitled',
      newId: newId,
    );

    test('new events become top-level events with their UID', () {
      final p = plan([task('t', order: 4)], [ev('u1', title: '')]);
      expect(p.added.single.title, 'Untitled');
      final created = p.build().created.single;
      expect(created.type, ItemType.event);
      expect(created.source, ItemSource.icsImport);
      expect(created.icsUid, 'u1');
      expect(created.sortOrder, 5);
      expect(created.parentId, isNull);
    });

    test('re-import matches by UID: unchanged, or updated in place', () {
      final existing = event(
        'e1',
        start: DateTime(2026, 11, 20, 9),
        end: DateTime(2026, 11, 20, 10),
      ).copyWith(title: 'Event', icsUid: 'u1', priority: Priority.high);
      expect(plan([existing], [ev('u1')]).unchangedCount, 1);

      final moved = plan(
        [existing],
        [ev('u1', title: 'Moved', start: DateTime(2026, 11, 21, 9))],
      );
      expect(moved.added, isEmpty);
      final updated = moved.build().updated.single;
      expect(updated.id, 'e1');
      expect(updated.title, 'Moved');
      expect(updated.start, DateTime(2026, 11, 21, 9));
      expect(updated.priority, Priority.high); // untouched
      expect(moved.updated.single.fields, hasLength(2));
    });

    test('an exported Wayfinch file matches the original items', () {
      final existing = event(
        'abc',
        start: DateTime(2026, 11, 20, 9),
        end: DateTime(2026, 11, 20, 10),
      ).copyWith(title: 'Event');
      final p = plan([existing], [ev('abc@wayfinch')]);
      expect(p.count, 0);
      expect(p.unchangedCount, 1);
    });

    test('past events are left out unless included; live repeats stay', () {
      final events = [
        ev(
          'old',
          start: DateTime(2026, 11, 1, 9),
          end: DateTime(2026, 11, 1, 10),
        ),
        ev(
          'weekly',
          start: DateTime(2026, 1, 5, 9),
          end: DateTime(2026, 1, 5, 10),
          rrule: 'FREQ=WEEKLY',
        ),
        ev(
          'ended',
          start: DateTime(2026, 1, 5, 9),
          end: DateTime(2026, 1, 5, 10),
          rrule: 'FREQ=WEEKLY;COUNT=3',
        ),
        // Ends later today: not past.
        ev(
          'today',
          start: DateTime(2026, 11, 16, 8),
          end: DateTime(2026, 11, 16, 9),
        ),
      ];
      final p = plan(const [], events);
      expect(p.added.map((a) => a.title), hasLength(2));
      expect(p.pastCount, 2);
      expect(plan(const [], events, includePast: true).added, hasLength(4));
    });
  });

  group('exportIcs', () {
    final now = DateTime(2026, 11, 16, 10);

    test('events and (optionally) tasks round-trip through readIcs', () {
      final items = [
        event(
          'meeting',
          start: DateTime(2026, 11, 20, 9),
          end: DateTime(2026, 11, 20, 10),
        ).copyWith(title: 'Team meeting, room 2', notes: 'Agenda:\nall'),
        event(
          'trip',
          start: DateTime(2026, 12, 10),
          end: DateTime(2026, 12, 13),
        ),
        event(
          'class',
          start: DateTime(2026, 11, 16, 13),
          end: DateTime(2026, 11, 16, 14),
          rrule: 'FREQ=WEEKLY;BYDAY=MO',
        ).copyWith(icsUid: 'from-google'),
        task('report', due: DateTime(2026, 11, 18, 17)),
        task('laundry', due: DateTime(2026, 11, 19), hasTime: false),
        task('done', due: DateTime(2026, 11, 18), doneAt: now),
      ];

      final eventsOnly = readIcs(
        exportIcs(items: items, includeTasks: false, now: now),
      );
      expect(eventsOnly.events.map((e) => e.uid), [
        'meeting@wayfinch',
        'trip@wayfinch',
        'from-google',
      ]);
      final meeting = eventsOnly.events.first;
      expect(meeting.title, 'Team meeting, room 2');
      expect(meeting.description, 'Agenda:\nall');
      expect(meeting.start, DateTime(2026, 11, 20, 9));
      final trip = eventsOnly.events[1];
      expect(trip.allDay, isTrue);
      expect(trip.end, DateTime(2026, 12, 13));
      final repeating = eventsOnly.events[2];
      expect(repeating.rrule, 'FREQ=WEEKLY;BYDAY=MO');
      expect(repeating.start, DateTime(2026, 11, 16, 13));

      final withTasks = readIcs(
        exportIcs(items: items, includeTasks: true, now: now),
      );
      final byUid = {for (final e in withTasks.events) e.uid: e};
      expect(byUid.keys, hasLength(5)); // the done task stays out
      expect(byUid['report@wayfinch']!.start, DateTime(2026, 11, 18, 17));
      expect(byUid['report@wayfinch']!.end, DateTime(2026, 11, 18, 17, 30));
      expect(byUid['laundry@wayfinch']!.allDay, isTrue);
    });

    test('long lines are folded at 75 bytes and read back whole', () {
      final title = 'Préparer la présentation ' * 8;
      final text = exportIcs(
        items: [
          event(
            'long',
            start: DateTime(2026, 11, 20, 9),
            end: DateTime(2026, 11, 20, 10),
          ).copyWith(title: title),
        ],
        includeTasks: false,
        now: now,
      );
      for (final line in text.split('\r\n')) {
        expect(line.codeUnits.length, lessThanOrEqualTo(75));
      }
      expect(readIcs(text).events.single.title, title.trim());
    });
  });
}
