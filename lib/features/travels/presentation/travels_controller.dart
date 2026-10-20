import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../countries/domain/explore_query.dart';
import '../../countries/presentation/country_providers.dart';
import '../domain/travel_entry.dart';
import '../domain/travel_list.dart';
import 'travel_providers.dart';

/// Search, region filter, and sort for My travels, kept for the session.
class TravelsQuery {
  const TravelsQuery({
    this.search = '',
    this.regions = const {},
    this.visitedSort = VisitedSort.date,
    this.wishlistSort = WishlistSort.priority,
  });

  final String search;
  final Set<String> regions;
  final VisitedSort visitedSort;
  final WishlistSort wishlistSort;

  bool get isFiltered => search.trim().isNotEmpty || regions.isNotEmpty;

  TravelsQuery copyWith({
    String? search,
    Set<String>? regions,
    VisitedSort? visitedSort,
    WishlistSort? wishlistSort,
  }) => TravelsQuery(
    search: search ?? this.search,
    regions: regions ?? this.regions,
    visitedSort: visitedSort ?? this.visitedSort,
    wishlistSort: wishlistSort ?? this.wishlistSort,
  );
}

final travelsQueryProvider =
    NotifierProvider<TravelsQueryController, TravelsQuery>(
      TravelsQueryController.new,
    );

class TravelsQueryController extends Notifier<TravelsQuery> {
  @override
  TravelsQuery build() => const TravelsQuery();

  void setSearch(String text) => state = state.copyWith(search: text);

  void toggleRegion(String region) {
    final regions = {...state.regions};
    if (!regions.remove(region)) regions.add(region);
    state = state.copyWith(regions: regions);
  }

  void setVisitedSort(VisitedSort sort) =>
      state = state.copyWith(visitedSort: sort);

  void setWishlistSort(WishlistSort sort) =>
      state = state.copyWith(wishlistSort: sort);

  void clearFilters() => state = TravelsQuery(
    visitedSort: state.visitedSort,
    wishlistSort: state.wishlistSort,
  );
}

/// Both tabs of My travels, filtered and sorted.
class TravelsView {
  const TravelsView({
    required this.visited,
    required this.wishlist,
    required this.visitedTotal,
    required this.wishlistTotal,
    required this.regions,
  });

  final List<TravelListItem> visited;
  final List<TravelListItem> wishlist;

  /// Counts before search and filters, shown on the tabs (FR-TRV-05).
  final int visitedTotal;
  final int wishlistTotal;

  /// Regions of the saved countries, offered as filters (FR-TRV-08).
  final List<String> regions;
}

/// My travels in the app language: [arabic] picks the names used for name
/// order. Search matches the same names as Explore (FR-TRV-08).
final travelsViewProvider = Provider.family<AsyncValue<TravelsView>, bool>((
  ref,
  arabic,
) {
  final query = ref.watch(travelsQueryProvider);
  final entries = ref.watch(travelEntriesProvider);
  final countries = ref.watch(countriesProvider);
  final index = ref.watch(countrySearchIndexProvider);

  if (entries case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  if (countries case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  final entryList = entries.valueOrNull;
  final countryList = countries.valueOrNull;
  final searchIndex = index.valueOrNull;
  if (entryList == null || countryList == null || searchIndex == null) {
    return const AsyncLoading();
  }

  final byCode = {for (final country in countryList) country.code: country};
  // An entry whose country left the data in a refresh can't be shown.
  final items = [
    for (final entry in entryList)
      if (byCode[entry.countryCode] case final country?)
        TravelListItem(entry, country),
  ];

  final matching = query.isFiltered
      ? {
          for (final country in searchIndex.apply(
            ExploreQuery(search: query.search, regions: query.regions),
            arabic: arabic,
          ))
            country.code,
        }
      : null;
  bool shown(TravelListItem item) =>
      matching == null || matching.contains(item.country.code);

  final visited = items.where((i) => i.entry.status == TravelStatus.visited);
  final wishlist = items.where((i) => i.entry.status == TravelStatus.wishlist);
  return AsyncData(
    TravelsView(
      visited: TravelListOrder.visited(
        visited.where(shown),
        query.visitedSort,
        arabic: arabic,
      ),
      wishlist: TravelListOrder.wishlist(
        wishlist.where(shown),
        query.wishlistSort,
        arabic: arabic,
      ),
      visitedTotal: visited.length,
      wishlistTotal: wishlist.length,
      regions: {for (final item in items) item.country.region}.toList()..sort(),
    ),
  );
});
