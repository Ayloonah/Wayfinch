import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';
import 'home/home_controller.dart';
import 'home/home_screen.dart';
import 'theme/tokens.dart';

/// The root widget: theme, localization and the home screen.
class WayfinchApp extends StatelessWidget {
  /// Creates the app around [controller].
  const WayfinchApp({super.key, required this.controller});

  /// App state and actions.
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildTheme(),
      home: HomeScreen(controller: controller),
    );
  }
}
