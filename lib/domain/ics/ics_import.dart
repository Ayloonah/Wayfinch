import '../dates.dart';
import '../exchange/exchange_model.dart';
import '../exchange/import_plan.dart';
import '../item.dart';
import '../item_enums.dart';
import '../item_tree.dart';
import '../recurrence.dart';
import 'ics_parser.dart';

/// The UID suffix Wayfinch writes for its own items on export, so a
/// re-import of an exported file matches the original items.
const wayfinchUidSuffix = '@wayfinch';

/// The preview of a calendar import, and how to apply it.
///
/// Calendar imports only add and update: events are matched to existing
/// items by their calendar UID (or the Wayfinch id in an exported file), and
/// nothing is ever removed.
class IcsImportPlan {
  const IcsImportPlan._(
    this._writes, {
    required this.changes,
    required this.unchangedCount,
    required this.pastCount,
  });

  /// Preview entries: new events, then updated ones.
  final List<PlannedChange> changes;

  /// Events already in the list with nothing to update.
  final int unchangedCount;

  /// Events that ended before today and were left out.
  final int pastCount;

  final ImportChanges _writes;

  /// New events.
  Iterable<AddedItem> get added => changes.whereType<AddedItem>();

  /// Updated events.
  Iterable<ChangedItem> get updated => changes.whereType<ChangedItem>();

  /// Number of items the import touches.
  int get count => changes.length;

  /// What applying the plan writes to the database.
  ImportChanges build() => _writes;
}

/// Compares calendar [events] with the current list.
///
/// - Events that ended before today are left out unless [includePast]; a
///   repeating event counts as past only when its rule has run out.
/// - A matching event (same UID) updates the existing item's title, times,
///   notes and repeat rule; tags, priority, subtasks and reminders stay.
///   Matching tasks (exported as events) are left alone.
/// - Everything else becomes a new top-level event. [untitled] names events
///   without a title.
IcsImportPlan planIcsImport({
  required ItemTree tree,
  required List<IcsEvent> events,
  required DateTime now,
  required bool includePast,
  required String untitled,
  required String Function() newId,
}) {
  final today = startOfDay(now);
  final byUid = <String, Item>{
    for (final i in tree.all)
      if (i.icsUid != null) i.icsUid!: i,
  };
  Item? match(IcsEvent e) {
    final direct = byUid[e.uid];
    if (direct != null) return direct;
    if (e.uid.endsWith(wayfinchUidSuffix)) {
      return tree[e.uid.substring(0, e.uid.length - wayfinchUidSuffix.length)];
    }
    return null;
  }

  bool isPast(IcsEvent e) {
    if (e.end.isAfter(today)) return false;
    final rule = e.rrule;
    if (rule == null) return true;
    return nextOccurrenceEndingAfter(
          rule,
          e.start,
          e.end.difference(e.start),
          today,
        ) ==
        null;
  }

  var nextOrder =
      tree.all
          .where((i) => i.parentId == null)
          .fold<int>(-1, (m, i) => i.sortOrder > m ? i.sortOrder : m) +
      1;
  final added = <AddedItem>[];
  final changed = <ChangedItem>[];
  final created = <Item>[];
  final updated = <Item>[];
  var unchanged = 0;
  var past = 0;

  for (final e in events) {
    if (!includePast && isPast(e)) {
      past++;
      continue;
    }
    final title = e.title.isEmpty ? untitled : e.title;
    final existing = match(e);
    if (existing == null) {
      added.add(AddedItem(title, 0, source: _exchangeItem(e, title)));
      created.add(
        Item(
          id: newId(),
          type: ItemType.event,
          title: title,
          notes: e.description,
          start: e.start,
          end: e.end,
          recurrence: e.rrule,
          sortOrder: nextOrder++,
          source: ItemSource.icsImport,
          icsUid: e.uid,
          createdAt: now,
          updatedAt: now,
        ),
      );
      continue;
    }
    if (!existing.isEvent) {
      unchanged++;
      continue;
    }
    final fields = <FieldChange>[
      if (title != existing.title) TitleChange(existing.title, title),
      if (e.start != existing.start)
        DateChange(
          DateField.start,
          _date(existing.start),
          ExchangeDate(e.start, hasTime: true),
        ),
      if (e.end != existing.end)
        DateChange(
          DateField.end,
          _date(existing.end),
          ExchangeDate(e.end, hasTime: true),
        ),
      if ((e.description ?? '') != (existing.notes ?? '')) const NotesChange(),
      if ((e.rrule ?? '').toUpperCase() !=
          (existing.recurrence ?? '').toUpperCase())
        RecurrenceChange(existing.recurrence, e.rrule),
    ];
    if (fields.isEmpty) {
      unchanged++;
      continue;
    }
    changed.add(ChangedItem(title, 0, before: existing, fields: fields));
    updated.add(
      existing.copyWith(
        title: title,
        start: e.start,
        end: e.end,
        notes: e.description,
        recurrence: e.rrule,
      ),
    );
  }

  return IcsImportPlan._(
    ImportChanges(updated: updated, created: created, deletedIds: const []),
    changes: [...added, ...changed],
    unchangedCount: unchanged,
    pastCount: past,
  );
}

ExchangeDate? _date(DateTime? d) =>
    d == null ? null : ExchangeDate(d, hasTime: true);

ExchangeItem _exchangeItem(IcsEvent e, String title) => ExchangeItem(
  id: null,
  type: ItemType.event,
  title: title,
  present: const {'type', 'title', 'start', 'end'},
  notes: e.description,
  start: ExchangeDate(e.start, hasTime: !e.allDay),
  end: ExchangeDate(e.end, hasTime: !e.allDay),
  recurrence: e.rrule,
  path: '',
);
