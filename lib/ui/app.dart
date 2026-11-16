import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../app/app_session.dart';
import '../l10n/app_localizations.dart';
import 'home/home_controller.dart';
import 'home/home_screen.dart';
import 'onboarding/onboarding_flow.dart';
import 'security/unlock_screen.dart';
import 'theme/appearance_controller.dart';
import 'theme/tokens.dart';
import 'widgets/celebration.dart';

/// The MaterialApp setup shared by the real shell and [WayfinchApp]:
/// localization, theme (from [appearance], or the defaults before the
/// database is open) and the confetti layer.
Widget buildMaterialApp({
  required AppearanceController? appearance,
  required Widget home,
}) {
  Widget app() => MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    theme: buildTheme(
      appearance?.colorsFor(Brightness.light) ??
          WayfinchColors.resolve(Brightness.light, AccentChoice.sky),
    ),
    darkTheme: buildTheme(
      appearance?.colorsFor(Brightness.dark) ??
          WayfinchColors.resolve(Brightness.dark, AccentChoice.sky),
    ),
    themeMode: appearance?.themeMode ?? ThemeMode.system,
    builder: (context, child) => Celebration(child: child!),
    home: home,
  );
  if (appearance == null) return app();
  return AppearanceScope(
    controller: appearance,
    child: ListenableBuilder(listenable: appearance, builder: (_, _) => app()),
  );
}

/// The app with an already-open database (tests and the dev demo).
class WayfinchApp extends StatelessWidget {
  /// Creates the app around its controllers.
  const WayfinchApp({
    super.key,
    required this.controller,
    required this.appearance,
    this.onReady,
  });

  /// App state and actions.
  final HomeController controller;

  /// Theme settings.
  final AppearanceController appearance;

  /// Passed to [HomeScreen.onReady] (dev demo only).
  final void Function(BuildContext context)? onReady;

  @override
  Widget build(BuildContext context) => buildMaterialApp(
    appearance: appearance,
    home: HomeScreen(controller: controller, onReady: onReady),
  );
}

/// The real app: unlock screen, setup, or the main screen, following
/// [session].
class WayfinchShell extends StatelessWidget {
  /// Creates the shell.
  const WayfinchShell({super.key, required this.session});

  /// Database, controllers and password state.
  final AppSession session;

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      session: session,
      child: ListenableBuilder(
        listenable: session,
        builder: (context, _) {
          final home = session.home;
          final Widget screen = switch (session.phase) {
            SessionPhase.starting => const Scaffold(),
            SessionPhase.locked => const UnlockScreen(),
            SessionPhase.ready when session.mustChooseNewPassword =>
              const NewPasswordScreen(),
            SessionPhase.ready when session.needsOnboarding => HomeScope(
              controller: home!,
              child: const OnboardingFlow(),
            ),
            SessionPhase.ready => HomeScreen(
              key: ObjectKey(home),
              controller: home!,
            ),
          };
          return buildMaterialApp(appearance: session.appearance, home: screen);
        },
      ),
    );
  }
}

/// Makes the [AppSession] available (Settings › Profile, setup).
class SessionScope extends InheritedNotifier<AppSession> {
  /// Provides [session] to [child].
  const SessionScope({
    super.key,
    required AppSession session,
    required super.child,
  }) : super(notifier: session);

  /// The session, or null when the app runs without one (tests, demo).
  static AppSession? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SessionScope>()?.notifier;
}
