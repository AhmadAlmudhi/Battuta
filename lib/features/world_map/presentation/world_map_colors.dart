import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// The world map's colors for each theme (PRD section 10.1).
class WorldMapColors {
  const WorldMapColors._({
    required this.ocean,
    required this.grid,
    required this.notYetFill,
    required this.notYetBorder,
    required this.visitedFill,
    required this.visitedBorder,
    required this.wishlistBase,
    required this.wishlistStripe,
    required this.wishlistBorder,
    required this.highlight,
  });

  static const light = WorldMapColors._(
    ocean: Color(0xFFF6F1E6),
    grid: Color(0xFFE8DFCB),
    notYetFill: Color(0xFFFFFFFF),
    notYetBorder: Color(0xFFC3C9D1),
    visitedFill: BrandColors.stampAmber,
    visitedBorder: Color(0xFFD99A35),
    wishlistBase: Color(0xFFE3F3F4),
    // Lagoon Teal at 55%.
    wishlistStripe: Color(0x8C0E7C86),
    wishlistBorder: BrandColors.lagoonTeal,
    highlight: BrandColors.deepInk,
  );

  static const dark = WorldMapColors._(
    ocean: Color(0xFF0F1A1F),
    grid: Color(0xFF1C2A31),
    notYetFill: Color(0xFF22313A),
    notYetBorder: Color(0xFF3A4A54),
    visitedFill: BrandColors.stampAmber,
    visitedBorder: Color(0xFFB97C1F),
    wishlistBase: Color(0xFF12383C),
    wishlistStripe: Color(0xFF4FB3BB),
    wishlistBorder: Color(0xFF4FB3BB),
    highlight: Color(0xFFFFFFFF),
  );

  static WorldMapColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  final Color ocean;
  final Color grid;
  final Color notYetFill;
  final Color notYetBorder;
  final Color visitedFill;
  final Color visitedBorder;
  final Color wishlistBase;
  final Color wishlistStripe;
  final Color wishlistBorder;

  /// The border of the selected or hovered country.
  final Color highlight;
}
