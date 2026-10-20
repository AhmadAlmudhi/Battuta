import 'package:battuta/features/auth/data/firebase_auth_repository.dart';
import 'package:battuta/features/auth/data/firestore_cloud_entries.dart';
import 'package:battuta/features/auth/domain/auth_repository.dart';
import 'package:battuta/features/auth/domain/sync_entry.dart';
import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Firestore documents (PRD 8.4)', () {
    const visit = SyncEntry(
      countryCode: 'FRA',
      status: TravelStatus.visited,
      visitedOn: '2026-03-14',
      rating: 4,
      notes: 'Paris',
      createdAt: 1,
      updatedAt: 2,
    );

    test('use camelCase fields without syncedAt', () {
      expect(syncEntryToMap(visit), {
        'countryCode': 'FRA',
        'status': 'visited',
        'visitedOn': '2026-03-14',
        'rating': 4,
        'priority': null,
        'targetYear': null,
        'notes': 'Paris',
        'createdAt': 1,
        'updatedAt': 2,
        'isDeleted': false,
      });
    });

    test('round-trip visits, wishlist entries, and deletions', () {
      const wish = SyncEntry(
        countryCode: 'JPN',
        status: TravelStatus.wishlist,
        priority: WishlistPriority.high,
        targetYear: 2027,
        createdAt: 1,
        updatedAt: 3,
        isDeleted: true,
      );
      for (final entry in [visit, wish]) {
        expect(syncEntryFromMap(syncEntryToMap(entry)), entry);
      }
    });

    test('unreadable documents are skipped, not fatal', () {
      expect(syncEntryFromMap(null), isNull);
      expect(syncEntryFromMap({'countryCode': 'FRA'}), isNull);
      expect(
        syncEntryFromMap({
          'countryCode': 'FRA',
          'status': 'someday',
          'createdAt': 1,
          'updatedAt': 2,
        }),
        isNull,
      );
    });

    test('missing optional fields read as empty', () {
      expect(
        syncEntryFromMap({
          'countryCode': 'FRA',
          'status': 'visited',
          'createdAt': 1,
          'updatedAt': 2,
        }),
        const SyncEntry(
          countryCode: 'FRA',
          status: TravelStatus.visited,
          createdAt: 1,
          updatedAt: 2,
        ),
      );
    });
  });

  test('Firebase error codes map to the PRD 8.6 messages', () {
    expect(
      [
        'invalid-credential',
        'wrong-password',
        'user-not-found',
      ].map(authFailureFromCode).toSet(),
      {AuthFailure.invalidCredentials},
    );
    expect(authFailureFromCode('email-already-in-use'), AuthFailure.emailInUse);
    expect(
      authFailureFromCode('too-many-requests'),
      AuthFailure.tooManyRequests,
    );
    expect(authFailureFromCode('network-request-failed'), AuthFailure.network);
    expect(authFailureFromCode('something-new'), AuthFailure.unknown);
  });
}
