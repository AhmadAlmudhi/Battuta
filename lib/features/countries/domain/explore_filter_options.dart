import 'country.dart';

/// The choices offered in the Explore filter panel, taken from the data
/// (FR-EXP-06).
class ExploreFilterOptions {
  ExploreFilterOptions._({
    required this.regions,
    required this.subregionsByRegion,
    required this.languages,
    required this.currencies,
  });

  factory ExploreFilterOptions.from(List<Country> countries) {
    final subregions = <String, Set<String>>{};
    final languages = <String>{};
    final currencies = <String, Currency>{};
    for (final country in countries) {
      final regionSubregions = subregions.putIfAbsent(country.region, () => {});
      if (country.subregion case final subregion?) {
        regionSubregions.add(subregion);
      }
      languages.addAll(country.languages);
      for (final currency in country.currencies) {
        currencies.putIfAbsent(currency.code, () => currency);
      }
    }

    int byLowercase(String a, String b) =>
        a.toLowerCase().compareTo(b.toLowerCase());
    return ExploreFilterOptions._(
      regions: subregions.keys.toList()..sort(),
      subregionsByRegion: {
        for (final MapEntry(:key, :value) in subregions.entries)
          key: value.toList()..sort(),
      },
      languages: languages.toList()..sort(byLowercase),
      currencies: currencies.values.toList()
        ..sort((a, b) => byLowercase(a.name, b.name)),
    );
  }

  final List<String> regions;
  final Map<String, List<String>> subregionsByRegion;
  final List<String> languages;
  final List<Currency> currencies;

  /// Subregion choices for the selected regions; none until a region is
  /// selected.
  List<String> subregionsFor(Set<String> regions) => [
    for (final region in this.regions)
      if (regions.contains(region)) ...?subregionsByRegion[region],
  ];
}
