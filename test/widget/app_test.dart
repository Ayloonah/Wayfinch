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
    await tester.pumpWidget(WayfinchApp(controller: h.controller));
    await settle(tester);
    return h;
  }

  Future<void> finish(WidgetTester tester, _Harness h) async {
    await tester.pumpWidget(const SizedBox());
    h.controller.dispose();
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
    expect(find.text('school'), findsOneWidget);
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
