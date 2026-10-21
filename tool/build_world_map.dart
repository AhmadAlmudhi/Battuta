// Builds the bundled world map from Natural Earth's country boundaries
// (PRD section 8.7).
//
// Usage: dart run tool/build_world_map.dart <ne_10m_admin_0_countries_sau.geojson>
//
// Download the source from the geojson folder of the Natural Earth repository
// (github.com/nvkelso/natural-earth-vector); it isn't committed. Needs
// Node.js, because it simplifies the shapes with mapshaper 0.7.71 through
// npx. Makes no API requests.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:battuta/features/world_map/domain/map_projection.dart';

const _outputPath = 'assets/data/world_map.json';
const _snapshotPath = 'assets/data/countries_snapshot.json';

/// Dataset countries that aren't on the map (D-11): Antarctica is cropped
/// off, this edition draws Western Sahara as part of Morocco, and it draws
/// Israel's area as Palestine, keeping only a placeholder about 1 km across.
const _excluded = {'ATA', 'ESH', 'ISR'};

/// Shapes coded -99 that still match a dataset country, by ADM0_A3.
const _manualCodes = {'KOS': 'UNK'};

/// A country whose largest part fits within this many map units each way
/// gets a dot (FR-MAP-09).
const _dotSize = 6.0;

/// Longitude and latitude pairs.
typedef _Ring = List<(double, double)>;

/// An outer ring, then any holes.
typedef _Polygon = List<_Ring>;

/// A ring in map units, as a flat list of x, y pairs.
typedef _MapRing = List<double>;

Future<void> main(List<String> args) async {
  if (args.length != 1 || !File(args.single).existsSync()) {
    stderr.writeln(
      'Usage: dart run tool/build_world_map.dart '
      '<ne_10m_admin_0_countries_sau.geojson>',
    );
    exit(64);
  }
  final source = File(args.single).absolute.path;
  final dataset = _datasetCodes();

  final temp = await Directory.systemTemp.createTemp('battuta_world_map');
  final _Countries simplified;
  final _Countries full;
  try {
    final simplifiedPath = '${temp.path}/world_simplified.geojson';
    await _simplify(source, simplifiedPath);
    simplified = _assign(_features(simplifiedPath), dataset);
    // The full-detail source still has the countries whose shapes vanish in
    // simplification, such as Vatican City, so it places their dots.
    full = _assign(_features(source), dataset);
  } finally {
    await temp.delete(recursive: true);
  }

  final shapes = <String, List<_MapRing>>{};
  final dots = <String, (double, double)>{};
  final fromFullSource = <String>[];
  final missing = <String>[];
  for (final code in dataset.difference(_excluded).toList()..sort()) {
    final polygons = _project(simplified.countries[code]);
    if (polygons.isNotEmpty) {
      shapes[code] = [for (final polygon in polygons) ...polygon];
      final largest = _largest(polygons);
      final (width, height) = _size(largest);
      if (width <= _dotSize && height <= _dotSize) {
        dots[code] = _centroid(largest);
      }
      continue;
    }
    final detailed = full.countries[code];
    if (detailed == null) {
      missing.add(code);
      continue;
    }
    // Some, like Vatican City, are smaller than a map unit even in full
    // detail, so the dot goes in the middle of the largest part before any
    // rounding.
    final largest = detailed.reduce(
      (a, b) => _degreeArea(b.first) > _degreeArea(a.first) ? b : a,
    );
    final (lon, lat) = _center(largest.first);
    final (x, y) = MapFrame.project(lon, lat);
    dots[code] = (_round(x), _round(y));
    fromFullSource.add(code);
  }
  final unmatched = [
    for (final polygon in _project(simplified.unmatched)) ...polygon,
  ];

  stdout
    ..writeln('Shapes: ${shapes.length} countries')
    ..writeln('Dots: ${dots.length} countries')
    ..writeln('  ${dots.keys.join(' ')}')
    ..writeln('Dots placed from the full-detail source: $fromFullSource')
    ..writeln('Not on the map, as expected: ${_excluded.toList()..sort()}')
    ..writeln('Shapes that match no country: ${simplified.unmatchedNames}');
  if (missing.isNotEmpty) {
    stderr.writeln('No shape or dot for: $missing');
    exit(1);
  }

  await File(_outputPath).writeAsString(_encode(shapes, dots, unmatched));
  stdout.writeln(
    'Wrote $_outputPath (${File(_outputPath).lengthSync() ~/ 1024} KB)',
  );
}

