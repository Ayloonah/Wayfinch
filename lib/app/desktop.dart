// window_manager 0.6 and tray_manager 0.8 moved to a new native API; their
// classic API (used here) lives on in `legacy.dart` and is marked
// deprecated. Newer versions need a newer Dart than this project uses.
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as p;
import 'package:tray_manager/legacy.dart';
import 'package:window_manager/legacy.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

import '../l10n/app_localizations.dart';
import 'app_session.dart';
import 'notification_service.dart';
import 'system_theme.dart';

/// Command-line flag used when Windows starts Wayfinch at login: start
/// hidden in the tray.
const startMinimizedFlag = '--minimized';

/// Wires Wayfinch into Windows: one running copy, close-to-tray with a tray
/// menu, toast notifications (with Snooze buttons), and starting with
/// Windows.
class Desktop with TrayListener, WindowListener {
  Desktop._(this._l10n, {required this.manageStartup});

  final AppLocalizations _l10n;

  /// Whether to keep the "start with Windows" registry entry in sync (off
  /// for dev entry points, which shouldn't register themselves).
  final bool manageStartup;
  final _notifications = FlutterLocalNotificationsPlugin();
  AppSession? _session;
  NotificationService? _service;
  bool _quitting = false;
  bool? _startupApplied;

  /// Sets everything up before the app runs. A second launch hands over to
  /// the running copy (which shows its window) and exits.
  static Future<Desktop> start(
    List<String> args, {
    bool manageStartup = true,
  }) async {
    await WindowsSingleInstance.ensureSingleInstance(
      args,
      'wayfinch_single_instance',
      onSecondWindow: (_) => _instance?.showWindow(),
    );
    await windowManager.ensureInitialized();
    final l10n = _appLocalizations();
    final desktop = Desktop._(l10n, manageStartup: manageStartup);
    _instance = desktop;
    windowManager.addListener(desktop);
    await windowManager.setPreventClose(true);
    trayManager.addListener(desktop);
    await desktop._setUpTray();
    await desktop._setUpNotifications();
    if (args.contains(startMinimizedFlag)) {
      await windowManager.hide();
    }
    return desktop;
  }

  static Desktop? _instance;

