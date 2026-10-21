import 'dart:math';

import 'map_projection.dart';
import 'map_view.dart';

/// The regions with a chip and a frame on the map (FR-MAP-21), in chip
/// order. The Antarctic region has neither.
const mapRegions = ['Africa', 'Americas', 'Asia', 'Europe', 'Oceania'];

/// Each region's starting frame in degrees: west, south, east, north
/// (PRD section 6.10).
const _frames = {
  'Africa': (-20.0, -36.0, 55.0, 38.0),
  'Americas': (-170.0, -56.0, -30.0, 74.0),
  'Asia': (25.0, -12.0, 150.0, 56.0),
  'Europe': (-25.0, 34.0, 45.0, 72.0),
  'Oceania': (110.0, -48.0, 180.0, 5.0),
};

final _bounds = <String, MapRect>{};

/// A region's frame in map units, or null for a region without one. Its
/// edges are sampled every degree, because Equal Earth's meridians curve
/// outward toward the equator (PRD section 11.5).
MapRect? regionFrame(String region) {
  final frame = _frames[region];
  if (frame == null) return null;
  return _bounds.putIfAbsent(region, () {
    final (west, south, east, north) = frame;
    var (left, top, right, bottom) = (
      double.infinity,
      double.infinity,
      -double.infinity,
      -double.infinity,
    );
    void include(double lon, double lat) {
      final (x, y) = MapFrame.project(lon, lat);
      (left, right) = (min(left, x), max(right, x));
      (top, bottom) = (min(top, y), max(bottom, y));
    }

    for (var lat = south; lat <= north; lat++) {
      include(west, lat);
      include(east, lat);
    }
    for (var lon = west; lon <= east; lon++) {
      include(lon, south);
      include(lon, north);
    }
    return MapRect(left, top, right, bottom);
  });
}
