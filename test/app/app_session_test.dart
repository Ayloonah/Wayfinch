import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/app/app_session.dart';
import 'package:wayfinch/data/encryption/key_vault.dart';
import 'package:wayfinch/domain/item_enums.dart';

const _fastKdf = KdfParams(memoryKib: 64, iterations: 1, parallelism: 1);

Future<T> _inline<T>(Future<T> Function() work) => work();

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('wayfinch_session');
  });

  tearDown(() async {
    // Give closing databases a moment before deleting their files.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  AppSession session() =>
      AppSession(dataDir: dir, kdf: _fastKdf, runInBackground: _inline);

  Future<List<String>> titles(AppSession s) async =>
      (await s.home!.items.loadAll()).map((i) => i.title).toList();

  String header(AppSession s) =>
      String.fromCharCodes(s.databaseFile.readAsBytesSync().take(15));

  test('first start: plain database, setup needed', () async {
    final s = session();
    await s.start();
    expect(s.phase, SessionPhase.ready);
    expect(s.needsOnboarding, isTrue);
    expect(s.hasPassword, isFalse);
    await s.completeOnboarding();
    s.dispose();

    final again = session();
    await again.start();
    expect(again.needsOnboarding, isFalse);
    again.dispose();
  });

  test('password on: file encrypted, data kept, unlock needed', () async {
    final s = session();
    await s.start();
    await s.home!.items.create(type: ItemType.task, title: 'Secret plan');
    final setup = await s.preparePassword('hunter2');
    await s.enablePassword(setup);

    expect(s.phase, SessionPhase.ready);
    expect(s.hasPassword, isTrue);
    expect(await titles(s), ['Secret plan']);
    expect(header(s), isNot('SQLite format 3'));
    expect(
      String.fromCharCodes(s.databaseFile.readAsBytesSync()),
      isNot(contains('Secret plan')),
    );
    s.dispose();

    final next = session();
    await next.start();
    expect(next.phase, SessionPhase.locked);
    expect(await next.unlockWithPassword('wrong'), isFalse);
    expect(next.phase, SessionPhase.locked);
    expect(await next.unlockWithPassword('hunter2'), isTrue);
    expect(await titles(next), ['Secret plan']);
    expect(next.mustChooseNewPassword, isFalse);
    next.dispose();
  });

  test('change password and recovery codes', () async {
    final s = session();
    await s.start();
    await s.enablePassword(await s.preparePassword('old'));
    expect(await s.changePassword('nope', 'new'), isFalse);
    expect(await s.changePassword('old', 'new'), isTrue);
    final code = await s.newRecoveryCode('new');
    expect(code, isNotNull);
    expect(await s.newRecoveryCode('old'), isNull);
    s.dispose();

    final locked = session();
    await locked.start();
    expect(await locked.unlockWithPassword('old'), isFalse);
    expect(
      await locked.unlockWithRecoveryCode('AAAA-AAAA-AAAA-AAAA-AAAA'),
      isFalse,
    );
    expect(await locked.unlockWithRecoveryCode(code!), isTrue);
    expect(locked.mustChooseNewPassword, isTrue);
    await locked.finishRecovery('fresh');
    expect(locked.mustChooseNewPassword, isFalse);
    locked.dispose();

    final again = session();
    await again.start();
    expect(await again.unlockWithPassword('fresh'), isTrue);
    again.dispose();
  });

  test('password off: back to plain SQLite, data kept', () async {
    final s = session();
    await s.start();
    await s.home!.items.create(type: ItemType.task, title: 'Keep me');
    await s.enablePassword(await s.preparePassword('pw'));
    expect(await s.disablePassword('wrong'), isFalse);
    expect(s.hasPassword, isTrue);
    expect(await s.disablePassword('pw'), isTrue);
    expect(s.hasPassword, isFalse);
    expect(header(s), 'SQLite format 3');
    expect(await titles(s), ['Keep me']);
    s.dispose();

    final again = session();
    await again.start();
    expect(again.phase, SessionPhase.ready);
    expect(await titles(again), ['Keep me']);
    again.dispose();
  });
}
