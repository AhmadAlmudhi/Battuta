import 'dart:math';
import 'dart:ui' show PathMetric;

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
  static const flightWidth = 2.0;
  static const flightDash = 1.0;
  static const flightGap = 5.0;
}

/// How far the map's animations have come: the reveal, a change made from
/// the tap card, or the replay (FR-MAP-26 to 40). Values are eased.
class MapMotion {
  const MapMotion({
    this.fills = const {},
    this.origins = const {},
    this.hatching = 1,
    this.hatchings = const {},
    this.fading = const {},
    this.flight,
  });

  /// Visited countries still filling, from 0 to 1. Countries not listed are
  /// filled.
  final Map<String, double> fills;

  /// Where a country's fill spreads from, when not the middle of its largest
  /// part: the point the user tapped (FR-MAP-32). In map units.
  final Map<String, Offset> origins;

  /// How far all wishlist hatching has faded in, from 0 to 1.
  final double hatching;

  /// Wishlist countries whose hatching is still fading in, from 0 to 1
  /// (FR-MAP-33).
  final Map<String, double> hatchings;

  /// Countries whose old status still shows under the new one, or under Not
  /// yet when the entry was removed (FR-MAP-34): the status they had, and
  /// how much of its color is left, from 1 to 0.
  final Map<String, (TravelStatus, double)> fading;

  /// The replay's flight path, while it draws (FR-MAP-36).
  final MapFlight? flight;
}

/// A dotted flight path from one country to the next, drawn as far as
/// [progress] (FR-MAP-36). Points are in map units.
class MapFlight {
  const MapFlight({
    required this.from,
    required this.to,
    required this.progress,
  });

  final Offset from;
  final Offset to;
  final double progress;
}

/// The layers that change only with the theme and the view (PRD section
/// 11.5): the ocean, grid lines, and every country in the Not yet colors. It
/// sits in its own repaint boundary, so statuses, highlights, and animations
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

/// Statuses, dots, the region fade, flight paths, and highlights, over the
/// base layer (FR-MAP-01, FR-MAP-10, FR-MAP-12, FR-MAP-23).
class WorldMapPainter extends CustomPainter {
  const WorldMapPainter({
    required this.geometry,
    required this.statuses,
    required this.colors,
    this.view = MapView.world,
    this.selected,
    this.hovered,
    this.motion,
    this.outside,
    this.fade = 0,
  });

  final WorldMapGeometry geometry;
  final Map<String, TravelStatus> statuses;
  final WorldMapColors colors;
  final MapView view;
  final String? selected;
  final String? hovered;

  /// Null when nothing is animating.
  final MapMotion? motion;

  /// What fades during a region focus, and by how much, from 0 to 1.
  final MapOutside? outside;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    final dp = _applyView(canvas, size, view);
    final motion = this.motion;
    double fillOf(String code) => motion?.fills[code] ?? 1;
    double hatchingOf(String code) =>
        (motion?.hatching ?? 1) * (motion?.hatchings[code] ?? 1);
    List<String> codesWith(TravelStatus status) => [
      for (final MapEntry(:key, :value) in statuses.entries)
        if (value == status) key,
    ];

    // Old statuses still showing: a removed country's color fading out
    // (FR-MAP-34), or hatching under amber spreading over it (FR-MAP-32).
    for (final MapEntry(key: code, value: (status, left))
        in motion?.fading.entries ??
            const <MapEntry<String, (TravelStatus, double)>>[]) {
      final path = geometry.countries[code];
      if (path == null || left <= 0) continue;
      switch (status) {
        case TravelStatus.visited:
          canvas.drawPath(
            path,
            Paint()..color = _faded(colors.visitedFill, left),
          );
        case TravelStatus.wishlist:
          _paintWishlist(canvas, path, left, dp);
      }
    }

    // Wishlist countries share one hatching pass, apart from any fading in
    // on their own (FR-MAP-33).
    final wishlist = codesWith(TravelStatus.wishlist);
    final fadingIn = motion?.hatchings ?? const {};
    _paintWishlist(
      canvas,
      union([
        for (final code in wishlist)
          if (!fadingIn.containsKey(code)) ?geometry.countries[code],
      ]),
      motion?.hatching ?? 1,
      dp,
    );
    for (final code in wishlist) {
      final path = geometry.countries[code];
      if (path != null && fadingIn.containsKey(code)) {
        _paintWishlist(canvas, path, hatchingOf(code), dp);
      }
    }

