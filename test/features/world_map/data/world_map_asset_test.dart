import 'dart:convert';
import 'dart:io';

import 'package:battuta/features/countries/data/country_parser.dart';
import 'package:battuta/features/world_map/domain/map_hit_tester.dart';
import 'package:battuta/features/world_map/domain/map_projection.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_world_map.dart';

/// Checks the committed map file against the country snapshot
/// (PRD sections 8.7 and 12.1).
void main() {
  final map = testWorldMap;
  final snapshot =
      jsonDecode(File('assets/data/countries_snapshot.json').readAsStringSync())
          as Map<String, Object?>;
  // The countries the app shows, read the way the app reads them.
  final dataset = {
    for (final record in snapshot['objects'] as List<Object?>)
      ?parseCountry(record as Map<String, Object?>)?.code,
  };
  final onMap = {...map.shapes.keys, ...map.dots.keys};
  final tester = MapHitTester(map, selectable: dataset);

  test('every dataset country has a shape or a dot, except Antarctica and '
      'Western Sahara (D-11)', () {
    expect(dataset, hasLength(249));
    expect(dataset.difference(onMap), {'ATA', 'ESH'});
  });

  test('shapes and dots belong to dataset countries; none is coded -99', () {
    expect(onMap.difference(dataset), isEmpty);
  });

  test('overseas parts belong to their own countries', () {
    expect(tester.countryAt(mapPointOf(55.5, -21.1)), 'REU');
    expect(tester.countryAt(mapPointOf(-53.1, 3.9)), 'GUF');
    expect(tester.countryAt(mapPointOf(15.6, 78.2)), 'SJM');
    // These are dots, and none of them is part of its old country.
    for (final (code, lon, lat, old) in [
      ('GLP', -61.55, 16.25, 'FRA'),
      ('MTQ', -61.02, 14.64, 'FRA'),
      ('MYT', 45.15, -12.8, 'FRA'),
      ('BES', -68.27, 12.15, 'NLD'),
      ('BVT', 3.4, -54.43, 'NOR'),
      ('TKL', -171.85, -9.2, 'NZL'),
      ('CXR', 105.62, -10.49, 'AUS'),
      ('CCK', 96.87, -12.17, 'AUS'),
    ]) {
      expect(map.dots, contains(code));
      expect(tester.countryAt(mapPointOf(lon, lat)), isNot(old), reason: code);
    }
    // Jan Mayen goes with Svalbard.
    expect(tester.countryAt(mapPointOf(-8.3, 71.0)), isNot('NOR'));
  });

  test('France\'s shape stays in metropolitan France and Corsica', () {
    final (west, north) = MapFrame.project(-6, 52);
    final (east, south) = MapFrame.project(11, 41);
    final (widestWest, _) = MapFrame.project(-6, 41);
    for (final ring in map.shapes['FRA']!) {
      for (var i = 0; i < ring.length; i += 2) {
        expect(ring[i], inInclusiveRange(widestWest, east));
        expect(ring[i + 1], inInclusiveRange(north, south));
      }
    }
    expect(west, greaterThan(widestWest));
  });

  test('Israel isn\'t in the dataset, and its area is Palestine on the map '
      '(D-11, D-12)', () {
    expect(dataset, isNot(contains('ISR')));
    expect(tester.countryAt(mapPointOf(34.78, 32.08)), 'PSE');
  });

  test('everything stays inside the frame', () {
    final rings = [...map.shapes.values.expand((r) => r), ...map.unmatched];
    for (final ring in rings) {
      for (var i = 0; i < ring.length; i += 2) {
        expect(ring[i], inInclusiveRange(0, map.width));
        expect(ring[i + 1], inInclusiveRange(0, map.height));
      }
    }
    expect(map.width, MapFrame.width);
    expect(map.height, MapFrame.height);
  });
}
