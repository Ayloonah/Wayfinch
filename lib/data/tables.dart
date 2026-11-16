import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/item_enums.dart';

const _uuid = Uuid();

/// Generates a new random (v4) UUID for a row id.
String newId() => _uuid.v4();

/// Every task and event. Items nest through [parentId] without a depth limit.
///
/// Ids are stable UUIDs: they survive AI round trips and future sync, so they
/// must never be reused or regenerated.
@DataClassName('ItemRow')
@TableIndex(name: 'items_parent_id', columns: {#parentId})
@TableIndex(name: 'items_due', columns: {#due})
@TableIndex(name: 'items_ics_uid', columns: {#icsUid})
class Items extends Table {
  /// Stable UUID, assigned once on creation.
  TextColumn get id => text().clientDefault(newId)();

  /// Task or event.
  TextColumn get type => textEnum<ItemType>()();

  /// Short title shown in lists.
  TextColumn get title => text()();

  /// Optional free-text notes.
  TextColumn get notes => text().nullable()();

  /// When a task is due. Null for events and for tasks without a due date.
  DateTimeColumn get due => dateTime().nullable()();

  /// Whether [due] includes a time of day. When false, only the date counts.
  BoolColumn get dueHasTime => boolean().withDefault(const Constant(false))();

  /// When an event starts. Null for tasks.
  DateTimeColumn get start => dateTime().nullable()();

  /// When an event ends. Null for tasks.
  DateTimeColumn get end => dateTime().nullable()();

  /// Importance of the item.
  TextColumn get priority =>
      textEnum<Priority>().withDefault(Constant(Priority.none.name))();

  /// iCal RRULE string (e.g. `FREQ=WEEKLY;BYDAY=MO`), or null if it doesn't repeat.
  TextColumn get recurrence => text().nullable()();

  /// Parent item id, or null for top-level items.
  TextColumn get parentId => text().nullable().references(Items, #id)();

  /// Manual order among siblings (lower comes first).
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// When a task was marked done, or null while it is open.
  DateTimeColumn get doneAt => dateTime().nullable()();

  /// Where the item came from.
  TextColumn get source =>
      textEnum<ItemSource>().withDefault(Constant(ItemSource.manual.name))();

  /// The VEVENT UID for items from an .ics import, used to match re-imports.
  TextColumn get icsUid => text().nullable()();

  /// When the item was created.
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  /// When the item was last changed.
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// User-created tags. The "overdue" auto tag is computed and never stored here.
@DataClassName('TagRow')
class Tags extends Table {
  /// Stable UUID.
  TextColumn get id => text().clientDefault(newId)();

  /// Display name, unique among tags.
  TextColumn get name => text().unique()();

  /// Tag color as a 32-bit ARGB value.
  IntColumn get color => integer()();

  /// When the tag was created.
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  /// When the tag was last changed.
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Which tags are on which items (many-to-many).
@DataClassName('ItemTagRow')
class ItemTags extends Table {
  /// The tagged item.
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();

  /// The tag applied to it.
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {itemId, tagId};
}

/// Reminders for an item, as offsets before its due (task) or start (event).
@DataClassName('ReminderRow')
class Reminders extends Table {
  /// Stable UUID.
  TextColumn get id => text().clientDefault(newId)();

  /// The item this reminder belongs to.
  TextColumn get itemId =>
      text().references(Items, #id, onDelete: KeyAction.cascade)();

  /// How many minutes before due/start to remind (0 = at that moment).
  IntColumn get offsetMinutes => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Small key/value app settings (e.g. which prompts are set to "Always").
/// Added in schema version 2.
@DataClassName('SettingRow')
class Settings extends Table {
  /// Setting name.
  TextColumn get key => text()();

  /// Setting value, as text.
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
