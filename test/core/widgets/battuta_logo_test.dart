import 'dart:ui' as ui;

import 'package:battuta/core/theme/app_theme.dart';
import 'package:battuta/core/widgets/battuta_logo.dart';
import 'package:battuta/features/settings/domain/app_settings.dart';
import 'package:battuta/features/settings/presentation/settings_controller.dart';
import 'package:battuta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

/// Paints the mark into a square of [side] pixels and returns its pixels.
Future<Color Function(int x, int y)> paintMark(int side) async {
  final recorder = ui.PictureRecorder();
  const BattutaMarkPainter(
    ring: BrandColors.lagoonTeal,
  ).paint(Canvas(recorder), Size.square(side.toDouble()));
  final image = await recorder.endRecording().toImage(side, side);
  final bytes = (await image.toByteData())!;
  return (x, y) {
    final i = (y * side + x) * 4;
    return Color.fromARGB(
      bytes.getUint8(i + 3),
      bytes.getUint8(i),
      bytes.getUint8(i + 1),
      bytes.getUint8(i + 2),
    );
  };
}

void main() {
  test('the mark is an amber globe in a stamp ring (PRD 1.4)', () async {
    final at = await paintMark(224);
    // Unit 112: the outer ring at 0.944, the inner ring at 0.777, and the
    // globe's equator through the middle.
    expect(at(112 + 106, 112), BrandColors.lagoonTeal);
    expect(at(112 + 87, 112), BrandColors.lagoonTeal);
    expect(at(112, 112), BrandColors.stampAmber);
  });

  test('a small mark leaves out the inner ring, which would blur', () async {
    // An odd size puts the center in the middle of a pixel.
    final at = await paintMark(29);
    // Unit 14.5: between the globe and the outer ring.
    expect(at(14 + 10, 14).a, 0);
    expect(at(14, 14), BrandColors.stampAmber);
  });

  testWidgets('the mark takes the theme\'s primary color', (tester) async {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Center(child: BattutaLogo()),
        ),
      );
      // The theme change animates.
      await tester.pumpAndSettle();
      final paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(BattutaMark),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(
        (paint.painter! as BattutaMarkPainter).ring,
        theme.colorScheme.primary,
      );
    }
  });

  testWidgets('the app bar shows the logo, with the mark leading the name '
      'in either language (FR-PLT-09)', (tester) async {
    final app = await pumpApp(tester, prefs: returningUser);

    void expectMarkFirst(String name, {required bool rtl}) {
      final logo = find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(BattutaLogo),
      );
      expect(logo, findsOneWidget);
      final mark = tester.getCenter(
        find.descendant(of: logo, matching: find.byType(BattutaMark)),
      );
      final text = tester.getCenter(
        find.descendant(of: logo, matching: find.text(name)),
      );
      expect(rtl ? mark.dx > text.dx : mark.dx < text.dx, isTrue);
    }

    expectMarkFirst('Battuta', rtl: false);
    await app.container
        .read(settingsProvider.notifier)
        .setLanguage(AppLanguage.ar);
    await tester.pumpAndSettle();
    expectMarkFirst('بطوطة', rtl: true);
  });
}
