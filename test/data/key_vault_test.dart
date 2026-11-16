import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/data/encryption/key_vault.dart';

/// Cheap KDF settings so the tests stay fast. Real use is [KdfParams.standard].
const _fastKdf = KdfParams(memoryKib: 64, iterations: 1, parallelism: 1);

void main() {
  final service = KeyVaultService();

  test('password and recovery code both unlock the same key', () async {
    final setup = await service.create(password: 'hunter2', kdf: _fastKdf);

    expect(setup.dbKey, hasLength(dbKeyLength));
    expect(
      await service.unlockWithPassword(setup.vault, 'hunter2'),
      setup.dbKey,
    );
    expect(
      await service.unlockWithRecoveryCode(setup.vault, setup.recoveryCode),
      setup.dbKey,
    );
  });

  test('wrong password is rejected', () async {
    final setup = await service.create(password: 'hunter2', kdf: _fastKdf);

    expect(
      service.unlockWithPassword(setup.vault, 'hunter3'),
      throwsA(isA<WrongSecretException>()),
    );
  });

  test('wrong recovery code is rejected', () async {
    final setup = await service.create(password: 'pw', kdf: _fastKdf);

    expect(
      service.unlockWithRecoveryCode(setup.vault, 'AAAA-AAAA-AAAA-AAAA-AAAA'),
      throwsA(isA<WrongSecretException>()),
    );
  });

  test('recovery code ignores case, spaces and dashes', () async {
    final setup = await service.create(password: 'pw', kdf: _fastKdf);
    final sloppy = setup.recoveryCode.toLowerCase().replaceAll('-', ' ');

    expect(
      await service.unlockWithRecoveryCode(setup.vault, sloppy),
      setup.dbKey,
    );
  });

  test('recovery code format', () {
    final code = service.generateRecoveryCode();

    expect(
      code,
      matches(RegExp(r'^([0-9A-HJKMNP-TV-Z]{4}-){4}[0-9A-HJKMNP-TV-Z]{4}$')),
    );
  });

  test('changing the password keeps the key and the recovery code', () async {
    final setup = await service.create(password: 'old', kdf: _fastKdf);
    final changed = await service.changePassword(
      setup.vault,
      dbKey: setup.dbKey,
      newPassword: 'new',
    );

    expect(await service.unlockWithPassword(changed, 'new'), setup.dbKey);
    expect(
      service.unlockWithPassword(changed, 'old'),
      throwsA(isA<WrongSecretException>()),
    );
    expect(
      await service.unlockWithRecoveryCode(changed, setup.recoveryCode),
      setup.dbKey,
    );
  });

  test('vault survives a save/load round trip and stores no secrets', () async {
    final setup = await service.create(password: 'hunter2', kdf: _fastKdf);
    final dir = await Directory.systemTemp.createTemp('wayfinch_vault');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/vault.json');

    await setup.vault.save(file);
    final raw = await file.readAsString();
    final loaded = await KeyVault.load(file);

    expect(raw, isNot(contains('hunter2')));
    expect(raw, isNot(contains(setup.recoveryCode)));
    expect(raw, isNot(contains(base64Encode(setup.dbKey))));
    expect(await service.unlockWithPassword(loaded!, 'hunter2'), setup.dbKey);
  });

  test('loading a missing vault returns null', () async {
    expect(await KeyVault.load(File('does/not/exist.json')), isNull);
  });

  test('standard KDF settings meet the OWASP Argon2id baseline', () {
    expect(KdfParams.standard.memoryKib, greaterThanOrEqualTo(19456));
    expect(KdfParams.standard.iterations, greaterThanOrEqualTo(2));
  });
}
