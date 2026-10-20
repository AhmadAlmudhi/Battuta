import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/database/database_provider.dart';
import '../data/travel_repository_impl.dart';
import '../domain/travel_entry.dart';
import '../domain/travel_repository.dart';

final travelRepositoryProvider = Provider<TravelRepository>(
  (ref) => TravelRepositoryImpl(
    ref.watch(appDatabaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final travelStatusesProvider = StreamProvider<Map<String, TravelStatus>>(
  (ref) => ref.watch(travelRepositoryProvider).watchStatuses(),
);

/// The entry for one country, or null when it isn't saved.
final travelEntryProvider = StreamProvider.family<TravelEntry?, String>(
  (ref, countryCode) =>
      ref.watch(travelRepositoryProvider).watchEntry(countryCode),
);
