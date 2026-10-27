import 'package:battuta/features/onboarding/presentation/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('Welcome says what the app does and that no account is '
      'needed (FR-ONB-01)', (tester) async {
    await pumpApp(tester);

    expect(find.byType(WelcomeScreen), findsOneWidget);
    for (final text in [
      'Explore every country, with its flag and facts',
      'Mark your visits with dates, ratings, and notes',
      'Watch your world map fill in',
      'No account needed. Sign in any time to back up and sync your '
          'travels.',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    // The buttons are easy to hit.
    expect(
      tester
          .getSize(find.widgetWithText(FilledButton, 'Continue as guest'))
          .height,
      52,
    );
  });

  testWidgets('the language switch changes the language before the user '
      'starts, and keeps it (FR-ONB-05)', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(find.text('المتابعة كضيف'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('المتابعة كضيف'))),
      TextDirection.rtl,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('locale'), 'ar');
    // Still on Welcome: choosing a language isn't the first choice.
    expect(prefs.getBool('onboarding_done'), isNull);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Continue as guest'), findsOneWidget);
    expect(prefs.getString('locale'), 'en');
  });

  testWidgets('wide screens put the flags beside the words', (tester) async {
    await pumpApp(tester, size: const Size(1280, 900));

    final logo = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName ==
              'assets/images/battuta_logo.jpg',
    );
    expect(logo, findsOneWidget);
    expect(
      tester.getCenter(logo).dx,
      lessThan(tester.getTopLeft(find.text('Battuta')).dx),
    );
    expect(
      tester.getCenter(logo).dy,
      moreOrLessEquals(
        tester.getCenter(find.text('Continue as guest')).dy,
        epsilon: 200,
      ),
    );
  });

  testWidgets('the logo lands and the flags appear, unless motion is '
      'reduced (PRD 10.2, NFR-09)', (tester) async {
    await pumpApp(tester);
    expect(find.byType(Animate), findsWidgets);

    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(Animate), findsNothing);
  });
}
