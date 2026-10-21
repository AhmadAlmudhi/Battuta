import 'dart:io';

import 'package:battuta/features/world_map/domain/map_projection.dart';
import 'package:battuta/features/world_map/domain/world_map.dart';

/// The bundled map file, read from disk. Widget tests use it through a
/// provider override, because they can't wait for `compute` or the asset
/// bundle.
final testWorldMap = WorldMap.parse(
  File('assets/data/world_map.json').readAsStringSync(),
);

/// Where a place in degrees lands on the map, in map units.
MapPoint mapPointOf(double lon, double lat) {
  final (x, y) = MapFrame.project(lon, lat);
  return (x: x, y: y);
}
