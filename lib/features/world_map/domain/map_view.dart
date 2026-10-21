import 'dart:math';

import 'map_projection.dart';

/// A rectangle in map units.
class MapRect {
  const MapRect(this.left, this.top, this.right, this.bottom);

  final double left, top, right, bottom;

  double get width => right - left;
  double get height => bottom - top;
  double get centerX => (left + right) / 2;
  double get centerY => (top + bottom) / 2;

  bool contains(double x, double y) =>
      x >= left && x <= right && y >= top && y <= bottom;
}

/// Which part of the map is on screen (FR-MAP-16 to 22): a zoom from 1× to
/// 8× and the map point at the middle of the view, in map units. The view
/// has the map's proportions, so the same view shows the same area at any
/// width.
class MapView {
  /// Clamps [scale] to 1× to 8×, and [centerX] and [centerY] so the map
  /// always fills the view.
  factory MapView({
    required double scale,
    required double centerX,
    required double centerY,
  }) {
    final s = scale.clamp(minScale, maxScale).toDouble();
    final halfWidth = MapFrame.width / 2 / s;
    final halfHeight = MapFrame.height / 2 / s;
    return MapView._(
      s,
      centerX.clamp(halfWidth, MapFrame.width - halfWidth).toDouble(),
      centerY.clamp(halfHeight, MapFrame.height - halfHeight).toDouble(),
    );
  }

  const MapView._(this.scale, this.centerX, this.centerY);

  static const world = MapView._(1, MapFrame.width / 2, MapFrame.height / 2);
  static const minScale = 1.0;
  static const maxScale = 8.0;

  final double scale;
  final double centerX;
  final double centerY;

  bool get isZoomed => scale > minScale + 1e-6;

  /// dp per map unit in a view [width] dp wide.
  double pixelsPerUnit(double width) => width / MapFrame.width * scale;

  /// The map point under a point in a view [width] by [height] dp.
  (double, double) toMap(double x, double y, double width, double height) {
    final k = pixelsPerUnit(width);
    return (centerX + (x - width / 2) / k, centerY + (y - height / 2) / k);
  }

  /// The view point, in dp, of a map point.
  (double, double) toView(double x, double y, double width, double height) {
    final k = pixelsPerUnit(width);
    return (width / 2 + (x - centerX) * k, height / 2 + (y - centerY) * k);
  }

  /// Zooms by [factor], keeping the map point under ([x], [y]) where it is.
  MapView zoomedBy(
    double factor, {
    required double x,
    required double y,
    required double width,
    required double height,
  }) {
    final (mapX, mapY) = toMap(x, y, width, height);
    final next = (scale * factor).clamp(minScale, maxScale).toDouble();
    final k = width / MapFrame.width * next;
    return MapView(
      scale: next,
      centerX: mapX - (x - width / 2) / k,
      centerY: mapY - (y - height / 2) / k,
    );
  }

  /// Moves the map by ([dx], [dy]) dp, as a drag does.
  MapView pannedBy(double dx, double dy, double width) {
    final k = pixelsPerUnit(width);
    return MapView(
      scale: scale,
      centerX: centerX - dx / k,
      centerY: centerY - dy / k,
    );
  }

  /// The view that shows [frame] whole, with [padding] dp around it in a
  /// view [width] by [height] dp.
  static MapView fit(
    MapRect frame, {
    required double width,
    required double height,
    double padding = 16,
  }) {
    final base = width / MapFrame.width;
    return MapView(
      scale: min(
        (width - 2 * padding) / (frame.width * base),
        (height - 2 * padding) / (frame.height * base),
      ),
      centerX: frame.centerX,
      centerY: frame.centerY,
    );
  }

  /// Between [a] and [b]. The zoom changes at an even pace, which looks
  /// steadier than changing the scale linearly.
  static MapView lerp(MapView a, MapView b, double t) => MapView(
    scale: a.scale * pow(b.scale / a.scale, t),
    centerX: a.centerX + (b.centerX - a.centerX) * t,
    centerY: a.centerY + (b.centerY - a.centerY) * t,
  );

  @override
  bool operator ==(Object other) =>
      other is MapView &&
      other.scale == scale &&
      other.centerX == centerX &&
      other.centerY == centerY;

  @override
  int get hashCode => Object.hash(scale, centerX, centerY);

  @override
  String toString() =>
      'MapView(${scale.toStringAsFixed(2)}×, '
      '${centerX.toStringAsFixed(1)}, ${centerY.toStringAsFixed(1)})';
}
