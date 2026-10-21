import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:battuta/features/world_map/domain/map_projection.dart';
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
  _Rendered._(this._bytes);

  static const _size = Size(2000, 870);

  static Future<_Rendered> of(
    Map<String, TravelStatus> statuses,
    WorldMapColors colors,
  ) async {
    final geometry = WorldMapGeometry(testWorldMap);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    for (final layer in <CustomPainter>[
      WorldMapBasePainter(geometry: geometry, colors: colors),
      WorldMapPainter(geometry: geometry, statuses: statuses, colors: colors),
    ]) {
      canvas.save();
      layer.paint(canvas, _size);
      canvas.restore();
    }
    final image = await recorder.endRecording().toImage(
      _size.width.toInt(),
      _size.height.toInt(),
    );
    return _Rendered._((await image.toByteData())!);
  }

  final ByteData _bytes;

  /// The color at a place, or [right] pixels to the right of it.
  Color at((double, double) place, {int right = 0}) {
    final (x, y) = MapFrame.project(place.$1, place.$2);
    return atMapPoint(x, y, right: right);
  }

  Color atMapPoint(double x, double y, {int right = 0}) {
    final scale = _size.width / MapFrame.width;
    final i = ((y * scale).round() * _size.width + (x * scale).round() + right)
        .toInt();
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

  test('dark mode uses the dark fill, not white (AC-MAP-05)', () async {
    const colors = WorldMapColors.dark;
    final map = await _Rendered.of({'JPN': TravelStatus.visited}, colors);

    expect(map.at(france), colors.notYetFill);
    expect(map.at(france), isNot(const Color(0xFFFFFFFF)));
    expect(map.at(ocean), colors.ocean);
    expect(map.at(japan), colors.visitedFill);
  });
}
