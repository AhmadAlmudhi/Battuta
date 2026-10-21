import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../countries/presentation/country_providers.dart';
import '../domain/map_hit_tester.dart';
import '../domain/world_map.dart';
import 'world_map_geometry.dart';

const worldMapAsset = 'assets/data/world_map.json';

/// Loads the bundled map file (PRD section 8.7). `compute` parses it in a
/// background isolate on Android and iOS; on web it runs on the main thread,
/// which is fast enough for this file.
final worldMapLoaderProvider = Provider<Future<WorldMap> Function()>(
  (ref) =>
      () async =>
          compute(parseWorldMap, await rootBundle.loadString(worldMapAsset)),
);

final worldMapProvider = FutureProvider<WorldMap>(
  (ref) => ref.watch(worldMapLoaderProvider)(),
);

/// The map's paths, built once.
final worldMapGeometryProvider = Provider<AsyncValue<WorldMapGeometry>>(
  (ref) => ref.watch(worldMapProvider).whenData(WorldMapGeometry.new),
);

/// The region the map focuses on, or null for the whole world (FR-MAP-21).
/// Set by the region chips and the region bars on Stats (FR-MAP-25).
final mapRegionProvider = StateProvider<String?>((ref) => null);

/// Each country's region, by code, for the region focus and its summary.
final countryRegionsProvider = Provider<Map<String, String>>(
  (ref) => {
    for (final country in ref.watch(countriesProvider).valueOrNull ?? [])
      country.code: country.region,
  },
);

/// Null until the map and the countries have loaded. Only countries in the
/// dataset can be selected (FR-MAP-07).
final mapHitTesterProvider = Provider<MapHitTester?>((ref) {
  final map = ref.watch(worldMapProvider).valueOrNull;
  final countries = ref.watch(countriesProvider).valueOrNull;
  if (map == null || countries == null) return null;
  return MapHitTester(
    map,
    selectable: {for (final country in countries) country.code},
  );
});
