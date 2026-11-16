import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../data/database.dart' show newId;
import '../../data/items_repository.dart';
import '../../data/settings_repository.dart';
import '../../data/tags_repository.dart';
import '../../domain/dates.dart';
import '../../domain/item.dart';
import '../../domain/item_enums.dart';
import '../../domain/item_rules.dart';
import '../../domain/item_tree.dart';
import '../../domain/quick_add_parser.dart';
import '../../domain/views.dart';
import '../theme/tokens.dart';

/// Sidebar destinations.
enum Destination {
  /// Today view.
  today,

  /// Upcoming view.
  upcoming,

  /// All view.
  all,

  /// Done view.
  done,

  /// Settings.
  settings;

  /// The list view for this destination, or null for settings.
  AppView? get view => switch (this) {
    today => AppView.today,
    upcoming => AppView.upcoming,
    all => AppView.all,
    done => AppView.done,
    settings => null,
  };
}

/// State and actions for the main screen.
///
/// Listens to the repositories, keeps the current destination and selection,
/// and routes every change through [ItemRules] so prompts and recurrence
/// apply everywhere.
class HomeController extends ChangeNotifier {
  /// Creates the controller. [clock] is injectable for tests.
  HomeController({
    required this.items,
    required this.tags,
    required this.settings,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _now = _clock();
    _subscriptions = [
      items.watchAll().listen(_onItems),
      tags.watchAll().listen((list) {
        _tags = {for (final t in list) t.id: t};
        notifyListeners();
      }),
      settings.watchRemembered().listen((map) {
        _remembered = map;
        notifyListeners();
      }),
    ];
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) => tick());
  }

  /// Item storage.
  final ItemsRepository items;

  /// Tag storage.
  final TagsRepository tags;

  /// Settings storage.
  final SettingsRepository settings;

  final DateTime Function() _clock;
  late final List<StreamSubscription<Object?>> _subscriptions;
  late final Timer _ticker;

  /// Shows a Confirm / Cancel / Always prompt. Set by the screen.
  PromptAsker asker = (kind, count) async => PromptResult.dismissed;

  ItemTree _tree = ItemTree(const []);
  Map<String, Tag> _tags = {};
  Map<PromptKind, PromptAnswer?> _remembered = const {};
  bool _loaded = false;
  late DateTime _now;
  Destination _destination = Destination.today;
  String? _selectedId;
  final Set<String> _showDoneFor = {};

  /// Whether the first load from the database finished.
  bool get loaded => _loaded;

  /// The current moment (refreshed every 30 seconds).
  DateTime get now => _now;

  /// All items.
  ItemTree get tree => _tree;

  /// Tags by id.
  Map<String, Tag> get tagsById => _tags;

  /// Remembered prompt answers (missing or null = ask).
  Map<PromptKind, PromptAnswer?> get remembered => _remembered;

  /// The selected sidebar destination.
  Destination get destination => _destination;

  /// The selected item, if it still exists.
  Item? get selected => _tree[_selectedId];

  /// Builds a list view for the current state.
  ViewData view(AppView view) =>
      ViewBuilder(_tree, _now, showDoneFor: _showDoneFor).build(view);

  ItemRules get _rules =>
      ItemRules(preferences: settings, ask: asker, newId: newId, clock: _clock);

  void _onItems(List<Item> list) {
    final firstLoad = !_loaded;
    _tree = ItemTree(list);
    _loaded = true;
    notifyListeners();
    if (firstLoad) unawaited(tick());
  }

  /// Refreshes "now" (overdue, today) and rolls ended recurring events.
  Future<void> tick() async {
    _now = _clock();
    notifyListeners();
    await items.apply(_rules.rollEndedEvents(_tree));
  }

  /// Opens [destination].
  void go(Destination destination) {
    _destination = destination;
    notifyListeners();
  }

  /// Selects [id] (or clears the selection).
  void select(String? id) {
    _selectedId = id;
    notifyListeners();
  }

  /// Shows or hides the completed subtasks of [parentId].
  void toggleShowDone(String parentId) {
    if (!_showDoneFor.remove(parentId)) _showDoneFor.add(parentId);
    notifyListeners();
  }

  /// Adds an item from quick-add text. In Today, items without a date are
  /// due today.
  Future<void> quickAdd(String text) async {
    if (text.trim().isEmpty) return;
    final parsed = parseQuickAdd(text, now: _clock());
    var due = parsed.due;
    if (due == null && _destination == Destination.today) {
      due = startOfDay(_clock());
    }
    final tagIds = <String>[];
    for (final name in parsed.tags) {
      tagIds.add((await tags.findOrCreate(name, colorFor: tagColorFor)).id);
    }
    await items.create(
      type: ItemType.task,
      title: parsed.title,
      due: due,
      dueHasTime: parsed.dueHasTime,
      priority: parsed.priority,
      tagIds: tagIds,
    );
  }

  /// Creates a new empty task (due today in Today) and selects it.
  Future<Item> newItem(String title) async {
    final item = await items.create(
      type: ItemType.task,
      title: title,
      due: _destination == Destination.today ? startOfDay(_clock()) : null,
    );
    _focusTitleFor = item.id;
    select(item.id);
    return item;
  }

  String? _focusTitleFor;

  /// Whether the title of [id] should get focus (once, right after "New
  /// item").
  bool takeTitleFocus(String id) {
    if (_focusTitleFor != id) return false;
    _focusTitleFor = null;
    return true;
  }

  /// Adds a subtask called [title] under [parentId] and opens it in the
  /// detail panel with its title selected, ready to edit.
  Future<Item> addSubtask(String parentId, String title) async {
    final item = await items.create(
      type: ItemType.task,
      title: title,
      parentId: parentId,
    );
    _focusTitleFor = item.id;
    select(item.id);
    return item;
  }

  /// Marks a task done (with prompts and recurrence).
  Future<void> complete(String id) async {
    final changes = await _rules.complete(_tree, id);
    if (changes != null) await items.apply(changes);
  }

  /// Reopens a done task.
  Future<void> reopen(String id) => items.apply(_rules.reopen(_tree, id));

  /// Toggles a task between done and open.
  Future<void> toggleDone(String id) =>
      _tree[id]?.isDone == true ? reopen(id) : complete(id);

  /// Sets a task's due date (may ask to push its parent's).
  Future<void> setDue(String id, DateTime? due, {required bool hasTime}) async {
    final changes = await _rules.setDue(_tree, id, due: due, hasTime: hasTime);
    if (changes != null) await items.apply(changes);
  }

  /// Saves an edited copy of an item.
  Future<void> save(Item item) => items.save(item);

  /// Switches an item between task and event, carrying the date over.
  Future<void> setType(Item item, ItemType type) async {
    if (item.type == type) return;
    if (type == ItemType.event) {
      final base = item.due ?? _clock();
      final start = item.dueHasTime
          ? base
          : DateTime(base.year, base.month, base.day, 9);
      await items.save(
        item.copyWith(
          type: type,
          start: start,
          end: start.add(const Duration(hours: 1)),
          due: null,
          dueHasTime: false,
          doneAt: null,
        ),
      );
    } else {
      await items.save(
        item.copyWith(
          type: type,
          due: item.start,
          dueHasTime: item.start != null,
          start: null,
          end: null,
        ),
      );
    }
  }

  /// Adds the tag called [name] (created if needed) to [item].
  Future<void> addTag(Item item, String name) async {
    if (name.trim().isEmpty) return;
    final tag = await tags.findOrCreate(name, colorFor: tagColorFor);
    if (item.tagIds.contains(tag.id)) return;
    await items.save(item.copyWith(tagIds: [...item.tagIds, tag.id]));
  }

  /// Removes tag [tagId] from [item].
  Future<void> removeTag(Item item, String tagId) => items.save(
    item.copyWith(tagIds: item.tagIds.where((t) => t != tagId).toList()),
  );

  /// Number of subtasks (at any depth) under [id].
  int subtaskCount(String id) => _tree.descendantsOf(id).length;

  /// Deletes an item and its subtasks. Returns what was deleted, for
  /// [undoDelete].
  Future<List<Item>> delete(String id) async {
    final item = _tree[id];
    if (item == null) return const [];
    final removed = [item, ..._tree.descendantsOf(id)];
    if (removed.any((i) => i.id == _selectedId)) _selectedId = null;
    await items.deleteWithSubtasks(id);
    return removed;
  }

  /// Puts back items returned by [delete], exactly as they were, and
  /// reselects the top one.
  Future<void> undoDelete(List<Item> removed) async {
    if (removed.isEmpty) return;
    final top = removed.first;
    // If its parent was deleted meanwhile, bring it back at the top level.
    final parentGone = top.parentId != null && _tree[top.parentId] == null;
    await items.restore([
      if (parentGone) top.copyWith(parentId: null) else top,
      ...removed.skip(1),
    ]);
    select(removed.first.id);
  }

  /// Remembers [answer] for a prompt, or asks again when null.
  Future<void> setRemembered(PromptKind kind, PromptAnswer? answer) =>
      settings.remember(kind, answer);

  @override
  void dispose() {
    _ticker.cancel();
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }
}

/// Makes a [HomeController] available to descendants.
class HomeScope extends InheritedNotifier<HomeController> {
  /// Provides [controller] to [child].
  const HomeScope({
    super.key,
    required HomeController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The nearest controller (rebuilds the caller when it changes).
  static HomeController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HomeScope>()!.notifier!;
}
