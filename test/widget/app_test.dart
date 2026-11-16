import 'dart:async';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/data/database.dart';
import 'package:wayfinch/data/items_repository.dart';
import 'package:wayfinch/data/settings_repository.dart';
import 'package:wayfinch/data/tags_repository.dart';
import 'package:wayfinch/domain/item_enums.dart';
import 'package:wayfinch/domain/item_rules.dart';
import 'package:wayfinch/ui/app.dart';
import 'package:wayfinch/ui/home/home_controller.dart';
import 'package:wayfinch/ui/theme/appearance_controller.dart';
import 'package:wayfinch/ui/theme/tokens.dart';
import 'package:wayfinch/ui/widgets/color_picker.dart';

/// Sunday, Nov 15, 2026, 10:00.
final _now = DateTime(2026, 11, 15, 10);

class _Harness {
  _Harness(this.db)
    : items = ItemsRepository(db, clock: () => _now),
      tags = TagsRepository(db, clock: () => _now),
      settings = SettingsRepository(db) {
    controller = HomeController(
      items: items,
      tags: tags,
      settings: settings,
      clock: () => _now,
    );
  }

  final WayfinchDatabase db;
  final ItemsRepository items;
  final TagsRepository tags;
  final SettingsRepository settings;
  late final HomeController controller;
  late final AppearanceController appearance = AppearanceController(settings);
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<_Harness> pumpApp(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Future<void> Function(_Harness h)? seed,
  }) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.localesTestValue = [locale];
    final h = _Harness(WayfinchDatabase(NativeDatabase.memory()));
    if (seed != null) await pumpUntilDone(tester, seed(h));
    await tester.pumpWidget(
      WayfinchApp(controller: h.controller, appearance: h.appearance),
    );
    await settle(tester);
    return h;
  }

  Future<void> finish(WidgetTester tester, _Harness h) async {
    await tester.pumpWidget(const SizedBox());
    h.controller.dispose();
    h.appearance.dispose();
    await pumpUntilDone(tester, h.db.close());
    tester.view.reset();
    tester.platformDispatcher.clearLocalesTestValue();
  }

  testWidgets('shows the three views and an empty Today', (tester) async {
    final h = await pumpApp(tester);
    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('Nothing due today. Enjoy the calm.'), findsOneWidget);

    await tester.tap(find.text('Upcoming'));
    await settle(tester);
    expect(find.text('The next 7 days'), findsOneWidget);

    await tester.tap(find.text('Done').first);
    await settle(tester);
    expect(find.text('Nothing done this week yet'), findsOneWidget);
    await finish(tester, h);
  });

  testWidgets('quick add parses and lands in the right view', (tester) async {
    final h = await pumpApp(tester);
    await tester.enterText(
      find.byType(TextField).first,
      'Lab report tomorrow 5pm #school !high',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);

    // Due tomorrow: not in Today, but in Upcoming with its tag.
    expect(find.text('Lab report'), findsNothing);
    await tester.tap(find.text('Upcoming'));
    await settle(tester);
    expect(find.text('Lab report'), findsOneWidget);
    // On the row and in the sidebar's tag list.
    expect(find.text('school'), findsNWidgets(2));
    expect(
      find.textContaining(RegExp(r'^Tomorrow, 5:00\sPM$')),
      findsOneWidget,
    );

    final stored = h.controller.tree.all.single;
    expect(stored.priority, Priority.high);
    await finish(tester, h);
  });

  testWidgets('plain quick add in Today is due today', (tester) async {
    final h = await pumpApp(tester);
    await tester.enterText(find.byType(TextField).first, 'Buy milk');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('TODAY  1'), findsOneWidget);
    await finish(tester, h);
  });

  testWidgets('completing a parent asks, then closes its subtasks', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      seed: (h) async {
        final p = await h.items.create(
          type: ItemType.task,
          title: 'Report',
          due: DateTime(2026, 11, 15, 23),
          dueHasTime: true,
        );
        await h.items.create(
          type: ItemType.task,
          title: 'Write results',
          parentId: p.id,
        );
      },
    );
    expect(find.text('Write results'), findsOneWidget);

    await tester.tap(find.byTooltip('Mark done').first);
    await settle(tester);
    expect(find.text('Close the subtasks too?'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await settle(tester);
    expect(find.text('Report'), findsNothing);
    expect(h.controller.tree.all.every((i) => i.isDone), isTrue);
    await finish(tester, h);
  });

  testWidgets('"Remember my answer" keeps the choice; Settings shows it', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      seed: (h) async {
        final p = await h.items.create(
          type: ItemType.task,
          title: 'Parent',
          due: DateTime(2026, 11, 15),
        );
        await h.items.create(
          type: ItemType.task,
          title: 'Only child',
          parentId: p.id,
        );
      },
    );
    // Complete the child: "Mark the parent done too?" -> remember "Cancel".
    await tester.tap(find.byTooltip('Mark done').last);
    await settle(tester);
    expect(find.text('Mark the parent done too?'), findsOneWidget);
    await tester.tap(find.text('Remember my answer'));
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Parent'), findsOneWidget);
    expect(
      h.controller.remembered[PromptKind.completeParent],
      PromptAnswer.cancel,
    );

    await tester.tap(find.text('Settings'));
    await settle(tester);
    expect(find.text('Leave the parent open'), findsOneWidget);
    expect(find.text('Ask me'), findsNWidgets(2));

    // Switch it back to asking.
    await tester.tap(find.text('Leave the parent open'));
    await settle(tester);
    await tester.tap(find.text('Ask me').last);
    await settle(tester);
    expect(h.controller.remembered[PromptKind.completeParent], isNull);
    await finish(tester, h);
  });

  testWidgets('push/close prompts say "Always do this without asking"', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      seed: (h) async {
        final p = await h.items.create(
          type: ItemType.task,
          title: 'Report',
          due: DateTime(2026, 11, 15, 23),
          dueHasTime: true,
        );
        await h.items.create(
          type: ItemType.task,
          title: 'Write results',
          parentId: p.id,
        );
      },
    );
    await tester.tap(find.byTooltip('Mark done').first);
    await settle(tester);
    expect(find.text('Always do this without asking'), findsOneWidget);
    await tester.tap(find.text('Always do this without asking'));
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    // Cancel is never remembered here.
    expect(h.controller.remembered[PromptKind.closeSubtasks], isNull);
    expect(find.text('Report'), findsOneWidget);
    await finish(tester, h);
  });

  testWidgets('delete shows Undo for 10 seconds, and Undo restores', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      seed: (h) => h.items.create(
        type: ItemType.task,
        title: 'Oops',
        due: DateTime(2026, 11, 15),
      ),
    );
    final id = h.controller.tree.all.single.id;
    await tester.tap(find.text('Oops'));
    await settle(tester);
    await tester.tap(find.byTooltip('Delete item'));
    await settle(tester);
    expect(find.text('Deleted "Oops"'), findsOneWidget);
    expect(h.controller.tree.all, isEmpty);

    await tester.tap(find.text('Undo'));
    await settle(tester);
    expect(h.controller.tree[id]!.title, 'Oops');
    expect(find.text('Oops'), findsWidgets);

    // Delete again and let the message time out.
    await tester.tap(find.byTooltip('Delete item'));
    await settle(tester);
    expect(find.text('Deleted "Oops"'), findsOneWidget);
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();
    expect(find.text('Deleted "Oops"'), findsNothing);
    await finish(tester, h);
  });

  testWidgets('new subtasks open right away (button and row +)', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      seed: (h) => h.items.create(
        type: ItemType.event,
        title: 'Trip',
        start: DateTime(2026, 11, 15, 14),
        end: DateTime(2026, 11, 15, 18),
      ),
    );
    await tester.tap(find.text('Trip'));
    await settle(tester);
    await tester.tap(find.text('+ Add subtask'));
    await settle(tester);
    expect(find.text('Subtask of Trip'), findsOneWidget);
    final sub = h.controller.selected!;
    expect(sub.parentId, isNotNull);
    expect(sub.title, 'New task');

    // The row "+" (shown on the selected row) adds a sub-subtask.
    await tester.tap(find.byTooltip('Add a subtask').first);
    await settle(tester);
    expect(h.controller.selected!.parentId, isNotNull);
    expect(h.controller.tree.all, hasLength(3));
    await finish(tester, h);
  });

  testWidgets('one dialog sets the due date (and time) together', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      seed: (h) => h.items.create(type: ItemType.task, title: 'Plan trip'),
    );
    await tester.tap(find.text('All'));
    await settle(tester);
    await tester.tap(find.text('Plan trip'));
    await settle(tester);
    await tester.tap(find.text('No due date'));
    await settle(tester);
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    expect(find.text('Add time'), findsOneWidget);
    await tester.tap(find.text('20'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await settle(tester);
    final item = h.controller.tree.all.single;
    expect(item.due, DateTime(2026, 11, 20));
    expect(item.dueHasTime, isFalse);
    await finish(tester, h);
  });

  testWidgets('selecting an item opens the detail panel', (tester) async {
    final h = await pumpApp(
      tester,
      seed: (h) => h.items.create(
        type: ItemType.task,
        title: 'Call the dentist',
        due: DateTime(2026, 11, 15, 15),
        dueHasTime: true,
        recurrence: 'FREQ=WEEKLY',
      ),
    );
    await tester.tap(find.text('Call the dentist'));
    await settle(tester);
    expect(find.text('Mark as done'), findsOneWidget);
    expect(find.text('Repeat'), findsOneWidget);
    expect(find.text('Weekly'), findsWidgets);

    await tester.tap(find.text('Mark as done'));
    await settle(tester);
    // The recurring task moves to next week; Today is empty again.
    expect(find.text('Nothing due today. Enjoy the calm.'), findsOneWidget);
    final next = h.controller.tree.all.where((i) => !i.isDone).single;
    expect(next.due, DateTime(2026, 11, 22, 15));
    await finish(tester, h);
  });

  testWidgets('overdue banner: Review opens Today, Snooze hides it', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      seed: (h) async {
        await h.items.create(
          type: ItemType.task,
          title: 'Late one',
          due: DateTime(2026, 11, 13),
        );
        await h.items.create(
          type: ItemType.task,
          title: 'Late two',
          due: DateTime(2026, 11, 14, 9),
          dueHasTime: true,
        );
      },
    );
    expect(find.text('2 overdue items need a new plan'), findsOneWidget);

    await tester.tap(find.text('All'));
    await settle(tester);
    expect(find.text('2 overdue items need a new plan'), findsOneWidget);
    await tester.tap(find.text('Review'));
    await settle(tester);
    expect(h.controller.destination, Destination.today);

    await tester.tap(find.text('Snooze until tomorrow'));
    await settle(tester);
    expect(find.text('2 overdue items need a new plan'), findsNothing);
    expect(
      await pumpUntilDone(tester, h.settings.getValue('banner.snoozedUntil')),
      DateTime(2026, 11, 16).toIso8601String(),
    );
    await finish(tester, h);
  });

  testWidgets('sidebar tags open the Tags view; quick add keeps the tag', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      seed: (h) async {
        final school = await h.tags.findOrCreate(
          'school',
          colorFor: (_) => 0xFF7950F2,
        );
        await h.items.create(
          type: ItemType.task,
          title: 'Essay',
          tagIds: [school.id],
        );
        await h.items.create(type: ItemType.task, title: 'Untagged');
      },
    );
    await tester.tap(find.text('school'));
    await settle(tester);
    expect(h.controller.destination, Destination.tag);
    expect(find.text('Essay'), findsOneWidget);
    expect(find.text('Untagged'), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'Read chapter 3');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    expect(find.text('Read chapter 3'), findsOneWidget);
    final added = h.controller.tree.all.firstWhere(
      (i) => i.title == 'Read chapter 3',
    );
    expect(added.tagIds, hasLength(1));

    // The overdue auto tag is always listed.
    expect(find.text('overdue'), findsOneWidget);
    expect(find.text('auto'), findsOneWidget);
    await finish(tester, h);
  });

  testWidgets('Settings: dark mode and accents apply right away', (
    tester,
  ) async {
    final h = await pumpApp(tester);
    await tester.tap(find.text('Settings'));
    await settle(tester);
    await tester.tap(find.text('Dark'));
    await settle(tester);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    final bg = Theme.of(tester.element(find.byType(Scaffold).first))
        .scaffoldBackgroundColor;
    expect(scaffold, isNotNull);
    expect(bg, const Color(0xFF121418));

    await tester.tap(find.byTooltip('Honey'));
    await settle(tester);
    final colors = Theme.of(tester.element(find.byType(Scaffold).first))
        .extension<WayfinchColors>()!;
    expect(colors.accent, const Color(0xFFFABF66));
    expect(
      await pumpUntilDone(tester, h.settings.getValue('theme.accent')),
      'honey',
    );
    await finish(tester, h);
  });

  testWidgets('custom theme builder shows and warns about contrast', (
    tester,
  ) async {
    final h = await pumpApp(tester);
    await tester.tap(find.text('Settings'));
    await settle(tester);
    await tester.tap(find.byTooltip('Custom'));
    await settle(tester);
    expect(find.text('Custom theme'), findsOneWidget);
    expect(find.text('Everything should be easy to read.'), findsOneWidget);
    expect(
      find.text('Your custom theme decides light or dark.'),
      findsOneWidget,
    );

    // Unreadable palette: warnings appear, nothing is blocked.
    await pumpUntilDone(
      tester,
      h.appearance.setCustom(
        CustomTheme.lightStart.copyWith(text: const Color(0xFFDDDDDD)),
      ),
    );
    await settle(tester);
    expect(find.text('Text may be hard to read here:'), findsOneWidget);
    expect(find.text('Text on panels'), findsOneWidget);
    // Areas only, no numbers.
    expect(find.textContaining(':1'), findsNothing);
    await finish(tester, h);
  });

  testWidgets('tag picker: pick an existing tag or create a new one', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      seed: (h) async {
        await h.tags.findOrCreate('school', colorFor: (_) => 0xFF7950F2);
        await h.items.create(
          type: ItemType.task,
          title: 'Essay',
          due: DateTime(2026, 11, 15),
        );
      },
    );
    await tester.tap(find.text('Essay'));
    await settle(tester);

    // Existing tags show as soon as the field opens.
    await tester.tap(find.text('+ Tag'));
    await settle(tester);
    final tagField = find.widgetWithText(TextField, 'Find or create a tag');
    await tester.enterText(tagField, 'sch');
    await settle(tester);
    expect(find.text('Create "sch"'), findsOneWidget);
    await tester.tap(find.text('school').last);
    await settle(tester);
    final schoolId = h.controller.tagsById.values.single.id;
    expect(h.controller.tree.all.single.tagIds, [schoolId]);

    // A new name: Enter on "Create" makes the tag.
    await tester.tap(find.text('+ Tag'));
    await settle(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Find or create a tag'),
      'reading',
    );
    await settle(tester);
    expect(find.text('Create "reading"'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    expect(
      h.controller.tagsById.values.map((t) => t.name),
      contains('reading'),
    );
    expect(h.controller.tree.all.single.tagIds, hasLength(2));
    await finish(tester, h);
  });

  testWidgets('Settings prompt dropdowns all have the same width', (
    tester,
  ) async {
    final h = await pumpApp(tester);
    await tester.tap(find.text('Settings'));
    await settle(tester);
    final dropdowns = find.byType(DropdownButton<PromptAnswer?>);
    expect(dropdowns, findsNWidgets(3));
    final rights = [
      for (var i = 0; i < 3; i++) tester.getRect(dropdowns.at(i)).right,
    ];
    final widths = [
      for (var i = 0; i < 3; i++) tester.getSize(dropdowns.at(i)).width,
    ];
    expect(widths.toSet(), hasLength(1));
    expect(rights.toSet(), hasLength(1));
    await finish(tester, h);
  });

  testWidgets('tag colors change from a chip menu and the sidebar dot', (
    tester,
  ) async {
    final h = await pumpApp(
      tester,
      seed: (h) async {
        final school = await h.tags.findOrCreate(
          'school',
          colorFor: (_) => tagPalette[0].light,
        );
        await h.items.create(
          type: ItemType.task,
          title: 'Essay',
          due: DateTime(2026, 11, 15),
          tagIds: [school.id],
        );
      },
    );
    int tagColor() => h.controller.tagsById.values.single.color;

    // Detail panel: chip -> "Change color..." -> pick the teal swatch.
    await tester.tap(find.text('Essay'));
    await settle(tester);
    await tester.tap(find.text('school').last);
    await settle(tester);
    expect(find.text('Change color...'), findsOneWidget);
    expect(find.text('Remove school'), findsOneWidget);
    await tester.tap(find.text('Change color...'));
    await settle(tester);
    expect(find.text('Color for "school"'), findsOneWidget);
    await tester.tap(find.byType(Swatch).at(1));
    await settle(tester);
    expect(tagColor(), tagPalette[1].light);

    // Sidebar: the dot opens the same dialog.
    await tester.tap(find.byTooltip('Change color').first);
    await settle(tester);
    await tester.tap(find.byType(Swatch).at(2));
    await settle(tester);
    expect(tagColor(), tagPalette[2].light);

    // The chip menu can still remove the tag.
    await tester.tap(find.text('school').last);
    await settle(tester);
    await tester.tap(find.text('Remove school'));
    await settle(tester);
    expect(h.controller.tree.all.single.tagIds, isEmpty);
    await finish(tester, h);
  });

  testWidgets('a custom tag color from the picker is saved', (tester) async {
    final h = await pumpApp(
      tester,
      seed: (h) =>
          h.tags.findOrCreate('school', colorFor: (_) => tagPalette[0].light),
    );
    await tester.tap(find.byTooltip('Change color').first);
    await settle(tester);
    await tester.tap(find.text('Custom color...'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Hex'), '#123456');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(find.text('Color for "school"'), findsNothing);
    expect(h.controller.tagsById.values.single.color, 0xFF123456);
    await finish(tester, h);
  });

  testWidgets('the overdue tag color can be changed and reset', (tester) async {
    final h = await pumpApp(tester);
    // The overdue row's dot is the last "Change color" button (no user tags).
    await tester.tap(find.byTooltip('Change color').last);
    await settle(tester);
    expect(find.text('Color for "overdue"'), findsOneWidget);
    expect(find.text('Use default'), findsNothing);
    await tester.tap(find.byType(Swatch).at(4));
    await settle(tester);
    expect(h.controller.overdueTagColor, tagPalette[4].light);
    expect(
      await pumpUntilDone(tester, h.settings.getValue('tag.overdue.color')),
      '${tagPalette[4].light}',
    );

    await tester.tap(find.byTooltip('Change color').last);
    await settle(tester);
    await tester.tap(find.text('Use default'));
    await settle(tester);
    expect(h.controller.overdueTagColor, isNull);
    await finish(tester, h);
  });

  testWidgets('French UI', (tester) async {
    final h = await pumpApp(tester, locale: const Locale('fr'));
    expect(find.text('Bonjour'), findsOneWidget);
    expect(find.text('À venir'), findsOneWidget);
    expect(
      find.text('Rien pour aujourd’hui. Profite du calme.'),
      findsOneWidget,
    );
    await finish(tester, h);
  });
}

/// Lets database work (real async) and the UI catch up.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

/// Runs [future] (database work started in the test zone) to completion by
/// pumping, since the test zone's timers only move when pumped.
Future<T> pumpUntilDone<T>(WidgetTester tester, Future<T> future) async {
  var done = false;
  late T result;
  unawaited(
    future.then((value) {
      result = value;
      done = true;
    }),
  );
  for (var i = 0; i < 200 && !done; i++) {
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 2)),
    );
  }
  if (!done) throw StateError('Timed out waiting for database work');
  return result;
}
