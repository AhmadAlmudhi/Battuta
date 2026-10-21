import 'dart:typed_data';

import 'package:battuta/features/world_map/domain/map_hit_tester.dart';
import 'package:battuta/features/world_map/domain/map_projection.dart';
import 'package:battuta/features/world_map/domain/world_map.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_world_map.dart';

Float64List square(double x, double y, double size) =>
    Float64List.fromList([x, y, x + size, y, x + size, y + size, x, y + size]);

void main() {
  group('hit testing rules (FR-MAP-11)', () {
    final map = WorldMap(
      width: 100,
      height: 100,
      shapes: {
        // A country with a hole, and the country that fills the hole.
        'OUT': [square(0, 0, 40), square(10, 10, 10)],
        'INN': [square(10, 10, 10)],
        'BIG': [square(50, 30, 40)],
        'DOT': [square(48, 45, 1)],
        'OFF': [square(60, 80, 10)],
      },
      dots: {'DOT': (x: 48.5, y: 45.5), 'OFF': (x: 30, y: 95)},
      unmatched: [square(0, 60, 20)],
    );
    // OFF isn't in the dataset.
    final tester = MapHitTester(map, selectable: {'OUT', 'INN', 'BIG', 'DOT'});
    String? hit(double x, double y) =>
        tester.hitTest((x: x, y: y), dotRadius: 3, reach: 10);

    test('a point in a shape selects its country', () {
      expect(hit(5, 5), 'OUT');
      expect(hit(80, 60), 'BIG');
    });

    test('a hole belongs to the country inside it, like Lesotho in South '
        'Africa', () {
      expect(hit(15, 15), 'INN');
    });

    test('a dot wins when the pointer is on it, over land or water', () {
      expect(hit(50.5, 45.5), 'DOT'); // On BIG.
      expect(hit(49.6, 47), 'DOT'); // In the water next to BIG's coast.
    });

    test('over land, off the dots, the country under the pointer wins', () {
      expect(hit(53, 45.5), 'BIG');
    });

    test('over water, the nearest country or dot within reach of its edge '
        'wins', () {
      expect(hit(45, 45.5), 'DOT');
      // BIG's coast is nearer than the dot's edge.
      expect(hit(49.8, 50), 'BIG');
      expect(hit(40.5, 41), 'OUT');
      expect(hit(30, 52), isNull);
    });

    test('shapes and dots of countries outside the dataset can\'t be '
        'selected (FR-MAP-07)', () {
      expect(hit(10, 70), isNull);
      expect(hit(65, 85), isNull);
      expect(hit(30, 95), isNull);
      expect(tester.countryAt((x: 65, y: 85)), 'OFF');
    });
  });

  group('the bundled map', () {
    final tester = MapHitTester(
      testWorldMap,
      selectable: {...testWorldMap.shapes.keys, ...testWorldMap.dots.keys},
    );

    /// What a tap at a place selects on a map shown [mapWidth] dp wide: about
    /// 364 on a phone, about 672 in a desktop browser.
    String? tapAt(MapPoint point, {required double mapWidth}) {
      final unitsPerDp = MapFrame.width / mapWidth;
      return tester.hitTest(
        point,
        dotRadius: 4 * unitsPerDp,
        reach: 24 * unitsPerDp,
      );
    }

    test('Madrid is Spain on a phone, though the Andorra dot is only 5 dp '
        'away', () {
      expect(tapAt(mapPointOf(-3.70, 40.42), mapWidth: 364), 'ESP');
    });

    test('a tap in the sea just north of Bahrain is Bahrain (AC-MAP-06)', () {
      final nearby = mapPointOf(50.55, 26.45);
      expect(tester.countryAt(nearby), isNull);
      expect(tapAt(nearby, mapWidth: 364), 'BHR');
    });

    test('the Singapore dot is Singapore (AC-MAP-07)', () {
      expect(tapAt(testWorldMap.dots['SGP']!, mapWidth: 364), 'SGP');
    });

    test('a tap on the Bahrain dot is Bahrain, though Qatar\'s coast and dot '
        'are close by on a phone', () {
      final bahrain = testWorldMap.dots['BHR']!;
      final onDot = (x: bahrain.x + 1, y: bahrain.y);
      expect(tester.countryAt(onDot), isNull);
      expect(tapAt(onDot, mapWidth: 364), 'BHR');
    });

    test('western Saudi Arabia is Saudi Arabia on a phone, away from the '
        'Bahrain and Qatar dots (AC-MAP-08)', () {
      expect(tapAt(mapPointOf(39.61, 24.47), mapWidth: 364), 'SAU'); // Medina
    });

    test('a tap in the Red Sea just off Jeddah is Saudi Arabia, not the '
        'nearest dot across the peninsula', () {
      final offshore = mapPointOf(38.9, 21.5);
      expect(tester.countryAt(offshore), isNull);
      expect(tapAt(offshore, mapWidth: 364), 'SAU');
    });

    test('the open ocean is nothing', () {
      expect(tapAt(mapPointOf(-130, -45), mapWidth: 672), isNull);
    });
  });
}
