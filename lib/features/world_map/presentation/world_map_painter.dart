import 'dart:math';

import 'package:flutter/material.dart';

import '../../travels/domain/travel_entry.dart';
import 'world_map_colors.dart';
import 'world_map_geometry.dart';

/// Line widths and dot sizes in dp; they keep their size on screen at any
/// map size (PRD section 10.1).
abstract final class MapSizes {
  static const border = 0.55;
  static const wishlistBorder = 0.9;
  static const grid = 0.6;
  static const dotRadius = 4.0;
  static const dotBorder = 1.2;
  static const stripeSpacing = 5.0;
  static const stripeWidth = 1.6;
  static const hoverBorder = 1.5;
  static const selectedBorder = 2.0;
}

/// The layers that change only with the theme (PRD section 11.5): the
/// ocean, grid lines, and every country in the Not yet colors. It sits in its
/// own repaint boundary, so statuses and highlights don't redraw it.
class WorldMapBasePainter extends CustomPainter {
  const WorldMapBasePainter({required this.geometry, required this.colors});

  final WorldMapGeometry geometry;
  final WorldMapColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final dp = _scaleToMap(canvas, size, geometry);
    canvas
      ..drawPath(geometry.outline, Paint()..color = colors.ocean)
      ..drawPath(geometry.grid, _stroke(colors.grid, MapSizes.grid * dp))
      ..drawPath(geometry.land, Paint()..color = colors.notYetFill)
      ..drawPath(
        geometry.land,
        _stroke(colors.notYetBorder, MapSizes.border * dp),
      );
  }

  @override
  bool shouldRepaint(WorldMapBasePainter old) =>
      old.geometry != geometry || old.colors != colors;
}

/// Statuses, dots, and highlights, over the base layer (FR-MAP-01,
/// FR-MAP-10, FR-MAP-12).
class WorldMapPainter extends CustomPainter {
  const WorldMapPainter({
    required this.geometry,
    required this.statuses,
    required this.colors,
    this.selected,
    this.hovered,
  });

  final WorldMapGeometry geometry;
  final Map<String, TravelStatus> statuses;
  final WorldMapColors colors;
  final String? selected;
  final String? hovered;

  @override
  void paint(Canvas canvas, Size size) {
    final dp = _scaleToMap(canvas, size, geometry);
    Path withStatus(TravelStatus status) => union([
      for (final MapEntry(:key, :value) in statuses.entries)
        if (value == status) ?geometry.countries[key],
    ]);
    final wishlist = withStatus(TravelStatus.wishlist);
    final visited = withStatus(TravelStatus.visited);

    canvas.drawPath(wishlist, Paint()..color = colors.wishlistBase);
    paintStripes(canvas, wishlist, colors.wishlistStripe, dp);
    canvas
      ..drawPath(visited, Paint()..color = colors.visitedFill)
      ..drawPath(visited, _stroke(colors.visitedBorder, MapSizes.border * dp))
      ..drawPath(
        wishlist,
        _stroke(colors.wishlistBorder, MapSizes.wishlistBorder * dp),
      );

    for (final MapEntry(key: code, value: center) in geometry.dots.entries) {
      final (fill, border) = switch (statuses[code]) {
        TravelStatus.visited => (colors.visitedFill, colors.visitedBorder),
        TravelStatus.wishlist => (colors.wishlistBase, colors.wishlistBorder),
        null => (colors.notYetFill, colors.notYetBorder),
      };
      canvas
        ..drawCircle(center, MapSizes.dotRadius * dp, Paint()..color = fill)
        ..drawCircle(
          center,
          MapSizes.dotRadius * dp,
          _stroke(border, MapSizes.dotBorder * dp),
        );
    }

    for (final (code, width) in [
      (hovered, MapSizes.hoverBorder),
      (selected, MapSizes.selectedBorder),
    ]) {
      if (code == null) continue;
      final highlight = _stroke(colors.highlight, width * dp);
      if (geometry.countries[code] case final path?) {
        canvas.drawPath(path, highlight);
      }
      if (geometry.dots[code] case final dot?) {
        canvas.drawCircle(dot, (MapSizes.dotRadius + 2) * dp, highlight);
      }
    }
  }

  @override
  bool shouldRepaint(WorldMapPainter old) =>
      old.geometry != geometry ||
      old.statuses != statuses ||
      old.colors != colors ||
      old.selected != selected ||
      old.hovered != hovered;
}

/// Wishlist hatching (PRD section 10.1): stripes rising at 45°, 5 dp apart,
/// clipped to [area]. [dp] is one dp in the canvas's units.
void paintStripes(Canvas canvas, Path area, Color color, double dp) {
  final bounds = area.getBounds();
  if (bounds.isEmpty) return;
  // Lines where x + y is a multiple of step, so the stripes stay put when
  // the area changes.
  final step = MapSizes.stripeSpacing * dp * sqrt2;
  final stripes = Path();
  for (
    var k = ((bounds.left + bounds.top) / step).floor() * step;
    k <= bounds.right + bounds.bottom;
    k += step
  ) {
    stripes
      ..moveTo(k - bounds.bottom, bounds.bottom)
      ..lineTo(k - bounds.top, bounds.top);
  }
  canvas
    ..save()
    ..clipPath(area)
    ..drawPath(stripes, _stroke(color, MapSizes.stripeWidth * dp))
    ..restore();
}

/// Scales the canvas from map units to [size], and returns one dp in map
/// units.
double _scaleToMap(Canvas canvas, Size size, WorldMapGeometry geometry) {
  final scale = size.width / geometry.size.width;
  canvas.scale(scale);
  return 1 / scale;
}

Paint _stroke(Color color, double width) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeJoin = StrokeJoin.round
  ..color = color;
