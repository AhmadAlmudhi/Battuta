import 'package:battuta/features/world_map/domain/map_regions.dart';
import 'package:battuta/features/world_map/domain/map_view.dart';
import 'package:flutter_test/flutter_test.dart';

// The map as a phone shows it: 364 dp wide, in the map's proportions.
const width = 364.0;
const height = width * 435 / 1000;

void main() {
  test('the world view shows the whole map', () {
    const view = MapView.world;

    expect(view.isZoomed, isFalse);
    expect(view.toMap(0, 0, width, height), (0.0, 0.0));
    expect(view.toMap(width, height, width, height), (1000.0, 435.0));
  });

  test('zoom stays between 1× and 8×, and the map always fills the view '
      '(FR-MAP-16)', () {
    expect(MapView(scale: 0.5, centerX: 500, centerY: 217.5).scale, 1);
    expect(MapView(scale: 20, centerX: 500, centerY: 217.5).scale, 8);
    // At 2×, half the map's width is on screen, so the middle of the view
    // can't be closer than 250 units to an edge.
    final atEdge = MapView(scale: 2, centerX: 10, centerY: 0);
    expect(atEdge.centerX, 250);
    expect(atEdge.centerY, 435 / 4);
  });

  test('zooming keeps the point under the pointer still', () {
    final before = MapView.world.toMap(100, 50, width, height);
    final zoomed = MapView.world.zoomedBy(
      2,
      x: 100,
      y: 50,
      width: width,
      height: height,
    );

    final (x, y) = zoomed.toMap(100, 50, width, height);
    expect(zoomed.scale, 2);
    expect(x, closeTo(before.$1, 1e-9));
    expect(y, closeTo(before.$2, 1e-9));
  });

  test('dragging moves the map with the finger, but not past its edges '
      '(FR-MAP-17)', () {
    final zoomed = MapView(scale: 2, centerX: 500, centerY: 217.5);
    // At 2× on a 364 dp map, a unit is 0.728 dp.
    expect(zoomed.pannedBy(36.4, 0, width).centerX, closeTo(450, 1e-9));
    expect(MapView.world.pannedBy(36.4, 20, width), MapView.world);
  });

  test('fitting shows a region\'s whole frame with 16 dp around it '
      '(FR-MAP-22)', () {
    final frame = regionFrame('Europe')!;
    final view = MapView.fit(frame, width: width, height: height);

    final (left, top) = view.toView(frame.left, frame.top, width, height);
    final (right, bottom) = view.toView(
      frame.right,
      frame.bottom,
      width,
      height,
    );
    expect(view.scale, greaterThan(3));
    for (final x in [left, right]) {
      expect(x, inInclusiveRange(16 - 1e-9, width - 16 + 1e-9));
    }
    for (final y in [top, bottom]) {
      expect(y, inInclusiveRange(16 - 1e-9, height - 16 + 1e-9));
    }
  });

  test('a flight starts and ends on its views and zooms at an even pace', () {
    final start = MapView.world;
    final end = MapView(scale: 4, centerX: 520, centerY: 120);

    expect(MapView.lerp(start, end, 0), start);
    expect(MapView.lerp(start, end, 1), end);
    expect(MapView.lerp(start, end, 0.5).scale, closeTo(2, 1e-9));
  });
}
