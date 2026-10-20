import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:battuta/features/travels/domain/travel_list.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_countries.dart';

void main() {
  final byCode = {for (final c in testCountries) c.code: c};
  final created = DateTime(2026);

  TravelListItem visit(String code, {DateTime? on}) => TravelListItem(
    TravelEntry(
      countryCode: code,
      status: TravelStatus.visited,
      visitedOn: on,
      createdAt: created,
      updatedAt: created,
    ),
    byCode[code]!,
  );

  TravelListItem wish(String code, WishlistPriority priority, [int? year]) =>
      TravelListItem(
        TravelEntry(
          countryCode: code,
          status: TravelStatus.wishlist,
          priority: priority,
          targetYear: year,
          createdAt: created,
          updatedAt: created,
        ),
        byCode[code]!,
      );

  List<String> codes(List<TravelListItem> items) => [
    for (final item in items) item.country.code,
  ];

  group('Visited (FR-TRV-06)', () {
    final items = [
      visit('FRA', on: DateTime(2025, 6, 1)),
      visit('DEU'),
      visit('JPN', on: DateTime(2026, 3, 14)),
      visit('BEL'),
      visit('ESP', on: DateTime(2026, 3, 14)),
    ];

    test('newest visit first, undated last, ties by name', () {
      // Japan and Spain share a date, so they sort by name; Belgium and
      // Germany have no date, so they come last, also by name.
      expect(
        codes(TravelListOrder.visited(items, VisitedSort.date, arabic: false)),
        ['JPN', 'ESP', 'FRA', 'BEL', 'DEU'],
      );
    });

    test('can switch to name order, in the app language', () {
      expect(
        codes(TravelListOrder.visited(items, VisitedSort.name, arabic: false)),
        ['BEL', 'FRA', 'DEU', 'JPN', 'ESP'],
      );
      // إسبانيا, ألمانيا, اليابان, بلجيكا, فرنسا after normalization.
      expect(
        codes(TravelListOrder.visited(items, VisitedSort.name, arabic: true)),
        ['ESP', 'DEU', 'JPN', 'BEL', 'FRA'],
      );
    });
  });

  group('Wishlist (FR-TRV-06)', () {
    final items = [
      wish('SEN', WishlistPriority.low),
      wish('ESP', WishlistPriority.high, 2028),
      wish('BEL', WishlistPriority.medium),
      wish('JPN', WishlistPriority.high),
      wish('SAU', WishlistPriority.high, 2027),
    ];

    test('high priority first, then the earliest target year, none last', () {
      expect(
        codes(
          TravelListOrder.wishlist(items, WishlistSort.priority, arabic: false),
        ),
        ['SAU', 'ESP', 'JPN', 'BEL', 'SEN'],
      );
    });

    test('can switch to name order', () {
      expect(
        codes(
          TravelListOrder.wishlist(items, WishlistSort.name, arabic: false),
        ),
        ['BEL', 'JPN', 'SAU', 'SEN', 'ESP'],
      );
    });
  });

  test('does not change the input list', () {
    final items = [visit('JPN'), visit('BEL')];
    TravelListOrder.visited(items, VisitedSort.name, arabic: false);
    expect(codes(items), ['JPN', 'BEL']);
  });
}
