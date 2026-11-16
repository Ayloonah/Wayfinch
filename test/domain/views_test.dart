import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/domain/item_enums.dart';
import 'package:wayfinch/domain/item_tree.dart';
import 'package:wayfinch/domain/sorting.dart';
import 'package:wayfinch/domain/views.dart';

import 'test_items.dart';

void main() {
  // Sunday, Nov 15, 2026, noon.
  final now = DateTime(2026, 11, 15, 12);

  List<String> titles(ViewData data) =>
      data.entries.whereType<ItemEntry>().map((e) => e.item.id).toList();

  group('Today', () {
    test('overdue section first, then today', () {
      final tree = ItemTree([
        task('late', due: DateTime(2026, 11, 14, 18)),
        task('later today', due: DateTime(2026, 11, 15, 17)),
        task('date only today', due: DateTime(2026, 11, 15), hasTime: false),
        task('tomorrow', due: DateTime(2026, 11, 16, 9)),
        task('no date'),
        task('done', due: DateTime(2026, 11, 15, 9), doneAt: now),
        event(
          'meeting',
          start: DateTime(2026, 11, 15, 14),
          end: DateTime(2026, 11, 15, 15),
        ),
        event(
          'ended',
          start: DateTime(2026, 11, 15, 8),
          end: DateTime(2026, 11, 15, 9),
        ),
      ]);
      final data = ViewBuilder(tree, now).today();
      final headers = data.entries.whereType<SectionHeader>().toList();
      expect(headers.map((h) => h.kind), [
        SectionKind.overdue,
        SectionKind.today,
      ]);
      expect(headers.first.count, 1);
      expect(titles(data), [
        'late',
        'meeting',
        'later today',
        'date only today',
      ]);
      expect(data.count, 4);
      expect(data.entries.whereType<ItemEntry>().first.isOverdue, isTrue);
    });

    test('a multi-day event that covers today shows', () {
      final tree = ItemTree([
        event(
          'trip',
          start: DateTime(2026, 11, 14, 9),
          end: DateTime(2026, 11, 16, 18),
        ),
      ]);
      expect(titles(ViewBuilder(tree, now).today()), ['trip']);
    });

    test('subtasks show under their parent, done ones collapsed', () {
      final tree = ItemTree([
        task('report', due: DateTime(2026, 11, 15, 23, 59)),
        task('results', parent: 'report', due: DateTime(2026, 11, 15, 18)),
        task('chart', parent: 'results', due: DateTime(2026, 11, 15, 16)),
        task('outline', parent: 'report', doneAt: now),
        task('intro', parent: 'report', doneAt: now),
      ]);
      final entries = ViewBuilder(tree, now).today().entries;
      final items = entries.whereType<ItemEntry>().toList();
      expect(items.map((e) => (e.item.id, e.depth)), [
        ('report', 0),
        ('results', 1),
        ('chart', 2),
      ]);
      expect(items.first.subtasksDone, 2);
      expect(items.first.subtasksTotal, 3);
      final hidden = entries.whereType<HiddenDoneEntry>().single;
      expect(hidden.count, 2);
      expect(hidden.shown, isFalse);
    });

    test('expanded done subtasks are listed', () {
      final tree = ItemTree([
        task('p', due: DateTime(2026, 11, 15, 20)),
        task('d', parent: 'p', doneAt: now),
      ]);
      final data = ViewBuilder(tree, now, showDoneFor: {'p'}).today();
      expect(titles(data), ['p', 'd']);
      expect(data.entries.whereType<HiddenDoneEntry>().single.shown, isTrue);
    });

    test('a matched subtask of an unmatched parent shows on its own', () {
      final tree = ItemTree([
        task('project', due: DateTime(2026, 12, 1)),
        task('step', parent: 'project', due: DateTime(2026, 11, 15, 15)),
      ]);
      final items = ViewBuilder(
        tree,
        now,
      ).today().entries.whereType<ItemEntry>().toList();
      expect(items.single.item.id, 'step');
      expect(items.single.depth, 0);
    });
  });

  test('Upcoming groups the next 7 days', () {
    final tree = ItemTree([
      task('today', due: DateTime(2026, 11, 15, 18)),
      task('mon', due: DateTime(2026, 11, 16, 9)),
      task('mon2', due: DateTime(2026, 11, 16), hasTime: false),
      event(
        'wed',
        start: DateTime(2026, 11, 18, 10),
        end: DateTime(2026, 11, 18, 11),
      ),
      task('day7', due: DateTime(2026, 11, 22, 9)),
      task('day8', due: DateTime(2026, 11, 23, 9)),
    ]);
    final data = ViewBuilder(tree, now).upcoming();
    final days = data.entries.whereType<SectionHeader>().map((h) => h.day);
    expect(days, [
      DateTime(2026, 11, 16),
      DateTime(2026, 11, 18),
      DateTime(2026, 11, 22),
    ]);
    expect(titles(data), ['mon', 'mon2', 'wed', 'day7']);
    expect(data.count, 4);
  });

  test('All shows open items as a tree; orphans of done parents surface', () {
    final tree = ItemTree([
      task('a'),
      task('a1', parent: 'a'),
      task('closed', doneAt: now),
      task('reopened child', parent: 'closed'),
    ]);
    final data = ViewBuilder(tree, now).all();
    expect(
      data.entries.whereType<ItemEntry>().map((e) => (e.item.id, e.depth)),
      [('a', 0), ('a1', 1), ('reopened child', 0)],
    );
  });

  test('Done lists completed tasks and ended events, newest first', () {
    final tree = ItemTree([
      task('old', doneAt: DateTime(2026, 11, 2)),
      task('mon', doneAt: DateTime(2026, 11, 9, 8)), // Monday this week
      task('sun', doneAt: DateTime(2026, 11, 8, 23)), // last week
      task('open'),
      event(
        'ended',
        start: DateTime(2026, 11, 15, 8),
        end: DateTime(2026, 11, 15, 9),
      ),
    ]);
    final data = ViewBuilder(tree, now).done();
    expect(titles(data), ['ended', 'mon', 'sun', 'old']);
    expect(data.doneThisWeek, 1);
  });

  group('Tags view', () {
    test('lists open items with the tag, as a tree', () {
      final tree = ItemTree([
        task('a').copyWith(tagIds: ['school']),
        task('a1', parent: 'a').copyWith(tagIds: ['school']),
        task('b').copyWith(tagIds: ['work']),
        task('done', doneAt: now).copyWith(tagIds: ['school']),
      ]);
      final data = ViewBuilder(tree, now).tag('school');
      expect(data.count, 1); // a1 shows (and counts) under a
      expect(
        data.entries.whereType<ItemEntry>().map((e) => (e.item.id, e.depth)),
        [('a', 0), ('a1', 1)],
      );
    });

    test('the overdue auto tag lists every overdue item', () {
      final tree = ItemTree([
        task('late', due: DateTime(2026, 11, 14)),
        task('fine', due: DateTime(2026, 11, 20)),
      ]);
      final data = ViewBuilder(
        tree,
        now,
      ).build(AppView.tag, tagId: overdueTagId);
      expect(titles(data), ['late']);
    });
  });

  group('each item shows once', () {
    test('Today: an overdue subtask only shows in Overdue', () {
      final tree = ItemTree([
        task('report', due: DateTime(2026, 11, 15, 23)),
        task('late step', parent: 'report', due: DateTime(2026, 11, 14, 9)),
        task('no date', parent: 'report'),
      ]);
      final entries = ViewBuilder(tree, now).today().entries;
      final rows = <(String, String)>[];
      var section = '';
      for (final e in entries) {
        if (e is SectionHeader) section = e.kind.name;
        if (e is ItemEntry) rows.add((section, e.item.id));
      }
      expect(rows, [
        ('overdue', 'late step'),
        ('today', 'report'),
        ('today', 'no date'),
      ]);
    });

    test('Today: a subtask due today of an overdue parent shows in Today', () {
      final tree = ItemTree([
        task('late', due: DateTime(2026, 11, 14, 9)),
        task('today step', parent: 'late', due: DateTime(2026, 11, 15, 18)),
        task('grandchild', parent: 'today step'),
      ]);
      final entries = ViewBuilder(tree, now).today().entries;
      final ids = entries.whereType<ItemEntry>().map((e) => e.item.id).toList();
      expect(ids, ['late', 'today step', 'grandchild']);
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('Today: overdue child between two today items stays out', () {
      final tree = ItemTree([
        task('gp', due: DateTime(2026, 11, 15, 22)),
        task('p', parent: 'gp', due: DateTime(2026, 11, 14, 9)),
        task('c', parent: 'p', due: DateTime(2026, 11, 15, 20)),
      ]);
      final ids = ViewBuilder(
        tree,
        now,
      ).today().entries.whereType<ItemEntry>().map((e) => e.item.id).toList();
      expect(ids, ['p', 'c', 'gp']);
    });

    test('Upcoming: a subtask shows under its own day only', () {
      final tree = ItemTree([
        task('mon parent', due: DateTime(2026, 11, 16, 9)),
        task('wed child', parent: 'mon parent', due: DateTime(2026, 11, 18, 9)),
      ]);
      final ids = ViewBuilder(tree, now)
          .upcoming()
          .entries
          .whereType<ItemEntry>()
          .map((e) => e.item.id)
          .toList();
      expect(ids, ['mon parent', 'wed child']);
      expect(ids.toSet(), hasLength(2));
    });
  });

  group('counts', () {
    test('a parent with subtasks counts once; subtasks show as progress', () {
      final tree = ItemTree([
        task('trip', due: DateTime(2026, 11, 15, 20)),
        for (final s in ['pack', 'tickets', 'hotel', 'charger'])
          task(s, parent: 'trip'),
      ]);
      final b = ViewBuilder(tree, now);
      final today = b.today();
      expect(today.count, 1);
      expect(today.entries.whereType<SectionHeader>().single.count, 1);
      final row = today.entries.whereType<ItemEntry>().first;
      expect((row.subtasksDone, row.subtasksTotal), (0, 4));
      expect(b.all().count, 1);
    });

    test('progress counts leaves at every depth, not inner parents', () {
      final tree = ItemTree([
        task('project'),
        task('research', parent: 'project'),
        task('read', parent: 'research', doneAt: now),
        task('notes', parent: 'research'),
        task('write', parent: 'project'),
        event(
          'meeting',
          parent: 'project',
          start: DateTime(2026, 11, 16, 9),
          end: DateTime(2026, 11, 16, 10),
        ),
      ]);
      // Leaves: read (done), notes, write. "research" is an inner parent;
      // events aren't steps.
      expect(subtaskProgress(tree, 'project'), (done: 1, total: 3));
      expect(subtaskProgress(tree, 'research'), (done: 1, total: 2));
      expect(subtaskProgress(tree, 'write'), (done: 0, total: 0));
    });

    test('a subtask shown on its own (parent elsewhere) counts as a row', () {
      final tree = ItemTree([
        task('project', due: DateTime(2026, 12, 1)),
        task('step', parent: 'project', due: DateTime(2026, 11, 15, 15)),
        task('other', due: DateTime(2026, 11, 15, 16)),
        task('other sub', parent: 'other', due: DateTime(2026, 11, 15, 14)),
      ]);
      expect(ViewBuilder(tree, now).today().count, 2); // step, other
    });
  });

  group('sorting', () {
    test('by due date, items without one last', () {
      final items = [
        task('none'),
        task('late', due: DateTime(2026, 11, 20)),
        task('soon', due: DateTime(2026, 11, 16)),
      ]..sort(compareItems);
      expect(items.map((i) => i.id), ['soon', 'late', 'none']);
    });

    test('priority breaks ties', () {
      final due = DateTime(2026, 11, 16, 9);
      final items = [
        task('low', due: due, priority: Priority.low),
        task('high', due: due, priority: Priority.high),
        task('none', due: due),
      ]..sort(compareItems);
      expect(items.map((i) => i.id), ['high', 'low', 'none']);
    });

    test('date-only sorts after timed items on the same day', () {
      final items = [
        task('all day', due: DateTime(2026, 11, 16), hasTime: false),
        task('morning', due: DateTime(2026, 11, 16, 9)),
      ]..sort(compareItems);
      expect(items.map((i) => i.id), ['morning', 'all day']);
    });
  });
}
