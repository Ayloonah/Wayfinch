import 'dart:io';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

/// Turns a plain database file into a SQLCipher-encrypted one (and back),
/// in place. The database must be closed while this runs.
///
/// SQLCipher can't encrypt a plain file directly, so the data is exported
/// into a new file (`sqlcipher_export`), which then replaces the original.
/// The schema version (`user_version`, used by Drift for migrations) is
/// carried over. If anything fails, the original file is left untouched.
class DatabaseConversion {
  const DatabaseConversion._();

  /// Encrypts the plain database [file] with [key] (32 bytes).
  static void encrypt(File file, Uint8List key) =>
      _convert(file, fromKey: null, toKey: key);

  /// Decrypts [file] (encrypted with [key]) back to plain SQLite.
  static void decrypt(File file, Uint8List key) =>
      _convert(file, fromKey: key, toKey: null);

  static void _convert(
    File file, {
    required Uint8List? fromKey,
    required Uint8List? toKey,
  }) {
    final temp = File('${file.path}.converting');
    if (temp.existsSync()) temp.deleteSync();
    final db = sqlite3.open(file.path);
    try {
      if (fromKey != null) db.execute('PRAGMA key = "${_keyLiteral(fromKey)}"');
      final version =
          db.select('PRAGMA user_version').first.values.first as int;
      final keyClause = toKey == null ? "''" : '"${_keyLiteral(toKey)}"';
      db.execute(
        "ATTACH DATABASE '${_quote(temp.path)}' AS converted KEY $keyClause",
      );
      db.select("SELECT sqlcipher_export('converted')");
      db.execute('PRAGMA converted.user_version = $version');
      db.execute('DETACH DATABASE converted');
    } catch (_) {
      db.close();
      if (temp.existsSync()) temp.deleteSync();
      rethrow;
    }
    db.close();

    // Swap: keep the original as .bak until the new file is in place.
    final backup = File('${file.path}.bak');
    if (backup.existsSync()) backup.deleteSync();
    file.renameSync(backup.path);
    try {
      temp.renameSync(file.path);
    } catch (_) {
      backup.renameSync(file.path);
      rethrow;
    }
    backup.deleteSync();
  }

  /// SQLCipher raw-key syntax: `x'<64 hex chars>'`.
  static String _keyLiteral(Uint8List key) {
    if (key.length != 32) {
      throw ArgumentError.value(key.length, 'key', 'must be 32 bytes');
    }
    final hex = key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return "x'$hex'";
  }

  static String _quote(String path) => path.replaceAll("'", "''");
}
