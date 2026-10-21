import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../world_map_colors.dart';
import '../world_map_painter.dart';

/// Visited, Wishlist, and Not yet with their swatches, and the note about
/// dots (FR-MAP-03).
class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = WorldMapColors.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _Item(
          swatch: _Swatch(
            fill: colors.visitedFill,
            border: colors.visitedBorder,
          ),
          label: l10n.mapLegendVisited,
        ),
        _Item(
          swatch: _Swatch(
            fill: colors.wishlistBase,
            border: colors.wishlistBorder,
            stripes: colors.wishlistStripe,
          ),
          label: l10n.mapLegendWishlist,
        ),
        _Item(
          swatch: _Swatch(fill: colors.notYetFill, border: colors.notYetBorder),
          label: l10n.mapLegendNotYet,
        ),
        _Item(
          swatch: _Swatch(
            fill: colors.notYetFill,
            border: colors.notYetBorder,
            dot: true,
          ),
          label: l10n.mapLegendDots,
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.swatch, required this.label});

  final Widget swatch;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        swatch,
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.fill,
    required this.border,
    this.stripes,
    this.dot = false,
  });

  final Color fill;
  final Color border;
  final Color? stripes;
  final bool dot;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: dot ? const Size.square(8) : const Size(16, 12),
    painter: _SwatchPainter(this),
  );
}

class _SwatchPainter extends CustomPainter {
  const _SwatchPainter(this.swatch);

  final _Swatch swatch;

  @override
  void paint(Canvas canvas, Size size) {
    final shape = Path();
    if (swatch.dot) {
      shape.addOval(Offset.zero & size);
    } else {
      shape.addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(2)),
      );
    }
    canvas.drawPath(shape, Paint()..color = swatch.fill);
    if (swatch.stripes case final stripes?) {
      paintStripes(canvas, shape, stripes, 1);
    }
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = swatch.border,
    );
  }

  @override
  bool shouldRepaint(_SwatchPainter old) => false;
}
