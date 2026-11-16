import 'item.dart';
import 'item_tree.dart';
import 'overdue.dart';
import 'recurrence.dart';

/// The three situations that ask before acting (Confirm / Cancel / Always).
enum PromptKind {
  /// A subtask's due date moves past its parent's: push the parent's too.
  pushParentDue,

  /// A parent is marked done with open subtasks: close them too.
  closeSubtasks,

  /// The last open subtask is marked done: mark the parent done too?
  completeParent,
}

/// The user's answer to a prompt.
enum PromptAnswer {
  /// Do it this time.
  confirm,

  /// Don't.
  cancel,

  /// Do it, and stop asking (can be undone in Settings).
  always,
}

/// Asks the user a [PromptKind] question. [count] is the number of items
/// affected (e.g. open subtasks), for the message.
typedef PromptAsker = Future<PromptAnswer> Function(PromptKind kind, int count);

/// Remembers which prompts the user answered with "Always do this".
abstract interface class PromptPreferences {
  /// Whether [kind] should be done without asking.
  Future<bool> isAlways(PromptKind kind);

  /// Stops asking about [kind].
  Future<void> setAlways(PromptKind kind);
}

/// The result of a rule: items to update and items to create. Apply both in
/// one transaction.
class ItemChanges {
  /// Creates a change set.
  ItemChanges({List<Item>? updated, List<Item>? created})
    : updated = updated ?? [],
      created = created ?? [];

  /// Existing items, in their new state.
  final List<Item> updated;

  /// New items (with fresh ids).
  final List<Item> created;

  /// Whether nothing changes.
  bool get isEmpty => updated.isEmpty && created.isEmpty;
}

