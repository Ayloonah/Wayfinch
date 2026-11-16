import 'dates.dart';
import 'item.dart';
import 'item_tree.dart';
import 'overdue.dart';
import 'sorting.dart';

/// The list views.
enum AppView {
  /// Overdue, then today's tasks and events.
  today,

  /// The next 7 days, grouped by day.
  upcoming,

  /// The full tree.
  all,

  /// Completed items.
  done,

  /// Open items with one tag, or the overdue auto tag.
  tag,
}

/// The id of the "overdue" auto tag. It is computed, never stored, and users
/// can't assign or delete it.
const overdueTagId = '__overdue__';

/// Kinds of section headers in a list.
enum SectionKind {
  /// Overdue tasks (warning color).
  overdue,

  /// Today's items.
  today,

  /// One day in Upcoming (see [SectionHeader.day]).
  day,
}

/// One row of a list view.
sealed class ListEntry {
  const ListEntry();
}

/// A section title like "Overdue 3".
class SectionHeader extends ListEntry {
  /// Creates a header.
  const SectionHeader(this.kind, this.count, {this.day});

  /// Which section.
  final SectionKind kind;

  /// Number of top-level rows in the section.
  final int count;

  /// The day, for [SectionKind.day].
  final DateTime? day;
}

/// An item row.
class ItemEntry extends ListEntry {
  /// Creates an item row.
  const ItemEntry({
    required this.item,
    required this.depth,
    required this.isOverdue,
    this.subtasksDone = 0,
    this.subtasksTotal = 0,
  });

  /// The item.
  final Item item;

  /// Nesting depth in this list (0 = top).
  final int depth;

  /// Whether it's overdue right now.
  final bool isOverdue;

  /// Done subtasks (leaves only; see [subtaskProgress]).
  final int subtasksDone;

  /// All subtasks (leaves only; see [subtaskProgress]).
  final int subtasksTotal;
}

/// Subtask progress of item [id]: its leaf subtasks at every depth (tasks
/// with no subtasks of their own), and how many are done. Inner parents
/// aren't counted, so "2 of 5" means five real steps.
({int done, int total}) subtaskProgress(ItemTree tree, String id) {
  var done = 0;
  var total = 0;
  for (final d in tree.descendantsOf(id)) {
    if (!d.isTask) continue;
    if (tree.childrenOf(d.id).any((c) => c.isTask)) continue;
    total++;
    if (d.isDone) done++;
  }
  return (done: done, total: total);
}

/// Number of top-level rows in [entries]: the items a list "has" (their
/// subtasks show as progress instead). Every count in the app uses this.
int topLevelCount(Iterable<ListEntry> entries) =>
    entries.whereType<ItemEntry>().where((e) => e.depth == 0).length;

/// "2 completed subtasks hidden · Show" (or "Hide" when [shown]).
class HiddenDoneEntry extends ListEntry {
  /// Creates the row.
  const HiddenDoneEntry({
    required this.parentId,
    required this.count,
    required this.depth,
    required this.shown,
  });

  /// The parent whose done subtasks are hidden.
  final String parentId;

  /// How many.
  final int count;

  /// Depth of the subtasks.
  final int depth;

  /// Whether they're currently shown.
  final bool shown;
}

/// A built list view.
class ViewData {
  /// Creates view data.
  const ViewData(this.entries, {this.count = 0, this.doneThisWeek = 0});

  /// Rows in order.
  final List<ListEntry> entries;

  /// Number of top-level rows (see [topLevelCount]); used for the sidebar
  /// and the view's subtitle.
  final int count;

  /// Tasks completed since Monday (Done view stat).
  final int doneThisWeek;
}

/// Builds list views from an [ItemTree] at a given moment.
class ViewBuilder {
  /// Creates a builder. [showDoneFor] holds parents whose done subtasks are
  /// expanded.
  ViewBuilder(this.tree, this.now, {Set<String>? showDoneFor})
    : showDoneFor = showDoneFor ?? const {};

  /// All items.
  final ItemTree tree;

  /// The current moment.
  final DateTime now;

  /// Parents whose completed subtasks are shown.
  final Set<String> showDoneFor;

  /// Builds [view].
  ///
  /// [tagId] is used by [AppView.tag].
  ViewData build(AppView view, {String? tagId}) => switch (view) {
    AppView.today => today(),
    AppView.upcoming => upcoming(),
    AppView.all => all(),
    AppView.done => done(),
    AppView.tag => tag(tagId ?? overdueTagId),
  };

  /// Open items carrying tag [tagId], as trees. For [overdueTagId], every
  /// overdue item.
  ViewData tag(String tagId) {
    final matched = tree.all.where((i) {
      if (!i.isVisible(now)) return false;
      return tagId == overdueTagId ? _isOverdue(i) : i.tagIds.contains(tagId);
    }).toList();
    final entries = _forest(matched);
    return ViewData(entries, count: topLevelCount(entries));
  }

  /// Overdue section, then today's tasks and events.
  ViewData today() {
    final todayStart = startOfDay(now);
    final tomorrow = addDays(todayStart, 1);
    final overdue = <Item>[];
    final todays = <Item>[];
    for (final item in tree.all) {
      if (!item.isVisible(now)) continue;
      if (_isOverdue(item)) {
        overdue.add(item);
      } else if (_occursBetween(item, todayStart, tomorrow)) {
        todays.add(item);
      }
    }
    // Each item shows once: an overdue subtask of a parent due today only
    // shows in Overdue, and a subtask due today of an overdue parent only
    // in Today.
    final overdueIds = {for (final i in overdue) i.id};
    final todayIds = {for (final i in todays) i.id};
    final entries = <ListEntry>[];
    var count = 0;
    void section(SectionKind kind, List<Item> items, Set<String> elsewhere) {
      if (items.isEmpty) return;
      final rows = _forest(items, shownElsewhere: elsewhere);
      final n = topLevelCount(rows);
      count += n;
      entries
        ..add(SectionHeader(kind, n))
        ..addAll(rows);
    }

    section(SectionKind.overdue, overdue, todayIds);
    section(SectionKind.today, todays, overdueIds);
    return ViewData(entries, count: count);
  }

