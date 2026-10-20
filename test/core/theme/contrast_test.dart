import 'package:battuta/core/theme/contrast.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const white = Color(0xFFFFFFFF);
  const black = Color(0xFF000000);

  test('contrast ratio follows WCAG 2.1', () {
    expect(contrastRatio(white, black), closeTo(21, 0.01));
    expect(contrastRatio(white, white), closeTo(1, 0.01));
    // White on Lagoon Teal is 4.95:1 (PRD 1.4).
    expect(contrastRatio(white, const Color(0xFF0E7C86)), closeTo(4.95, 0.05));
  });

  test('tints as far as text keeps AA contrast (FR-DET-07)', () {
    const surface = Color(0xFFF4FAFB);
    const text = Color(0xFF161D1E);
    const flagRed = Color(0xFFD43E34);

    final tinted = tintWithinContrast(
      surface: surface,
      tint: flagRed,
      foregrounds: const [text],
    );

    expect(tinted, isNot(surface));
    expect(contrastRatio(text, tinted), greaterThanOrEqualTo(4.5));
  });

  test('falls back to the plain surface when no tint keeps contrast', () {
    const surface = Color(0xFF777777);
    const text = Color(0xFF2A2A2A);

    expect(contrastRatio(text, surface), lessThan(4.5));
    expect(
      tintWithinContrast(
        surface: surface,
        tint: black,
        foregrounds: const [text],
      ),
      surface,
    );
  });

  test('parses hex colors', () {
    expect(parseHexColor('#006C35'), const Color(0xFF006C35));
    expect(parseHexColor('006c35'), const Color(0xFF006C35));
    expect(parseHexColor(null), isNull);
    expect(parseHexColor('#12345'), isNull);
    expect(parseHexColor('#zzzzzz'), isNull);
  });
}
