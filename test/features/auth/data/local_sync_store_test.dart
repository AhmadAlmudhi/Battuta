import 'package:battuta/core/database/app_database.dart';
import 'package:battuta/features/auth/data/local_sync_store.dart';
import 'package:battuta/features/auth/domain/sync_entry.dart';
import 'package:battuta/features/travels/data/travel_repository_impl.dart';
import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

SyncEntry cloudEntry(
  String code, {
  required int updatedAt,
  TravelStatus status = TravelStatus.visited,
  String notes = '',
  bool deleted = false,
}) => SyncEntry(
  countryCode: code,
  status: status,
  notes: notes,
  createdAt: 1,
  updatedAt: updatedAt,
  isDeleted: deleted,
);

void main() {
  group('SyncRules.cloudWins (PRD 7.3)', () {
    final local = cloudEntry('FRA', updatedAt: 100);

    test('cloud wins when there is no local copy', () {
      expect(
        SyncRules.cloudWins(
          local: null,
          cloud: cloudEntry('FRA', updatedAt: 1),
        ),
        isTrue,
      );
    });

    test('newer wins, and on equal times the cloud wins', () {
      bool wins(int cloudTime) => SyncRules.cloudWins(
        local: local,
        cloud: cloudEntry('FRA', updatedAt: cloudTime),
      );
      expect(wins(99), isFalse);
      expect(wins(100), isTrue);
      expect(wins(101), isTrue);
    });

    test('a newer deletion wins over an older edit', () {
      expect(
        SyncRules.cloudWins(
          local: local,
          cloud: cloudEntry('FRA', updatedAt: 200, deleted: true),
        ),
        isTrue,
      );
    });
  });

  group('LocalSyncStore', () {
    late AppDatabase db;
    late LocalSyncStore store;
    late TravelRepositoryImpl travels;
    var now = DateTime(2026, 10, 20, 12);

    setUp(() {
      db = inMemoryDatabase();
      store = LocalSyncStore(db);
      now = DateTime(2026, 10, 20, 12);
      travels = TravelRepositoryImpl(db, now: () => now);
    });
    tearDown(() => db.close());

    Future<TravelEntryRow?> row(String code) => (db.select(
      db.travelEntries,
    )..where((t) => t.countryCode.equals(code))).getSingleOrNull();

    test('new and changed entries are pending until synced', () async {
      await travels.saveVisit('FRA');
      await travels.saveWishlist('JPN');
      expect((await store.pending()).map((e) => e.countryCode), {'FRA', 'JPN'});

      await store.markSynced(await store.pending());
      expect(await store.pending(), isEmpty);

      now = now.add(const Duration(minutes: 1));
      await travels.saveVisit('FRA', rating: 5);
      expect((await store.pending()).map((e) => e.countryCode), ['FRA']);
    });

    test('a change made during an upload stays pending', () async {
      await travels.saveVisit('FRA');
      final uploaded = await store.pending();
      now = now.add(const Duration(minutes: 1));
      await travels.saveVisit('FRA', rating: 2);

      await store.markSynced(uploaded);

      expect((await store.pending()).single.rating, 2);
    });

    test('soft-deleted entries are pending, so deletions sync '
        '(FR-SYNC-06)', () async {
      await travels.saveVisit('FRA');
      await store.markSynced(await store.pending());
      now = now.add(const Duration(minutes: 1));
      await travels.remove('FRA');

      final pending = await store.pending();
      expect(pending.single.isDeleted, isTrue);
    });

    test('applies cloud copies that win and marks them synced', () async {
      await travels.saveVisit('FRA', notes: 'local'); // updatedAt = now
      final localTime = now.millisecondsSinceEpoch;

      final applied = await store.applyCloud([
        cloudEntry('FRA', updatedAt: localTime - 1, notes: 'older'),
        cloudEntry('JPN', updatedAt: 5, notes: 'only in cloud'),
      ]);

      expect(applied, 1);
      expect((await row('FRA'))?.notes, 'local');
      expect((await row('JPN'))?.notes, 'only in cloud');
      expect((await row('JPN'))?.syncedAt, 5);
      expect((await store.pending()).map((e) => e.countryCode), ['FRA']);
    });

    test('a newer cloud deletion removes the entry from view', () async {
      await travels.saveVisit('FRA');
      await store.applyCloud([
        cloudEntry(
          'FRA',
          updatedAt: now.millisecondsSinceEpoch + 1,
          deleted: true,
        ),
      ]);

      expect(await travels.watchEntry('FRA').first, isNull);
    });

    test('clearAll removes every entry from the device (D-4)', () async {
      await travels.saveVisit('FRA');
      await travels.saveWishlist('JPN');
      await store.clearAll();

      expect(await db.select(db.travelEntries).get(), isEmpty);
    });

    test('purges synced deletions older than 30 days only', () async {
      await travels.saveVisit('FRA');
      await travels.saveVisit('JPN');
      await travels.remove('FRA');
      await travels.remove('JPN');
      await store.markSynced(await store.pending());
      // JPN's deletion isn't uploaded yet.
      await (db.update(db.travelEntries)
            ..where((t) => t.countryCode.equals('JPN')))
          .write(const TravelEntriesCompanion(syncedAt: Value(null)));

      await store.purgeOldDeletions(now.add(const Duration(days: 29)));
      expect(await row('FRA'), isNotNull);

      await store.purgeOldDeletions(now.add(const Duration(days: 31)));
      expect(await row('FRA'), isNull);
      expect(await row('JPN'), isNotNull);
    });
  });
}
