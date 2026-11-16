import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../data/database.dart' show newId;
import '../../data/import_repository.dart';
import '../../data/items_repository.dart';
import '../../data/notification_prefs.dart';
import '../../data/settings_repository.dart';
import '../../data/tags_repository.dart';
import '../../domain/dates.dart';
import '../../domain/exchange/exchange_export.dart';
import '../../domain/exchange/exchange_model.dart';
import '../../domain/exchange/import_plan.dart';
import '../../domain/item.dart';
import '../../domain/item_enums.dart';
import '../../domain/item_rules.dart';
import '../../domain/item_tree.dart';
import '../../domain/quick_add_parser.dart';
import '../../domain/views.dart';
import '../onboarding/tutorial.dart';
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

  /// One tag's items (see [HomeController.tagFilter]).
  tag,

  /// Help.
  help,

  /// Settings.
  settings;

  /// The list view for this destination, or null for Help and Settings.
  AppView? get view => switch (this) {
    today => AppView.today,
    upcoming => AppView.upcoming,
    all => AppView.all,
    done => AppView.done,
    tag => AppView.tag,
    help || settings => null,
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
    required this.imports,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _now = _clock();
    _subscriptions = [
      imports.watchAll().listen((backups) {
        _backups = backups;
        notifyListeners();
      }),
      items.watchAll().listen(_onItems),
      tags.watchAll().listen((list) {
        _tags = {for (final t in list) t.id: t};
        notifyListeners();
      }),
      settings.watchRemembered().listen((map) {
        _remembered = map;
        notifyListeners();
      }),
      settings.watchAll().listen((values) {
        _bannerSnoozedUntil = DateTime.tryParse(values[_snoozeKey] ?? '');
        _overdueTagColor = int.tryParse(values[_overdueColorKey] ?? '');
        _firstName = values[_firstNameKey] ?? '';
        _tutorial = TutorialSteps.decode(values[_tutorialKey]);
        _notificationPrefs = NotificationPrefs.fromMap(values);
        _viewOrder = _parseViewOrder(values[_viewOrderKey]);
        _tagOrder = (values[_tagOrderKey] ?? '')
            .split(',')
            .where((s) => s.isNotEmpty)
            .toList();
        _startView =
            startViews.asNameMap()[values[_startViewKey]] ?? Destination.today;
        // Open the chosen start view once, unless the user already moved.
        if (!_startApplied) {
          _startApplied = true;
          if (!_navigated) _destination = _startView;
        }
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

  /// AI import storage (apply, backups, undo).
  final ImportRepository imports;

  List<ImportBackupInfo> _backups = const [];

  /// Stored backups, newest first (Settings › Import history).
  List<ImportBackupInfo> get backups => _backups;

  /// The latest backup if it was taken before an import (what "Undo last
  /// import" undoes), else null.
  ImportBackupInfo? get lastImport {
    final latest = _backups.firstOrNull;
    return latest?.reason == BackupReason.import ? latest : null;
  }

  /// Restores backup [id]; the current list is backed up first.
  Future<bool> restoreBackup(int id) {
    _selectedId = null;
    return imports.restore(id);
  }

  static const _exportOptionsKey = 'export.options';
  static const _instructionsKey = 'export.instructions';

  /// Saved "What to include" choices.
  Future<ExportOptions> loadExportOptions() async =>
      ExportOptions.decode(await settings.getValue(_exportOptionsKey));

  /// Saves "What to include".
  Future<void> saveExportOptions(ExportOptions options) =>
      settings.setValue(_exportOptionsKey, options.encode());

  /// Saved "My instructions" (empty by default).
  Future<String> loadInstructions() async =>
      await settings.getValue(_instructionsKey) ?? '';

  /// Saves "My instructions".
  Future<void> saveInstructions(String text) =>
      settings.setValue(_instructionsKey, text.isEmpty ? null : text);

  /// The "My list" JSON for [options].
  ExportResult exportList(ExportOptions options) =>
      buildExportJson(_tree, _tags, options, _clock());

  /// Counts for the export checkboxes.
  ExportCounts get exportItemCounts => exportCounts(_tree, _clock());

  /// Plans importing [doc] in [mode] against the current list.
  ImportPlan planImportOf(ExchangeDocument doc, ImportMode mode) => planImport(
    tree: _tree,
    tagsById: _tags,
    doc: doc,
    mode: mode,
    now: _clock(),
    newId: newId,
  );

  /// Backs up the list and applies [plan]. Returns the number of changes.
  Future<int> applyImport(ImportPlan plan, {Set<String> keep = const {}}) =>
      imports.apply(plan, keep: keep, colorFor: tagColorFor);

  /// Restores the list from before the latest import.
  Future<bool> undoImport() async {
    _selectedId = null;
    return imports.undoLatest();
  }

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
  String? _tagFilter;
  String? _selectedId;
  final Set<String> _showDoneFor = {};
  DateTime? _bannerSnoozedUntil;

  static const _snoozeKey = 'banner.snoozedUntil';
  static const _overdueColorKey = 'tag.overdue.color';
  int? _overdueTagColor;

  /// The color the user picked for the "overdue" auto tag, or null for the
  /// theme's warning color.
  int? get overdueTagColor => _overdueTagColor;

  /// Sets the "overdue" auto tag's color (null = back to the default).
  Future<void> setOverdueTagColor(int? color) {
    _overdueTagColor = color;
    notifyListeners();
    return settings.setValue(_overdueColorKey, color?.toString());
  }

  /// The tag shown by [Destination.tag]: a tag id, or [overdueTagId].
  String? get tagFilter => _tagFilter;

  /// Number of overdue items right now.
  int get overdueCount =>
      view(AppView.today).entries
          .whereType<SectionHeader>()
          .where((h) => h.kind == SectionKind.overdue)
          .fold(0, (sum, h) => sum + h.count);

  /// Whether the overdue banner shows: something is overdue and it isn't
  /// snoozed for today.
  bool get showOverdueBanner {
    final until = _bannerSnoozedUntil;
    final snoozed = until != null && _now.isBefore(until);
    return !snoozed && overdueCount > 0;
  }

  /// Hides the overdue banner until tomorrow.
  Future<void> snoozeBanner() {
    final tomorrow = addDays(startOfDay(_clock()), 1);
    _bannerSnoozedUntil = tomorrow;
    notifyListeners();
    return settings.setValue(_snoozeKey, tomorrow.toIso8601String());
  }

  /// Opens the Today view (where the overdue section is).
  void reviewOverdue() => go(Destination.today);

  /// Opens the view for tag [tagId] (or [overdueTagId]).
  void openTag(String tagId) {
    _navigated = true;
    _tagFilter = tagId;
    _destination = Destination.tag;
    notifyListeners();
  }

  /// In a (real) tag's view, new items get that tag.
  List<String> get _currentTagIds {
    final tag = _tagFilter;
    if (_destination != Destination.tag || tag == null) return const [];
    return _tags.containsKey(tag) ? [tag] : const [];
  }

  /// Number of open items with tag [tagId] (or overdue items).
  int tagCount(String tagId) => _viewBuilder.tag(tagId).count;

  /// Changes a tag's color.
  Future<void> setTagColor(String tagId, int color) =>
      tags.setColor(tagId, color);

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
  ViewData view(AppView view) => _viewBuilder.build(view, tagId: _tagFilter);

  ViewBuilder get _viewBuilder =>
      ViewBuilder(_tree, _now, showDoneFor: _showDoneFor);

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

  static const _startViewKey = 'app.startView';

  /// Views the app can start in.
  static const startViews = [
    Destination.today,
    Destination.upcoming,
    Destination.all,
    Destination.done,
  ];

  Destination _startView = Destination.today;
  bool _startApplied = false;
  bool _navigated = false;

  static const _viewOrderKey = 'sidebar.viewOrder';
  static const _tagOrderKey = 'sidebar.tagOrder';
  List<Destination> _viewOrder = startViews;
  List<String> _tagOrder = const [];

  /// Sidebar views in the user's order (drag to reorder).
  List<Destination> get viewOrder => _viewOrder;

  static List<Destination> _parseViewOrder(String? stored) {
    final names = (stored ?? '').split(',');
    final byName = startViews.asNameMap();
    final saved = [for (final n in names) ?byName[n]];
    // Any view missing from the saved order goes at the end.
    return [...saved, ...startViews.where((d) => !saved.contains(d))];
  }

  /// Sidebar tag ids in the user's order, including [overdueTagId]. Tags
  /// that were never reordered follow, by name; the overdue tag defaults
  /// to the end.
  List<String> get sidebarTagIds {
    final known = {..._tags.keys, overdueTagId};
    final ordered = [
      for (final id in _tagOrder)
        if (known.contains(id)) id,
    ];
    final rest = _tags.values.where((t) => !ordered.contains(t.id)).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return [
      ...ordered,
      for (final t in rest) t.id,
      if (!ordered.contains(overdueTagId)) overdueTagId,
    ];
  }

  /// Moves the sidebar view at [oldIndex] to [newIndex] (its final spot).
  Future<void> moveView(int oldIndex, int newIndex) {
    _viewOrder = _moved(_viewOrder, oldIndex, newIndex);
    notifyListeners();
    return settings.setValue(
      _viewOrderKey,
      _viewOrder.map((d) => d.name).join(','),
    );
  }

  /// Moves the sidebar tag at [oldIndex] to [newIndex] (its final spot).
  Future<void> moveTag(int oldIndex, int newIndex) {
    _tagOrder = _moved(sidebarTagIds, oldIndex, newIndex);
    notifyListeners();
    return settings.setValue(_tagOrderKey, _tagOrder.join(','));
  }

  /// [list] with the element at [oldIndex] moved to end up at [newIndex].
  static List<T> _moved<T>(List<T> list, int oldIndex, int newIndex) {
    final copy = [...list];
    final item = copy.removeAt(oldIndex);
    copy.insert(newIndex.clamp(0, copy.length), item);
    return copy;
  }

  /// The view the app opens in (Settings › General).
  Destination get startView => _startView;

  /// Sets the view the app opens in.
  Future<void> setStartView(Destination view) {
    _startView = view;
    notifyListeners();
    return settings.setValue(_startViewKey, view.name);
  }

  /// Opens [destination].
  void go(Destination destination) {
    _navigated = true;
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
    final tagIds = <String>[..._currentTagIds];
    for (final name in parsed.tags) {
      final id = (await tags.findOrCreate(name, colorFor: tagColorFor)).id;
      if (!tagIds.contains(id)) tagIds.add(id);
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
      tagIds: _currentTagIds,
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
    if (_inTutorial(parentId)) {
      await completeTutorialStep(TutorialStep.addSubtask);
    }
    return item;
  }

  /// Marks a task done (with prompts and recurrence).
  ///
  /// Returns whether [id] actually got completed (false when cancelled).
  Future<bool> complete(String id) async {
    final changes = await _rules.complete(_tree, id);
    if (changes == null || changes.isEmpty) return false;
    await items.apply(changes);
    return true;
  }

  /// Reopens a done task.
  Future<void> reopen(String id) => items.apply(_rules.reopen(_tree, id));

  /// Toggles a task between done and open.
  ///
  /// Returns true when it was completed (worth a little celebration).
  Future<bool> toggleDone(String id) async {
    if (_tree[id]?.isDone == true) {
      await reopen(id);
      return false;
    }
    return complete(id);
  }

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
    await addTagId(item, tag.id);
  }

  // ---- Reminders and notification settings ------------------------------

  NotificationPrefs _notificationPrefs = const NotificationPrefs();

  /// Current notification preferences (defaults, digest, quiet hours...).
  NotificationPrefs get notificationPrefs => _notificationPrefs;

  /// Saves notification preferences.
  Future<void> saveNotificationPrefs(NotificationPrefs prefs) {
    _notificationPrefs = prefs;
    notifyListeners();
    return prefs.save(settings);
  }

  /// Gives [item] its own reminders ([offsets] in minutes; empty = none).
  Future<void> setReminders(Item item, List<int> offsets) => items.save(
    item.copyWith(
      customReminders: true,
      reminderOffsets: ({...offsets}.toList()..sort()),
    ),
  );

  /// Puts [item] back on the default reminders.
  Future<void> useDefaultReminders(Item item) => items.save(
    item.copyWith(customReminders: false, reminderOffsets: const []),
  );

  /// Adds the existing tag [tagId] to [item].
  Future<void> addTagId(Item item, String tagId) async {
    if (item.tagIds.contains(tagId)) return;
    await items.save(item.copyWith(tagIds: [...item.tagIds, tagId]));
    if (_inTutorial(item.id)) {
      await completeTutorialStep(TutorialStep.tag);
    }
  }

  // ---- Profile and tutorial ----------------------------------------------

  static const _firstNameKey = 'profile.firstName';
  static const _tutorialKey = 'tutorial.steps';
  String _firstName = '';
  TutorialSteps? _tutorial;

  /// The user's first name (for greetings); empty until setup.
  String get firstName => _firstName;

  /// Saves the first name.
  Future<void> setFirstName(String name) {
    _firstName = name.trim();
    notifyListeners();
    return settings.setValue(_firstNameKey, _firstName);
  }

  /// The tutorial's item ids, if it was created.
  TutorialSteps? get tutorial => _tutorial;

  /// Creates the "Getting started" tutorial, but only when the list is
  /// empty (people who already have items don't get it). Returns whether it
  /// was created.
  Future<bool> createTutorial(TutorialTexts texts) async {
    if (_tree.all.isNotEmpty || (await items.loadAll()).isNotEmpty) {
      return false;
    }
    final parent = await items.create(
      type: ItemType.task,
      title: texts.title,
      notes: texts.notes,
      due: startOfDay(_clock()),
    );
    Future<String> step(int order, String title, String notes) async =>
        (await items.create(
          type: ItemType.task,
          title: title,
          notes: notes,
          parentId: parent.id,
          sortOrder: order,
        )).id;
    final steps = TutorialSteps(
      parent: parent.id,
      checkOff: await step(0, texts.checkOff, texts.checkOffNotes),
      addSubtask: await step(1, texts.addSubtask, texts.addSubtaskNotes),
      tag: await step(2, texts.tag, texts.tagNotes),
      export: await step(3, texts.export, texts.exportNotes),
    );
    _tutorial = steps;
    await settings.setValue(_tutorialKey, steps.encode());
    return true;
  }

  /// Called when an automatic check finished the tutorial (shows a friendly
  /// message). Set by the screen.
  void Function() onTutorialFinished = () {};

  /// Checks off a tutorial step when the user did what it teaches (if it's
  /// still open).
  ///
  /// Automatic checks never prompt: no "Close the subtasks too?" or "Mark
  /// the parent done too?" pops up over whatever the user was doing. When
  /// that was the last step, the whole tutorial closes: "Getting started"
  /// and anything still open under it (practice subtasks the user added
  /// while learning) are marked done, not deleted, and
  /// [onTutorialFinished] is called.
  Future<void> completeTutorialStep(TutorialStep step) async {
    final steps = _tutorial;
    if (steps == null) return;
    _tree = ItemTree(await items.loadAll());
    final item = _tree[steps.idOf(step)];
    if (item == null || item.isDone) return;
    final now = _clock();
    await items.save(item.copyWith(doneAt: now));

    _tree = ItemTree(await items.loadAll());
    final allStepsDone = TutorialStep.values.every(
      (s) => _tree[steps.idOf(s)]?.isDone ?? true,
    );
    final parent = _tree[steps.parent];
    if (!allStepsDone || parent == null || parent.isDone) return;
    await items.apply(
      ItemChanges(
        updated: [
          for (final i in [parent, ..._tree.descendantsOf(parent.id)])
            if (i.isTask && !i.isDone) i.copyWith(doneAt: now),
        ],
      ),
    );
    onTutorialFinished();
  }

  /// Whether [id] is the tutorial task or anything under it (its steps,
  /// or subtasks added to them): actions there count for the tutorial.
  bool _inTutorial(String? id) {
    final parent = _tutorial?.parent;
    if (parent == null || id == null) return false;
    if (id == parent) return true;
    return _tree.ancestorsOf(id).any((a) => a.id == parent);
  }

  /// Called after an export was copied or saved (a tutorial step).
  Future<void> markExported() => completeTutorialStep(TutorialStep.export);

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
