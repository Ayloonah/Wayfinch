import 'package:drift/drift.dart';

import '../domain/item.dart';
import 'database.dart';

/// Reads and writes user tags.
class TagsRepository {
  /// Creates a repository over [db].
  TagsRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final WayfinchDatabase _db;
  final DateTime Function() _clock;

  /// All tags by name, updated live.
  Stream<List<Tag>> watchAll() =>
      (_db.select(_db.tags)..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch()
          .map((rows) => rows.map(_toTag).toList());

  /// All tags by name.
  Future<List<Tag>> loadAll() =>
      (_db.select(_db.tags)..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get()
          .then((rows) => rows.map(_toTag).toList());

  /// Returns the tag called [name] (ignoring case), creating it with
  /// [colorFor] (given how many tags exist) when it doesn't exist yet.
  Future<Tag> findOrCreate(
    String name, {
    required int Function(int existingCount) colorFor,
  }) async {
    final trimmed = name.trim();
    return _db.transaction(() async {
      final existing = await loadAll();
      for (final tag in existing) {
        if (tag.name.toLowerCase() == trimmed.toLowerCase()) return tag;
      }
      final now = _clock();
      final row = await _db
          .into(_db.tags)
          .insertReturning(
            TagsCompanion.insert(
              name: trimmed,
              color: colorFor(existing.length),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      return _toTag(row);
    });
  }

  Tag _toTag(TagRow row) => Tag(id: row.id, name: row.name, color: row.color);
}
