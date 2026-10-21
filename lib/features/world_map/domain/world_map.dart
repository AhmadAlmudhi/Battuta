import 'dart:convert';
import 'dart:typed_data';

/// A point on the map, in map units (PRD section 8.7).
typedef MapPoint = ({double x, double y});

/// The bundled world map (PRD section 8.7): every country's rings, already
/// projected to map units, plus dots for small countries.
class WorldMap {
  const WorldMap({
    required this.width,
    required this.height,
    required this.shapes,
    required this.dots,
    required this.unmatched,
  });

  /// Parses `assets/data/world_map.json`.
  factory WorldMap.parse(String source) {
    final json = jsonDecode(source) as Map<String, Object?>;
    return WorldMap(
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      shapes: {
        for (final MapEntry(:key, :value)
            in (json['shapes'] as Map<String, Object?>).entries)
          key: _rings(value),
      },
      dots: {
        for (final MapEntry(:key, :value)
            in (json['dots'] as Map<String, Object?>).entries)
          key: switch (value) {
            [final num x, final num y] => (x: x.toDouble(), y: y.toDouble()),
            _ => throw FormatException('Bad dot for $key: $value'),
          },
      },
      unmatched: _rings(json['unmatched']),
    );
  }

  final double width;
  final double height;

  /// Each country's rings by 3-letter code. A ring is a flat list of x, y
  /// pairs. Holes are rings too, so rings fill with the even-odd rule.
  final Map<String, List<Float64List>> shapes;

  /// Where small countries' dots go (FR-MAP-09).
  final Map<String, MapPoint> dots;

  /// Shapes that match no country, such as Bir Tawil (FR-MAP-07).
  final List<Float64List> unmatched;

  static List<Float64List> _rings(Object? rings) => [
    for (final ring in rings as List<Object?>)
      Float64List.fromList([
        for (final value in ring as List<Object?>) (value as num).toDouble(),
      ]),
  ];
}

/// For `compute`, which needs a top-level function.
WorldMap parseWorldMap(String source) => WorldMap.parse(source);
