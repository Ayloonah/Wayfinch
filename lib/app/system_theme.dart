import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

/// Windows' "system" light/dark mode: the taskbar and tray's theme
/// (`SystemUsesLightTheme` under
/// `HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize`).
/// It's separate from the apps' mode and from Wayfinch's own theme.
///
/// Uses `dart:ffi` directly (advapi32/kernel32), so it needs no package.
class SystemTheme {
  SystemTheme._();

  /// The registry key (under HKCU) holding the setting.
  static const keyPath =
      r'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize';

  /// The DWORD value: 1 = light, 0 = dark.
  static const valueName = 'SystemUsesLightTheme';

  /// Whether the system (taskbar) theme is light right now. Windows'
  /// default, and the answer when the setting doesn't exist, is dark.
  /// [path] and [name] are for tests.
  static bool isLight({String path = keyPath, String name = valueName}) {
    final key = _openKey(path);
    if (key == null) return false;
    try {
      return _readIsLight(key, name);
    } finally {
      _api.regCloseKey(key);
    }
  }

  /// Emits the new value each time the system theme changes (not the
  /// current one). Watches the registry key from a background isolate.
  /// [path] and [name] are for tests.
  static Stream<bool> changes({
    String path = keyPath,
    String name = valueName,
  }) {
    late final StreamController<bool> controller;
    final port = ReceivePort();
    Isolate? isolate;
    controller = StreamController<bool>(
      onListen: () async {
        port.listen((m) {
          if (m is bool) controller.add(m);
        });
        isolate = await Isolate.spawn(_watch, (port.sendPort, path, name));
      },
      onCancel: () {
        isolate?.kill(priority: Isolate.immediate);
        port.close();
      },
    );
    return controller.stream;
  }

  /// Background loop: waits (in half-second slices, so the isolate can be
  /// stopped) for the key to change, and reports the value when it does.
  static Future<void> _watch((SendPort, String, String) args) async {
    final (out, path, name) = args;
    final key = _openKey(path, notify: true);
    if (key == null) return;
    final event = _api.createEvent(nullptr, 1, 0, nullptr);
    var last = _readIsLight(key, name);
    while (true) {
      // Asynchronous registration: signals [event] on the next change.
      if (_api.regNotify(key, 0, _regNotifyChangeLastSet, event, 1) != 0) {
        break;
      }
      while (_api.waitForSingleObject(event, 500) != _waitObject0) {
        // Let the isolate handle a kill between waits.
        await Future<void>.delayed(Duration.zero);
      }
      _api.resetEvent(event);
      final now = _readIsLight(key, name);
      if (now != last) {
        last = now;
        out.send(now);
      }
    }
    _api.closeHandle(event);
    _api.regCloseKey(key);
  }

  static Pointer<Void>? _openKey(String keyPath, {bool notify = false}) {
    final path = _Wide(keyPath);
    final out = _Mem(8);
    try {
      final access = _keyQueryValue | (notify ? _keyNotify : 0);
      final status = _api.regOpenKeyEx(
        _hkeyCurrentUser,
        path.ptr,
        0,
        access,
        out.ptr.cast(),
      );
      if (status != 0) return null;
      return out.ptr.cast<Pointer<Void>>().value;
    } finally {
      path.free();
      out.free();
    }
  }

  static bool _readIsLight(Pointer<Void> key, String valueName) {
    final name = _Wide(valueName);
    final data = _Mem(4);
    final size = _Mem(4);
    try {
      size.ptr.cast<Uint32>().value = 4;
      final status = _api.regGetValue(
        key,
        nullptr,
        name.ptr,
        _rrfRtRegDword,
        nullptr,
        data.ptr,
        size.ptr.cast(),
      );
      if (status != 0) return false;
      return data.ptr.cast<Uint32>().value != 0;
    } finally {
      name.free();
      data.free();
      size.free();
    }
  }
}

// HKEY_CURRENT_USER is (HKEY)(LONG)0x80000001, sign-extended on 64-bit.
final _hkeyCurrentUser = Pointer<Void>.fromAddress(-0x7FFFFFFF);
const _keyQueryValue = 0x0001;
const _keyNotify = 0x0010;
const _rrfRtRegDword = 0x00000010;
const _regNotifyChangeLastSet = 0x00000004;
const _waitObject0 = 0;

final _api = _Win32();

