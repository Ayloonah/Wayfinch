import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lets database work (real async) and the UI catch up.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

/// Runs [future] (database work started in the test zone) to completion by
/// pumping, since the test zone's timers only move when pumped.
Future<T> pumpUntilDone<T>(WidgetTester tester, Future<T> future) async {
  var done = false;
  late T result;
  unawaited(
    future.then((value) {
      result = value;
      done = true;
    }),
  );
  for (var i = 0; i < 200 && !done; i++) {
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 2)),
    );
  }
  if (!done) throw StateError('Timed out waiting for database work');
  return result;
}

/// The first text field inside the open dialog.
Finder dialogField() => find
    .descendant(of: find.byType(Dialog), matching: find.byType(TextField))
    .first;

/// A SelectableText (the export preview) containing [text].
Finder selectable(String text) => find.byWidgetPredicate(
  (w) => w is SelectableText && (w.data ?? '').contains(text),
);

/// Moves a drag gesture to [to] in small steps, one frame each, the way a
/// real mouse drag reaches a reorderable list.
Future<void> dragTo(
  WidgetTester tester,
  TestGesture gesture, {
  required Offset from,
  required Offset to,
}) async {
  const steps = 12;
  final step = (to - from) / steps.toDouble();
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(step);
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Pumps until [finder] finds something (slow work such as key derivation
/// and real file IO), or fails after about 5 seconds.
Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
  expect(finder, findsWidgets);
}
