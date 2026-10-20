import 'package:battuta/core/database/app_database.dart';
import 'package:battuta/features/travels/data/travel_repository_impl.dart';
import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  late AppDatabase db;
  late DateTime now;
  late TravelRepositoryImpl repo;

  setUp(() {
    db = inMemoryDatabase();
    now = DateTime(2026, 10, 20, 12);
    repo = TravelRepositoryImpl(db, now: () => now);
  });
  tearDown(() => db.close());

  Future<TravelEntryRow> row(String code) => (db.select(
    db.travelEntries,
  )..where((t) => t.countryCode.equals(code))).getSingle();

  test('saveVisit stores the visit with an ISO date (PRD 8.3)', () async {
    await repo.saveVisit(
      'FRA',
      visitedOn: DateTime(2026, 3, 14),
      rating: 4,
      notes: 'Paris in spring',
    );

    final entry = await repo.watchEntry('FRA').first;
    expect(entry?.status, TravelStatus.visited);
    expect(entry?.visitedOn, DateTime(2026, 3, 14));
    expect(entry?.rating, 4);
    expect(entry?.notes, 'Paris in spring');
    expect(entry?.createdAt, now);
    expect(entry?.updatedAt, now);

    final saved = await row('FRA');
    expect(saved.visitedOn, '2026-03-14');
    expect(saved.isDeleted, isFalse);
    expect(saved.syncedAt, isNull);
  });

  test('saving again keeps createdAt and moves updatedAt', () async {
    await repo.saveVisit('FRA', rating: 3);
    final created = now;
    now = now.add(const Duration(hours: 1));

    await repo.saveVisit('FRA', rating: 5);

    final entry = await repo.watchEntry('FRA').first;
    expect(entry?.rating, 5);
    expect(entry?.createdAt, created);
    expect(entry?.updatedAt, now);
  });

  test('a wishlist entry becomes a visit with its notes and without its '
      'wishlist fields (FR-TRV-03, AC-TRV-02)', () async {
    await repo.saveWishlist(
      'JPN',
      priority: WishlistPriority.high,
      targetYear: 2027,
      notes: 'Go in spring',
    );
    final wish = await repo.watchEntry('JPN').first;

    await repo.saveVisit('JPN', notes: wish!.notes);

    final entry = await repo.watchEntry('JPN').first;
    expect(entry?.status, TravelStatus.visited);
    expect(entry?.notes, 'Go in spring');
    expect(entry?.priority, isNull);
    expect(entry?.targetYear, isNull);
    expect(await repo.watchEntry('XYZ').first, isNull);
  });

  test('remove soft-deletes and hides the entry everywhere '
      '(FR-SYNC-06)', () async {
    await repo.saveVisit('FRA', rating: 5);
    now = now.add(const Duration(minutes: 5));

    final removed = await repo.remove('FRA');

    expect(removed?.rating, 5);
    expect(await repo.watchEntry('FRA').first, isNull);
    expect(await repo.watchStatuses().first, isEmpty);
    final saved = await row('FRA');
    expect(saved.isDeleted, isTrue);
    expect(saved.updatedAt, now.millisecondsSinceEpoch);
  });

  test('restore brings the entry back unchanged, with a newer update time '
      '(AC-TRV-03)', () async {
    await repo.saveVisit(
      'FRA',
      visitedOn: DateTime(2025, 6, 1),
      rating: 5,
      notes: 'Lovely',
    );
    final removed = await repo.remove('FRA');
    now = now.add(const Duration(seconds: 3));

    await repo.restore(removed!);

    final entry = await repo.watchEntry('FRA').first;
    expect(
      entry,
      removed.copyWith(updatedAt: now),
      reason: 'every field the user sees is unchanged',
    );
  });

  test('a country saved again after removal starts a new entry', () async {
    await repo.saveVisit('FRA');
    await repo.remove('FRA');
    now = now.add(const Duration(days: 1));

    await repo.saveWishlist('FRA');

    final entry = await repo.watchEntry('FRA').first;
    expect(entry?.status, TravelStatus.wishlist);
    expect(entry?.createdAt, now);
  });

  test('remove returns null when the country is not saved', () async {
    expect(await repo.remove('FRA'), isNull);
  });

  test('saving leaves synced_at alone, so the newer updated_at marks the '
      'entry for upload', () async {
    await repo.saveVisit('FRA');
    final syncedAt = now.millisecondsSinceEpoch;
    await (db.update(db.travelEntries)
          ..where((t) => t.countryCode.equals('FRA')))
        .write(TravelEntriesCompanion(syncedAt: Value(syncedAt)));
    now = now.add(const Duration(minutes: 1));

    await repo.saveVisit('FRA', rating: 2);

    final saved = await row('FRA');
    expect(saved.syncedAt, syncedAt);
    expect(saved.updatedAt, greaterThan(syncedAt));
  });

  test('statuses list every saved country', () async {
    await repo.saveVisit('FRA');
    await repo.saveWishlist('JPN');

    expect(await repo.watchStatuses().first, {
      'FRA': TravelStatus.visited,
      'JPN': TravelStatus.wishlist,
    });
  });
}
