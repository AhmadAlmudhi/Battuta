import 'country.dart';
import 'explore_query.dart';
import 'search_normalizer.dart';

/// Search, filter, and sort over all countries, entirely in memory so results
/// update well within 100 ms (NFR-04).
///
/// Names are normalized once when the index is built, not on every query.
/// [arrivals], international tourist arrivals by country code, order Most
/// visited.
class CountrySearchIndex {
  CountrySearchIndex(
    List<Country> countries, {
    Map<String, int> arrivals = const {},
  }) : _entries = [
         for (final country in countries)
           _Entry(country, arrivals[country.code]),
       ];

  final List<_Entry> _entries;

  /// Countries matching [query], in display order.
  ///
  /// Filters combine with AND across fields and OR within a field
  /// (FR-EXP-07). With search text, names that start with the text rank
  /// above names that only contain it (FR-EXP-05); within each group the
  /// chosen sort applies. [arabic] picks the name used for name sorting.
  List<Country> apply(ExploreQuery query, {required bool arabic}) {
    final search = normalizeForSearch(query.search);
    final matches = <({_Entry entry, int rank})>[];

    for (final entry in _entries) {
      if (!_passesFilters(entry.country, query)) continue;
      if (search.isEmpty) {
        matches.add((entry: entry, rank: 0));
      } else if (entry.names.any((name) => name.contains(search))) {
        final startsWith = entry.prefixes.any((p) => p.startsWith(search));
        matches.add((entry: entry, rank: startsWith ? 0 : 1));
      }
    }

    final compare = _comparator(query.sort, arabic: arabic);
    matches.sort((a, b) {
      final byRank = a.rank.compareTo(b.rank);
      return byRank != 0 ? byRank : compare(a.entry, b.entry);
    });
    return [for (final match in matches) match.entry.country];
  }

  static bool _passesFilters(Country country, ExploreQuery query) =>
      (query.regions.isEmpty || query.regions.contains(country.region)) &&
      (query.subregions.isEmpty ||
          query.subregions.contains(country.subregion)) &&
      (query.language == null || country.languages.contains(query.language)) &&
      (query.currency == null ||
          country.currencies.any((c) => c.code == query.currency));

  static int Function(_Entry, _Entry) _comparator(
    CountrySort sort, {
    required bool arabic,
  }) {
    int byName(_Entry a, _Entry b) => arabic
        ? a.sortKeyAr.compareTo(b.sortKeyAr)
        : a.sortKeyEn.compareTo(b.sortKeyEn);

    // Missing areas sort last in both directions; ties fall back to name.
    int byArea(_Entry a, _Entry b, {required bool descending}) {
      final x = a.country.areaKm2, y = b.country.areaKm2;
      if (x == null || y == null) {
        return x == y ? byName(a, b) : (x == null ? 1 : -1);
      }
      final result = descending ? y.compareTo(x) : x.compareTo(y);
      return result != 0 ? result : byName(a, b);
    }

    // Countries without a figure follow the rest, in name order.
    int byArrivals(_Entry a, _Entry b) {
      final x = a.arrivals, y = b.arrivals;
      if (x == null || y == null) {
        return x == y ? byName(a, b) : (x == null ? 1 : -1);
      }
      final result = y.compareTo(x);
      return result != 0 ? result : byName(a, b);
    }

    int byPopulation(_Entry a, _Entry b, {required bool descending}) {
      final x = a.country.population, y = b.country.population;
      final result = descending ? y.compareTo(x) : x.compareTo(y);
      return result != 0 ? result : byName(a, b);
    }

    return switch (sort) {
      CountrySort.mostVisited => byArrivals,
      CountrySort.nameAsc => byName,
      CountrySort.nameDesc => (a, b) => byName(b, a),
      CountrySort.populationDesc => (a, b) => byPopulation(
        a,
        b,
        descending: true,
      ),
      CountrySort.populationAsc => (a, b) => byPopulation(
        a,
        b,
        descending: false,
      ),
      CountrySort.areaDesc => (a, b) => byArea(a, b, descending: true),
      CountrySort.areaAsc => (a, b) => byArea(a, b, descending: false),
    };
  }
}

class _Entry {
  _Entry(this.country, this.arrivals)
    : sortKeyEn = normalizeForSearch(country.nameEn),
      sortKeyAr = normalizeForSearch(country.name(arabic: true)) {
    names = [
      sortKeyEn,
      normalizeForSearch(country.nameOfficialEn),
      if (country.nameAr != null) sortKeyAr,
    ];
    // Most Arabic country names start with the article ال, which people
    // often leave out when they type, so the name without it also counts as
    // a prefix: سعو ranks السعودية as a starts-with match.
    prefixes = [
      ...names,
      if (country.nameAr != null && sortKeyAr.startsWith('ال'))
        sortKeyAr.substring(2),
    ];
  }

  final Country country;

  /// International tourist arrivals; null without a figure.
  final int? arrivals;
  final String sortKeyEn;
  final String sortKeyAr;

  /// Normalized English common, English official, and Arabic names (FR-EXP-04).
  late final List<String> names;
  late final List<String> prefixes;
}
