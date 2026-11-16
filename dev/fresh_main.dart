// Dev-only entry point: the real app (unlock, setup, everything) on a fresh,
// throwaway data folder, so first-run setup can be tried without touching
// real data. Not part of the shipped app.
//
//   flutter run -d windows -t dev/fresh_main.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wayfinch/app/app_session.dart';
import 'package:wayfinch/app/desktop.dart';
import 'package:wayfinch/ui/app.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Tray, close-to-tray and toasts as in the real app, but never touching
  // the "start with Windows" registry entry.
  // Its own single-instance name, so it runs next to an installed Wayfinch
  // instead of handing over to it.
  final desktop = await Desktop.start(
    args,
    manageStartup: false,
    instanceName: 'wayfinch_fresh_dev',
  );
  final dir = Directory.systemTemp.createTempSync('wayfinch_fresh_');
  final session = AppSession(dataDir: dir);
  desktop.attach(session);
  runApp(WayfinchShell(session: session));
  await session.start();
}
