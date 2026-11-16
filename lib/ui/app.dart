import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';
import 'home/home_controller.dart';
import 'home/home_screen.dart';
import 'theme/appearance_controller.dart';
import 'theme/tokens.dart';
import 'widgets/celebration.dart';

/// The root widget: theme, localization and the home screen.
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
  Widget build(BuildContext context) {
    return AppearanceScope(
      controller: appearance,
      child: ListenableBuilder(
        listenable: appearance,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          theme: buildTheme(appearance.colorsFor(Brightness.light)),
          darkTheme: buildTheme(appearance.colorsFor(Brightness.dark)),
          themeMode: appearance.themeMode,
          builder: (context, child) => Celebration(child: child!),
          home: HomeScreen(controller: controller, onReady: onReady),
        ),
      ),
    );
  }
}