    final visited = codesWith(TravelStatus.visited);
    final filled = union([
      for (final code in visited)
        if (fillOf(code) >= 1) ?geometry.countries[code],
    ]);
    canvas
      ..drawPath(filled, Paint()..color = colors.visitedFill)
      ..drawPath(filled, _stroke(colors.visitedBorder, MapSizes.border * dp));
    // Countries mid-fill: the color spreads from the middle of the largest
    // part, or from the tap point, like ink soaking into paper (PRD 11.5).
    for (final code in visited) {
      final progress = fillOf(code);
      final path = geometry.countries[code];
      if (path == null || progress <= 0 || progress >= 1) continue;
      final origin = motion?.origins[code] ?? geometry.spreadStart(code);
      canvas
        ..save()
        ..clipPath(path)
        ..drawCircle(
          origin,
          geometry.spreadReach(code, origin) * progress,
          Paint()..color = colors.visitedFill,
        )
        ..restore();
    }

    (Color, Color) dotColors(TravelStatus status) => switch (status) {
      TravelStatus.visited => (colors.visitedFill, colors.visitedBorder),
      TravelStatus.wishlist => (colors.wishlistBase, colors.wishlistBorder),
    };
    for (final MapEntry(key: code, value: center) in geometry.dots.entries) {
      // A dot starts from Not yet, or from the old status still fading.
      var (fill, border) = (colors.notYetFill, colors.notYetBorder);
      if (motion?.fading[code] case (final status, final left)) {
        final (oldFill, oldBorder) = dotColors(status);
        fill = Color.lerp(fill, oldFill, left)!;
        border = Color.lerp(border, oldBorder, left)!;
      }
      if (statuses[code] case final status?) {
        final (newFill, newBorder) = dotColors(status);
        final progress = status == TravelStatus.visited
            ? fillOf(code)
            : hatchingOf(code);
        fill = Color.lerp(fill, newFill, progress)!;
        border = Color.lerp(border, newBorder, progress)!;
      }
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

    if (motion?.flight case final flight?) {
      _paintFlight(canvas, flight, dp);
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

  /// Hatching (PRD section 10.1) at [opacity]: base, stripes, and border.
  void _paintWishlist(Canvas canvas, Path area, double opacity, double dp) {
    if (opacity <= 0) return;
    canvas.drawPath(
      area,
      Paint()..color = _faded(colors.wishlistBase, opacity),
    );
    paintStripes(
      canvas,
      area,
      _faded(colors.wishlistStripe, opacity),
      dp,
      within: _visible(),
    );
    canvas.drawPath(
      area,
      _stroke(
        _faded(colors.wishlistBorder, opacity),
        MapSizes.wishlistBorder * dp,
      ),
    );
  }

  /// A curve from one country to the next, bent sideways by 20% of the
  /// distance between them, drawn in dots as far as it has come (FR-MAP-36).
  void _paintFlight(Canvas canvas, MapFlight flight, double dp) {
    final (from, to) = (flight.from, flight.to);
    final bend = flightBend(from, to);
    final curve = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(bend.dx, bend.dy, to.dx, to.dy);
    final dots = Path();
    final step = (MapSizes.flightDash + MapSizes.flightGap) * dp;
    for (final PathMetric metric in curve.computeMetrics()) {
      final end = metric.length * flight.progress;
      for (var start = 0.0; start < end; start += step) {
        dots.addPath(
          metric.extractPath(start, min(start + MapSizes.flightDash * dp, end)),
          Offset.zero,
        );
      }
    }
    canvas.drawPath(
      dots,
      _stroke(colors.highlight, MapSizes.flightWidth * dp)
        ..strokeCap = StrokeCap.round,
    );
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
      old.motion != motion ||
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

/// The control point of the flight path from [from] to [to]: the middle of
/// the straight line, moved sideways by 20% of its length (FR-MAP-36). It
/// always moves toward the top of the map, so every flight arcs upward,
/// whichever way it goes.
Offset flightBend(Offset from, Offset to) {
  final along = to - from;
  final side = Offset(-along.dy, along.dx) * 0.2;
  return Offset.lerp(from, to, 0.5)! + (side.dy > 0 ? -side : side);
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
