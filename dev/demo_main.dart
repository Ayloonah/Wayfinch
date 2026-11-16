// Dev-only entry point: runs Wayfinch on a throwaway in-memory database
// filled with sample items, so the UI can be checked without touching real
// data. Not part of the shipped app.
//
//   flutter run -d windows -t dev/demo_main.dart

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:wayfinch/data/database.dart';
import 'package:wayfinch/data/import_repository.dart';
import 'package:wayfinch/data/items_repository.dart';
import 'package:wayfinch/data/settings_repository.dart';
import 'package:wayfinch/data/tags_repository.dart';
import 'package:wayfinch/domain/dates.dart';
import 'package:wayfinch/domain/item_enums.dart';
import 'package:wayfinch/ui/app.dart';
import 'package:wayfinch/ui/exchange/export_dialog.dart';
import 'package:wayfinch/ui/exchange/import_dialog.dart';
import 'package:wayfinch/ui/home/home_controller.dart';
import 'package:wayfinch/ui/theme/appearance_controller.dart';
import 'package:wayfinch/ui/theme/tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = WayfinchDatabase(NativeDatabase.memory());
  final items = ItemsRepository(db);
  final tags = TagsRepository(db);
  await _seed(items, tags);
  final settings = SettingsRepository(db);
  // Optional look for screenshots, as environment variables or defines:
  //   --dart-define=DEMO_MODE=dark --dart-define=DEMO_ACCENT=honey
  //   --dart-define=DEMO_VIEW=settings   (or export / import)
  final mode = _option('DEMO_MODE', const String.fromEnvironment('DEMO_MODE'));
  final accent = _option(
    'DEMO_ACCENT',
    const String.fromEnvironment('DEMO_ACCENT'),
  );
  final view = _option('DEMO_VIEW', const String.fromEnvironment('DEMO_VIEW'));
  if (mode.isNotEmpty) await settings.setValue('theme.mode', mode);
  if (accent.isNotEmpty) await settings.setValue('theme.accent', accent);
  final controller = HomeController(
    items: items,
    tags: tags,
    settings: settings,
    imports: ImportRepository(db, items),
  );
  final id = await _firstParent(items);
  controller.select(id);
  if (view == 'settings') controller.go(Destination.settings);
  runApp(
    WayfinchApp(
      controller: controller,
      appearance: AppearanceController(settings),
      onReady: switch (view) {
        'export' => showExportDialog,
        'import' => showImportDialog,
        _ => null,
      },
    ),
  );
}

Future<String> _firstParent(ItemsRepository items) async {
  final all = await items.loadAll();
  return all.firstWhere((i) => i.title.startsWith('CV term')).id;
}

Future<void> _seed(ItemsRepository items, TagsRepository tags) async {
  final today = startOfDay(DateTime.now());
  DateTime at(int dayOffset, int hour, [int minute = 0]) {
    final d = addDays(today, dayOffset);
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  Future<String> tag(String name) async =>
      (await tags.findOrCreate(name, colorFor: tagColorFor)).id;
  final school = await tag('school');
  final work = await tag('work');
  final personal = await tag('personal');
  final errands = await tag('errands');

  await items.create(
    type: ItemType.task,
    title: 'Submit CNT 4714 PA3',
    due: at(-1, 23, 59),
    dueHasTime: true,
    priority: Priority.high,
    tagIds: [school],
  );
  await items.create(
    type: ItemType.task,
    title: 'Reply to internship recruiter',
    due: addDays(today, -2),
    priority: Priority.medium,
    tagIds: [work],
  );
  await items.create(
    type: ItemType.event,
    title: 'Study group',
    start: at(0, 14),
    end: at(0, 15, 30),
    tagIds: [school],
  );
  final project = await items.create(
    type: ItemType.task,
    title: 'CV term project: report draft',
    due: at(0, 23, 59),
    dueHasTime: true,
    priority: Priority.high,
    tagIds: [school],
    notes: 'Use the report template from the syllabus.',
  );
  final results = await items.create(
    type: ItemType.task,
    title: 'Write results section',
    due: at(0, 18),
    dueHasTime: true,
    priority: Priority.medium,
    parentId: project.id,
  );
  await items.create(
    type: ItemType.task,
    title: 'Make accuracy chart',
    due: at(0, 16),
    dueHasTime: true,
    parentId: results.id,
  );
  await items.create(
    type: ItemType.task,
    title: 'Proofread and submit',
    due: at(0, 22),
    dueHasTime: true,
    parentId: project.id,
  );
  for (final title in ['Collect data', 'Train model']) {
    final done = await items.create(
      type: ItemType.task,
      title: title,
      parentId: project.id,
    );
    await items.save(done.copyWith(doneAt: DateTime.now()));
  }
  await items.create(
    type: ItemType.task,
    title: 'Grade CS1 lab submissions',
    due: at(0, 21),
    dueHasTime: true,
    priority: Priority.medium,
    recurrence: 'FREQ=WEEKLY',
    tagIds: [work],
  );
  await items.create(
    type: ItemType.event,
    title: 'Gym',
    start: at(1, 18, 30),
    end: at(1, 19, 30),
    tagIds: [personal],
  );
  await items.create(
    type: ItemType.task,
    title: 'Return library books',
    due: addDays(today, 3),
    priority: Priority.low,
    tagIds: [errands],
  );
}

/// A demo option from an environment variable (so one build can show any
/// view), falling back to the `--dart-define` value.
String _option(String name, String fromDefine) {
  final env = Platform.environment[name];
  return env == null || env.isEmpty ? fromDefine : env;
}
