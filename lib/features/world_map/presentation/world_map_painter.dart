import 'dart:math';

import 'package:flutter/material.dart';

import '../../travels/domain/travel_entry.dart';
import '../domain/map_view.dart';
import 'world_map_colors.dart';
import 'world_map_geometry.dart';

/// Line widths and dot sizes in dp. They keep their size on screen at every
/// zoom level (PRD section 10.1, FR-MAP-20).
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

/// How far the reveal has come (FR-MAP-26 to 29).
class MapReveal {
  const MapReveal({required this.fills, required this.hatching});

  /// Each visited country's fill, eased, from 0 to 1. Countries not listed
  /// are filled.
  final Map<String, double> fills;

  /// How far the wishlist hatching has faded in, eased, from 0 to 1.
  final double hatching;
}

/// The layers that change only with the theme and the view (PRD section
/// 11.5): the ocean, grid lines, and every country in the Not yet colors. It
/// sits in its own repaint boundary, so statuses, highlights, and the reveal
/// don't redraw it.
class WorldMapBasePainter extends CustomPainter {
  const WorldMapBasePainter({
    required this.geometry,
    required this.colors,
    this.view = MapView.world,
  });

  final WorldMapGeometry geometry;
  final WorldMapColors colors;
  final MapView view;

  @override
  void paint(Canvas canvas, Size size) {
    final dp = _applyView(canvas, size, view);
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
      old.geometry != geometry || old.colors != colors || old.view != view;
}

/// Statuses, dots, the region fade, and highlights, over the base layer
/// (FR-MAP-01, FR-MAP-10, FR-MAP-12, FR-MAP-23).
class WorldMapPainter extends CustomPainter {
  const WorldMapPainter({
    required this.geometry,
    required this.statuses,
    required this.colors,
    this.view = MapView.world,
    this.selected,
    this.hovered,
    this.reveal,
    this.outside,
    this.fade = 0,
  });

  final WorldMapGeometry geometry;
  final Map<String, TravelStatus> statuses;
  final WorldMapColors colors;
  final MapView view;
  final String? selected;
  final String? hovered;

  /// Null once the reveal is over, or when it doesn't play.
  final MapReveal? reveal;

  /// What fades during a region focus, and by how much, from 0 to 1.
  final MapOutside? outside;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    final dp = _applyView(canvas, size, view);
    double fillOf(String code) => reveal?.fills[code] ?? 1;
    final hatching = reveal?.hatching ?? 1;
    Path withStatus(TravelStatus status, {bool filled = false}) => union([
      for (final MapEntry(:key, :value) in statuses.entries)
        if (value == status && (!filled || fillOf(key) >= 1))
          ?geometry.countries[key],
    ]);

    if (hatching > 0) {
      final wishlist = withStatus(TravelStatus.wishlist);
      canvas.drawPath(
        wishlist,
        Paint()..color = _faded(colors.wishlistBase, hatching),
      );
      paintStripes(
        canvas,
        wishlist,
        _faded(colors.wishlistStripe, hatching),
        dp,
        within: _visible(),
      );
      canvas.drawPath(
        wishlist,
        _stroke(
          _faded(colors.wishlistBorder, hatching),
          MapSizes.wishlistBorder * dp,
        ),
      );
    }

    final visited = withStatus(TravelStatus.visited, filled: true);
    canvas
      ..drawPath(visited, Paint()..color = colors.visitedFill)
      ..drawPath(visited, _stroke(colors.visitedBorder, MapSizes.border * dp));
    // Countries mid-reveal: the color spreads from the middle of the largest
    // part like ink soaking into paper (PRD section 11.5).
    for (final MapEntry(key: code, value: progress)
        in reveal?.fills.entries ?? const <MapEntry<String, double>>[]) {
      final path = geometry.countries[code];
      if (path == null || progress <= 0 || progress >= 1) continue;
      canvas
        ..save()
        ..clipPath(path)
        ..drawCircle(
          geometry.spreadStart(code),
          geometry.spreadReach(code) * progress,
          Paint()..color = colors.visitedFill,
        )
        ..restore();
    }

    for (final MapEntry(key: code, value: center) in geometry.dots.entries) {
      final (fill, border) = switch (statuses[code]) {
        TravelStatus.visited => (
          Color.lerp(colors.notYetFill, colors.visitedFill, fillOf(code))!,
          Color.lerp(colors.notYetBorder, colors.visitedBorder, fillOf(code))!,
        ),
        TravelStatus.wishlist => (
          Color.lerp(colors.notYetFill, colors.wishlistBase, hatching)!,
          Color.lerp(colors.notYetBorder, colors.wishlistBorder, hatching)!,
        ),
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

    // Fading lays the ocean color over the countries outside the region at
    // 70%, which shows them at 30% without a saveLayer per country.
    if (outside case final outside? when fade > 0) {
      final veil = Paint()..color = _faded(colors.ocean, 0.7 * fade);
      canvas.drawPath(outside.shapes, veil);
      for (final dot in outside.dots) {
        canvas.drawCircle(
          dot,
          (MapSizes.dotRadius + MapSizes.dotBorder) * dp,
          veil,
        );
      }
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

  /// The part of the map on screen, in map units.
  Rect _visible() {
    final halfWidth = geometry.size.width / 2 / view.scale;
    final halfHeight = geometry.size.height / 2 / view.scale;
    return Rect.fromLTRB(
      view.centerX - halfWidth,
      view.centerY - halfHeight,
      view.centerX + halfWidth,
      view.centerY + halfHeight,
    );
  }

  @override
  bool shouldRepaint(WorldMapPainter old) =>
      old.geometry != geometry ||
      old.statuses != statuses ||
      old.colors != colors ||
      old.view != view ||
      old.selected != selected ||
      old.hovered != hovered ||
      old.reveal != reveal ||
      old.outside != outside ||
      old.fade != fade;
}

/// Wishlist hatching (PRD section 10.1): stripes rising at 45°, 5 dp apart,
/// clipped to [area] and drawn only [within] the visible part of it. [dp] is
/// one dp in the canvas's units.
void paintStripes(
  Canvas canvas,
  Path area,
  Color color,
  double dp, {
  Rect? within,
}) {
  var bounds = area.getBounds();
  if (within != null) bounds = bounds.intersect(within);
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

/// Clips to [size] and moves the canvas into map units for [view]; returns
/// one dp in map units.
double _applyView(Canvas canvas, Size size, MapView view) {
  final k = view.pixelsPerUnit(size.width);
  canvas
    ..clipRect(Offset.zero & size)
    ..translate(size.width / 2, size.height / 2)
    ..scale(k)
    ..translate(-view.centerX, -view.centerY);
  return 1 / k;
}

Color _faded(Color color, double opacity) =>
    color.withValues(alpha: color.a * opacity);

Paint _stroke(Color color, double width) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeJoin = StrokeJoin.round
  ..color = color;
