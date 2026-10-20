import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/sync_entry.dart';

/// The device's side of sync: reads and writes `travel_entries` with all
/// sync fields, including soft-deleted rows (PRD section 8.3).
class LocalSyncStore {
  LocalSyncStore(this._db);

  final AppDatabase _db;

  $TravelEntriesTable get _entries => _db.travelEntries;

  /// Rows changed since their last upload: `synced_at` is null or older
  /// than `updated_at`.
  Expression<bool> get _isPending =>
      _entries.syncedAt.isNull() |
      _entries.syncedAt.isSmallerThan(_entries.updatedAt);

  Future<List<SyncEntry>> pending() =>
      (_db.select(_entries)..where((_) => _isPending)).map(_toSync).get();

  /// Emits whenever the set of rows waiting for upload changes.
  Stream<List<SyncEntry>> watchPending() =>
      (_db.select(_entries)..where((_) => _isPending)).map(_toSync).watch();

  /// Applies cloud copies that win under [SyncRules.cloudWins], in one
  /// transaction, and marks them as synced. Returns how many were applied.
  Future<int> applyCloud(List<SyncEntry> cloud) {
    if (cloud.isEmpty) return Future.value(0);
    return _db.transaction(() async {
      final codes = [for (final entry in cloud) entry.countryCode];
      final local = {
        for (final row in await (_db.select(
          _entries,
        )..where((t) => t.countryCode.isIn(codes))).get())
          row.countryCode: _toSync(row),
      };
      var applied = 0;
      for (final entry in cloud) {
        if (!SyncRules.cloudWins(
          local: local[entry.countryCode],
          cloud: entry,
        )) {
          continue;
        }
        await _db
            .into(_entries)
            .insertOnConflictUpdate(
              _toCompanion(entry).copyWith(syncedAt: Value(entry.updatedAt)),
            );
        applied++;
      }
      return applied;
    });
  }

  /// Marks uploaded entries as synced, unless they changed again while the
  /// upload was running: those stay pending.
  Future<void> markSynced(List<SyncEntry> uploaded) =>
      _db.transaction(() async {
        for (final entry in uploaded) {
          await (_db.update(_entries)..where(
                (t) =>
                    t.countryCode.equals(entry.countryCode) &
                    t.updatedAt.equals(entry.updatedAt),
              ))
              .write(TravelEntriesCompanion(syncedAt: Value(entry.updatedAt)));
        }
      });

  /// Signing out removes the user's entries from the device; the cloud copy
  /// stays (D-4, FR-AUTH-06).
  Future<void> clearAll() => _db.delete(_entries).go();

  /// Deleted rows that are synced and older than 30 days are no longer
  /// needed to carry the deletion to other devices (PRD section 8.3).
  Future<void> purgeOldDeletions(DateTime now) {
    final cutoff = now
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;
    return (_db.delete(_entries)..where(
          (t) =>
              t.isDeleted.equals(true) &
              t.syncedAt.isBiggerOrEqual(t.updatedAt) &
              t.updatedAt.isSmallerThanValue(cutoff),
        ))
        .go();
  }

  static SyncEntry _toSync(TravelEntryRow row) => SyncEntry(
    countryCode: row.countryCode,
    status: row.status,
    visitedOn: row.visitedOn,
    rating: row.rating,
    priority: row.priority,
    targetYear: row.targetYear,
    notes: row.notes,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    isDeleted: row.isDeleted,
  );

  static TravelEntriesCompanion _toCompanion(SyncEntry entry) =>
      TravelEntriesCompanion(
        countryCode: Value(entry.countryCode),
        status: Value(entry.status),
        visitedOn: Value(entry.visitedOn),
        rating: Value(entry.rating),
        priority: Value(entry.priority),
        targetYear: Value(entry.targetYear),
        notes: Value(entry.notes),
        createdAt: Value(entry.createdAt),
        updatedAt: Value(entry.updatedAt),
        isDeleted: Value(entry.isDeleted),
      );
}
