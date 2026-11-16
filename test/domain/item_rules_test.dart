import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/domain/item.dart';
import 'package:wayfinch/domain/item_rules.dart';
import 'package:wayfinch/domain/item_tree.dart';

import 'test_items.dart';

class _Prefs implements PromptPreferences {
  final Map<PromptKind, PromptAnswer> saved = {};

  @override
  Future<PromptAnswer?> remembered(PromptKind kind) async => saved[kind];

  @override
  Future<void> remember(PromptKind kind, PromptAnswer? answer) async {
    if (answer == null) {
      saved.remove(kind);
    } else {
      saved[kind] = answer;
    }
  }
}

void main() {
  final now = DateTime(2026, 11, 15, 12);
  late _Prefs prefs;
  late List<PromptKind> asked;
  late PromptAnswer answer;
  late bool remember;
  late ItemRules rules;
  var ids = 0;

  setUp(() {
    prefs = _Prefs();
    asked = [];
    answer = PromptAnswer.confirm;
    remember = false;
    ids = 0;
    rules = ItemRules(
      preferences: prefs,
      ask: (kind, count) async {
        asked.add(kind);
        return PromptResult(answer, remember: remember);
      },
      newId: () => 'new${ids++}',
      clock: () => now,
    );
  });

  Map<String, Item> byId(ItemChanges c) => {for (final i in c.updated) i.id: i};

  group('complete', () {
    test('a simple task is marked done without asking', () async {
      final changes = await rules.complete(ItemTree([task('a')]), 'a');
      expect(byId(changes!)['a']!.doneAt, now);
      expect(asked, isEmpty);
    });

    test('parent with open subtasks asks, then closes them all', () async {
      final tree = ItemTree([
        task('p'),
        task('c1', parent: 'p'),
        task('c2', parent: 'p'),
        task('g', parent: 'c1'),
        task('done', parent: 'p', doneAt: DateTime(2026, 11, 1)),
      ]);
      final changes = await rules.complete(tree, 'p');
      final updated = byId(changes!);
      expect(asked, [PromptKind.closeSubtasks]);
      expect(updated.keys, containsAll(['p', 'c1', 'c2', 'g']));
      expect(updated.values.every((i) => i.doneAt == now), isTrue);
      expect(updated.containsKey('done'), isFalse);
    });

    test('Cancel on close-subtasks changes nothing', () async {
      answer = PromptAnswer.cancel;
      final tree = ItemTree([task('p'), task('c', parent: 'p')]);
      expect(await rules.complete(tree, 'p'), isNull);
    });

    test('last open subtask asks to complete the parent', () async {
      final tree = ItemTree([
        task('p'),
        task('c1', parent: 'p', doneAt: DateTime(2026, 11, 1)),
        task('c2', parent: 'p'),
      ]);
      final changes = await rules.complete(tree, 'c2');
      expect(asked, [PromptKind.completeParent]);
      expect(byId(changes!)['p']!.doneAt, now);
    });

    test('declining the parent still completes the subtask', () async {
      answer = PromptAnswer.cancel;
      final tree = ItemTree([task('p'), task('c', parent: 'p')]);
      final updated = byId((await rules.complete(tree, 'c'))!);
      expect(updated['c']!.doneAt, now);
      expect(updated.containsKey('p'), isFalse);
    });

    test('not the last subtask: no prompt', () async {
      final tree = ItemTree([
        task('p'),
        task('c1', parent: 'p'),
        task('c2', parent: 'p'),
      ]);
      await rules.complete(tree, 'c1');
      expect(asked, isEmpty);
    });

    test('completing the parent chain goes up level by level', () async {
      final tree = ItemTree([
        task('gp'),
        task('p', parent: 'gp'),
        task('c', parent: 'p'),
      ]);
      final updated = byId((await rules.complete(tree, 'c'))!);
      expect(asked, [PromptKind.completeParent, PromptKind.completeParent]);
      expect(updated.keys, containsAll(['c', 'p', 'gp']));
    });

    test('a remembered Confirm skips the prompt next time', () async {
      remember = true;
      await rules.complete(ItemTree([task('p'), task('c', parent: 'p')]), 'c');
      expect(prefs.saved, {PromptKind.completeParent: PromptAnswer.confirm});
      remember = false;

      asked.clear();
      final changes = await rules.complete(
        ItemTree([task('q'), task('d', parent: 'q')]),
        'd',
      );
      expect(asked, isEmpty);
      expect(byId(changes!)['q']!.doneAt, now);
    });

    test('a remembered Cancel leaves parents open without asking', () async {
      answer = PromptAnswer.cancel;
      remember = true;
      await rules.complete(ItemTree([task('p'), task('c', parent: 'p')]), 'c');
      expect(prefs.saved, {PromptKind.completeParent: PromptAnswer.cancel});

      asked.clear();
      answer = PromptAnswer.confirm;
      final updated = byId(
        (await rules.complete(
          ItemTree([task('q'), task('d', parent: 'q')]),
          'd',
        ))!,
      );
      expect(asked, isEmpty);
      expect(updated.containsKey('q'), isFalse);
      expect(updated['d']!.doneAt, now);
    });

    test('Cancel is never remembered for close-subtasks', () async {
      answer = PromptAnswer.cancel;
      remember = true;
      final tree = ItemTree([task('p'), task('c', parent: 'p')]);
      expect(await rules.complete(tree, 'p'), isNull);
      expect(prefs.saved, isEmpty);

      // Next time it asks again.
      asked.clear();
      await rules.complete(tree, 'p');
      expect(asked, [PromptKind.closeSubtasks]);
    });

    test('a remembered close-subtasks Confirm closes without asking', () async {
      prefs.saved[PromptKind.closeSubtasks] = PromptAnswer.confirm;
      final tree = ItemTree([task('p'), task('c', parent: 'p')]);
      final updated = byId((await rules.complete(tree, 'p'))!);
      expect(asked, isEmpty);
      expect(updated.keys, containsAll(['p', 'c']));
    });

    test('unchecked remember stores nothing', () async {
      await rules.complete(ItemTree([task('p'), task('c', parent: 'p')]), 'c');
      expect(prefs.saved, isEmpty);
    });

    test('events and done tasks are ignored', () async {
      final tree = ItemTree([
        event('e', start: now, end: now.add(const Duration(hours: 1))),
        task('d', doneAt: now),
      ]);
      expect((await rules.complete(tree, 'e'))!.isEmpty, isTrue);
      expect((await rules.complete(tree, 'd'))!.isEmpty, isTrue);
    });
  });

  group('recurrence on completion', () {
    test('creates the next occurrence and moves the rule to it', () async {
      final tree = ItemTree([
        task('r', due: DateTime(2026, 11, 15, 9), rrule: 'FREQ=WEEKLY'),
      ]);
      final changes = (await rules.complete(tree, 'r'))!;
      final done = byId(changes)['r']!;
      expect(done.doneAt, now);
      expect(done.recurrence, isNull);
      final next = changes.created.single;
      expect(next.id, 'new0');
      expect(next.due, DateTime(2026, 11, 22, 9));
      expect(next.doneAt, isNull);
      expect(next.recurrence, 'FREQ=WEEKLY');
    });

    test('copies subtasks reopened and shifted', () async {
      final tree = ItemTree([
        task('r', due: DateTime(2026, 11, 15, 18), rrule: 'FREQ=DAILY'),
        task('s1', parent: 'r', due: DateTime(2026, 11, 15, 12)),
        task('s2', parent: 'r', doneAt: DateTime(2026, 11, 15, 8)),
        task('g', parent: 's1'),
      ]);
      answer = PromptAnswer.confirm;
      final changes = (await rules.complete(tree, 'r'))!;
      final created = {for (final c in changes.created) c.title: c};
      expect(created.keys, containsAll(['r', 's1', 's2', 'g']));
      final parent = created['r']!;
      expect(created['s1']!.parentId, parent.id);
      expect(created['s1']!.due, DateTime(2026, 11, 16, 12));
      expect(created['s2']!.doneAt, isNull);
      expect(created['g']!.parentId, created['s1']!.id);
      // Every copy has a fresh id.
      expect(created.values.map((c) => c.id).toSet(), hasLength(4));
      expect(created.values.any((c) => tree[c.id] != null), isFalse);
    });

    test('a finished COUNT doesn\'t spawn', () async {
      final tree = ItemTree([
        task('r', due: DateTime(2026, 11, 15), rrule: 'FREQ=DAILY;COUNT=1'),
      ]);
      expect((await rules.complete(tree, 'r'))!.created, isEmpty);
    });

    test('recurring task without a due date repeats from now', () async {
      final tree = ItemTree([task('r', rrule: 'FREQ=DAILY')]);
      final next = (await rules.complete(tree, 'r'))!.created.single;
      expect(next.due, isNull);
    });
  });

  test('reopen clears doneAt only', () {
    final tree = ItemTree([task('a', doneAt: now)]);
    final changes = rules.reopen(tree, 'a');
    expect(changes.updated.single.doneAt, isNull);
  });

  group('setDue', () {
    test('within the parent\'s date: no prompt', () async {
      final tree = ItemTree([
        task('p', due: DateTime(2026, 12, 5, 23, 59)),
        task('c', parent: 'p'),
      ]);
      final changes = await rules.setDue(
        tree,
        'c',
        due: DateTime(2026, 12, 3, 12),
        hasTime: true,
      );
      expect(asked, isEmpty);
      expect(changes!.updated.single.due, DateTime(2026, 12, 3, 12));
    });

    test(
      'past the parent asks and pushes every ancestor that needs it',
      () async {
        final tree = ItemTree([
          task('gp', due: DateTime(2026, 12, 6, 12)),
          task('p', parent: 'gp', due: DateTime(2026, 12, 5, 12)),
          task('c', parent: 'p'),
        ]);
        final changes = await rules.setDue(
          tree,
          'c',
          due: DateTime(2026, 12, 10, 9),
          hasTime: true,
        );
        expect(asked, [PromptKind.pushParentDue]);
        final updated = byId(changes!);
        expect(updated['p']!.due, DateTime(2026, 12, 10, 9));
        expect(updated['gp']!.due, DateTime(2026, 12, 10, 9));
      },
    );

    test('stops at the first ancestor that is late enough', () async {
      final tree = ItemTree([
        task('gp', due: DateTime(2026, 12, 31)),
        task('p', parent: 'gp', due: DateTime(2026, 12, 5, 12)),
        task('c', parent: 'p'),
      ]);
      final changes = await rules.setDue(
        tree,
        'c',
        due: DateTime(2026, 12, 10, 9),
        hasTime: true,
      );
      expect(byId(changes!).keys, containsAll(['c', 'p']));
      expect(byId(changes).containsKey('gp'), isFalse);
    });

    test('date-only parent counts as end of day', () async {
      final tree = ItemTree([
        task('p', due: DateTime(2026, 12, 5), hasTime: false),
        task('c', parent: 'p'),
      ]);
      await rules.setDue(
        tree,
        'c',
        due: DateTime(2026, 12, 5, 17),
        hasTime: true,
      );
      expect(asked, isEmpty);
    });

    test('parent without a due date is never pushed', () async {
      final tree = ItemTree([task('p'), task('c', parent: 'p')]);
      await rules.setDue(tree, 'c', due: DateTime(2027), hasTime: false);
      expect(asked, isEmpty);
    });

    test('Cancel with remember checked is not remembered', () async {
      answer = PromptAnswer.cancel;
      remember = true;
      final tree = ItemTree([
        task('p', due: DateTime(2026, 12, 5)),
        task('c', parent: 'p'),
      ]);
      await rules.setDue(tree, 'c', due: DateTime(2026, 12, 9), hasTime: false);
      expect(prefs.saved, isEmpty);
    });

    test('Cancel changes nothing at all', () async {
      answer = PromptAnswer.cancel;
      final tree = ItemTree([
        task('p', due: DateTime(2026, 12, 5)),
        task('c', parent: 'p'),
      ]);
      expect(
        await rules.setDue(
          tree,
          'c',
          due: DateTime(2026, 12, 9),
          hasTime: false,
        ),
        isNull,
      );
    });

    test('clearing the due date never asks', () async {
      final tree = ItemTree([
        task('p', due: DateTime(2026, 12, 5)),
        task('c', parent: 'p', due: DateTime(2026, 12, 1)),
      ]);
      final changes = await rules.setDue(tree, 'c', due: null, hasTime: false);
      expect(changes!.updated.single.due, isNull);
      expect(asked, isEmpty);
    });
  });

  group('rollEndedEvents', () {
    test('creates the next upcoming occurrence of an ended event', () {
      final tree = ItemTree([
        event(
          'e',
          start: DateTime(2026, 11, 10, 14),
          end: DateTime(2026, 11, 10, 15),
          rrule: 'FREQ=WEEKLY',
        ),
      ]);
      final changes = rules.rollEndedEvents(tree);
      expect(changes.updated.single.recurrence, isNull);
      final next = changes.created.single;
      expect(next.start, DateTime(2026, 11, 17, 14));
      expect(next.end, DateTime(2026, 11, 17, 15));
      expect(next.recurrence, 'FREQ=WEEKLY');
    });

    test('leaves running and non-recurring events alone', () {
      final tree = ItemTree([
        event(
          'running',
          start: DateTime(2026, 11, 15, 11),
          end: DateTime(2026, 11, 15, 13),
          rrule: 'FREQ=DAILY',
        ),
        event(
          'once',
          start: DateTime(2026, 11, 10, 14),
          end: DateTime(2026, 11, 10, 15),
        ),
      ]);
      expect(rules.rollEndedEvents(tree).isEmpty, isTrue);
    });
  });
}
