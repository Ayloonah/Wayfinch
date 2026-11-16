import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/exchange/import_plan.dart';
import 'database.dart';
import 'items_repository.dart';

/// How many backups are kept (oldest are dropped).
const maxImportBackups = 10;

/// Why a backup was taken.
enum BackupReason {
  /// Right before an AI import.
  import,

  /// Right before restoring an older backup (so the restore can be undone).
  restore,
}

/// Info about one stored backup.
class ImportBackupInfo {
  /// Creates the info.
  const ImportBackupInfo({
    required this.id,
    required this.createdAt,
    this.reason = BackupReason.import,
    this.mode,
    this.changes,
    this.itemCount = 0,
  });

  /// Backup row id (newest = highest).
  final int id;

  /// When it was taken.
  final DateTime createdAt;

  /// Why it was taken.
  final BackupReason reason;

  /// For imports: Add or Replace (null for older backups).
  final ImportMode? mode;

  /// For imports: how many changes the import made (null if unknown).
  final int? changes;

  /// How many items the list had at that point.
  final int itemCount;
}

/// Applies AI imports, undoes them, and restores older backups.
///
/// Every import first stores a snapshot of the whole list (items, tags, tag
/// links, reminders) in the database. Backups live in the database, so
/// they're encrypted with it. The last [maxImportBackups] are kept.
class ImportRepository {
  /// Creates a repository over [db]. [items] does the item writes.
  ImportRepository(this._db, this._items, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final WayfinchDatabase _db;
  final ItemsRepository _items;
  final DateTime Function() _clock;

  /// Backs up the list, then applies [plan] (minus removals in [keep]) in
  /// one transaction. Creates any tags the import introduces. Returns the
  /// number of items touched.
  Future<int> apply(
    ImportPlan plan, {
    Set<String> keep = const {},
    required int Function(int existingCount) colorFor,
  }) {
    return _db.transaction(() async {
      final now = _clock();
      // Snapshot first: before any new tags exist.
      await _backup(
        now,
        reason: BackupReason.import,
        mode: plan.mode,
        changes: plan.countFor(keep),
      );
      final tagIds = await _ensureTags(plan.newTagNames, colorFor, now);
      final changes = plan.build(tagIdsByName: tagIds, keep: keep);
      await _items.applyInTransaction(
        updated: changes.updated,
        created: changes.created,
        deletedIds: changes.deletedIds,
      );
      return changes.total;
    });
  }

  /// The latest backup, live (null when there's nothing to undo).
  Stream<ImportBackupInfo?> watchLatest() =>
      watchAll().map((list) => list.firstOrNull);

  /// Every stored backup, newest first, live.
  Stream<List<ImportBackupInfo>> watchAll() {
    final query = _db.select(_db.importBackups)
      ..orderBy([(b) => OrderingTerm.desc(b.id)]);
    return query.watch().map((rows) => rows.map(_info).toList());
  }

  /// Puts the list back exactly as it was before the latest backup was
  /// taken, and drops that backup. Changes made since are lost. Returns
  /// false when there was nothing to undo.
  Future<bool> undoLatest() {
    return _db.transaction(() async {
      final row =
          await (_db.select(_db.importBackups)
                ..orderBy([(b) => OrderingTerm.desc(b.id)])
                ..limit(1))
              .getSingleOrNull();
      if (row == null) return false;
      await _restore(row.payload);
      await (_db.delete(
        _db.importBackups,
      )..where((b) => b.id.equals(row.id))).go();
      return true;
    });
  }

  /// Restores backup [id]. The current list is backed up first (as a
  /// "before restore" backup), so this can be undone too. Returns false if
  /// that backup no longer exists.
  Future<bool> restore(int id) {
    return _db.transaction(() async {
      final row = await (_db.select(
        _db.importBackups,
      )..where((b) => b.id.equals(id))).getSingleOrNull();
      if (row == null) return false;
      await _backup(_clock(), reason: BackupReason.restore);
      await _restore(row.payload);
      return true;
    });
  }

  ImportBackupInfo _info(ImportBackupRow row) {
    // Only the small header is needed; older backups have none.
    final data = jsonDecode(row.payload) as Map<String, dynamic>;
    final meta = data['meta'] as Map<String, dynamic>? ?? const {};
    return ImportBackupInfo(
      id: row.id,
      createdAt: row.createdAt,
      reason:
          BackupReason.values.asNameMap()[meta['reason']] ??
          BackupReason.import,
      mode: ImportMode.values.asNameMap()[meta['mode']],
      changes: meta['changes'] as int?,
      itemCount: (data['items'] as List?)?.length ?? 0,
    );
  }

  Future<void> _backup(
    DateTime now, {
    required BackupReason reason,
    ImportMode? mode,
    int? changes,
  }) async {
    await _db
        .into(_db.importBackups)
        .insert(
          ImportBackupsCompanion.insert(
            createdAt: now,
            payload: await _snapshot({
              'reason': reason.name,
              'mode': ?mode?.name,
              'changes': ?changes,
            }),
          ),
        );
    await _pruneBackups();
  }

  Future<Map<String, String>> _ensureTags(
    List<String> names,
    int Function(int) colorFor,
    DateTime now,
  ) async {
    final existing = await _db.select(_db.tags).get();
    final byName = {for (final t in existing) t.name.toLowerCase(): t.id};
    var count = existing.length;
    for (final name in names) {
      final lower = name.toLowerCase();
      if (byName.containsKey(lower)) continue;
      final row = await _db
          .into(_db.tags)
          .insertReturning(
            TagsCompanion.insert(
              name: name,
              color: colorFor(count++),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      byName[lower] = row.id;
    }
    return byName;
  }

  Future<void> _pruneBackups() async {
    final rows = await (_db.select(
      _db.importBackups,
    )..orderBy([(b) => OrderingTerm.desc(b.id)])).get();
    for (final old in rows.skip(maxImportBackups)) {
      await (_db.delete(
        _db.importBackups,
      )..where((b) => b.id.equals(old.id))).go();
    }
  }

  Future<String> _snapshot(Map<String, Object> meta) async => jsonEncode({
    'meta': meta,
    'items': [for (final r in await _db.select(_db.items).get()) r.toJson()],
    'tags': [for (final r in await _db.select(_db.tags).get()) r.toJson()],
    'itemTags': [
      for (final r in await _db.select(_db.itemTags).get()) r.toJson(),
    ],
    'reminders': [
      for (final r in await _db.select(_db.reminders).get()) r.toJson(),
    ],
  });

  Future<void> _restore(String payload) async {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    List<Map<String, dynamic>> rows(String key) =>
        (data[key] as List).cast<Map<String, dynamic>>();

    // Parents and children go in together; check references at commit.
    await _db.customStatement('PRAGMA defer_foreign_keys = ON');
    await _db.delete(_db.itemTags).go();
    await _db.delete(_db.reminders).go();
    await _db.delete(_db.items).go();
    await _db.delete(_db.tags).go();
    await _db.batch((b) {
      b.insertAll(_db.tags, [for (final r in rows('tags')) TagRow.fromJson(r)]);
      b.insertAll(_db.items, [
        for (final r in rows('items')) ItemRow.fromJson(r),
      ]);
      b.insertAll(_db.itemTags, [
        for (final r in rows('itemTags')) ItemTagRow.fromJson(r),
      ]);
      b.insertAll(_db.reminders, [
        for (final r in rows('reminders')) ReminderRow.fromJson(r),
      ]);
    });
  }
}
