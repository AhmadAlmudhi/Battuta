import 'package:flutter/material.dart';

/// Brand colors (PRD section 1.4).
abstract final class BrandColors {
  static const lagoonTeal = Color(0xFF0E7C86);
  static const stampAmber = Color(0xFFF2B24B);
  static const passportCream = Color(0xFFFBEFD9);
  static const deepInk = Color(0xFF13232B);
}

/// Material 3 themes generated from the Lagoon Teal seed with the Stamp Amber
/// secondary color fixed (PRD section 10.1).
abstract final class AppTheme {
  static ThemeData light() => _build(
    ColorScheme.fromSeed(
      seedColor: BrandColors.lagoonTeal,
      secondary: BrandColors.stampAmber,
      onSecondary: BrandColors.deepInk,
    ),
  );

  static ThemeData dark() => _build(
    ColorScheme.fromSeed(
      seedColor: BrandColors.lagoonTeal,
      brightness: Brightness.dark,
      secondary: BrandColors.stampAmber,
      onSecondary: BrandColors.deepInk,
    ),
  );

  static ThemeData _build(ColorScheme scheme) => ThemeData(
    colorScheme: scheme,
    // Inter has no Arabic glyphs, so Arabic text falls back to IBM Plex Sans
    // Arabic in every language, and Latin text always uses Inter.
    fontFamily: 'Inter',
    fontFamilyFallback: const ['IBMPlexSansArabic'],
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
