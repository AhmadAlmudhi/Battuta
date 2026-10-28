import 'package:freezed_annotation/freezed_annotation.dart';

part 'explore_query.freezed.dart';

/// Sort options for Explore (FR-EXP-08).
enum CountrySort {
  /// By international tourist arrivals, most first; the default, so the
  /// countries people have most likely been to come first.
  mostVisited,
  nameAsc,
  nameDesc,
  populationDesc,
  populationAsc,
  areaDesc,
  areaAsc,
}

/// The search text, filters, and sort applied on Explore (FR-EXP-03 to 08).
@freezed
abstract class ExploreQuery with _$ExploreQuery {
  const ExploreQuery._();

  const factory ExploreQuery({
    @Default('') String search,

    /// Regions to include; empty means all. OR within the field (FR-EXP-07).
    @Default(<String>{}) Set<String> regions,

    /// Subregions to include, limited to the selected regions.
    @Default(<String>{}) Set<String> subregions,

    /// A language name, for example French.
    String? language,

    /// A currency code, for example EUR.
    String? currency,
    @Default(CountrySort.mostVisited) CountrySort sort,
  }) = _ExploreQuery;

  /// The number shown on the Filters button (FR-EXP-07).
  int get activeFilterCount =>
      regions.length +
      subregions.length +
      (language == null ? 0 : 1) +
      (currency == null ? 0 : 1);

  bool get hasFilters => activeFilterCount > 0;

  /// Removes every filter but keeps the search text and sort.
  ExploreQuery clearFilters() => ExploreQuery(search: search, sort: sort);
}
