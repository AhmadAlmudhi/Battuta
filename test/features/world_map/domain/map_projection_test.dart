import 'package:battuta/features/world_map/domain/map_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Equal Earth (PRD section 8.7)', () {
    test('the origin projects to (0, 0)', () {
      expect(equalEarth(0, 0), (0.0, 0.0));
    });

    test('matches a reference implementation', () {
      // Longitude, latitude, x, and y from geoEqualEarthRaw in d3-geo 3.1.1.
      const reference = [
        (180.0, 0.0, 2.706629984, 0.0),
        (0.0, 90.0, 0.0, 1.317362759),
        (-74.006, 40.7128, -0.981861450, 0.787064220), // New York
        (139.6917, 35.6895, 1.909462942, 0.697844716), // Tokyo
        (46.6753, 24.7136, 0.670933721, 0.492428381), // Riyadh
        (-58.3816, -34.6037, -0.802723755, -0.678117877), // Buenos Aires
      ];
      for (final (lon, lat, x, y) in reference) {
        final (px, py) = equalEarth(lon, lat);
        expect(px, closeTo(x, 1e-6), reason: 'x at ($lon, $lat)');
        expect(py, closeTo(y, 1e-6), reason: 'y at ($lon, $lat)');
      }
    });
  });

  group('the map frame (PRD section 10.1)', () {
    test('the equator spans the full width', () {
      expect(MapFrame.project(-180, 0).$1, closeTo(0, 1e-9));
      expect(MapFrame.project(0, 0).$1, 500);
      expect(MapFrame.project(180, 0).$1, closeTo(1000, 1e-9));
    });

    test('84° north is the top edge, and 57° south is 434.8 units down, '
        'inside the 435-unit frame', () {
      expect(MapFrame.project(0, 84).$2, closeTo(0, 1e-9));
      expect(MapFrame.project(0, -57).$2, closeTo(434.8, 0.05));
      expect(MapFrame.project(0, -57).$2, lessThanOrEqualTo(MapFrame.height));
    });

    test('latitudes outside the crop are held at its edges', () {
      expect(MapFrame.project(10, -80), MapFrame.project(10, -57));
      expect(MapFrame.project(10, 89), MapFrame.project(10, 84));
    });
  });
}
