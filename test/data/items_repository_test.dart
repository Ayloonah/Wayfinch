import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/data/database.dart';
import 'package:wayfinch/data/items_repository.dart';
import 'package:wayfinch/domain/item_enums.dart';

void main() {
  late WayfinchDatabase db;
  late ItemsRepository repo;
  late DateTime now;

  setUp(() {
    db = WayfinchDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 15, 9);
    repo = ItemsRepository(db, clock: () => now);
  });

  tearDown(() => db.close());

  ItemsCompanion task(String title, {String? parentId, int order = 0}) =>
      ItemsCompanion.insert(
        type: ItemType.task,
        title: title,
        parentId: Value(parentId),
        sortOrder: Value(order),
      );

  test('create assigns a UUID, timestamps and defaults', () async {
    final item = await repo.create(task('Buy milk'));

    expect(
      item.id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(item.createdAt, now);
    expect(item.updatedAt, now);
    expect(item.priority, Priority.none);
    expect(item.source, ItemSource.manual);
    expect(item.doneAt, isNull);
  });

  test('create keeps an id that is given (e.g. from an import)', () async {
    final item = await repo.create(
      task('Kept').copyWith(id: const Value('a1b2')),
    );

    expect(item.id, 'a1b2');
  });

  test('each item gets a different id', () async {
    final a = await repo.create(task('A'));
    final b = await repo.create(task('B'));

    expect(a.id, isNot(b.id));
  });

  test('update bumps updatedAt but never id or createdAt', () async {
    final item = await repo.create(task('Draft'));
    now = now.add(const Duration(hours: 1));

    final updated = await repo.update(
      item.id,
      ItemsCompanion(
        title: const Value('Final'),
        id: const Value('hijacked'),
        createdAt: Value(DateTime(2000)),
      ),
    );

    expect(updated.id, item.id);
    expect(updated.title, 'Final');
    expect(updated.createdAt, item.createdAt);
    expect(updated.updatedAt, now);
  });

  test('update of a missing item throws', () async {
    expect(
      repo.update('nope', const ItemsCompanion(title: Value('x'))),
      throwsStateError,
    );
  });

  test('items nest deeper than the UI shows', () async {
    String? parent;
    for (var depth = 0; depth < 8; depth++) {
      parent = (await repo.create(task('Level $depth', parentId: parent))).id;
    }
    final deepest = await repo.getById(parent!);

    expect(deepest!.title, 'Level 7');
  });

  test('children come back in manual order', () async {
    final parent = await repo.create(task('Parent'));
    await repo.create(task('Second', parentId: parent.id, order: 2));
    await repo.create(task('First', parentId: parent.id, order: 1));
    await repo.create(task('Top level'));

    final kids = await repo.children(parent.id);
    final top = await repo.children(null);

    expect(kids.map((i) => i.title), ['First', 'Second']);
    expect(top.map((i) => i.title), containsAll(['Parent', 'Top level']));
    expect(top, hasLength(2));
  });

  test('watchCount follows inserts', () async {
    final counts = repo.watchCount();
    expect(await counts.first, 0);

    await repo.create(task('One'));
    expect(await counts.first, 1);
  });

  test('deleting an item cascades to its tags and reminders', () async {
    final item = await repo.create(task('Tagged'));
    final tag = await db
        .into(db.tags)
        .insertReturning(
          TagsCompanion.insert(name: 'school', color: 0xFF60A3EB),
        );
    await db
        .into(db.itemTags)
        .insert(ItemTagsCompanion.insert(itemId: item.id, tagId: tag.id));
    await db
        .into(db.reminders)
        .insert(RemindersCompanion.insert(itemId: item.id, offsetMinutes: 60));

    await (db.delete(db.items)..where((t) => t.id.equals(item.id))).go();

    expect(await db.select(db.itemTags).get(), isEmpty);
    expect(await db.select(db.reminders).get(), isEmpty);
    expect(await db.select(db.tags).get(), hasLength(1));
  });

  test('date-times round-trip', () async {
    final due = DateTime(2026, 12, 5, 23, 59);
    final item = await repo.create(
      task('Report').copyWith(due: Value(due), dueHasTime: const Value(true)),
    );

    final loaded = await repo.getById(item.id);
    expect(loaded!.due, due);
    expect(loaded.dueHasTime, isTrue);
  });
}
