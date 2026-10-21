import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/format/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../travels/domain/travel_entry.dart';
import 'world_map_colors.dart';
import 'world_map_geometry.dart';
import 'world_map_painter.dart';

/// The web address on every shared map (FR-MAP-41). It's the same in both
/// languages.
const shareAddress = 'battuta-travel.web.app';

/// A 360 × 450 dp layout drawn at 3×: a 1,080 × 1,350 pixel image
/// (FR-MAP-41).
const mapShareLayout = Size(360, 450);
const mapSharePixelRatio = 3.0;

/// The words on a shared map, already in the app language.
class MapShareTexts {
  const MapShareTexts({
    required this.appName,
    required this.label,
    required this.count,
    required this.detail,
    required this.visited,
    required this.wishlist,
  });

  /// The app name, label, and counts in the app language, formatted the way
  /// the Stats headline is (FR-STA-01, FR-MAP-41).
  factory MapShareTexts.of(
    BuildContext context, {
    required int visited,
    required int total,
    required int wishlist,
  }) {
    final l10n = AppLocalizations.of(context);
    final share = total == 0 ? 0.0 : visited / total;
    return MapShareTexts(
      appName: l10n.appName,
      label: l10n.statsCountriesVisited,
      count: context.formatInteger(visited),
      detail: l10n.statsOfTotal(
        context.formatInteger(total),
        context.formatPercent(share * 100),
        context.formatInteger(wishlist),
      ),
      visited: l10n.mapLegendVisited,
      wishlist: l10n.mapLegendWishlist,
    );
  }

  final String appName;

  /// Countries visited.
  final String label;

  /// For example: 16.
  final String count;

  /// For example: of 249 · 6.4% · 12 on your wishlist.
  final String detail;

  /// Legend labels.
  final String visited;
  final String wishlist;
}

/// Draws "Share my map" in the current theme and language (FR-MAP-41,
/// FR-MAP-43): the app name, the user's counts, the map, a legend, and the
/// web address. Returns a PNG.
Future<Uint8List> renderMapShareImage({
  required WorldMapGeometry geometry,
  required Map<String, TravelStatus> statuses,
  required ThemeData theme,
  required TextDirection direction,
  required MapShareTexts texts,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(mapSharePixelRatio);
  final scheme = theme.colorScheme;
  final styles = theme.textTheme;
  final colors = theme.brightness == Brightness.dark
      ? WorldMapColors.dark
      : WorldMapColors.light;
  const margin = 20.0;
  final width = mapShareLayout.width - 2 * margin;
  final ltr = direction == TextDirection.ltr;

  canvas.drawRect(
    Offset.zero & mapShareLayout,
    Paint()..color = scheme.surface,
  );

  /// Lays out [text] across the content width, paints it at [top], and
  /// returns where it ends.
  double write(
    String text,
    TextStyle? style,
    double top, {
    TextAlign align = TextAlign.start,
    int? maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textAlign: align,
      maxLines: maxLines,
      ellipsis: maxLines == null ? null : '…',
    )..layout(minWidth: width, maxWidth: width);
    painter.paint(canvas, Offset(margin, top));
    final bottom = top + painter.height;
    painter.dispose();
    return bottom;
  }

  var y = write(
    texts.appName,
    styles.titleLarge?.copyWith(
      color: scheme.primary,
      fontWeight: FontWeight.w700,
    ),
    24,
  );
  y = write(
    texts.label,
    styles.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
    y + 16,
  );
  y = write(
    texts.count,
    styles.displayMedium?.copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    y + 2,
  );
  y = write(
    texts.detail,
    styles.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
    y,
    maxLines: 2,
  );

  final mapTop = y + 20;
  final mapSize = Size(
    width,
    width * geometry.size.height / geometry.size.width,
  );
  for (final layer in <CustomPainter>[
    WorldMapBasePainter(geometry: geometry, colors: colors),
    WorldMapPainter(geometry: geometry, statuses: statuses, colors: colors),
  ]) {
    canvas
      ..save()
      ..translate(margin, mapTop);
    layer.paint(canvas, mapSize);
    canvas.restore();
  }

  // The legend runs from the start edge, like the one on the card.
  final legendTop = mapTop + mapSize.height + 16;
  var edge = ltr ? margin : mapShareLayout.width - margin;
  for (final (label, wishlist) in [
    (texts.visited, false),
    (texts.wishlist, true),
  ]) {
    final swatch = Rect.fromLTWH(ltr ? edge : edge - 16, legendTop + 2, 16, 12);
    final shape = Path()
      ..addRRect(RRect.fromRectAndRadius(swatch, const Radius.circular(2)));
    canvas.drawPath(
      shape,
      Paint()..color = wishlist ? colors.wishlistBase : colors.visitedFill,
    );
    if (wishlist) paintStripes(canvas, shape, colors.wishlistStripe, 1);
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = wishlist ? colors.wishlistBorder : colors.visitedBorder,
    );
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: styles.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      textDirection: direction,
    )..layout();
    final textX = ltr ? swatch.right + 6 : swatch.left - 6 - painter.width;
    painter.paint(canvas, Offset(textX, legendTop));
    edge = ltr ? textX + painter.width + 16 : textX - 16;
    painter.dispose();
  }

  write(
    shareAddress,
    styles.titleSmall?.copyWith(color: scheme.primary),
    mapShareLayout.height - 40,
    align: TextAlign.center,
  );

  final image = await recorder.endRecording().toImage(
    (mapShareLayout.width * mapSharePixelRatio).round(),
    (mapShareLayout.height * mapSharePixelRatio).round(),
  );
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return png!.buffer.asUint8List();
}
