import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../data/travel_repository_impl.dart';
import '../domain/travel_entry.dart';
import '../domain/travel_repository.dart';

final travelRepositoryProvider = Provider<TravelRepository>(
  (ref) => TravelRepositoryImpl(ref.watch(appDatabaseProvider)),
);

final travelStatusesProvider = StreamProvider<Map<String, TravelStatus>>(
  (ref) => ref.watch(travelRepositoryProvider).watchStatuses(),
);
