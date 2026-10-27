import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// The Battuta logo: the stamp mark beside the name in the app language,
/// Battuta or بطوطة (PRD 1.4). It is drawn, not an image, so it stays sharp
/// at any size and takes the theme's colors. The mark sits on the start
/// side, so it leads the name in Arabic too.
class BattutaLogo extends StatelessWidget {
  const BattutaLogo({super.key, this.size = 22});

  /// The name's font size; the mark is [markScale] times as tall.
  final double size;

  static const markScale = 1.3;

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).appName,
    child: ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BattutaMark(size: size * markScale),
          SizedBox(width: size * 0.36),
          BattutaName(size: size),
        ],
      ),
    ),
  );
}

/// The name as the logo writes it: Alexandria Bold in the primary color.
class BattutaName extends StatelessWidget {
  const BattutaName({super.key, required this.size});

  final double size;

  /// The name's style, for canvases outside the widget tree.
  static TextStyle style(ThemeData theme, double size) =>
      (theme.textTheme.titleLarge ?? const TextStyle()).copyWith(
        fontSize: size,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0,
        color: theme.colorScheme.primary,
      );

  @override
  Widget build(BuildContext context) => Text(
    AppLocalizations.of(context).appName,
    style: style(Theme.of(context), size),
  );
}

/// The mark: a passport stamp, a double ring with two dots, tilted 12
/// degrees like the app icon, around an amber globe (PRD 1.4).
class BattutaMark extends StatelessWidget {
  const BattutaMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: BattutaMarkPainter(ring: Theme.of(context).colorScheme.primary),
  );
}

/// Paints [BattutaMark] into a square; the shared map image uses it
/// directly.
class BattutaMarkPainter extends CustomPainter {
  const BattutaMarkPainter({
    required this.ring,
    this.globe = BrandColors.stampAmber,
  });

  final Color ring;
  final Color globe;

  @override
  void paint(Canvas canvas, Size size) {
    // Measured from the app icon, in units of the stamp's outer radius.
    final unit = size.shortestSide / 2;
    // A small mark, as in the app bar, leaves out the inner ring and the
    // dots and draws bolder lines, which would otherwise blur together.
    final small = size.shortestSide < 40;
    Paint stroke(Color color, double width) => Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = math.max(width * unit, 1);

    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(-12 * math.pi / 180);
    if (small) {
      canvas.drawCircle(Offset.zero, 0.92 * unit, stroke(ring, 0.16));
    } else {
      final dot = Paint()..color = ring;
      canvas
        ..drawCircle(Offset.zero, 0.944 * unit, stroke(ring, 0.111))
        ..drawCircle(Offset.zero, 0.777 * unit, stroke(ring, 0.033))
        ..drawCircle(Offset(0.86 * unit, 0), 0.036 * unit, dot)
        ..drawCircle(Offset(-0.86 * unit, 0), 0.036 * unit, dot);
    }

    // The globe: its rim, one meridian, and three parallels.
    final radius = (small ? 0.56 : 0.5) * unit;
    final lines = stroke(globe, small ? 0.09 : 0.07);
    canvas
      ..drawCircle(Offset.zero, radius, stroke(globe, small ? 0.12 : 0.085))
      ..save()
      ..clipPath(
        Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: radius)),
      )
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: radius, height: radius * 2),
        lines,
      );
    for (final y in [-0.54, 0.0, 0.54]) {
      canvas.drawLine(
        Offset(-radius, y * radius),
        Offset(radius, y * radius),
        lines,
      );
    }
    canvas
      ..restore()
      ..restore();
  }

  @override
  bool shouldRepaint(BattutaMarkPainter oldDelegate) =>
      ring != oldDelegate.ring || globe != oldDelegate.globe;
}
