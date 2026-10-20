import 'package:battuta/features/settings/domain/app_settings.dart';
import 'package:battuta/features/settings/presentation/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/pump_app.dart';

void main() {
  group('onboarding', () {
    testWidgets('first launch shows Welcome (AC-ONB-01)', (tester) async {
      await pumpApp(tester);

      expect(find.text('Every country, stamped.'), findsOneWidget);
      expect(find.text('Continue as guest'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('Continue as guest opens Explore and is remembered '
        '(FR-ONB-02, AC-ONB-02)', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Continue as guest'));
      await tester.pumpAndSettle();

      expect(find.text('Explore'), findsWidgets);
      expect(find.text('France'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding_done'), isTrue);

      await pumpApp(tester, prefs: {'onboarding_done': true});
      expect(find.text('Every country, stamped.'), findsNothing);
      expect(find.text('France'), findsOneWidget);
    });

    testWidgets('a deep link opened on first visit continues after Welcome', (
      tester,
    ) async {
      final app = await pumpApp(tester);
      await app.goTo(tester, '/country/JPN');
      expect(find.text('Every country, stamped.'), findsOneWidget);

      await tester.tap(find.text('Continue as guest'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Japan'), findsOneWidget);
    });
  });

  group('navigation', () {
    testWidgets('an unknown country code shows Country not found '
        '(AC-DET-04)', (tester) async {
      final app = await pumpApp(tester, prefs: returningUser);
      await app.goTo(tester, '/country/XYZ');

      expect(find.text('Country not found'), findsOneWidget);
      await tester.tap(find.text('Back to Explore'));
      await tester.pumpAndSettle();
      expect(find.text('France'), findsOneWidget);
    });

    testWidgets('an unknown path shows Page not found', (tester) async {
      final app = await pumpApp(tester, prefs: returningUser);
      await app.goTo(tester, '/nowhere');

      expect(find.text('Page not found'), findsOneWidget);
    });

    testWidgets('opening a country and pressing Back returns to Explore', (
      tester,
    ) async {
      await pumpApp(tester, prefs: returningUser);
      await tester.tap(find.text('Japan'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Japan'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('France'), findsOneWidget);
    });

    testWidgets('a screen opened by URL has an up button to its parent', (
      tester,
    ) async {
      final app = await pumpApp(tester, prefs: returningUser);
      await app.goTo(tester, '/settings');
      expect(find.byType(BackButton), findsNothing);

      await tester.tap(find.byType(BackButtonIcon));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Account'), findsOneWidget);
    });

    testWidgets('compact screens use a bottom navigation bar', (tester) async {
      await pumpApp(tester, prefs: returningUser);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('a 1,440 px window uses a navigation rail (AC-PLT-02)', (
      tester,
    ) async {
      await pumpApp(tester, prefs: returningUser, size: const Size(1440, 900));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('tabs switch between Explore, My travels, and Stats', (
      tester,
    ) async {
      await pumpApp(tester, prefs: returningUser);

      await tester.tap(find.text('My travels'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'My travels'), findsOneWidget);

      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Stats'), findsOneWidget);
    });
  });

  group('settings', () {
    testWidgets('Arabic applies instantly with right-to-left layout '
        '(FR-SET-02)', (tester) async {
      final app = await pumpApp(tester, prefs: returningUser);
      await app.container
          .read(settingsProvider.notifier)
          .setLanguage(AppLanguage.ar);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'استكشف'), findsOneWidget);
      expect(find.text('فرنسا'), findsOneWidget);
      final context = tester.element(find.text('فرنسا'));
      expect(Directionality.of(context), TextDirection.rtl);
    });

    testWidgets('saved language and theme load on startup (FR-SET-03)', (
      tester,
    ) async {
      await pumpApp(
        tester,
        prefs: {...returningUser, 'locale': 'ar', 'theme_mode': 'dark'},
      );

      final context = tester.element(find.text('فرنسا'));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(Theme.of(context).brightness, Brightness.dark);
    });

    testWidgets('choosing Dark on the Settings screen applies and saves it '
        '(FR-SET-01)', (tester) async {
      final app = await pumpApp(tester, prefs: returningUser);
      await app.goTo(tester, '/settings');

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Dark'));
      expect(Theme.of(context).brightness, Brightness.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'dark');
    });
  });
}