Set<String> _datasetCodes() {
  final snapshot =
      jsonDecode(File(_snapshotPath).readAsStringSync())
          as Map<String, Object?>;
  return {
    for (final record in snapshot['objects'] as List<Object?>)
      if (((record as Map<String, Object?>)['codes']
              as Map<String, Object?>)['alpha_3']
          case final String code when code.isNotEmpty)
        code,
  };
}

/// Drops Antarctica, keeps only the fields the build needs, and reduces
/// detail, as listed in PRD section 8.7.
Future<void> _simplify(String source, String output) async {
  final result = await Process.run('npx', [
    '--yes',
    'mapshaper@0.7.71',
    '-i',
    source,
    '-filter',
    'CONTINENT != "Antarctica"',
    '-filter-fields',
    'ADM0_A3,ISO_A3_EH,NAME',
    '-simplify',
    '2%',
    'keep-shapes',
    '-o',
    'precision=0.01',
    'format=geojson',
    output,
  ]);
  if (result.exitCode != 0) {
    stderr.writeln('mapshaper failed:\n${result.stdout}${result.stderr}');
    exit(1);
  }
}

List<Map<String, Object?>> _features(String path) =>
    ((jsonDecode(File(path).readAsStringSync())
                as Map<String, Object?>)['features']
            as List<Object?>)
        .cast<Map<String, Object?>>();

typedef _Countries = ({
  Map<String, List<_Polygon>> countries,
  List<_Polygon> unmatched,
  List<String> unmatchedNames,
});

/// Groups polygons by dataset country: by ISO_A3_EH, with the manual codes
/// and the overseas parts split out by location (PRD section 8.7).
_Countries _assign(List<Map<String, Object?>> features, Set<String> dataset) {
  final countries = <String, List<_Polygon>>{};
  final unmatched = <_Polygon>[];
  final unmatchedNames = <String>[];
  for (final feature in features) {
    final properties = feature['properties'] as Map<String, Object?>;
    // Only the full-detail source still has Antarctica. Shapes that vanished
    // in simplification have no geometry; the full source places them.
    if (properties['CONTINENT'] == 'Antarctica') continue;
    if (feature['geometry'] == null) continue;
    final admin = properties['ADM0_A3'] as String;
    final code = _manualCodes[admin] ?? properties['ISO_A3_EH'] as String;
    var matched = false;
    for (final polygon in _polygons(feature['geometry'])) {
      final part = _splitOverseas(admin, code, polygon);
      if (dataset.contains(part) && !_excluded.contains(part)) {
        countries.putIfAbsent(part, () => []).add(polygon);
        matched = true;
      } else {
        unmatched.add(polygon);
      }
    }
    if (!matched) unmatchedNames.add(properties['NAME'] as String);
  }
  return (
    countries: countries,
    unmatched: unmatched,
    unmatchedNames: unmatchedNames,
  );
}

/// Overseas parts that the dataset lists as countries of their own,
/// told apart by where they are.
String _splitOverseas(String admin, String code, _Polygon polygon) {
  final (lon, lat) = _center(polygon.first);
  return switch (admin == 'IOA' ? admin : code) {
    // The Indian Ocean Territories, coded AUS.
    'IOA' => lon > 100 ? 'CXR' : 'CCK',
    'FRA' when lon < -58 => lat < 15.5 ? 'MTQ' : 'GLP',
    'FRA' when lon < -40 => 'GUF',
    'FRA' when lat < -18 => 'REU',
    'FRA' when lat < 0 => 'MYT',
    'NLD' when lon < -30 => 'BES',
    'NOR' when lat < 0 => 'BVT',
    // Svalbard, and Jan Mayen west of the mainland.
    'NOR' when lat > 73 || lon < -2 => 'SJM',
    'NZL' when lat > -15 => 'TKL',
    _ => code,
  };
}

Iterable<_Polygon> _polygons(Object? geometry) sync* {
  final shape = geometry as Map<String, Object?>;
  final coordinates = shape['coordinates'] as List<Object?>;
  final polygons = shape['type'] == 'Polygon' ? [coordinates] : coordinates;
  for (final polygon in polygons.cast<List<Object?>>()) {
    yield [
      for (final ring in polygon.cast<List<Object?>>())
        [
          for (final point in ring.cast<List<Object?>>())
            ((point[0] as num).toDouble(), (point[1] as num).toDouble()),
        ],
    ];
  }
}

