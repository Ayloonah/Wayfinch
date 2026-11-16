import '../domain/item_rules.dart';
import 'database.dart';

/// App settings stored in the database, including which prompts were set to
/// "Always do this".
class SettingsRepository implements PromptPreferences {
  /// Creates a repository over [db].
  SettingsRepository(this._db);

  final WayfinchDatabase _db;

  static String _alwaysKey(PromptKind kind) => 'prompt.always.${kind.name}';

  @override
  Future<bool> isAlways(PromptKind kind) async =>
      await _get(_alwaysKey(kind)) == 'true';

  @override
  Future<void> setAlways(PromptKind kind) => setAsk(kind, ask: false);

  /// Turns the prompt for [kind] on ([ask] true) or off ("always do it").
  Future<void> setAsk(PromptKind kind, {required bool ask}) async {
    final key = _alwaysKey(kind);
    if (ask) {
      await (_db.delete(_db.settings)..where((s) => s.key.equals(key))).go();
    } else {
      await _db
          .into(_db.settings)
          .insertOnConflictUpdate(
            SettingsCompanion.insert(key: key, value: 'true'),
          );
    }
  }

  /// Which prompts are still asked, updated live.
  Stream<Map<PromptKind, bool>> watchAskPrompts() =>
      _db.select(_db.settings).watch().map((rows) {
        final values = {for (final r in rows) r.key: r.value};
        return {
          for (final kind in PromptKind.values)
            kind: values[_alwaysKey(kind)] != 'true',
        };
      });

  Future<String?> _get(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }
}
