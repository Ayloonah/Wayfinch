import 'package:flutter/material.dart';

import 'app/app_session.dart';
import 'data/database_opener.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = AppSession(dataDir: await wayfinchDataDirectory());
  runApp(WayfinchShell(session: session));
  // Unlock screen when a password is set; otherwise the database opens
  // (and setup runs the first time).
  await session.start();
}