  static AppLocalizations _appLocalizations() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    try {
      return lookupAppLocalizations(Locale(locale.languageCode));
    } on FlutterError {
      return lookupAppLocalizations(const Locale('en'));
    }
  }

  /// A notifier backed by Windows toasts.
  Notifier get notifier => _ToastNotifier(_notifications);

  /// Strings for notifications, in the system language.
  AppLocalizations get l10n => _l10n;

  /// Follows [session]: starts the notification service whenever the
  /// database opens, and keeps "Start with Windows" in sync.
  void attach(AppSession session) {
    _session = session;
    session.addListener(_onSession);
    _onSession();
  }

  void _onSession() {
    final home = _session?.home;
    if (home == null) {
      _service?.dispose();
      _service = null;
      return;
    }
    if (_service?.home == home) return;
    _service?.dispose();
    final service = NotificationService(
      home: home,
      notifier: notifier,
      l10n: _l10n,
      locale: Platform.localeName.split('.').first.replaceAll('_', '-'),
      onOpenItem: (id) {
        showWindow();
        if (id != null) home.select(id);
      },
    );
    _service = service;
    service.start();
    home.addListener(
      () => _syncStartup(home.notificationPrefs.launchAtStartup),
    );
    _syncStartup(home.notificationPrefs.launchAtStartup);
  }

  /// Brings the window back (from the tray or behind other windows).
  Future<void> showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _quit() async {
    _quitting = true;
    _service?.dispose();
    await _themeChanges?.cancel();
    await trayManager.destroy();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }

  // ---- Icons follow the Windows system theme ------------------------------

  /// Sets the tray and running-window (taskbar, title bar) icons for the
  /// Windows *system* theme: the navy-check mark on light, the light-check
  /// mark on dark. The exe's embedded icon stays the outlined one.
  Future<void> _applyThemeIcons(bool systemIsLight) async {
    final icon = systemIsLight
        ? 'assets/icons/wayfinch_light.ico'
        : 'assets/icons/wayfinch_dark.ico';
    await trayManager.setIcon(icon);
    await windowManager.setIcon(icon);
  }

  void _followSystemTheme() {
    _themeChanges = SystemTheme.changes().listen(
      (light) => unawaited(_applyThemeIcons(light)),
    );
  }

  StreamSubscription<bool>? _themeChanges;

  // ---- Tray ---------------------------------------------------------------

  Future<void> _setUpTray() async {
    await _applyThemeIcons(SystemTheme.isLight());
    _followSystemTheme();
    await trayManager.setToolTip(_l10n.appTitle);
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: 'open', label: _l10n.trayOpen),
          MenuItem.separator(),
          MenuItem(key: 'quit', label: _l10n.trayQuit),
        ],
      ),
    );
  }

  @override
  void onTrayIconMouseDown() => showWindow();

  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu();

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'open':
        showWindow();
      case 'quit':
        _quit();
    }
  }

  // ---- Window: closing hides to the tray ----------------------------------

  @override
  Future<void> onWindowClose() async {
    if (_quitting) return;
    await windowManager.hide();
    final settings = _session?.settings;
    if (settings == null) return;
    if (await settings.getValue('app.trayHintShown') != 'true') {
      await settings.setValue('app.trayHintShown', 'true');
      await notifier.show(
        id: 2,
        title: _l10n.trayHintTitle,
        body: _l10n.trayHintBody,
        payload: 'tray',
      );
    }
  }

  // ---- Notifications --------------------------------------------------------

  Future<void> _setUpNotifications() async {
    await _notifications.initialize(
      settings: InitializationSettings(
        windows: WindowsInitializationSettings(
          appName: _l10n.appTitle,
          appUserModelId: 'Wayfinch.Wayfinch.Desktop',
          guid: '6f7c1b3e-2a4d-4c8e-9b1f-5d3a7e9c2b41',
          iconPath: _notificationIconPath(),
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final args = response.actionId ?? response.payload;
        if (args != null) _service?.handle(args);
      },
    );
  }

  /// The bundled logo for toasts (next to the exe, in Flutter's assets), or
  /// null if it isn't there.
  static String? _notificationIconPath() {
    final path = p.join(
      File(Platform.resolvedExecutable).parent.path,
      'data',
      'flutter_assets',
      'assets',
      'brand',
      'notification_icon.png',
    );
    return File(path).existsSync() ? path : null;
  }

  // ---- Start with Windows (HKCU Run key, via the built-in reg tool) --------

  static const _runKey = r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run';

  Future<void> _syncStartup(bool enabled) async {
    if (!manageStartup || _startupApplied == enabled) return;
    _startupApplied = enabled;
    try {
      if (enabled) {
        final exe = Platform.resolvedExecutable;
        await Process.run('reg', [
          'add',
          _runKey,
          '/v',
          'Wayfinch',
          '/t',
          'REG_SZ',
          '/d',
          '"$exe" $startMinimizedFlag',
          '/f',
        ]);
      } else {
        await Process.run('reg', ['delete', _runKey, '/v', 'Wayfinch', '/f']);
      }
    } on ProcessException {
      _startupApplied = null; // try again next time
    }
  }
}

class _ToastNotifier implements Notifier {
  _ToastNotifier(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String payload,
    List<NotificationButton> buttons = const [],
  }) => _plugin.show(
    id: id,
    title: title,
    body: body,
    payload: payload,
    notificationDetails: NotificationDetails(
      windows: WindowsNotificationDetails(
        actions: [
          for (final b in buttons)
            WindowsAction(content: b.label, arguments: b.arguments),
        ],
      ),
    ),
  );
}
