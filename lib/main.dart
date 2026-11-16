import 'package:flutter/material.dart';

import 'data/database_opener.dart';
import 'data/items_repository.dart';
import 'data/settings_repository.dart';
import 'data/tags_repository.dart';
import 'ui/app.dart';
import 'ui/home/home_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // No password setup yet (that's onboarding, milestone 5), so the database
  // opens unencrypted. The SQLCipher check still runs.
  final db = openWayfinchDatabase(file: await defaultDatabaseFile());
  final controller = HomeController(
    items: ItemsRepository(db),
    tags: TagsRepository(db),
    settings: SettingsRepository(db),
  );
  runApp(WayfinchApp(controller: controller));
}
