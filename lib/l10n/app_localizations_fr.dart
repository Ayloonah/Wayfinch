// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Wayfinch';

  @override
  String get homeGreeting => 'Salut !';

  @override
  String get homeGettingReady =>
      'Wayfinch se prépare. Tes listes vont bientôt vivre ici.';

  @override
  String homeItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '1 élément',
      zero: 'Aucun élément pour l’instant',
    );
    return '$_temp0';
  }

  @override
  String get databaseOpenError =>
      'Oups, Wayfinch n’arrive pas à ouvrir tes données. Essaie de redémarrer l’app.';
}
