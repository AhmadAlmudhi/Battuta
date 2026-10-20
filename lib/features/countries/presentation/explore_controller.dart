import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/country.dart';
import '../domain/explore_filter_options.dart';
import '../domain/explore_query.dart';
import 'country_providers.dart';

/// Explore's search text, filters, and sort. Kept for the whole session, so
/// they stay applied while the user moves between screens, until the app or
/// tab closes (FR-EXP-09).
final exploreQueryProvider = NotifierProvider<ExploreController, ExploreQuery>(
  ExploreController.new,
);

class ExploreController extends Notifier<ExploreQuery> {
  @override
  ExploreQuery build() => const ExploreQuery();

  void setSearch(String text) => state = state.copyWith(search: text);

  void setSort(CountrySort sort) => state = state.copyWith(sort: sort);

  /// Deselecting a region also drops its subregions, which are only offered
  /// for selected regions (FR-EXP-06).
  void toggleRegion(String region, ExploreFilterOptions options) {
    final regions = {...state.regions};
    if (!regions.remove(region)) regions.add(region);
    final allowed = options.subregionsFor(regions).toSet();
    state = state.copyWith(
      regions: regions,
      subregions: state.subregions.where(allowed.contains).toSet(),
    );
  }

  void toggleSubregion(String subregion) {
    final subregions = {...state.subregions};
    if (!subregions.remove(subregion)) subregions.add(subregion);
    state = state.copyWith(subregions: subregions);
  }

  void setLanguage(String? language) =>
      state = state.copyWith(language: language);

  void setCurrency(String? currency) =>
      state = state.copyWith(currency: currency);

  void clearFilters() => state = state.clearFilters();

  /// The empty state's Clear filters button: also clears the search, so
  /// every country shows again.
  void clearAll() => state = ExploreQuery(sort: state.sort);
}

/// Explore results for the current query, with names sorted in the app
/// language.
final exploreResultsProvider = Provider.family<AsyncValue<List<Country>>, bool>(
  (ref, arabic) {
    final query = ref.watch(exploreQueryProvider);
    return ref
        .watch(countrySearchIndexProvider)
        .whenData((index) => index.apply(query, arabic: arabic));
  },
);