class _Win32 {
  _Win32() {
    final advapi = DynamicLibrary.open('advapi32.dll');
    final kernel = DynamicLibrary.open('kernel32.dll');
    regOpenKeyEx = advapi
        .lookupFunction<
          Int32 Function(
            Pointer<Void>,
            Pointer<Uint16>,
            Uint32,
            Uint32,
            Pointer<Pointer<Void>>,
          ),
          int Function(
            Pointer<Void>,
            Pointer<Uint16>,
            int,
            int,
            Pointer<Pointer<Void>>,
          )
        >('RegOpenKeyExW');
    regGetValue = advapi
        .lookupFunction<
          Int32 Function(
            Pointer<Void>,
            Pointer<Uint16>,
            Pointer<Uint16>,
            Uint32,
            Pointer<Uint32>,
            Pointer<Void>,
            Pointer<Uint32>,
          ),
          int Function(
            Pointer<Void>,
            Pointer<Uint16>,
            Pointer<Uint16>,
            int,
            Pointer<Uint32>,
            Pointer<Void>,
            Pointer<Uint32>,
          )
        >('RegGetValueW');
    regNotify = advapi
        .lookupFunction<
          Int32 Function(Pointer<Void>, Int32, Uint32, Pointer<Void>, Int32),
          int Function(Pointer<Void>, int, int, Pointer<Void>, int)
        >('RegNotifyChangeKeyValue');
    regCloseKey = advapi
        .lookupFunction<
          Int32 Function(Pointer<Void>),
          int Function(Pointer<Void>)
        >('RegCloseKey');
    createEvent = kernel
        .lookupFunction<
          Pointer<Void> Function(Pointer<Void>, Int32, Int32, Pointer<Uint16>),
          Pointer<Void> Function(Pointer<Void>, int, int, Pointer<Uint16>)
        >('CreateEventW');
    resetEvent = kernel
        .lookupFunction<
          Int32 Function(Pointer<Void>),
          int Function(Pointer<Void>)
        >('ResetEvent');
    waitForSingleObject = kernel
        .lookupFunction<
          Uint32 Function(Pointer<Void>, Uint32),
          int Function(Pointer<Void>, int)
        >('WaitForSingleObject');
    closeHandle = kernel
        .lookupFunction<
          Int32 Function(Pointer<Void>),
          int Function(Pointer<Void>)
        >('CloseHandle');
    final getProcessHeap = kernel
        .lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
          'GetProcessHeap',
        );
    heap = getProcessHeap();
    heapAlloc = kernel
        .lookupFunction<
          Pointer<Void> Function(Pointer<Void>, Uint32, IntPtr),
          Pointer<Void> Function(Pointer<Void>, int, int)
        >('HeapAlloc');
    heapFree = kernel
        .lookupFunction<
          Int32 Function(Pointer<Void>, Uint32, Pointer<Void>),
          int Function(Pointer<Void>, int, Pointer<Void>)
        >('HeapFree');
  }

  late final int Function(
    Pointer<Void>,
    Pointer<Uint16>,
    int,
    int,
    Pointer<Pointer<Void>>,
  )
  regOpenKeyEx;
  late final int Function(
    Pointer<Void>,
    Pointer<Uint16>,
    Pointer<Uint16>,
    int,
    Pointer<Uint32>,
    Pointer<Void>,
    Pointer<Uint32>,
  )
  regGetValue;
  late final int Function(Pointer<Void>, int, int, Pointer<Void>, int)
  regNotify;
  late final int Function(Pointer<Void>) regCloseKey;
  late final Pointer<Void> Function(Pointer<Void>, int, int, Pointer<Uint16>)
  createEvent;
  late final int Function(Pointer<Void>) resetEvent;
  late final int Function(Pointer<Void>, int) waitForSingleObject;
  late final int Function(Pointer<Void>) closeHandle;
  late final Pointer<Void> heap;
  late final Pointer<Void> Function(Pointer<Void>, int, int) heapAlloc;
  late final int Function(Pointer<Void>, int, Pointer<Void>) heapFree;
}

const _heapZeroMemory = 0x00000008;

/// A zeroed block of native memory.
class _Mem {
  _Mem(int bytes) : ptr = _api.heapAlloc(_api.heap, _heapZeroMemory, bytes);

  final Pointer<Void> ptr;

  void free() => _api.heapFree(_api.heap, 0, ptr);
}

/// A NUL-terminated UTF-16 string in native memory.
class _Wide {
  _Wide(String s) : _mem = _Mem((s.length + 1) * 2) {
    final units = _mem.ptr.cast<Uint16>();
    for (var i = 0; i < s.length; i++) {
      units[i] = s.codeUnitAt(i);
    }
  }

  final _Mem _mem;

  Pointer<Uint16> get ptr => _mem.ptr.cast();

  void free() => _mem.free();
}
