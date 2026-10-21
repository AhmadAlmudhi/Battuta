import 'dart:math';
import 'dart:typed_data';

import 'world_map.dart';

/// Decides which country a tap or the pointer selects (FR-MAP-11).
/// Distances are in map units; the caller converts them from dp at the
/// current scale.
class MapHitTester {
  MapHitTester(WorldMap map, {required Set<String> selectable})
    : _selectable = selectable,
      _shapes = [
        for (final MapEntry(:key, :value) in map.shapes.entries)
          _Shape(key, value),
        _Shape(null, map.unmatched),
      ],
      _dots = {
        for (final MapEntry(:key, :value) in map.dots.entries)
          if (selectable.contains(key)) key: value,
      };

  /// Countries in the dataset; anything else can't be selected (FR-MAP-07).
  final Set<String> _selectable;

  /// Countries, then the shapes that match none.
  final List<_Shape> _shapes;

  final Map<String, MapPoint> _dots;

  /// The country at [point], or null.
  ///
  /// A dot wins when the pointer is on it, within [dotRadius] of its center.
  /// Otherwise, over land, the country under the pointer wins, so large
  /// countries next to small ones stay selectable. Over water, the nearest
  /// country or dot within [reach] of its edge wins: a tap just off a coast
  /// selects that country, and a dot in open water is easy to hit.
  String? hitTest(
    MapPoint point, {
    required double dotRadius,
    required double reach,
  }) {
    final (dot, toCenter) = _nearestDot(point) ?? (null, double.infinity);
    if (toCenter <= dotRadius) return dot;
    if (_shapeAt(point) case final shape?) {
      final code = shape.code;
      return code != null && _selectable.contains(code) ? code : null;
    }
    var (nearest, best) = toCenter - dotRadius <= reach
        ? (dot, toCenter - dotRadius)
        : (null, reach);
    for (final shape in _shapes) {
      final code = shape.code;
      if (code == null || !_selectable.contains(code)) continue;
      final distance = shape.distanceTo(point.x, point.y, best);
      if (distance < best) {
        nearest = code;
        best = distance;
      }
    }
    return nearest;
  }

  /// The country whose shape contains [point], whether or not it can be
  /// selected; null over water or on a shape that matches no country.
  String? countryAt(MapPoint point) => _shapeAt(point)?.code;

  _Shape? _shapeAt(MapPoint point) {
    for (final shape in _shapes) {
      if (shape.contains(point.x, point.y)) return shape;
    }
    return null;
  }

  /// The dot whose center is nearest, and how far that is.
  (String, double)? _nearestDot(MapPoint point) {
    (String, double)? nearest;
    for (final MapEntry(key: code, value: dot) in _dots.entries) {
      final distance = sqrt(pow(dot.x - point.x, 2) + pow(dot.y - point.y, 2));
      if (nearest == null || distance < nearest.$2) nearest = (code, distance);
    }
    return nearest;
  }
}

/// One country's rings, with bounding boxes so most checks end early.
class _Shape {
  _Shape(this.code, this.rings)
    : boxes = [for (final ring in rings) _Box.of(ring)];

  final String? code;
  final List<Float64List> rings;
  final List<_Box> boxes;

  /// The even-odd rule across every ring, so holes such as Lesotho inside
  /// South Africa don't count.
  bool contains(double x, double y) {
    var inside = false;
    for (var r = 0; r < rings.length; r++) {
      if (boxes[r].contains(x, y) && _ringContains(rings[r], x, y)) {
        inside = !inside;
      }
    }
    return inside;
  }

  /// How far a point is from the nearest edge; infinity when no edge is
  /// within [limit].
  double distanceTo(double x, double y, double limit) {
    var best = double.infinity;
    for (var r = 0; r < rings.length; r++) {
      if (!boxes[r].contains(x, y, margin: min(limit, best))) continue;
      final ring = rings[r];
      for (var i = 0, j = ring.length - 2; i < ring.length; j = i, i += 2) {
        best = min(
          best,
          _toSegment(x, y, ring[j], ring[j + 1], ring[i], ring[i + 1]),
        );
      }
    }
    return best;
  }

  static bool _ringContains(Float64List ring, double x, double y) {
    var inside = false;
    for (var i = 0, j = ring.length - 2; i < ring.length; j = i, i += 2) {
      final (xi, yi, xj, yj) = (ring[i], ring[i + 1], ring[j], ring[j + 1]);
      if ((yi > y) != (yj > y) && x < (xj - xi) * (y - yi) / (yj - yi) + xi) {
        inside = !inside;
      }
    }
    return inside;
  }

  /// The distance from (x, y) to the segment from a to b.
  static double _toSegment(
    double x,
    double y,
    double ax,
    double ay,
    double bx,
    double by,
  ) {
    final (dx, dy) = (bx - ax, by - ay);
    final length = dx * dx + dy * dy;
    final t = length == 0
        ? 0.0
        : (((x - ax) * dx + (y - ay) * dy) / length).clamp(0.0, 1.0);
    return sqrt(pow(ax + t * dx - x, 2) + pow(ay + t * dy - y, 2));
  }
}

class _Box {
  const _Box(this.left, this.top, this.right, this.bottom);

  factory _Box.of(Float64List ring) {
    var (left, top, right, bottom) = (ring[0], ring[1], ring[0], ring[1]);
    for (var i = 2; i < ring.length; i += 2) {
      left = min(left, ring[i]);
      right = max(right, ring[i]);
      top = min(top, ring[i + 1]);
      bottom = max(bottom, ring[i + 1]);
    }
    return _Box(left, top, right, bottom);
  }

  final double left, top, right, bottom;

  bool contains(double x, double y, {double margin = 0}) =>
      x >= left - margin &&
      x <= right + margin &&
      y >= top - margin &&
      y <= bottom + margin;
}
