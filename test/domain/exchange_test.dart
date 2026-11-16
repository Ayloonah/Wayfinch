import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/domain/exchange/exchange_export.dart';
import 'package:wayfinch/domain/exchange/exchange_model.dart';
import 'package:wayfinch/domain/exchange/exchange_parser.dart';
import 'package:wayfinch/domain/item.dart';
import 'package:wayfinch/domain/item_enums.dart';
import 'package:wayfinch/domain/item_tree.dart';

import 'test_items.dart';

void main() {
  final now = DateTime(2026, 11, 15, 12);
  const school = Tag(id: 't1', name: 'school', color: 0);
  final tags = {school.id: school};

  group('export', () {
    final tree = ItemTree([
      task(
        'p',
        due: DateTime(2026, 12, 5, 23, 59),
        priority: Priority.high,
      ).copyWith(tagIds: ['t1'], notes: 'Use the template'),
      task('c', parent: 'p', due: DateTime(2026, 12, 3), hasTime: false),
      task('done', doneAt: now),
      task('open under done', parent: 'done'),
      event(
        'e',
        start: DateTime(2026, 11, 20, 14),
        end: DateTime(2026, 11, 20, 15),
      ),
    ]);

    Map<String, dynamic> export(ExportOptions o) =>
        jsonDecode(buildExportJson(tree, tags, o, now).json)
            as Map<String, dynamic>;

    test('writes the Wayfinch format with nesting and all fields', () {
      final doc = export(const ExportOptions());
      expect(doc['format'], 'wayfinch');
      expect(doc['version'], 1);
      final items = (doc['items'] as List).cast<Map<String, dynamic>>();
      final p = items.firstWhere((i) => i['id'] == 'p');
      expect(p['type'], 'task');
      expect(p['due'], '2026-12-05T23:59');
      expect(p['priority'], 'high');
      expect(p['tags'], ['school']);
      expect(p['notes'], 'Use the template');
      expect(p['recurrence'], isNull);
      final c = (p['children'] as List).single as Map<String, dynamic>;
      expect(c['due'], '2026-12-03');
      final e = items.firstWhere((i) => i['id'] == 'e');
      expect(e['start'], '2026-11-20T14:00');
      expect(e.containsKey('due'), isFalse);
    });

    test('done items are left out by default; their subtasks move up', () {
      final doc = export(const ExportOptions());
      final ids = (doc['items'] as List).map((i) => i['id']).toList();
      expect(ids, isNot(contains('done')));
      expect(ids, contains('open under done'));
    });

    test('options: no notes, no events, with done items', () {
      final doc = export(
        const ExportOptions(notes: false, events: false, doneItems: true),
      );
      final items = (doc['items'] as List).cast<Map<String, dynamic>>();
      expect(items.any((i) => i['id'] == 'e'), isFalse);
      expect(
        items.firstWhere((i) => i['id'] == 'p').containsKey('notes'),
        isFalse,
      );
      final done = items.firstWhere((i) => i['id'] == 'done');
      expect(done['done'], true);
      expect((done['children'] as List).single['id'], 'open under done');
    });

    test('counts and item count', () {
      final counts = exportCounts(tree, now);
      expect(counts.openTasks, 3);
      expect(counts.events, 1);
      expect(counts.doneItems, 1);
      expect(
        buildExportJson(tree, tags, const ExportOptions(), now).itemCount,
        4,
      );
    });

    test('export options round-trip through settings', () {
      const o = ExportOptions(events: false, doneItems: true);
      final back = ExportOptions.decode(o.encode());
      expect(back.events, isFalse);
      expect(back.doneItems, isTrue);
      expect(ExportOptions.decode('junk').doneItems, isFalse);
    });

    test('an export parses back cleanly', () {
      final json = buildExportJson(
        tree,
        tags,
        const ExportOptions(doneItems: true),
        now,
      ).json;
      final outcome = parseExchange(json);
      expect(outcome.errors, isEmpty);
      expect(outcome.document!.allItems.length, 5);
    });
  });

  group('extractJson', () {
    test('strips chatter and code fences', () {
      const reply =
          'Sure! Here is your plan:\n```json\n{"a": {"b": "}"}}\n```\nGood luck!';
      expect(extractJson(reply), '{"a": {"b": "}"}}');
    });

    test('no braces, or unbalanced, gives null', () {
      expect(extractJson('No JSON here'), isNull);
      expect(extractJson('{"a": 1'), isNull);
    });
  });

  group('parseExchange', () {
    String doc(String items, {String extra = ''}) =>
        '{"format":"wayfinch","version":1,"items":[$items]$extra}';

    List<ExchangeErrorCode> codes(String text) =>
        parseExchange(text).errors.map((e) => e.code).toList();

    test('a minimal valid reply', () {
      final outcome = parseExchange(
        doc('{"type":"task","title":"Write report","due":"2026-12-03T23:59"}'),
      );
      expect(outcome.isValid, isTrue);
      final item = outcome.document!.items.single;
      expect(item.id, isNull);
      expect(
        item.due,
        ExchangeDate(DateTime(2026, 12, 3, 23, 59), hasTime: true),
      );
    });

    test('nested children keep their order and paths', () {
      final outcome = parseExchange(
        doc(
          '{"type":"task","title":"P","children":['
          '{"type":"task","title":"A"},{"type":"task","title":"B"}]}',
        ),
      );
      final p = outcome.document!.items.single;
      expect(p.children.map((c) => c.title), ['A', 'B']);
      expect(p.children[1].path, 'items[0].children[1]');
    });

    test('no JSON / broken JSON / not an object', () {
      expect(codes('nothing to see'), [ExchangeErrorCode.noJson]);
      expect(codes('{"format": wayfinch}'), [ExchangeErrorCode.invalidJson]);
    });

    test('wrong format and unsupported version', () {
      expect(codes('{"format":"other","version":1,"items":[]}'), [
        ExchangeErrorCode.wrongFormat,
      ]);
      expect(codes('{"format":"wayfinch","version":2,"items":[]}'), [
        ExchangeErrorCode.unsupportedVersion,
      ]);
      expect(codes('{"format":"wayfinch","version":1}'), [
        ExchangeErrorCode.missingField,
      ]);
    });

    test('strict: unknown fields are errors, with where they are', () {
      final outcome = parseExchange(
        doc('{"type":"task","title":"x","description":"?"}'),
      );
      expect(outcome.errors.single.code, ExchangeErrorCode.unknownField);
      expect(outcome.errors.single.path, 'items[0]');
      expect(outcome.errors.single.detail, 'description');
    });

    test('field values are checked', () {
      expect(codes(doc('{"type":"chore","title":"x"}')), [
        ExchangeErrorCode.invalidType,
      ]);
      expect(codes(doc('{"type":"task","title":"  "}')), [
        ExchangeErrorCode.emptyTitle,
      ]);
      expect(codes(doc('{"type":"task","title":"x","due":"Dec 5"}')), [
        ExchangeErrorCode.invalidDate,
      ]);
      expect(codes(doc('{"type":"task","title":"x","due":"2026-02-30"}')), [
        ExchangeErrorCode.invalidDate,
      ]);
      expect(codes(doc('{"type":"task","title":"x","priority":"urgent"}')), [
        ExchangeErrorCode.invalidPriority,
      ]);
      expect(codes(doc('{"type":"task","title":"x","recurrence":"WEEKLY"}')), [
        ExchangeErrorCode.invalidRecurrence,
      ]);
      expect(codes(doc('{"type":"task","title":"x","tags":"school"}')), [
        ExchangeErrorCode.wrongType,
      ]);
    });

    test('task and event fields stay on their own kind', () {
      expect(
        codes(doc('{"type":"task","title":"x","start":"2026-12-03T10:00"}')),
        [ExchangeErrorCode.fieldNotForType],
      );
      expect(codes(doc('{"type":"event","title":"x"}')), [
        ExchangeErrorCode.eventNeedsTimes,
        ExchangeErrorCode.eventNeedsTimes,
      ]);
      expect(
        codes(
          doc(
            '{"type":"event","title":"x","start":"2026-12-03T10:00",'
            '"end":"2026-12-03T09:00"}',
          ),
        ),
        [ExchangeErrorCode.endBeforeStart],
      );
    });

    test('duplicate ids are caught', () {
      expect(
        codes(
          doc(
            '{"id":"a","type":"task","title":"x"},'
            '{"id":"a","type":"task","title":"y"}',
          ),
        ),
        [ExchangeErrorCode.duplicateId],
      );
    });

    test('existing items may leave fields out', () {
      final outcome = parseExchange(doc('{"id":"a","priority":"high"}'));
      expect(outcome.isValid, isTrue);
      expect(outcome.document!.items.single.has('title'), isFalse);
    });

    test('several problems are all reported', () {
      final outcome = parseExchange(
        doc('{"type":"chore","title":""},{"type":"task"}'),
      );
      expect(outcome.errors.length, 3);
    });
  });
}
