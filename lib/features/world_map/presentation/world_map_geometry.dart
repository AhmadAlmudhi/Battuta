import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import '../domain/map_projection.dart';
import '../domain/world_map.dart';

/// The map's paths in map units, built once from the map file
/// (PRD section 11.5).
class WorldMapGeometry {
  WorldMapGeometry(WorldMap map)
    : size = Size(map.width, map.height),
      _shapes = map.shapes,
      countries = {
        for (final MapEntry(:key, :value) in map.shapes.entries)
          key: _path(value),
      },
      unmatched = _path(map.unmatched),
      dots = {
        for (final MapEntry(:key, :value) in map.dots.entries)
          key: Offset(value.x, value.y),
      };

  final Size size;
  final Map<String, List<Float64List>> _shapes;

  /// One path per country, filled with the even-odd rule so holes stay
  /// empty.
  final Map<String, Path> countries;

  /// Shapes that match no country, drawn as Not yet (FR-MAP-07).
  final Path unmatched;

  /// Where small countries' dots go (FR-MAP-09).
  final Map<String, Offset> dots;

  /// Every shape, for the Not yet layer.
  late final Path land = union([...countries.values, unmatched]);

  final _starts = <String, Offset>{};
  final _bounds = <String, Rect>{};
  final _outside = <(String, Map<String, String>), MapOutside>{};

  /// Where a country's ink spread starts: the middle of its largest part
  /// (PRD section 11.5).
  Offset spreadStart(String code) => _starts.putIfAbsent(code, () {
    final largest = _shapes[code]!.reduce(
      (a, b) => _area(b).abs() > _area(a).abs() ? b : a,
    );
    final area = _area(largest);
    var (x, y) = (0.0, 0.0);
    for (var i = 0, j = largest.length - 2; i < largest.length; j = i, i += 2) {
      final cross = largest[j] * largest[i + 1] - largest[i] * largest[j + 1];
      x += (largest[j] + largest[i]) * cross;
      y += (largest[j + 1] + largest[i + 1]) * cross;
    }
    return Offset(x / (6 * area), y / (6 * area));
  });

  /// How far a spread from [start] must grow to cover every part: to the
  /// farthest corner of the country's bounds.
  double spreadReach(String code, Offset start) {
    final bounds = _bounds.putIfAbsent(
      code,
      () => countries[code]!.getBounds(),
    );
    return [
      bounds.topLeft,
      bounds.topRight,
      bounds.bottomLeft,
      bounds.bottomRight,
    ].map((corner) => (corner - start).distance).reduce(max);
  }

  /// The shapes and dots outside [region], given each country's region,
  /// which fade during a region focus (FR-MAP-23).
  MapOutside outside(String region, Map<String, String> regions) =>
      _outside.putIfAbsent((region, regions), () {
        bool isOutside(String code) => regions[code] != region;
        return MapOutside(
          shapes: union([
            for (final MapEntry(:key, :value) in countries.entries)
              if (isOutside(key)) value,
            unmatched,
          ]),
          dots: [
            for (final MapEntry(:key, :value) in dots.entries)
              if (isOutside(key)) value,
          ],
        );
      });

  static double _area(Float64List ring) {
    var sum = 0.0;
    for (var i = 0, j = ring.length - 2; i < ring.length; j = i, i += 2) {
      sum += ring[j] * ring[i + 1] - ring[i] * ring[j + 1];
    }
    return sum / 2;
  }

  /// The crop in whole degrees, for drawing curves a degree at a time.
  static final _south = MapFrame.south.toInt(), _north = MapFrame.north.toInt();

  /// The Equal Earth outline: curved meridians at 180° west and east, and
  /// straight parallels at the crop.
  late final Path outline = () {
    final path = Path();
    for (var lat = _south; lat <= _north; lat++) {
      final (x, y) = MapFrame.project(-180, lat.toDouble());
      lat == _south ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    for (var lat = _north; lat >= _south; lat--) {
      final (x, y) = MapFrame.project(180, lat.toDouble());
      path.lineTo(x, y);
    }
    return path..close();
  }();

  /// Meridians and parallels every 10°.
  late final Path grid = () {
    final path = Path();
    for (var lon = -170; lon <= 170; lon += 10) {
      for (var lat = _south; lat <= _north; lat++) {
        final (x, y) = MapFrame.project(lon.toDouble(), lat.toDouble());
        lat == _south ? path.moveTo(x, y) : path.lineTo(x, y);
      }
    }
    for (var lat = -50; lat <= 80; lat += 10) {
      final (x1, y) = MapFrame.project(-180, lat.toDouble());
      final (x2, _) = MapFrame.project(180, lat.toDouble());
      path
        ..moveTo(x1, y)
        ..lineTo(x2, y);
    }
    return path;
  }();

  static Path _path(List<Float64List> rings) {
    final path = Path()..fillType = PathFillType.evenOdd;
    for (final ring in rings) {
      path.moveTo(ring[0], ring[1]);
      for (var i = 2; i < ring.length; i += 2) {
        path.lineTo(ring[i], ring[i + 1]);
      }
      path.close();
    }
    return path;
  }
}

/// What fades outside a focused region (FR-MAP-23).
class MapOutside {
  const MapOutside({required this.shapes, required this.dots});

  final Path shapes;
  final List<Offset> dots;
}

/// Several countries' paths as one, so each layer is a single draw call.
Path union(Iterable<Path> paths) {
  final union = Path()..fillType = PathFillType.evenOdd;
  for (final path in paths) {
    union.addPath(path, Offset.zero);
  }
  return union;
}
