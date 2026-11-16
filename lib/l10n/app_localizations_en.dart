// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wayfinch';

  @override
  String get homeGreeting => 'Hi there!';

  @override
  String get homeGettingReady =>
      'Wayfinch is getting ready. Your lists will live here soon.';

  @override
  String homeItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items yet',
    );
    return '$_temp0';
  }

  @override
  String get databaseOpenError =>
      'Hmm, Wayfinch couldn\'t open your data. Try restarting the app.';
}
