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

  testWidgets('"Always do this" skips the prompt and shows in Settings', (
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
    // Complete the child: "Mark the parent done too?"
    await tester.tap(find.byTooltip('Mark done').last);
    await settle(tester);
    expect(find.text('Mark the parent done too?'), findsOneWidget);
    await tester.tap(find.text('Always do this'));
    await settle(tester);
    expect(find.text('Parent'), findsNothing);

    await tester.tap(find.text('Settings'));
    await settle(tester);
    final tile = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Ask before marking a parent done'),
    );
    expect(tile.value, isFalse);
    await pumpUntilDone(
      tester,
      h.settings.setAsk(PromptKind.completeParent, ask: true),
    );
    await settle(tester);
    expect(
      tester
          .widget<SwitchListTile>(
            find.widgetWithText(
              SwitchListTile,
              'Ask before marking a parent done',
            ),
          )
          .value,
      isTrue,
    );
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
