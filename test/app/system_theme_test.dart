@TestOn('windows')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/app/system_theme.dart';

/// A scratch key of our own, created and deleted by these tests (the real
/// theme setting is only read, never changed).
const _scratch = r'Software\WayfinchTest\SystemTheme';
const _value = 'SystemUsesLightTheme';

Future<void> _reg(List<String> args) async {
  final r = await Process.run('reg', args);
  if (r.exitCode != 0) fail('reg ${args.join(' ')}: ${r.stderr}');
}

Future<void> _set(int v) => _reg([
  'add',
  'HKCU\\$_scratch',
  '/v',
  _value,
  '/t',
  'REG_DWORD',
  '/d',
  '$v',
  '/f',
]);

void main() {
  tearDownAll(() async {
    await Process.run('reg', ['delete', r'HKCU\Software\WayfinchTest', '/f']);
  });

  test('reads the real setting the same way reg.exe does', () async {
    final r = await Process.run('reg', [
      'query',
      'HKCU\\${SystemTheme.keyPath}',
      '/v',
      SystemTheme.valueName,
    ]);
    final expected = RegExp(r'0x0*1\b').hasMatch('${r.stdout}');
    expect(SystemTheme.isLight(), expected);
  });

  test('missing key or value means dark', () {
    expect(SystemTheme.isLight(path: r'Software\WayfinchTest\Nope'), isFalse);
  });

  test('reports changes live, and only real changes', () async {
    await _set(0);
    expect(SystemTheme.isLight(path: _scratch), isFalse);
    final seen = <bool>[];
    final sub = SystemTheme.changes(path: _scratch).listen(seen.add);
    // Let the watcher start and register for notifications.
    await Future<void>.delayed(const Duration(milliseconds: 800));

    await _set(1);
    await _waitFor(() => seen.length == 1);
    expect(seen, [true]);

    await _set(1); // same value: not reported
    await _set(0);
    await _waitFor(() => seen.length == 2);
    expect(seen, [true, false]);
    expect(SystemTheme.isLight(path: _scratch), isFalse);
    await sub.cancel();
  });
}

Future<void> _waitFor(bool Function() done) async {
  for (var i = 0; i < 50 && !done(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  expect(done(), isTrue, reason: 'timed out');
}