(double, double) _center(_Ring ring) {
  final lons = ring.map((p) => p.$1), lats = ring.map((p) => p.$2);
  return (
    (lons.reduce(min) + lons.reduce(max)) / 2,
    (lats.reduce(min) + lats.reduce(max)) / 2,
  );
}

/// Projects polygons to map units. Rings that collapse when rounded are
/// dropped, and a polygon without its outer ring is dropped whole.
List<List<_MapRing>> _project(List<_Polygon>? polygons) => [
  for (final polygon in polygons ?? const <_Polygon>[])
    if (_projectRing(polygon.first) case final outer when outer.isNotEmpty)
      [
        outer,
        for (final hole in polygon.skip(1))
          if (_projectRing(hole) case final ring when ring.isNotEmpty) ring,
      ],
];

_MapRing _projectRing(_Ring ring) {
  final points = <double>[];
  for (final (lon, lat) in ring) {
    final (x, y) = MapFrame.project(lon, lat);
    final px = _round(x), py = _round(y);
    final n = points.length;
    if (n >= 2 && points[n - 2] == px && points[n - 1] == py) continue;
    points.addAll([px, py]);
  }
  // GeoJSON repeats the first point at the end; the app closes rings itself.
  final n = points.length;
  if (n >= 4 && points[0] == points[n - 2] && points[1] == points[n - 1]) {
    points.removeRange(n - 2, n);
  }
  return points.length >= 6 && _area(points) > 0 ? points : const [];
}

double _round(double value) => (value * 10).roundToDouble() / 10;

/// A ring's area in square degrees, good enough to compare parts of one
/// country.
double _degreeArea(_Ring ring) {
  var sum = 0.0;
  for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    sum += ring[j].$1 * ring[i].$2 - ring[i].$1 * ring[j].$2;
  }
  return sum.abs() / 2;
}

/// The polygon whose outer ring has the largest area.
List<_MapRing> _largest(List<List<_MapRing>> polygons) =>
    polygons.reduce((a, b) => _area(b.first) > _area(a.first) ? b : a);

double _area(_MapRing ring) => _signedArea(ring).abs();

double _signedArea(_MapRing ring) {
  var sum = 0.0;
  for (var i = 0, j = ring.length - 2; i < ring.length; j = i, i += 2) {
    sum += ring[j] * ring[i + 1] - ring[i] * ring[j + 1];
  }
  return sum / 2;
}

(double, double) _size(List<_MapRing> polygon) {
  final outer = polygon.first;
  final xs = [for (var i = 0; i < outer.length; i += 2) outer[i]];
  final ys = [for (var i = 1; i < outer.length; i += 2) outer[i]];
  return (xs.reduce(max) - xs.reduce(min), ys.reduce(max) - ys.reduce(min));
}

/// The middle of a polygon's outer ring.
(double, double) _centroid(List<_MapRing> polygon) {
  final ring = polygon.first;
  final area = _signedArea(ring);
  var cx = 0.0, cy = 0.0;
  for (var i = 0, j = ring.length - 2; i < ring.length; j = i, i += 2) {
    final cross = ring[j] * ring[i + 1] - ring[i] * ring[j + 1];
    cx += (ring[j] + ring[i]) * cross;
    cy += (ring[j + 1] + ring[i + 1]) * cross;
  }
  return (_round(cx / (6 * area)), _round(cy / (6 * area)));
}

/// One country per line, so changes to the file are easy to review.
String _encode(
  Map<String, List<_MapRing>> shapes,
  Map<String, (double, double)> dots,
  List<_MapRing> unmatched,
) {
  String rings(List<_MapRing> rings) =>
      jsonEncode([for (final ring in rings) ring.map(_number).toList()]);
  final shapeLines = [
    for (final MapEntry(key: code, value: value) in shapes.entries)
      '"$code":${rings(value)}',
  ];
  final dotLines = [
    for (final MapEntry(key: code, value: (x, y)) in dots.entries)
      '"$code":[${_number(x)},${_number(y)}]',
  ];
  return '{"version":1,"width":${_number(MapFrame.width)},'
      '"height":${_number(MapFrame.height)},\n'
      '"shapes":{\n${shapeLines.join(',\n')}\n},\n'
      '"dots":{\n${dotLines.join(',\n')}\n},\n'
      '"unmatched":${rings(unmatched)}\n}\n';
}

/// Whole numbers without a trailing .0, to keep the file small.
num _number(double value) =>
    value == value.truncateToDouble() ? value.toInt() : value;
