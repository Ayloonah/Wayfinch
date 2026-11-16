import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/data/database.dart';
import 'package:wayfinch/data/items_repository.dart';
import 'package:wayfinch/data/settings_repository.dart';
import 'package:wayfinch/data/tags_repository.dart';
import 'package:wayfinch/domain/item_enums.dart';
import 'package:wayfinch/domain/item_rules.dart';

void main() {
  late WayfinchDatabase db;
  late ItemsRepository repo;
  late TagsRepository tags;
  late DateTime now;

  setUp(() {
    db = WayfinchDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 15, 9);
    repo = ItemsRepository(db, clock: () => now);
    tags = TagsRepository(db, clock: () => now);
  });

  tearDown(() => db.close());

  test('create assigns a UUID, timestamps, defaults and sort order', () async {
    final a = await repo.create(type: ItemType.task, title: 'Buy milk');
    final b = await repo.create(type: ItemType.task, title: 'Bread');

    expect(
      a.id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(a.id, isNot(b.id));
    expect(a.createdAt, now);
    expect(a.updatedAt, now);
    expect(a.priority, Priority.none);
    expect(a.source, ItemSource.manual);
    expect(a.sortOrder, 0);
    expect(b.sortOrder, 1);
  });

  test('create keeps an id that is given (e.g. from an import)', () async {
    final item = await repo.create(
      type: ItemType.task,
      title: 'Kept',
      id: 'a1b2',
    );
    expect(item.id, 'a1b2');
    expect((await repo.getById('a1b2'))!.title, 'Kept');
  });

  test('save bumps updatedAt but never id or createdAt', () async {
    final item = await repo.create(type: ItemType.task, title: 'Draft');
    now = now.add(const Duration(hours: 1));

    await repo.save(item.copyWith(title: 'Final', createdAt: DateTime(2000)));
    final saved = await repo.getById(item.id);

    expect(saved!.title, 'Final');
    expect(saved.createdAt, item.createdAt);
    expect(saved.updatedAt, now);
  });

  test('saving a missing item throws', () async {
    final item = await repo.create(type: ItemType.task, title: 'x');
    await repo.deleteWithSubtasks(item.id);
    expect(repo.save(item), throwsStateError);
  });

  test('tags round-trip and are found case-insensitively', () async {
    final school = await tags.findOrCreate('school', colorFor: (_) => 1);
    final again = await tags.findOrCreate('School', colorFor: (_) => 2);
    final work = await tags.findOrCreate('work', colorFor: (n) => 100 + n);
    expect(again.id, school.id);
    expect(work.color, 101);

    final item = await repo.create(
      type: ItemType.task,
      title: 'Tagged',
      tagIds: [school.id, work.id],
    );
    expect(
      (await repo.getById(item.id))!.tagIds,
      unorderedEquals([school.id, work.id]),
    );

    await repo.save(item.copyWith(tagIds: [work.id]));
    expect((await repo.getById(item.id))!.tagIds, [work.id]);
  });

  test('items nest deeper than the UI shows', () async {
    String? parent;
    for (var depth = 0; depth < 8; depth++) {
      parent = (await repo.create(
        type: ItemType.task,
        title: 'Level $depth',
        parentId: parent,
      )).id;
    }
    expect((await repo.getById(parent!))!.title, 'Level 7');
  });

  test('deleteWithSubtasks removes the branch and its links', () async {
    final tag = await tags.findOrCreate('t', colorFor: (_) => 0);
    final p = await repo.create(
      type: ItemType.task,
      title: 'p',
      tagIds: [tag.id],
    );
    final c = await repo.create(
      type: ItemType.task,
      title: 'c',
      parentId: p.id,
    );
    await repo.create(type: ItemType.task, title: 'g', parentId: c.id);
    final other = await repo.create(type: ItemType.task, title: 'other');

    await repo.deleteWithSubtasks(p.id);

    final left = await repo.loadAll();
    expect(left.map((i) => i.id), [other.id]);
    expect(await db.select(db.itemTags).get(), isEmpty);
    expect(await tags.loadAll(), hasLength(1));
  });

  test('apply saves updates and inserts in one go', () async {
    final a = await repo.create(type: ItemType.task, title: 'a');
    now = now.add(const Duration(minutes: 5));
    await repo.apply(
      ItemChanges(
        updated: [a.copyWith(doneAt: now)],
        created: [a.copyWith(id: 'copy', doneAt: null, title: 'a again')],
      ),
    );
    final all = {for (final i in await repo.loadAll()) i.id: i};
    expect(all[a.id]!.doneAt, now);
    expect(all['copy']!.title, 'a again');
    expect(all['copy']!.createdAt, now);
  });

  test('watchAll follows changes', () async {
    final stream = repo.watchAll();
    expect(await stream.first, isEmpty);
    await repo.create(type: ItemType.task, title: 'One');
    expect((await stream.first).single.title, 'One');
  });

  test('date-times round-trip', () async {
    final due = DateTime(2026, 12, 5, 23, 59);
    final item = await repo.create(
      type: ItemType.task,
      title: 'Report',
      due: due,
      dueHasTime: true,
    );
    final loaded = await repo.getById(item.id);
    expect(loaded!.due, due);
    expect(loaded.dueHasTime, isTrue);
  });

  test('restore puts a deleted branch back exactly', () async {
    final tag = await tags.findOrCreate('t', colorFor: (_) => 0);
    final p = await repo.create(
      type: ItemType.task,
      title: 'p',
      tagIds: [tag.id],
    );
    final c = await repo.create(
      type: ItemType.task,
      title: 'c',
      parentId: p.id,
    );
    final g = await repo.create(
      type: ItemType.task,
      title: 'g',
      parentId: c.id,
    );
    final before = {for (final i in await repo.loadAll()) i.id: i};

    await repo.deleteWithSubtasks(p.id);
    now = now.add(const Duration(hours: 2));
    // Children listed first on purpose: restore must sort parents first.
    await repo.restore([before[g.id]!, before[c.id]!, before[p.id]!]);

    final after = {for (final i in await repo.loadAll()) i.id: i};
    expect(after.keys, unorderedEquals([p.id, c.id, g.id]));
    expect(after[c.id]!.parentId, p.id);
    expect(after[p.id]!.tagIds, [tag.id]);
    expect(after[p.id]!.createdAt, before[p.id]!.createdAt);
    expect(after[p.id]!.updatedAt, before[p.id]!.updatedAt);
  });

  test(
    'custom reminders round-trip, survive restore, and can be reset',
    () async {
      final item = await repo.create(
        type: ItemType.task,
        title: 'Dentist',
        due: DateTime(2026, 11, 20, 14),
        dueHasTime: true,
      );
      expect((await repo.getById(item.id))!.customReminders, isFalse);

      await repo.save(
        item.copyWith(customReminders: true, reminderOffsets: [1440, 30]),
      );
      var loaded = (await repo.getById(item.id))!;
      expect(loaded.customReminders, isTrue);
      expect(loaded.reminderOffsets, [30, 1440]);

      await repo.deleteWithSubtasks(item.id);
      await repo.restore([loaded]);
      loaded = (await repo.getById(item.id))!;
      expect(loaded.reminderOffsets, [30, 1440]);

      await repo.save(
        loaded.copyWith(customReminders: false, reminderOffsets: const []),
      );
      loaded = (await repo.getById(item.id))!;
      expect(loaded.customReminders, isFalse);
      expect(loaded.reminderOffsets, isEmpty);
      expect(await db.select(db.reminders).get(), isEmpty);
    },
  );

  group('settings', () {
    test('remembered answers persist and can be cleared', () async {
      final settings = SettingsRepository(db);
      expect(await settings.remembered(PromptKind.closeSubtasks), isNull);

      await settings.remember(PromptKind.closeSubtasks, PromptAnswer.confirm);
      await settings.remember(PromptKind.completeParent, PromptAnswer.cancel);
      expect(
        await settings.remembered(PromptKind.closeSubtasks),
        PromptAnswer.confirm,
      );
      expect(
        await settings.remembered(PromptKind.completeParent),
        PromptAnswer.cancel,
      );
      final live = await settings.watchRemembered().first;
      expect(live[PromptKind.pushParentDue], isNull);
      expect(live[PromptKind.completeParent], PromptAnswer.cancel);

      await settings.remember(PromptKind.closeSubtasks, null);
      expect(await settings.remembered(PromptKind.closeSubtasks), isNull);
    });

    test('the old "always" value still reads as Confirm', () async {
      await db
          .into(db.settings)
          .insert(
            SettingsCompanion.insert(
              key: 'prompt.always.pushParentDue',
              value: 'true',
            ),
          );
      expect(
        await SettingsRepository(db).remembered(PromptKind.pushParentDue),
        PromptAnswer.confirm,
      );
    });
  });
}
