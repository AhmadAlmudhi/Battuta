import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../countries/presentation/country_providers.dart';
import '../../travels/presentation/travel_providers.dart';
import '../domain/travel_stats.dart';

/// Recomputed whenever an entry changes, so Stats is always current
/// (AC-STA-01).
final travelStatsProvider = Provider<AsyncValue<TravelStats>>((ref) {
  final countries = ref.watch(countriesProvider);
  final entries = ref.watch(travelEntriesProvider);
  if (countries case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  if (entries case AsyncError(:final error, :final stackTrace)) {
    return AsyncError(error, stackTrace);
  }
  final countryList = countries.valueOrNull;
  final entryList = entries.valueOrNull;
  if (countryList == null || entryList == null) return const AsyncLoading();
  return AsyncData(
    TravelStats.from(countries: countryList, entries: entryList),
  );
});