/// Completion, due-date and recurrence rules from the spec.
///
/// Pure domain logic: it reads an [ItemTree] and returns [ItemChanges];
/// saving them is the repository's job.
class ItemRules {
  /// Creates the rules. [newId] makes ids for new occurrences.
  ItemRules({
    required this.preferences,
    required this.ask,
    required this.newId,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Where "Always do this" choices are kept.
  final PromptPreferences preferences;

  /// Shows a prompt.
  final PromptAsker ask;

  /// Generates new item ids.
  final String Function() newId;

  final DateTime Function() _clock;

  /// Marks task [id] done, following the spec:
  ///
  /// - open subtasks? ask to close them too (Cancel aborts everything);
  /// - recurring? create the next occurrence (with fresh copies of its
  ///   subtasks, reopened and shifted);
  /// - was it its parent's last open subtask? ask to mark the parent done too,
  ///   and so on up the tree.
  ///
  /// Returns null when the user cancelled, an empty change set when there's
  /// nothing to do.
  Future<ItemChanges?> complete(ItemTree tree, String id) async {
    final item = tree[id];
    if (item == null || !item.isTask || item.isDone) return ItemChanges();
    final now = _clock();
    final state = _Working(tree);

    final openSubtasks = tree
        .descendantsOf(id)
        .where((d) => d.isTask && d.doneAt == null)
        .toList();
    if (openSubtasks.isNotEmpty &&
        !await _confirm(PromptKind.closeSubtasks, openSubtasks.length)) {
      return null;
    }
    for (final sub in openSubtasks) {
      state.update(sub.copyWith(doneAt: now, updatedAt: now));
    }
    _markDone(state, item, now);

    var parent = tree[item.parentId];
    while (parent != null && parent.isTask && parent.doneAt == null) {
      final siblings = tree.childrenOf(parent.id).where((c) => c.isTask);
      final allDone = siblings.every((c) => state[c.id].doneAt != null);
      if (!allDone) break;
      if (!await _confirm(PromptKind.completeParent, 1)) break;
      _markDone(state, state[parent.id], now);
      parent = tree[parent.parentId];
    }
    return state.changes;
  }

  /// Reopens a done task. Its parent and subtasks are left as they are.
  ItemChanges reopen(ItemTree tree, String id) {
    final item = tree[id];
    if (item == null || !item.isDone) return ItemChanges();
    final now = _clock();
    return ItemChanges(updated: [item.copyWith(doneAt: null, updatedAt: now)]);
  }

  /// Sets task [id]'s due date. If that moves it past its parent's due date,
  /// asks to push the parent's (and any further ancestors') due date along.
  ///
  /// Returns null when the user cancelled (nothing changes at all).
  Future<ItemChanges?> setDue(
    ItemTree tree,
    String id, {
    required DateTime? due,
    required bool hasTime,
  }) async {
    final item = tree[id];
    if (item == null) return ItemChanges();
    final now = _clock();
    final updated = item.copyWith(
      due: due,
      dueHasTime: due != null && hasTime,
      updatedAt: now,
    );
    final changes = ItemChanges(updated: [updated]);
    if (due == null) return changes;

    final moment = effectiveDueMoment(due: due, dueHasTime: hasTime);
    final toPush = <Item>[];
    for (final ancestor in tree.ancestorsOf(id)) {
      final ancestorDue = ancestor.due;
      if (!ancestor.isTask || ancestorDue == null) break;
      final ancestorMoment = effectiveDueMoment(
        due: ancestorDue,
        dueHasTime: ancestor.dueHasTime,
      );
      if (!moment.isAfter(ancestorMoment)) break;
      toPush.add(ancestor);
    }
    if (toPush.isEmpty) return changes;
    if (!await _confirm(PromptKind.pushParentDue, toPush.length)) return null;
    for (final ancestor in toPush) {
      changes.updated.add(
        ancestor.copyWith(due: due, dueHasTime: hasTime, updatedAt: now),
      );
    }
    return changes;
  }

  /// Moves recurring events whose end has passed forward: the ended one stays
  /// (it shows in Done) without its repeat rule, and the next occurrence that
  /// hasn't ended yet is created. No prompts.
  ItemChanges rollEndedEvents(ItemTree tree) {
    final now = _clock();
    final state = _Working(tree);
    for (final event in tree.all) {
      final start = event.start;
      final end = event.end;
      if (!event.isEvent || !event.isRecurring || start == null) continue;
      if (end == null || end.isAfter(now)) continue;
      final next = nextOccurrenceEndingAfter(
        event.recurrence!,
        start,
        end.difference(start),
        now,
      );
      state.update(event.copyWith(recurrence: null, updatedAt: now));
      if (next != null) _spawn(state, event, next, start, now);
    }
    return state.changes;
  }

  void _markDone(_Working state, Item item, DateTime now) {
    final rrule = item.recurrence;
    if (!item.isRecurring) {
      state.update(item.copyWith(doneAt: now, updatedAt: now));
      return;
    }
    // A recurring task's rule moves to the next occurrence, so completing
    // (or reopening and re-completing) the old one never repeats it twice.
    state.update(item.copyWith(doneAt: now, recurrence: null, updatedAt: now));
    final anchor = item.due ?? now;
    final next = nextOccurrence(rrule!, anchor);
    if (next != null) _spawn(state, item, next, anchor, now);
  }

  /// Creates the next occurrence of [item] (and fresh, open copies of its
  /// subtree) moved from [from] to [next].
  void _spawn(
    _Working state,
    Item item,
    NextOccurrence next,
    DateTime from,
    DateTime now,
  ) {
    DateTime? shift(DateTime? dt) =>
        dt == null ? null : shiftLike(dt, from, next.anchor);

    final copyId = newId();
    final Item copy;
    if (item.isEvent) {
      final duration = item.end!.difference(item.start!);
      copy = item.copyWith(
        id: copyId,
        start: next.anchor,
        end: next.anchor.add(duration),
      );
    } else {
      copy = item.copyWith(
        id: copyId,
        due: item.due == null ? null : next.anchor,
        doneAt: null,
      );
    }
    state.create(
      copy.copyWith(
        recurrence: next.rrule,
        icsUid: null,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final idMap = {item.id: copyId};
    for (final sub in state.tree.descendantsOf(item.id)) {
      final subId = newId();
      idMap[sub.id] = subId;
      state.create(
        sub.copyWith(
          id: subId,
          parentId: idMap[sub.parentId],
          due: shift(sub.due),
          start: shift(sub.start),
          end: shift(sub.end),
          doneAt: null,
          icsUid: null,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  Future<bool> _confirm(PromptKind kind, int count) async {
    if (await preferences.isAlways(kind)) return true;
    final answer = await ask(kind, count);
    if (answer == PromptAnswer.always) await preferences.setAlways(kind);
    return answer != PromptAnswer.cancel;
  }
}

/// Tracks pending changes on top of a tree.
class _Working {
  _Working(this.tree);

  final ItemTree tree;
  final Map<String, Item> _updated = {};
  final List<Item> _created = [];

  Item operator [](String id) => _updated[id] ?? tree[id]!;

  void update(Item item) => _updated[item.id] = item;

  void create(Item item) => _created.add(item);

  ItemChanges get changes =>
      ItemChanges(updated: _updated.values.toList(), created: _created);
}
