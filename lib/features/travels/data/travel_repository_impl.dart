import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/travel_entry.dart';
import '../domain/travel_repository.dart';

class TravelRepositoryImpl implements TravelRepository {
  TravelRepositoryImpl(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  $TravelEntriesTable get _entries => _db.travelEntries;

  @override
  Stream<Map<String, TravelStatus>> watchStatuses() {
    final query = _db.selectOnly(_entries)
      ..addColumns([_entries.countryCode, _entries.status])
      ..where(_entries.isDeleted.equals(false));
    return query.watch().map(
      (rows) => {
        for (final row in rows)
          row.read(_entries.countryCode)!: row.readWithConverter(
            _entries.status,
          )!,
      },
    );
  }

  @override
  Stream<TravelEntry?> watchEntry(String countryCode) {
    final query = _db.select(_entries)
      ..where(
        (t) => t.countryCode.equals(countryCode) & t.isDeleted.equals(false),
      );
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _toEntry(row),
    );
  }

  @override
  Future<void> saveVisit(
    String countryCode, {
    DateTime? visitedOn,
    int? rating,
    String notes = '',
  }) => _upsert(
    countryCode,
    TravelEntriesCompanion(
      status: const Value(TravelStatus.visited),
      visitedOn: Value(visitedOn == null ? null : _formatDate(visitedOn)),
      rating: Value(rating),
      priority: const Value(null),
      targetYear: const Value(null),
      notes: Value(notes),
    ),
  );

  @override
  Future<void> saveWishlist(
    String countryCode, {
    WishlistPriority priority = WishlistPriority.medium,
    int? targetYear,
    String notes = '',
  }) => _upsert(
    countryCode,
    TravelEntriesCompanion(
      status: const Value(TravelStatus.wishlist),
      visitedOn: const Value(null),
      rating: const Value(null),
      priority: Value(priority),
      targetYear: Value(targetYear),
      notes: Value(notes),
    ),
  );

  @override
  Future<TravelEntry?> remove(String countryCode) => _db.transaction(() async {
    final row = await _find(countryCode);
    if (row == null || row.isDeleted) return null;
    await (_db.update(
      _entries,
    )..where((t) => t.countryCode.equals(countryCode))).write(
      TravelEntriesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(_millis()),
      ),
    );
    return _toEntry(row);
  });

  @override
  Future<void> restore(TravelEntry entry) => _db
      .into(_entries)
      .insertOnConflictUpdate(
        TravelEntriesCompanion(
          countryCode: Value(entry.countryCode),
          status: Value(entry.status),
          visitedOn: Value(
            entry.visitedOn == null ? null : _formatDate(entry.visitedOn!),
          ),
          rating: Value(entry.rating),
          priority: Value(entry.priority),
          targetYear: Value(entry.targetYear),
          notes: Value(entry.notes),
          createdAt: Value(entry.createdAt.millisecondsSinceEpoch),
          updatedAt: Value(_millis()),
          isDeleted: const Value(false),
        ),
      );

  /// Inserts or updates one country's entry. `synced_at` is left alone, so
  /// the newer `updated_at` marks the entry for upload. A country saved again
  /// after deletion counts as a new entry.
  Future<void> _upsert(String countryCode, TravelEntriesCompanion values) =>
      _db.transaction(() async {
        final existing = await _find(countryCode);
        final now = _millis();
        final keepCreatedAt = existing != null && !existing.isDeleted;
        await _db
            .into(_entries)
            .insertOnConflictUpdate(
              values.copyWith(
                countryCode: Value(countryCode),
                createdAt: Value(keepCreatedAt ? existing.createdAt : now),
                updatedAt: Value(now),
                isDeleted: const Value(false),
              ),
            );
      });

  Future<TravelEntryRow?> _find(String countryCode) => (_db.select(
    _entries,
  )..where((t) => t.countryCode.equals(countryCode))).getSingleOrNull();

  int _millis() => _now().millisecondsSinceEpoch;

  static TravelEntry _toEntry(TravelEntryRow row) => TravelEntry(
    countryCode: row.countryCode,
    status: row.status,
    visitedOn: row.visitedOn == null ? null : DateTime.parse(row.visitedOn!),
    rating: row.rating,
    priority: row.priority,
    targetYear: row.targetYear,
    notes: row.notes,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
  );

  /// ISO date, YYYY-MM-DD (PRD section 8.3).
  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
