import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/app/app_session.dart';
import 'package:wayfinch/data/database.dart';
import 'package:wayfinch/data/database_opener.dart';
import 'package:wayfinch/data/encryption/key_vault.dart';
import 'package:wayfinch/data/notification_prefs.dart';
import 'package:wayfinch/domain/item_enums.dart';
import 'package:wayfinch/ui/app.dart';
import 'package:wayfinch/ui/home/home_controller.dart';

import 'helpers.dart';

const _fastKdf = KdfParams(memoryKib: 64, iterations: 1, parallelism: 1);
final _now = DateTime(2026, 11, 15, 10);

Future<T> _inline<T>(Future<T> Function() work) => work();

/// Opens the file in the test zone (no background isolate).
WayfinchDatabase _open(File file, Uint8List? key) => WayfinchDatabase(
  NativeDatabase(file, setup: (db) => applyEncryptionKey(db, key)),
);

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('wayfinch_onboard'));
  tearDown(() {
    try {
      dir.deleteSync(recursive: true);
    } on FileSystemException {
      // A file may still be closing on Windows; temp dirs get cleaned up.
    }
  });

  AppSession newSession() => AppSession(
    dataDir: dir,
    kdf: _fastKdf,
    runInBackground: _inline,
    clock: () => _now,
    openDatabase: _open,
  );

  Future<AppSession> pumpShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1100);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.localesTestValue = [const Locale('en')];
    final session = newSession();
    await tester.pumpWidget(WayfinchShell(session: session));
    await pumpUntilDone(tester, session.start());
    await settle(tester);
    return session;
  }

  Future<void> finish(WidgetTester tester, AppSession session) async {
    await tester.pumpWidget(const SizedBox());
    await pumpUntilDone(tester, session.shutdown());
    tester.view.reset();
    tester.platformDispatcher.clearLocalesTestValue();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await settle(tester);
  }

  testWidgets('setup without a password: name, vibe, reminders, tutorial', (
    tester,
  ) async {
    final s = await pumpShell(tester);
    expect(find.text("Hi, I'm Wayfinch!"), findsOneWidget);
    await tapText(tester, "Let's start");

    expect(find.text('What should I call you?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Judhy');
    await tester.pump();
    await tapText(tester, 'Next');

    expect(find.text('Want a password?'), findsOneWidget);
    await tapText(tester, 'Skip for now');

    expect(find.text('Pick your vibe'), findsOneWidget);
    await tester.tap(find.byTooltip('Honey'));
    await settle(tester);
    expect(s.appearance!.value.accent.name, 'honey');
    await tapText(tester, 'Next');

    expect(find.text('Reminders'), findsOneWidget);
    await tester.tap(find.text('Morning digest'));
    await settle(tester);
    await tapText(tester, 'Next');

    expect(find.text('How to use it with your AI'), findsOneWidget);
    await tapText(tester, "Let's go!");

    // The main screen, greeting by name, with the tutorial in Today.
    expect(find.text('Good morning, Judhy'), findsOneWidget);
    expect(find.text('Getting started with Wayfinch'), findsOneWidget);
    expect(s.hasPassword, isFalse);
    expect(s.needsOnboarding, isFalse);
    final prefs = await pumpUntilDone(
      tester,
      NotificationPrefs.load(s.settings!),
    );
    expect(prefs.digestEnabled, isFalse);
    expect(prefs.taskReminderMinutes, 60);
    await finish(tester, s);
  });

  testWidgets('setup with a password: recovery code, then encrypted', (
    tester,
  ) async {
    final s = await pumpShell(tester);
    await tapText(tester, "Let's start");
    await tester.enterText(find.byType(TextField), 'Sam');
    await tester.pump();
    await tapText(tester, 'Next');

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'hunter2');
    await tester.enterText(fields.at(1), 'hunter2');
    await tester.pump();
    await tapText(tester, 'Next');

    expect(find.text('Your recovery code'), findsOneWidget);
    final next = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Next'),
    );
    expect(next.onPressed, isNull); // until "I saved it"
    await tester.tap(find.text('I saved my recovery code'));
    await settle(tester);
    await tapText(tester, 'Next'); // vibe
    await tapText(tester, 'Next'); // reminders
    await tapText(tester, 'Next'); // AI loop
    await tapText(tester, "Let's go!");
    await settle(tester);

    expect(s.hasPassword, isTrue);
    expect(find.text('Good morning, Sam'), findsOneWidget);
    final header = String.fromCharCodes(
      s.databaseFile.readAsBytesSync().take(15),
    );
    expect(header, isNot('SQLite format 3'));
    await finish(tester, s);
  });

  testWidgets('existing data: setup runs, but no tutorial is added', (
    tester,
  ) async {
    final seed = newSession();
    await tester.runAsync(() async {
      await seed.start();
      await seed.home!.items.create(type: ItemType.task, title: 'Old stuff');
      await seed.shutdown();
    });

    final s = await pumpShell(tester);
    expect(find.text("Hi, I'm Wayfinch!"), findsOneWidget);
    await tapText(tester, "Let's start");
    await tester.enterText(find.byType(TextField), 'Alex');
    await tester.pump();
    await tapText(tester, 'Next');
    await tapText(tester, 'Skip for now');
    await tapText(tester, 'Next');
    await tapText(tester, 'Next');
    await tapText(tester, "Let's go!");
    final titles = s.home!.tree.all.map((i) => i.title).toList();
    expect(titles, ['Old stuff']);
    await finish(tester, s);
  });

  testWidgets('unlock screen: wrong password, then recovery code', (
    tester,
  ) async {
    late String code;
    final seed = newSession();
    await tester.runAsync(() async {
      await seed.start();
      await seed.completeOnboarding();
      final setup = await seed.preparePassword('right');
      code = setup.recoveryCode;
      await seed.enablePassword(setup);
      await seed.shutdown();
    });

    final s = await pumpShell(tester);
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'wrong');
    await tapText(tester, 'Unlock');
    expect(find.text("That password didn't work."), findsOneWidget);

    await tapText(tester, 'Forgot your password? Use your recovery code');
    await tester.enterText(find.byType(TextField), code.toLowerCase());
    await tapText(tester, 'Unlock');
    expect(find.text('Choose a new password'), findsOneWidget);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'fresh');
    await tester.enterText(fields.at(1), 'fresh');
    await tester.pump();
    await tapText(tester, 'Save password');
    await pumpUntilFound(tester, find.text('Today'));
    expect(s.home, isNotNull);
    expect(find.text('Today'), findsWidgets);
    await finish(tester, s);

    // The new password works next time.
    final again = newSession();
    final ok = await tester.runAsync(() async {
      await again.start();
      final unlocked = await again.unlockWithPassword('fresh');
      await again.shutdown();
      return unlocked;
    });
    expect(ok, isTrue);
  });

  testWidgets('Settings › Profile: set a password, then remove it', (
    tester,
  ) async {
    final seed = newSession();
    await tester.runAsync(() async {
      await seed.start();
      await seed.completeOnboarding();
      await seed.home!.setFirstName('Judhy');
      await seed.shutdown();
    });
    final s = await pumpShell(tester);
    s.home!.go(Destination.settings);
    await settle(tester);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.textContaining('Off:'), findsOneWidget);

    await tapText(tester, 'Set a password');
    final fields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'pw');
    await tester.enterText(fields.at(1), 'pw');
    await tester.pump();
    await tapText(tester, 'Next');
    await pumpUntilFound(tester, find.text('Your recovery code'));
    await tester.tap(find.text('I saved my recovery code'));
    await settle(tester);
    await tapText(tester, 'Turn on password');
    await pumpUntilFound(tester, find.textContaining('On:'));
    expect(s.hasPassword, isTrue);
    // Back on Settings after the database reopened.
    expect(s.home!.destination, Destination.settings);

    await tapText(tester, 'Remove password');
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'pw',
    );
    await tester.pump();
    await tapText(tester, 'Confirm');
    await pumpUntilFound(tester, find.textContaining('Off:'));
    expect(s.hasPassword, isFalse);
    await finish(tester, s);
  });

  testWidgets('tutorial steps check themselves off; Help searches', (
    tester,
  ) async {
    final s = await pumpShell(tester);
    await tapText(tester, "Let's start");
    await tester.enterText(find.byType(TextField), 'Judhy');
    await tester.pump();
    await tapText(tester, 'Next');
    await tapText(tester, 'Skip for now');
    await tapText(tester, 'Next');
    await tapText(tester, 'Next');
    await tapText(tester, "Let's go!");

    final home = s.home!;
    final steps = home.tutorial!;
    bool done(String id) => home.tree[id]!.isDone;

    await pumpUntilDone(tester, home.addSubtask(steps.parent, 'My step'));
    await settle(tester);
    expect(done(steps.addSubtask), isTrue);

    final parent = home.tree[steps.parent]!;
    await pumpUntilDone(tester, home.addTag(parent, 'learning'));
    await settle(tester);
    expect(done(steps.tag), isTrue);

    await pumpUntilDone(tester, home.markExported());
    await settle(tester);
    expect(done(steps.export), isTrue);
    expect(done(steps.checkOff), isFalse); // that one is yours to check

    // Help: search opens matching sections; the AI section shows the rules.
    home.go(Destination.help);
    await settle(tester);
    expect(find.text('Getting around'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'recovery code');
    await settle(tester);
    expect(find.text('Password and recovery code'), findsOneWidget);
    expect(find.text('Getting around'), findsNothing);
    await tester.enterText(find.byType(TextField).last, 'format rules');
    await settle(tester);
    expect(find.text('Using Wayfinch with your AI'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is SelectableText && (w.data ?? '').contains('"wayfinch"'),
      ),
      findsOneWidget,
    );
    await finish(tester, s);
  });
}
