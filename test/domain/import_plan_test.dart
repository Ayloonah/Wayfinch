import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/domain/exchange/exchange_parser.dart';
import 'package:wayfinch/domain/exchange/import_plan.dart';
import 'package:wayfinch/domain/item.dart';
import 'package:wayfinch/domain/item_enums.dart';
import 'package:wayfinch/domain/item_tree.dart';

import 'test_items.dart';

void main() {
  final now = DateTime(2026, 11, 15, 12);
  const school = Tag(id: 't1', name: 'school', color: 0);
  final tags = {school.id: school};
  late int ids;

  setUp(() => ids = 0);

  ImportPlan plan(
    ItemTree tree,
    String items, {
    ImportMode mode = ImportMode.replace,
  }) {
    final outcome = parseExchange(
      '{"format":"wayfinch","version":1,"items":[$items]}',
    );
    expect(outcome.errors, isEmpty, reason: 'reply should parse');
    return planImport(
      tree: tree,
      tagsById: tags,
      doc: outcome.document!,
      mode: mode,
      now: now,
      newId: () => 'new${ids++}',
    );
  }

  final tagIds = {'school': 't1', 'ta': 't2'};

  group('Replace', () {
    final tree = ItemTree([
      task(
        'report',
        due: DateTime(2026, 11, 15, 23, 59),
        created: DateTime(2026, 10, 1),
      ),
      task('results', parent: 'report', priority: Priority.medium),
      task('books', due: DateTime(2026, 11, 12), hasTime: false),
      task('old win', doneAt: DateTime(2026, 11, 1)),
    ]);

    test('counts new, changed and removed; done items untouched', () {
      final p = plan(tree, '''
        {"id":"report","type":"task","title":"report","due":"2026-11-17T23:59",
         "children":[{"id":"results","type":"task","title":"results","priority":"high"},
                     {"type":"task","title":"Proofread"}]},
        {"type":"task","title":"Book a room","tags":["school","ta"]}
      ''');
      expect(p.added.map((a) => a.title), ['Proofread', 'Book a room']);
      expect(p.changed.map((c) => c.title), ['report', 'results']);
      expect(p.removed.map((r) => r.item.id), ['books']);
      expect(p.doneUntouched, 1);
      expect(p.newTagNames, ['ta']);

      final due = p.changed.first.fields.single as DateChange;
      expect(due.field, DateField.due);
      expect(due.to!.value, DateTime(2026, 11, 17, 23, 59));
      final pri = p.changed.last.fields.single as PriorityChange;
      expect((pri.from, pri.to), (Priority.medium, Priority.high));
    });

    test('applying keeps ids and history, and never deletes done items', () {
      final p = plan(tree, '''
        {"id":"report","type":"task","title":"Report v2",
         "children":[{"id":"results","type":"task","title":"results"}]}
      ''');
      final changes = p.build(tagIdsByName: tagIds);
      final report = changes.updated.firstWhere((i) => i.id == 'report');
      expect(report.title, 'Report v2');
      expect(report.createdAt, DateTime(2026, 10, 1)); // history kept
      expect(changes.deletedIds, ['books']);
      expect(changes.deletedIds, isNot(contains('old win')));
    });

    test('"Keep this item" saves a removal', () {
      final p = plan(tree, '{"id":"report","type":"task","title":"report"}');
      expect(
        p.removed.map((r) => r.item.id),
        containsAll(['books', 'results']),
      );
      final changes = p.build(tagIdsByName: tagIds, keep: {'books'});
      expect(changes.deletedIds, ['results']);
      expect(p.countFor({'books'}), p.changes.length - 1);
    });

    test('missing fields on existing items stay as they are', () {
      final p = plan(tree, '{"id":"results","title":"results renamed"}');
      final changes = p.build(tagIdsByName: tagIds);
      final results = changes.updated.firstWhere((i) => i.id == 'results');
      expect(results.title, 'results renamed');
      expect(results.priority, Priority.medium);
      expect(results.type, ItemType.task);
    });

    test('nothing changed: counted as unchanged, not as a change', () {
      final p = plan(tree, '''
        {"id":"report","type":"task","title":"report","due":"2026-11-15T23:59",
         "children":[{"id":"results","type":"task","title":"results","priority":"medium"}]},
        {"id":"books","type":"task","title":"books","due":"2026-11-12"}
      ''');
      expect(p.changes, isEmpty);
      expect(p.unchangedCount, 3);
    });

    test('moves between parents follow the reply', () {
      final p = plan(tree, '''
        {"id":"report","type":"task","title":"report"},
        {"id":"books","type":"task","title":"books",
         "children":[{"id":"results","type":"task","title":"results"}]}
      ''');
      final move = p.changed
          .firstWhere((c) => c.before.id == 'results')
          .fields
          .whereType<MoveChange>()
          .single;
      expect(move.newParentTitle, 'books');
      final changes = p.build(tagIdsByName: tagIds);
      expect(
        changes.updated.firstWhere((i) => i.id == 'results').parentId,
        'books',
      );
    });

    test('marking done in the reply completes the item', () {
      final p = plan(
        tree,
        '{"id":"books","type":"task","title":"books","done":true}',
      );
      expect(
        p.changed.single.fields.whereType<DoneChange>().single.done,
        isTrue,
      );
      final books = p
          .build(tagIdsByName: tagIds)
          .updated
          .firstWhere((i) => i.id == 'books');
      expect(books.doneAt, now);
    });

    test('a top-level item keeps its unexported done parent', () {
      final tree = ItemTree([
        task('done parent', doneAt: DateTime(2026, 11, 1)),
        task('open child', parent: 'done parent'),
      ]);
      final p = plan(
        tree,
        '{"id":"open child","type":"task","title":"open child"}',
      );
      expect(p.changes, isEmpty);
      final child = p.build(tagIdsByName: tagIds).updated.single;
      expect(child.parentId, 'done parent');
    });

    test('survivors under a removed item move up', () {
      final tree = ItemTree([
        task('gp'),
        task('p', parent: 'gp'),
        task('done kid', parent: 'p', doneAt: DateTime(2026, 11, 1)),
      ]);
      final p = plan(tree, '{"id":"gp","type":"task","title":"gp"}');
      final changes = p.build(tagIdsByName: tagIds);
      expect(changes.deletedIds, ['p']);
      expect(
        changes.updated.firstWhere((i) => i.id == 'done kid').parentId,
        'gp',
      );
    });

    test('unknown ids become new items with fresh ids', () {
      final p = plan(tree, '{"id":"ai-made-up","type":"task","title":"Hello"}');
      expect(p.added.single.title, 'Hello');
      final created = p.build(tagIdsByName: tagIds).created.single;
      expect(created.id, startsWith('new'));
      expect(created.source, ItemSource.aiImport);
    });

    test('an unknown id without a title is an error', () {
      final p = plan(tree, '{"id":"ghost","priority":"high"}');
      expect(p.errors.map((e) => e.detail), containsAll(['type', 'title']));
    });

    test('new items get tags, nesting and reply order', () {
      final p = plan(tree, '''
        {"type":"task","title":"Outline","tags":["School"],"children":[
          {"type":"task","title":"Slides","due":"2026-11-28"},
          {"type":"task","title":"Rehearse"}]}
      ''');
      final created = p.build(tagIdsByName: tagIds).created;
      final outline = created.firstWhere((i) => i.title == 'Outline');
      final slides = created.firstWhere((i) => i.title == 'Slides');
      final rehearse = created.firstWhere((i) => i.title == 'Rehearse');
      expect(outline.tagIds, ['t1']);
      expect(slides.parentId, outline.id);
      expect(slides.due, DateTime(2026, 11, 28));
      expect(slides.dueHasTime, isFalse);
      expect((slides.sortOrder, rehearse.sortOrder), (0, 1));
      expect(p.added.map((a) => a.depth), [0, 1, 1]);
    });

    test('tag changes list added and removed names', () {
      final tree = ItemTree([
        task('a').copyWith(tagIds: ['t1']),
      ]);
      final p = plan(
        tree,
        '{"id":"a","type":"task","title":"a","tags":["ta"]}',
      );
      final change = p.changed.single.fields.whereType<TagsChange>().single;
      expect(change.added, ['ta']);
      expect(change.removed, ['school']);
    });
  });

  group('Add', () {
    final tree = ItemTree([task('report'), task('books')]);

    test('only new items; nothing changed or removed', () {
      final p = plan(tree, '''
        {"id":"report","type":"task","title":"Renamed!",
         "children":[{"type":"task","title":"New step"}]},
        {"type":"task","title":"Brand new"}
      ''', mode: ImportMode.add);
      expect(p.added.map((a) => a.title), ['New step', 'Brand new']);
      expect(p.changed, isEmpty);
      expect(p.removed, isEmpty);
      final changes = p.build(tagIdsByName: tagIds);
      expect(changes.updated, isEmpty);
      expect(changes.deletedIds, isEmpty);
      // The new step lands under the existing item.
      expect(
        changes.created.firstWhere((i) => i.title == 'New step').parentId,
        'report',
      );
    });
  });
}
