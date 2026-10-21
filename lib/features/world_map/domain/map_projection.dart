import 'dart:math';

/// Equal Earth coefficients (Šavrič, Patterson, and Jenny).
const _a1 = 1.340264, _a2 = -0.081106, _a3 = 0.000893, _a4 = 0.003796;
final _m = sqrt(3) / 2;

/// Equal Earth projection (PRD section 8.7). Takes degrees; returns unscaled
/// x and y, with y pointing north.
(double, double) equalEarth(double lonDeg, double latDeg) {
  final lambda = lonDeg * pi / 180, phi = latDeg * pi / 180;
  final t = asin(_m * sin(phi)), t2 = t * t, t6 = t2 * t2 * t2;
  final x =
      lambda *
      cos(t) /
      (_m * (_a1 + 3 * _a2 * t2 + t6 * (7 * _a3 + 9 * _a4 * t2)));
  final y = t * (_a1 + _a2 * t2 + t6 * (_a3 + _a4 * t2));
  return (x, y);
}

/// The world map's frame (PRD section 10.1): Equal Earth, cropped between
/// 57° south and 84° north, 1,000 units wide and 435 tall, with y pointing
/// down from the top edge. Pure Dart, so `tool/build_world_map.dart` can
/// import it.
abstract final class MapFrame {
  static const width = 1000.0;

  /// The cropped map is 434.8 units tall; rounding up keeps every shape
  /// inside.
  static const height = 435.0;

  static const south = -57.0;
  static const north = 84.0;

  /// Map units per unscaled Equal Earth unit: the equator spans the width.
  static final double _scale = width / (2 * equalEarth(180, 0).$1);
  static final double _top = equalEarth(0, north).$2 * _scale;

  /// Projects a point in degrees to map units, clamping latitude to the
  /// frame. x runs from 0 at 180° W to 1,000 at 180° E.
  static (double, double) project(double lon, double lat) {
    final (x, y) = equalEarth(lon, lat.clamp(south, north).toDouble());
    return (width / 2 + x * _scale, _top - y * _scale);
  }
}
