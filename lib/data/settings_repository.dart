import '../domain/item_rules.dart';
import 'database.dart';

/// App settings stored in the database, including remembered prompt answers.
class SettingsRepository implements PromptPreferences {
  /// Creates a repository over [db].
  SettingsRepository(this._db);

  final WayfinchDatabase _db;

  // Key name kept from the first version, which could only store "true"
  // (= always confirm); that value still reads as confirm.
  static String _key(PromptKind kind) => 'prompt.always.${kind.name}';

  static PromptAnswer? _decode(String? value) => switch (value) {
    'true' || 'confirm' => PromptAnswer.confirm,
    'cancel' => PromptAnswer.cancel,
    _ => null,
  };

  @override
  Future<PromptAnswer?> remembered(PromptKind kind) async {
    final key = _key(kind);
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return _decode(row?.value);
  }

  @override
  Future<void> remember(PromptKind kind, PromptAnswer? answer) async {
    final key = _key(kind);
    if (answer == null) {
      await (_db.delete(_db.settings)..where((s) => s.key.equals(key))).go();
    } else {
      await _db
          .into(_db.settings)
          .insertOnConflictUpdate(
            SettingsCompanion.insert(key: key, value: answer.name),
          );
    }
  }

  /// The value stored under [key], or null.
  Future<String?> getValue(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  /// Stores [value] under [key], or removes the key when null.
  Future<void> setValue(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.settings)..where((s) => s.key.equals(key))).go();
    } else {
      await _db
          .into(_db.settings)
          .insertOnConflictUpdate(
            SettingsCompanion.insert(key: key, value: value),
          );
    }
  }

  /// All stored settings as key/value pairs, updated live.
  Stream<Map<String, String>> watchAll() => _db
      .select(_db.settings)
      .watch()
      .map((rows) => {for (final r in rows) r.key: r.value});

  /// Remembered prompt answers (null = ask), updated live.
  Stream<Map<PromptKind, PromptAnswer?>> watchRemembered() =>
      _db.select(_db.settings).watch().map((rows) {
        final values = {for (final r in rows) r.key: r.value};
        return {
          for (final kind in PromptKind.values)
            kind: _decode(values[_key(kind)]),
        };
      });
}
