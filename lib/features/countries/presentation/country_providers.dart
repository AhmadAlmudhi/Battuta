import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../data/country_repository_impl.dart';
import '../domain/country.dart';
import '../domain/country_repository.dart';

const snapshotAsset = 'assets/data/countries_snapshot.json';

final countryRepositoryProvider = Provider<CountryRepository>(
  (ref) => CountryRepositoryImpl(
    ref.watch(appDatabaseProvider),
    () => rootBundle.loadString(snapshotAsset),
  ),
);

/// Completes once the bundled snapshot is in the local database.
final countriesSeededProvider = FutureProvider<void>(
  (ref) => ref.watch(countryRepositoryProvider).ensureSeeded(),
);

final countriesProvider = StreamProvider<List<Country>>((ref) async* {
  await ref.watch(countriesSeededProvider.future);
  yield* ref.watch(countryRepositoryProvider).watchAll();
});
