import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:battuta/features/world_map/domain/map_projection.dart';
import 'package:battuta/features/world_map/domain/map_view.dart';
import 'package:battuta/features/world_map/presentation/world_map_colors.dart';
import 'package:battuta/features/world_map/presentation/world_map_geometry.dart';
import 'package:battuta/features/world_map/presentation/world_map_painter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_world_map.dart';

/// The map's two layers, stacked as on screen, 2,000 px wide, so colors can
/// be read back where countries are. Exact colors in the middle of shapes,
/// not golden images (PRD section 12.1).
class _Rendered {
  _Rendered._(this._bytes, this._view);

  static const _size = Size(2000, 870);
  static final _geometry = WorldMapGeometry(testWorldMap);

  static Future<_Rendered> of(
    Map<String, TravelStatus> statuses,
    WorldMapColors colors, {
    MapView view = MapView.world,
    MapOutside? outside,
    double fade = 0,
    MapMotion? motion,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    for (final layer in <CustomPainter>[
      WorldMapBasePainter(geometry: _geometry, colors: colors, view: view),
      WorldMapPainter(
        geometry: _geometry,
        statuses: statuses,
        colors: colors,
        view: view,
        outside: outside,
        fade: fade,
        motion: motion,
      ),
    ]) {
      canvas.save();
      layer.paint(canvas, _size);
      canvas.restore();
    }
    final image = await recorder.endRecording().toImage(
      _size.width.toInt(),
      _size.height.toInt(),
    );
    return _Rendered._((await image.toByteData())!, view);
  }

  final ByteData _bytes;
  final MapView _view;

  /// The color at a place, or [right] pixels to the right of it.
  Color at((double, double) place, {int right = 0}) {
    final (x, y) = MapFrame.project(place.$1, place.$2);
    return atMapPoint(x, y, right: right);
  }

  Color atMapPoint(double x, double y, {int right = 0, int down = 0}) {
    final (vx, vy) = _view.toView(x, y, _size.width, _size.height);
    final i = ((vy.round() + down) * _size.width + vx.round() + right).toInt();
    return Color.fromARGB(
      _bytes.getUint8(i * 4 + 3),
      _bytes.getUint8(i * 4),
      _bytes.getUint8(i * 4 + 1),
      _bytes.getUint8(i * 4 + 2),
    );
  }
}

const japan = (138.3, 36.3);
const france = (2.5, 46.5);
const brazil = (-52.0, -10.0);
const ocean = (-25.0, -15.0);

void main() {
  test('visited is amber, wishlist is hatched teal, and other countries are '
      'white (AC-MAP-01)', () async {
    const colors = WorldMapColors.light;
    final map = await _Rendered.of({
      'JPN': TravelStatus.visited,
      'BRA': TravelStatus.wishlist,
    }, colors);

    expect(map.at(japan), colors.visitedFill);
    expect(map.at(france), colors.notYetFill);
    expect(map.at(ocean), colors.ocean);
    // A row across Brazil crosses both the base color and the stripes.
    final row = [for (var i = 0; i < 40; i++) map.at(brazil, right: i)];
    expect(row, contains(colors.wishlistBase));
    expect(row.any((color) => color.r < 0.6), isTrue);
  });

  test('small countries\' dots take their status color (FR-MAP-10)', () async {
    const colors = WorldMapColors.light;
    final map = await _Rendered.of({'BHR': TravelStatus.visited}, colors);
    final bahrain = testWorldMap.dots['BHR']!;

    expect(map.atMapPoint(bahrain.x, bahrain.y), colors.visitedFill);
  });

  test('at 8× a border is still a thin line (FR-MAP-20, AC-MAP-12)', () async {
    const colors = WorldMapColors.light;
    // The Pyrenees at 0° E, between France and Spain, both Not yet.
    final (x, y) = MapFrame.project(0, 42.7);
    final map = await _Rendered.of(
      const {},
      colors,
      view: MapView(scale: 8, centerX: x, centerY: y),
    );
    final (_, north) = MapFrame.project(0, 43.6);
    final (_, south) = MapFrame.project(0, 41.8);
    final column = [
      for (var down = 0; down <= ((south - north) * 16).round(); down++)
        map.atMapPoint(x, north, down: down),
    ];

    // A 0.55 dp border scaled with the zoom would be over 4 px wide here.
    final line = column.where((color) => color != colors.notYetFill);
    expect(line, isNotEmpty);
    expect(line.length, lessThanOrEqualTo(2));
  });

  test('outside a focused region, countries show at 30% (FR-MAP-23)', () async {
    const colors = WorldMapColors.light;
    final geometry = _Rendered._geometry;
    final map = await _Rendered.of(
      {'FRA': TravelStatus.visited, 'JPN': TravelStatus.visited},
      colors,
      outside: geometry.outside('Europe', const {
        'FRA': 'Europe',
        'JPN': 'Asia',
      }),
      fade: 1,
    );

    expect(map.at(france), colors.visitedFill);
    final faded = map.at(japan);
    final expected = Color.lerp(colors.visitedFill, colors.ocean, 0.7)!;
    for (final (actual, wanted) in [
      (faded.r, expected.r),
      (faded.g, expected.g),
      (faded.b, expected.b),
    ]) {
      expect(actual, closeTo(wanted, 2 / 255));
    }
  });

  test('a wishlist country being visited keeps its hatching until the '
      'amber covers it (FR-MAP-32)', () async {
    const colors = WorldMapColors.light;
    final map = await _Rendered.of(
      {'BRA': TravelStatus.visited, 'BHR': TravelStatus.visited},
      colors,
      motion: const MapMotion(
        fills: {'BRA': 0, 'BHR': 0},
        fading: {
          'BRA': (TravelStatus.wishlist, 1),
          'BHR': (TravelStatus.wishlist, 1),
        },
      ),
    );
    final bahrain = testWorldMap.dots['BHR']!;

    final row = [for (var i = 0; i < 40; i++) map.at(brazil, right: i)];
    expect(row, contains(colors.wishlistBase));
    expect(row, isNot(contains(colors.visitedFill)));
    // A dot starts from its old color too.
    expect(map.atMapPoint(bahrain.x, bahrain.y), colors.wishlistBase);
  });

  test('flight paths arc upward in both directions (FR-MAP-36)', () {
    const west = Offset(100, 200);
    const east = Offset(300, 200);

    // 20% of the 200-unit flight, above the middle.
    expect(flightBend(west, east), const Offset(200, 160));
    expect(flightBend(east, west), const Offset(200, 160));
    // A flight south still bends by 20%, to one side.
    expect(
      (flightBend(const Offset(0, 0), const Offset(0, 100)) -
              const Offset(0, 50))
          .distance,
      closeTo(20, 1e-9),
    );
  });

  test('dark mode uses the dark fill, not white (AC-MAP-05)', () async {
    const colors = WorldMapColors.dark;
    final map = await _Rendered.of({'JPN': TravelStatus.visited}, colors);

    expect(map.at(france), colors.notYetFill);
    expect(map.at(france), isNot(const Color(0xFFFFFFFF)));
    expect(map.at(ocean), colors.ocean);
    expect(map.at(japan), colors.visitedFill);
  });
}
