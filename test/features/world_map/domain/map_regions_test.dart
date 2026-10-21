import 'dart:math';

import 'package:battuta/features/world_map/domain/map_projection.dart';
import 'package:battuta/features/world_map/domain/map_regions.dart';
import 'package:flutter_test/flutter_test.dart';

bool frameHas(String region, double lon, double lat) {
  final (x, y) = MapFrame.project(lon, lat);
  return regionFrame(region)!.contains(x, y);
}

void main() {
  test('chips cover every region except the Antarctic (FR-MAP-21)', () {
    expect(mapRegions, ['Africa', 'Americas', 'Asia', 'Europe', 'Oceania']);
    expect(regionFrame('Antarctic'), isNull);
  });

  test('each frame holds its region\'s core', () {
    expect(frameHas('Europe', 2.35, 48.86), isTrue); // Paris
    expect(frameHas('Europe', -3.70, 40.42), isTrue); // Madrid
    expect(frameHas('Europe', 139.69, 35.69), isFalse); // Tokyo
    expect(frameHas('Africa', 18.42, -33.92), isTrue); // Cape Town
    expect(frameHas('Asia', 139.69, 35.69), isTrue); // Tokyo
    expect(frameHas('Americas', -74.01, 40.71), isTrue); // New York
    expect(frameHas('Oceania', 151.21, -33.87), isTrue); // Sydney
  });

  test('frames follow their curved edges, so the Horn of Africa stays in '
      'the Africa frame', () {
    // Cape Guardafui, near the frame's east edge at 55° E but close to the
    // equator, where the meridian bows outward.
    expect(frameHas('Africa', 51.27, 11.83), isTrue);

    // A frame made from the four corners alone would cut it off.
    final corners = [
      for (final (lon, lat) in [(-20.0, -36.0), (55.0, -36.0), (55.0, 38.0)])
        MapFrame.project(lon, lat),
    ];
    final cornersRight = corners.map((p) => p.$1).reduce(max);
    expect(MapFrame.project(51.27, 11.83).$1, greaterThan(cornersRight));
  });
}
