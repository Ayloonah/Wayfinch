import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/data/database.dart';
import 'package:wayfinch/data/items_repository.dart';
import 'package:wayfinch/main.dart';

void main() {
  Future<WayfinchDatabase> pumpApp(WidgetTester tester, Locale locale) async {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final db = WayfinchDatabase(NativeDatabase.memory());
    await tester.pumpWidget(WayfinchApp(repository: ItemsRepository(db)));
    await tester.pumpAndSettle();
    return db;
  }

  testWidgets('shows the English placeholder home', (tester) async {
    final db = await pumpApp(tester, const Locale('en'));

    expect(find.text('Hi there!'), findsOneWidget);
    expect(find.text('No items yet'), findsOneWidget);

    await db.close();
  });

  testWidgets('shows the French placeholder home', (tester) async {
    final db = await pumpApp(tester, const Locale('fr'));

    expect(find.text('Salut !'), findsOneWidget);
    expect(find.text('Aucun élément pour l’instant'), findsOneWidget);

    await db.close();
  });
}
