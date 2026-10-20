import '../../countries/domain/country.dart';
import '../../travels/domain/travel_entry.dart';

/// Visited countries out of one region's countries (FR-STA-02).
class RegionProgress {
  const RegionProgress({
    required this.region,
    required this.visited,
    required this.total,
  });

  final String region;
  final int visited;
  final int total;

  double get fraction => total == 0 ? 0 : visited / total;
}

/// The figures on the Stats screen (PRD section 6.5).
class TravelStats {
  const TravelStats({
    required this.visited,
    required this.total,
    required this.regions,
    required this.wishlistSize,
    this.latestTrip,
    this.firstTripYear,
  });

  /// Computes the stats from the dataset and the saved entries. Entries for
  /// countries no longer in the dataset aren't counted.
  factory TravelStats.from({
    required List<Country> countries,
    required List<TravelEntry> entries,
  }) {
    final byCode = {for (final country in countries) country.code: country};
    final visits = [
      for (final entry in entries)
        if (entry.status == TravelStatus.visited &&
            byCode.containsKey(entry.countryCode))
          entry,
    ];
    final visitedCodes = {for (final entry in visits) entry.countryCode};

    final regionTotals = <String, int>{};
    final regionVisited = <String, int>{};
    for (final country in countries) {
      regionTotals.update(country.region, (n) => n + 1, ifAbsent: () => 1);
      if (visitedCodes.contains(country.code)) {
        regionVisited.update(country.region, (n) => n + 1, ifAbsent: () => 1);
      }
    }

    final dated = [
      for (final entry in visits)
        if (entry.visitedOn != null) entry,
    ]..sort((a, b) => a.visitedOn!.compareTo(b.visitedOn!));

    return TravelStats(
      visited: visits.length,
      total: countries.length,
      regions: [
        for (final MapEntry(key: region, value: total) in regionTotals.entries)
          RegionProgress(
            region: region,
            visited: regionVisited[region] ?? 0,
            total: total,
          ),
      ],
      wishlistSize: entries
          .where(
            (e) =>
                e.status == TravelStatus.wishlist &&
                byCode.containsKey(e.countryCode),
          )
          .length,
      latestTrip: dated.isEmpty
          ? null
          : (
              country: byCode[dated.last.countryCode]!,
              date: dated.last.visitedOn!,
            ),
      firstTripYear: dated.isEmpty ? null : dated.first.visitedOn!.year,
    );
  }

  final int visited;

  /// Every country and territory in the dataset, about 250 (D-3).
  final int total;

  final List<RegionProgress> regions;
  final int wishlistSize;

  /// The most recent dated visit (FR-STA-03); null without dated visits.
  final ({Country country, DateTime date})? latestTrip;

  /// The year of the earliest dated visit; null without dated visits.
  final int? firstTripYear;

  /// The visited share of the dataset, 0 to 1 (FR-STA-01).
  double get share => total == 0 ? 0 : visited / total;
}