  /// The next 7 days after today, one section per day that has items.
  ViewData upcoming() {
    final entries = <ListEntry>[];
    var count = 0;
    final todayStart = startOfDay(now);
    final days = <(DateTime, List<Item>)>[];
    for (var offset = 1; offset <= 7; offset++) {
      final day = addDays(todayStart, offset);
      final next = addDays(todayStart, offset + 1);
      final matched = tree.all
          .where((i) => i.isVisible(now) && _startsOrDueBetween(i, day, next))
          .toList();
      if (matched.isNotEmpty) days.add((day, matched));
    }
    // Each item shows once, under its own day.
    final allMatched = {
      for (final (_, items) in days)
        for (final i in items) i.id,
    };
    for (final (day, matched) in days) {
      final own = {for (final i in matched) i.id};
      final rows = _forest(matched, shownElsewhere: allMatched.difference(own));
      final n = topLevelCount(rows);
      count += n;
      entries
        ..add(SectionHeader(SectionKind.day, n, day: day))
        ..addAll(rows);
    }
    return ViewData(entries, count: count);
  }

  /// Every open item, as a tree.
  ViewData all() {
    final visible = tree.all.where((i) => i.isVisible(now)).toList();
    final entries = _forest(visible);
    return ViewData(entries, count: topLevelCount(entries));
  }

  /// Completed tasks and ended events, most recent first.
  ViewData done() {
    final items = tree.all.where((i) => i.isDone || i.isEnded(now)).toList()
      ..sort((a, b) => _finishedAt(b).compareTo(_finishedAt(a)));
    final weekStart = startOfWeek(now);
    final thisWeek = tree.all
        .where((i) => i.isDone && !i.doneAt!.isBefore(weekStart))
        .length;
    return ViewData(
      [for (final item in items) _entry(item, 0)],
      count: items.length,
      doneThisWeek: thisWeek,
    );
  }

  /// Renders [matched] items as trees: each matched item shows with its
  /// visible subtasks, unless it already shows under a matched ancestor.
  /// Subtasks in [shownElsewhere] are left out (another section shows them).
  List<ListEntry> _forest(
    List<Item> matched, {
    Set<String> shownElsewhere = const {},
  }) {
    final matchedIds = {for (final m in matched) m.id};
    final roots =
        matched
            .where((m) => !_coveredBy(m, matchedIds, shownElsewhere))
            .toList()
          ..sort(compareItems);
    final entries = <ListEntry>[];
    for (final root in roots) {
      _subtree(root, 0, entries, shownElsewhere);
    }
    return entries;
  }

  /// Whether [item] already appears inside a matched ancestor's subtree
  /// (every item between them is visible and not shown elsewhere).
  bool _coveredBy(
    Item item,
    Set<String> matchedIds,
    Set<String> shownElsewhere,
  ) {
    var parent = tree[item.parentId];
    while (parent != null) {
      if (!parent.isVisible(now)) return false;
      if (shownElsewhere.contains(parent.id)) return false;
      if (matchedIds.contains(parent.id)) return true;
      parent = tree[parent.parentId];
    }
    return false;
  }

  void _subtree(
    Item item,
    int depth,
    List<ListEntry> out,
    Set<String> shownElsewhere,
  ) {
    out.add(_entry(item, depth));
    final children = tree.childrenOf(item.id);
    for (final child in children) {
      if (child.isVisible(now) && !shownElsewhere.contains(child.id)) {
        _subtree(child, depth + 1, out, shownElsewhere);
      }
    }
    final doneChildren = children.where((c) => !c.isVisible(now)).toList();
    if (doneChildren.isEmpty) return;
    final shown = showDoneFor.contains(item.id);
    if (shown) {
      for (final child in doneChildren) {
        out.add(_entry(child, depth + 1));
      }
    }
    out.add(
      HiddenDoneEntry(
        parentId: item.id,
        count: doneChildren.length,
        depth: depth + 1,
        shown: shown,
      ),
    );
  }

  ItemEntry _entry(Item item, int depth) {
    final progress = subtaskProgress(tree, item.id);
    return ItemEntry(
      item: item,
      depth: depth,
      isOverdue: _isOverdue(item),
      subtasksDone: progress.done,
      subtasksTotal: progress.total,
    );
  }

  bool _isOverdue(Item item) => isOverdue(
    type: item.type,
    due: item.due,
    dueHasTime: item.dueHasTime,
    doneAt: item.doneAt,
    now: now,
  );

  /// Tasks due in [from, to); events overlapping it.
  bool _occursBetween(Item item, DateTime from, DateTime to) {
    if (item.isTask) return _inRange(item.due, from, to);
    final start = item.start;
    final end = item.end ?? start;
    if (start == null || end == null) return false;
    return start.isBefore(to) && end.isAfter(from);
  }

  /// Tasks due in [from, to); events starting in it.
  bool _startsOrDueBetween(Item item, DateTime from, DateTime to) =>
      _inRange(item.isTask ? item.due : item.start, from, to);

  bool _inRange(DateTime? dt, DateTime from, DateTime to) =>
      dt != null && !dt.isBefore(from) && dt.isBefore(to);

  DateTime _finishedAt(Item item) => item.doneAt ?? item.end ?? item.updatedAt;
}
