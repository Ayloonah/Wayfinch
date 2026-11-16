import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wayfinch/app/notification_service.dart';
import 'package:wayfinch/data/database.dart';
import 'package:wayfinch/data/import_repository.dart';
import 'package:wayfinch/data/items_repository.dart';
import 'package:wayfinch/data/settings_repository.dart';
import 'package:wayfinch/data/tags_repository.dart';
import 'package:wayfinch/domain/item_enums.dart';
import 'package:wayfinch/l10n/app_localizations.dart';
import 'package:wayfinch/ui/home/home_controller.dart';

typedef _Shown = ({
  String title,
  String body,
  String payload,
  List<NotificationButton> buttons,
});

class _FakeNotifier implements Notifier {
  final shown = <_Shown>[];

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String payload,
    List<NotificationButton> buttons = const [],
  }) async {
    shown.add((title: title, body: body, payload: payload, buttons: buttons));
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late WayfinchDatabase db;
  late ItemsRepository items;
  late SettingsRepository settings;
  late DateTime now;
  HomeController? controller;
  late NotificationService service;
  late _FakeNotifier notifier;
  final opened = <String?>[];

  setUpAll(initializeDateFormatting);

  setUp(() {
    db = WayfinchDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 16, 15);
    items = ItemsRepository(db, clock: () => now);
    settings = SettingsRepository(db);
    notifier = _FakeNotifier();
    opened.clear();
  });

  tearDown(() async {
    controller?.dispose();
    controller = null;
    await db.close();
  });

  /// Waits (real time) until [ready] holds.
  Future<void> until(bool Function() ready) async {
    for (var i = 0; i < 400 && !ready(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    expect(ready(), isTrue, reason: 'timed out waiting');
  }

  /// Creates the controller and service once the data is seeded, and waits
  /// until the controller has loaded it.
  Future<void> start({required bool Function(HomeController) ready}) async {
    final c = HomeController(
      items: items,
      tags: TagsRepository(db, clock: () => now),
      settings: settings,
      imports: ImportRepository(db, items, clock: () => now),
      clock: () => now,
    );
    controller = c;
    service = NotificationService(
      home: c,
      notifier: notifier,
      l10n: lookupAppLocalizations(const Locale('en')),
      locale: 'en',
      onOpenItem: opened.add,
      clock: () => now,
    );
    await until(() => ready(c));
  }

  Future<String> timedTask(String title, DateTime due) async =>
      (await items.create(
        type: ItemType.task,
        title: title,
        due: due,
        dueHasTime: true,
      )).id;

  Future<void> digestOff() => settings.setValue('notif.digestEnabled', 'false');

  test('starts from now, then shows each reminder once', () async {
    await digestOff();
    final id = await timedTask('Call the bank', DateTime(2026, 11, 16, 16, 15));
    await start(
      ready: (c) => c.tree[id] != null && !c.notificationPrefs.digestEnabled,
    );

    await service.tick(); // 15:00: first check, nothing due yet
    expect(notifier.shown, isEmpty);

    now = DateTime(2026, 11, 16, 15, 16);
    await service.tick();
    final n = notifier.shown.single;
    expect(n.title, 'Call the bank');
    // intl puts a narrow no-break space before AM/PM.
    expect(n.body, 'Due at 4:15 PM');
    expect(n.payload, 'open|$id');
    expect(n.buttons.map((b) => b.label), ['10 min', '1 hour', 'Tomorrow']);

    now = DateTime(2026, 11, 16, 15, 17);
    await service.tick();
    expect(notifier.shown, hasLength(1));
  });

  test('skips reminders that are more than 30 minutes late', () async {
    await digestOff();
    await settings.setValue(
      'notif.lastCheck',
      DateTime(2026, 11, 16, 14).toIso8601String(),
    );
    final late = await timedTask('Late', DateTime(2026, 11, 16, 16, 20));
    final ok = await timedTask('Recent', DateTime(2026, 11, 16, 16, 45));
    now = DateTime(2026, 11, 16, 16);
    await start(
      ready: (c) =>
          c.tree[late] != null &&
          c.tree[ok] != null &&
          !c.notificationPrefs.digestEnabled,
    );

    await service.tick();
    expect(notifier.shown.map((n) => n.title), ['Recent']);
  });

  test('quiet hours hold reminders until they end', () async {
    await digestOff();
    await settings.setValue('notif.quietEnabled', 'true');
    await settings.setValue('notif.quietStart', '22:00');
    await settings.setValue('notif.quietEnd', '07:00');
    await settings.setValue(
      'notif.lastCheck',
      DateTime(2026, 11, 16, 22, 30).toIso8601String(),
    );
    final id = await timedTask('Night owl', DateTime(2026, 11, 16, 23, 45));
    now = DateTime(2026, 11, 16, 23);
    await start(
      ready: (c) => c.tree[id] != null && c.notificationPrefs.quietEnabled,
    );

    await service.tick();
    expect(notifier.shown, isEmpty);

    now = DateTime(2026, 11, 17, 6, 30);
    await service.tick();
    expect(notifier.shown, isEmpty);

    now = DateTime(2026, 11, 17, 7, 1);
    await service.tick();
    expect(notifier.shown.map((n) => n.title), ['Night owl']);
    expect(notifier.shown.single.body, 'Due Mon, Nov 16 at 11:45 PM');

    await service.tick();
    expect(notifier.shown, hasLength(1));
  });

  test('snooze shows the reminder again later', () async {
    await digestOff();
    final id = await timedTask('Stretch', DateTime(2026, 11, 16, 16, 15));
    await start(
      ready: (c) => c.tree[id] != null && !c.notificationPrefs.digestEnabled,
    );
    await service.tick();
    now = DateTime(2026, 11, 16, 15, 16);
    await service.tick();
    final snooze = notifier.shown.single.buttons.first.arguments;

    await service.handle(snooze); // 10 minutes → 15:26
    now = DateTime(2026, 11, 16, 15, 25);
    await service.tick();
    expect(notifier.shown, hasLength(1));

    now = DateTime(2026, 11, 16, 15, 27);
    await service.tick();
    expect(notifier.shown, hasLength(2));
    expect(notifier.shown.last.payload, 'open|$id');

    now = DateTime(2026, 11, 16, 15, 40);
    await service.tick();
    expect(notifier.shown, hasLength(2));
  });

  test('morning digest: once a day, with a short list', () async {
    await settings.setValue('profile.firstName', 'Sam');
    for (final t in ['Laundry', 'Groceries', 'Email Prof', 'Water plants']) {
      await items.create(
        type: ItemType.task,
        title: t,
        due: DateTime(2026, 11, 16),
      );
    }
    now = DateTime(2026, 11, 16, 8, 5);
    await start(ready: (c) => c.tree.all.length == 4 && c.firstName == 'Sam');

    await service.tick();
    final digest = notifier.shown.single;
    expect(digest.title, 'Morning, Sam! 4 things on today');
    expect(digest.body.split('\n'), hasLength(4));
    expect(digest.body, endsWith('+ 1 more'));
    expect(digest.payload, 'digest');

    now = DateTime(2026, 11, 16, 9);
    await service.tick();
    expect(notifier.shown, hasLength(1));
  });

  test('clicking opens the item, or the app for the digest', () async {
    await start(ready: (c) => true);
    await service.handle('open|abc');
    await service.handle('digest');
    await service.handle('nonsense');
    expect(opened, ['abc', null]);
  });
}
