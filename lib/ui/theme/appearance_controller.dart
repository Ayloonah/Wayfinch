import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/settings_repository.dart';
import 'tokens.dart';

/// Loads, applies and saves the user's [ThemeSettings].
class AppearanceController extends ChangeNotifier {
  /// Creates the controller and starts listening to stored settings.
  AppearanceController(this._settings) {
    _subscription = _settings.watchAll().listen(_onSettings);
  }

  static const _modeKey = 'theme.mode';
  static const _accentKey = 'theme.accent';
  static const _customKey = 'theme.custom';

  final SettingsRepository _settings;
  late final StreamSubscription<Map<String, String>> _subscription;

  ThemeSettings _value = const ThemeSettings();

  /// The current settings.
  ThemeSettings get value => _value;

  void _onSettings(Map<String, String> stored) {
    final next = ThemeSettings(
      mode:
          ThemeModeSetting.values.asNameMap()[stored[_modeKey]] ??
          ThemeModeSetting.system,
      accent:
          AccentChoice.values.asNameMap()[stored[_accentKey]] ??
          AccentChoice.sky,
      custom: CustomTheme.decode(stored[_customKey]),
    );
    if (next == _value) return;
    _value = next;
    notifyListeners();
  }

  /// Light, dark or system.
  Future<void> setMode(ThemeModeSetting mode) {
    _apply(_value.copyWith(mode: mode));
    return _settings.setValue(_modeKey, mode.name);
  }

  /// Picks an accent (or the custom theme).
  Future<void> setAccent(AccentChoice accent) {
    _apply(_value.copyWith(accent: accent));
    return _settings.setValue(_accentKey, accent.name);
  }

  /// Saves the custom palette (and switches to it).
  Future<void> setCustom(CustomTheme custom) async {
    _apply(_value.copyWith(custom: custom, accent: AccentChoice.custom));
    await _settings.setValue(_customKey, custom.encode());
    await _settings.setValue(_accentKey, AccentChoice.custom.name);
  }

  // Applies right away so the UI doesn't wait for the database round trip.
  void _apply(ThemeSettings next) {
    if (next == _value) return;
    _value = next;
    notifyListeners();
  }

  /// Material theme mode for the current settings.
  ThemeMode get themeMode {
    if (_value.accent == AccentChoice.custom) {
      return _value.custom.isDarkTheme ? ThemeMode.dark : ThemeMode.light;
    }
    return switch (_value.mode) {
      ThemeModeSetting.system => ThemeMode.system,
      ThemeModeSetting.light => ThemeMode.light,
      ThemeModeSetting.dark => ThemeMode.dark,
    };
  }

  /// Colors for [brightness] under the current settings.
  WayfinchColors colorsFor(Brightness brightness) =>
      WayfinchColors.resolve(brightness, _value.accent, custom: _value.custom);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Makes the [AppearanceController] available to Settings.
class AppearanceScope extends InheritedNotifier<AppearanceController> {
  /// Provides [controller] to [child].
  const AppearanceScope({
    super.key,
    required AppearanceController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The nearest controller.
  static AppearanceController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppearanceScope>()!.notifier!;
}
