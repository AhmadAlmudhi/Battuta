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
