import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/database_opener.dart';
import 'data/items_repository.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Milestone 1: no password setup yet (that's onboarding, milestone 5), so
  // the database opens unencrypted. The SQLCipher check still runs.
  final db = openWayfinchDatabase(file: await defaultDatabaseFile());
  runApp(WayfinchApp(repository: ItemsRepository(db)));
}

/// The root widget: theme, localization and the home screen.
class WayfinchApp extends StatelessWidget {
  /// Creates the app around an [ItemsRepository].
  const WayfinchApp({super.key, required this.repository});

  /// Where items are read from.
  final ItemsRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF60A3EB)),
      home: PlaceholderHome(repository: repository),
    );
  }
}

/// Temporary home screen until the three-pane layout lands (milestone 2).
class PlaceholderHome extends StatelessWidget {
  /// Creates the placeholder screen.
  const PlaceholderHome({super.key, required this.repository});

  /// Source of the item count shown on screen.
  final ItemsRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.homeGreeting, style: textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(l10n.homeGettingReady),
            const SizedBox(height: 16),
            _ItemCount(repository: repository),
          ],
        ),
      ),
    );
  }
}

class _ItemCount extends StatelessWidget {
  const _ItemCount({required this.repository});

  final ItemsRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StreamBuilder<int>(
      stream: repository.watchCount(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(l10n.databaseOpenError);
        if (!snapshot.hasData) return const SizedBox.shrink();
        return Text(l10n.homeItemCount(snapshot.data!));
      },
    );
  }
}
