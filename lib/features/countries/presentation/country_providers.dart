import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/network/connectivity.dart';
import '../../settings/presentation/settings_controller.dart';
import '../data/country_api_client.dart';
import '../data/country_refresher.dart';
import '../data/country_repository_impl.dart';
import '../data/tourism_arrivals.dart';
import '../domain/country.dart';
import '../domain/country_repository.dart';
import '../domain/country_search.dart';
import '../domain/explore_filter_options.dart';

const snapshotAsset = 'assets/data/countries_snapshot.json';

/// Passed at build time with `--dart-define-from-file=env.json`
/// (PRD section 11.4). Empty when missing; refresh then always fails and the
/// app keeps the bundled data.
const _apiKey = String.fromEnvironment('RC_API_KEY');

final snapshotLoaderProvider = Provider<SnapshotLoader>(
  (ref) =>
      () => rootBundle.loadString(snapshotAsset),
);

final countryApiClientProvider = Provider<CountryApiClient?>(
  (ref) => _apiKey.isEmpty ? null : CountryApiClient.withKey(_apiKey),
);

final countryRepositoryProvider = Provider<CountryRepository>(
  (ref) => CountryRepositoryImpl(
    ref.watch(appDatabaseProvider),
    ref.watch(snapshotLoaderProvider),
    ref.watch(countryApiClientProvider),
  ),
);

final countryRefresherProvider = Provider<CountryRefresher>(
  (ref) => CountryRefresher(
    repository: ref.watch(countryRepositoryProvider),
    prefs: ref.watch(sharedPreferencesProvider),
    isOnline: ref.watch(connectivityServiceProvider).isOnline,
  ),
);

/// Completes once the bundled snapshot is in the local database, then starts
/// a background refresh if the data is older than 7 days (PRD 7.1, step 3).
final countriesSeededProvider = FutureProvider<void>((ref) async {
  await ref.watch(countryRepositoryProvider).ensureSeeded();
  // Not awaited: screens show the saved data while the refresh runs, and a
  // failed refresh keeps it. API failures are handled inside; anything else
  // is a bug and is reported.
  unawaited(
    ref
        .read(countryRefresherProvider)
        .refreshIfStale()
        .then<void>(
          (_) {},
          onError: (Object error, StackTrace stack) => FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stack,
              library: 'country refresh',
            ),
          ),
        ),
  );
});

final countriesProvider = StreamProvider<List<Country>>((ref) async* {
  await ref.watch(countriesSeededProvider.future);
  yield* ref.watch(countryRepositoryProvider).watchAll();
});

/// Null when no country has this code (FR-DET-06). Read from the loaded
/// list, so a screen opened from Explore has its country on the first frame
/// and the flag hero can fly.
final countryByCodeProvider = Provider.family<AsyncValue<Country?>, String>((
  ref,
  code,
) {
  final upper = code.toUpperCase();
  return ref
      .watch(countriesProvider)
      .whenData(
        (countries) => countries.where((c) => c.code == upper).firstOrNull,
      );
});

final countrySearchIndexProvider = Provider<AsyncValue<CountrySearchIndex>>(
  (ref) => ref
      .watch(countriesProvider)
      .whenData(
        (countries) => CountrySearchIndex(countries, arrivals: tourismArrivals),
      ),
);

final exploreFilterOptionsProvider = Provider<AsyncValue<ExploreFilterOptions>>(
  (ref) => ref.watch(countriesProvider).whenData(ExploreFilterOptions.from),
);
