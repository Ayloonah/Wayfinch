import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'database.dart';

/// File name of the database inside the app data folder.
const databaseFileName = 'wayfinch.db';

/// File name of the key vault, next to the database.
const vaultFileName = 'wayfinch.vault.json';

/// The folder Wayfinch keeps its data in (per user; `%APPDATA%\app.wayfinch\wayfinch` on Windows).
Future<Directory> wayfinchDataDirectory() async {
  final dir = await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  return dir;
}

/// Opens (or creates) the database in [file].
///
/// With a [key] the file is encrypted with SQLCipher; without one it is a
/// plain SQLite file (the password is optional). Either way this checks that
/// the SQLCipher build is loaded, so a misconfigured build can never silently
/// write an unencrypted file when a key was given.
WayfinchDatabase openWayfinchDatabase({required File file, Uint8List? key}) {
  return WayfinchDatabase(openDatabaseExecutor(file: file, key: key));
}

/// Opens the query executor behind [openWayfinchDatabase]. Exposed for tests.
QueryExecutor openDatabaseExecutor({required File file, Uint8List? key}) {
  return NativeDatabase.createInBackground(
    file,
    setup: (db) => applyEncryptionKey(db, key),
  );
}

/// Applies SQLCipher [key] to a freshly opened [db] and checks it works.
///
/// Throws a [StateError] if SQLCipher isn't available, and a
/// [SqliteException] if the key doesn't match the file.
void applyEncryptionKey(Database db, Uint8List? key) {
  final cipher = db.select('PRAGMA cipher_version');
  if (cipher.isEmpty) {
    throw StateError('SQLCipher is not available in this build.');
  }
  if (key == null) return;
  if (key.length != 32) {
    throw ArgumentError.value(key.length, 'key', 'must be 32 bytes');
  }
  db.execute('PRAGMA key = "x\'${_hex(key)}\'"');
  // Reading the schema fails right away if the key is wrong.
  db.select('SELECT count(*) FROM sqlite_master');
}

/// Default database file location: `<app data>/wayfinch.db`.
Future<File> defaultDatabaseFile() async =>
    File(p.join((await wayfinchDataDirectory()).path, databaseFileName));

String _hex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
