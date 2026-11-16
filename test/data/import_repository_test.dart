import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/data/database.dart';
import 'package:wayfinch/data/import_repository.dart';
import 'package:wayfinch/data/items_repository.dart';
import 'package:wayfinch/data/tags_repository.dart';
import 'package:wayfinch/domain/exchange/exchange_parser.dart';
import 'package:wayfinch/domain/exchange/import_plan.dart';
import 'package:wayfinch/domain/item_enums.dart';
import 'package:wayfinch/domain/item_tree.dart';

void main() {
  late WayfinchDatabase db;
  late ItemsRepository items;
  late TagsRepository tags;
  late ImportRepository imports;
  late DateTime now;

  setUp(() {
    db = WayfinchDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 15, 12);
    items = ItemsRepository(db, clock: () => now);
    tags = TagsRepository(db, clock: () => now);
    imports = ImportRepository(db, items, clock: () => now);
  });

  tearDown(() => db.close());

  Future<ImportPlan> plan(String itemsJson, ImportMode mode) async {
    final doc = parseExchange(
      '{"format":"wayfinch","version":1,"items":[$itemsJson]}',
    ).document!;
    return planImport(
      tree: ItemTree(await items.loadAll()),
      tagsById: {for (final t in await tags.loadAll()) t.id: t},
      doc: doc,
      mode: mode,
      now: now,
      newId: newId,
    );
  }

  test('Replace applies, creates tags, and Undo restores exactly', () async {
    final school = await tags.findOrCreate('school', colorFor: (_) => 1);
    final report = await items.create(
      type: ItemType.task,
      title: 'Report',
      tagIds: [school.id],
    );
    final books = await items.create(type: ItemType.task, title: 'Books');
    final before = {for (final i in await items.loadAll()) i.id: i};

    now = now.add(const Duration(hours: 1));
    final p = await plan(
      '{"id":"${report.id}","type":"task","title":"Report v2","tags":["ta"]},'
      '{"type":"task","title":"New thing"}',
      ImportMode.replace,
    );
    final touched = await imports.apply(p, colorFor: (_) => 7);
    expect(touched, 3); // 1 changed, 1 new, 1 removed

    final after = {for (final i in await items.loadAll()) i.id: i};
    expect(after[report.id]!.title, 'Report v2');
    expect(after[report.id]!.createdAt, before[report.id]!.createdAt);
    expect(after.containsKey(books.id), isFalse);
    expect(after.values.map((i) => i.title), contains('New thing'));
    final ta = (await tags.loadAll()).firstWhere((t) => t.name == 'ta');
    expect(ta.color, 7);
    expect(await imports.watchLatest().first, isNotNull);

    expect(await imports.undoLatest(), isTrue);
    final restored = {for (final i in await items.loadAll()) i.id: i};
    expect(restored.keys, unorderedEquals(before.keys));
    expect(restored[report.id]!.title, 'Report');
    expect(restored[report.id]!.tagIds, [school.id]);
    expect(restored[report.id]!.updatedAt, before[report.id]!.updatedAt);
    expect((await tags.loadAll()).map((t) => t.name), ['school']);
    expect(await imports.watchLatest().first, isNull);
    expect(await imports.undoLatest(), isFalse);
  });

  test('Add only inserts; nested new items keep their parent', () async {
    final report = await items.create(type: ItemType.task, title: 'Report');
    final p = await plan(
      '{"id":"${report.id}","type":"task","title":"Ignored rename",'
      '"children":[{"type":"task","title":"Step"}]}',
      ImportMode.add,
    );
    await imports.apply(p, colorFor: (_) => 0);
    final all = await items.loadAll();
    expect(all.firstWhere((i) => i.id == report.id).title, 'Report');
    final step = all.firstWhere((i) => i.title == 'Step');
    expect(step.parentId, report.id);
    expect(step.source, ItemSource.aiImport);
  });

  test('Undo restores nested items whose parent was deleted', () async {
    final p0 = await items.create(type: ItemType.task, title: 'Parent');
    await items.create(type: ItemType.task, title: 'Child', parentId: p0.id);
    final p = await plan(
      '{"type":"task","title":"Only this"}',
      ImportMode.replace,
    );
    await imports.apply(p, colorFor: (_) => 0);
    expect((await items.loadAll()).map((i) => i.title), ['Only this']);

    await imports.undoLatest();
    final titles = (await items.loadAll()).map((i) => i.title);
    expect(titles, unorderedEquals(['Parent', 'Child']));
  });

  test('backups record why they were taken; any one can be restored', () async {
    await items.create(type: ItemType.task, title: 'Original');
    final first = await plan(
      '{"type":"task","title":"Import 1"}',
      ImportMode.add,
    );
    await imports.apply(first, colorFor: (_) => 0);
    final second = await plan(
      '{"type":"task","title":"Only import 2"}',
      ImportMode.replace,
    );
    await imports.apply(second, colorFor: (_) => 0);

    var history = await imports.watchAll().first;
    expect(history, hasLength(2));
    expect(history.first.mode, ImportMode.replace);
    expect(history.first.changes, 3); // 1 new, 2 removed
    expect(history.first.itemCount, 2); // before import 2
    expect(history.last.mode, ImportMode.add);
    expect(history.last.itemCount, 1); // before import 1

    // Restore the oldest: back to just "Original".
    expect(await imports.restore(history.last.id), isTrue);
    expect((await items.loadAll()).map((i) => i.title), ['Original']);

    // The restore itself was backed up first, so it can be undone.
    history = await imports.watchAll().first;
    expect(history.first.reason, BackupReason.restore);
    expect(history.first.itemCount, 1);
    await imports.undoLatest();
    expect((await items.loadAll()).map((i) => i.title), ['Only import 2']);
  });

  test('Undo brings back custom reminders', () async {
    final dentist = await items.create(
      type: ItemType.task,
      title: 'Dentist',
      due: DateTime(2026, 11, 20, 14),
      dueHasTime: true,
    );
    await items.save(
      dentist.copyWith(customReminders: true, reminderOffsets: [30]),
    );
    final p = await plan('{"type":"task","title":"Only"}', ImportMode.replace);
    await imports.apply(p, colorFor: (_) => 0);
    expect(await db.select(db.reminders).get(), isEmpty);

    await imports.undoLatest();
    final back = (await items.getById(dentist.id))!;
    expect(back.customReminders, isTrue);
    expect(back.reminderOffsets, [30]);
  });

  test('backups from before reminders existed still restore', () async {
    await items.create(type: ItemType.task, title: 'Old');
    final p = await plan('{"type":"task","title":"New"}', ImportMode.replace);
    await imports.apply(p, colorFor: (_) => 0);
    // Make the stored backup look like one taken by schema v3.
    final row = (await db.select(db.importBackups).get()).single;
    final data = jsonDecode(row.payload) as Map<String, dynamic>;
    for (final item in data['items'] as List) {
      (item as Map<String, dynamic>).remove('customReminders');
    }
    data.remove('reminders');
    data['reminders'] = <Object>[];
    await (db.update(db.importBackups)..where((b) => b.id.equals(row.id)))
        .write(ImportBackupsCompanion(payload: Value(jsonEncode(data))));

    expect(await imports.undoLatest(), isTrue);
    final all = await items.loadAll();
    expect(all.map((i) => i.title), ['Old']);
    expect(all.single.customReminders, isFalse);
  });

  test('only the last $maxImportBackups backups are kept', () async {
    for (var i = 0; i < maxImportBackups + 3; i++) {
      final p = await plan('{"type":"task","title":"n$i"}', ImportMode.add);
      await imports.apply(p, colorFor: (_) => 0);
    }
    expect(
      await db.select(db.importBackups).get(),
      hasLength(maxImportBackups),
    );
  });
}
