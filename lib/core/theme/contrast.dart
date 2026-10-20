import 'package:flutter/painting.dart';

/// WCAG 2.1 contrast ratio between two opaque colors, from 1 to 21.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final (light, dark) = la > lb ? (la, lb) : (lb, la);
  return (light + 0.05) / (dark + 0.05);
}

/// [surface] tinted toward [tint] as far as possible, up to [maxStrength],
/// while every color in [foregrounds] keeps at least [minContrast] against it
/// (WCAG AA for body text is 4.5).
Color tintWithinContrast({
  required Color surface,
  required Color tint,
  required List<Color> foregrounds,
  double maxStrength = 0.24,
  double minContrast = 4.5,
}) {
  for (var strength = maxStrength; strength > 0; strength -= 0.04) {
    final candidate = Color.alphaBlend(
      tint.withValues(alpha: strength),
      surface,
    );
    if (foregrounds.every(
      (fg) => contrastRatio(fg, candidate) >= minContrast,
    )) {
      return candidate;
    }
  }
  return surface;
}

/// Parses a hex color such as #006C35; null when it isn't one.
Color? parseHexColor(String? hex) {
  if (hex == null) return null;
  final digits = hex.replaceFirst('#', '');
  if (digits.length != 6) return null;
  final value = int.tryParse(digits, radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}
