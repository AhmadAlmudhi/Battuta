import 'package:battuta/features/stats/domain/travel_stats.dart';
import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_countries.dart';

void main() {
  final created = DateTime(2026);

  TravelEntry visit(String code, [DateTime? on]) => TravelEntry(
    countryCode: code,
    status: TravelStatus.visited,
    visitedOn: on,
    createdAt: created,
    updatedAt: created,
  );

  TravelEntry wish(String code) => TravelEntry(
    countryCode: code,
    status: TravelStatus.wishlist,
    createdAt: created,
    updatedAt: created,
  );

  TravelStats stats(List<TravelEntry> entries) =>
      TravelStats.from(countries: testCountries, entries: entries);

  test('the total is every country in the dataset (D-3)', () {
    final result = stats([visit('FRA'), visit('JPN')]);

    expect(result.visited, 2);
    expect(result.total, 8);
    expect(result.share, 0.25);
  });

  test('each region counts its visited countries out of its total '
      '(FR-STA-02)', () {
    final result = stats([visit('FRA'), visit('DEU'), visit('JPN')]);
    final byRegion = {
      for (final r in result.regions) r.region: (r.visited, r.total),
    };

    expect(byRegion, {
      'Europe': (2, 4),
      'Asia': (1, 2),
      'Africa': (0, 1),
      'Antarctic': (0, 1),
    });
  });

  test('highlights: wishlist size, most recent trip, and first trip year '
      '(FR-STA-03)', () {
    final result = stats([
      visit('FRA', DateTime(2019, 7, 2)),
      visit('JPN', DateTime(2026, 3, 14)),
      visit('DEU'),
      wish('SAU'),
      wish('SEN'),
    ]);

    expect(result.wishlistSize, 2);
    expect(result.latestTrip?.country.code, 'JPN');
    expect(result.latestTrip?.date, DateTime(2026, 3, 14));
    expect(result.firstTripYear, 2019);
  });

  test('without dated visits there is no latest or first trip', () {
    final result = stats([visit('FRA')]);

    expect(result.latestTrip, isNull);
    expect(result.firstTripYear, isNull);
  });

  test('entries for countries no longer in the dataset are not counted', () {
    final result = stats([visit('FRA'), visit('XXX'), wish('YYY')]);

    expect(result.visited, 1);
    expect(result.wishlistSize, 0);
  });

  test('no visits gives zero, which the screen shows as the zero state', () {
    final result = stats([wish('SAU')]);

    expect(result.visited, 0);
    expect(result.share, 0);
  });
}
