import 'package:flutter/material.dart';

import 'app/app_session.dart';
import 'app/desktop.dart';
import 'data/database_opener.dart';
import 'ui/app.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  // One running copy, the tray, close-to-tray, toasts, start with Windows.
  final desktop = await Desktop.start(args);
  final session = AppSession(dataDir: await wayfinchDataDirectory());
  desktop.attach(session);
  runApp(WayfinchShell(session: session));
  // Unlock screen when a password is set; otherwise the database opens
  // (and setup runs the first time).
  await session.start();
}
