// Dev-only entry point: the real app (unlock, setup, everything) on a fresh,
// throwaway data folder, so first-run setup can be tried without touching
// real data. Not part of the shipped app.
//
//   flutter run -d windows -t dev/fresh_main.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wayfinch/app/app_session.dart';
import 'package:wayfinch/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = Directory.systemTemp.createTempSync('wayfinch_fresh_');
  final session = AppSession(dataDir: dir);
  runApp(WayfinchShell(session: session));
  await session.start();
}
