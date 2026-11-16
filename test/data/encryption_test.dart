import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayfinch/data/database.dart';
import 'package:wayfinch/data/database_opener.dart';
import 'package:wayfinch/domain/item_enums.dart';

Uint8List _key(int fill) => Uint8List.fromList(List.filled(32, fill));

void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('wayfinch_db');
    file = File('${dir.path}/test.db');
  });

  tearDown(() => dir.delete(recursive: true));

  Future<void> insertSecret(WayfinchDatabase db) => db
      .into(db.items)
      .insert(
        ItemsCompanion.insert(type: ItemType.task, title: 'TopSecretTitle'),
      );

  test(
    'encrypted file is unreadable on disk and reopens with the key',
    () async {
      final db = openWayfinchDatabase(file: file, key: _key(7));
      await insertSecret(db);
      await db.close();

      final bytes = await file.readAsBytes();
      expect(String.fromCharCodes(bytes), isNot(contains('SQLite format 3')));
      expect(String.fromCharCodes(bytes), isNot(contains('TopSecretTitle')));

      final reopened = openWayfinchDatabase(file: file, key: _key(7));
      final items = await reopened.select(reopened.items).get();
      expect(items.single.title, 'TopSecretTitle');
      await reopened.close();
    },
  );

  test('wrong key fails to open', () async {
    final db = openWayfinchDatabase(file: file, key: _key(7));
    await insertSecret(db);
    await db.close();

    final wrong = openWayfinchDatabase(file: file, key: _key(8));
    await expectLater(wrong.select(wrong.items).get(), throwsA(anything));
    await wrong.close();
  });

  test('without a key the file is plain SQLite', () async {
    final db = openWayfinchDatabase(file: file);
    await insertSecret(db);
    await db.close();

    final header = String.fromCharCodes((await file.readAsBytes()).take(15));
    expect(header, 'SQLite format 3');
  });

  test('foreign keys are enforced', () async {
    final db = openWayfinchDatabase(file: file);
    addTearDown(db.close);

    await expectLater(
      db
          .into(db.items)
          .insert(
            ItemsCompanion.insert(
              type: ItemType.task,
              title: 'Orphan',
              parentId: const Value('missing-parent'),
            ),
          ),
      throwsA(anything),
    );
  });
}
