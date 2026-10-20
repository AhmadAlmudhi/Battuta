import 'package:battuta/core/router/app_router.dart';
import 'package:battuta/features/travels/presentation/travel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<TestApp> openStats(
    WidgetTester tester, {
    Future<void> Function(TestApp app)? seed,
    Map<String, Object> prefs = const {},
  }) async {
    final app = await pumpApp(tester, prefs: {...returningUser, ...prefs});
    await seed?.call(app);
    await app.goTo(tester, '/stats');
    return app;
  }

  Future<void> twoVisits(TestApp app) async {
    final repo = app.container.read(travelRepositoryProvider);
    await repo.saveVisit('FRA', visitedOn: DateTime(2019, 7, 2));
    await repo.saveVisit('JPN', visitedOn: DateTime(2026, 3, 14));
    await repo.saveWishlist('SAU');
  }

  testWidgets('no visits shows the zero state, not empty bars (AC-STA-02)', (
    tester,
  ) async {
    await openStats(tester);

    expect(find.text('No countries visited yet'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.tap(find.text('Explore countries'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Explore'), findsOneWidget);
  });

  testWidgets('the headline shows visited out of the dataset total with one '
      'decimal (FR-STA-01)', (tester) async {
    await openStats(tester, seed: twoVisits);

    // The test dataset has 8 countries: 2 of 8 is 25.0%.
    expect(find.text('2'), findsOneWidget);
    expect(find.text('of 8 · 25.0%'), findsOneWidget);
    expect(
      find.bySemanticsLabel('2 of 8 countries visited, 25.0 percent'),
      findsOneWidget,
    );
  });

  testWidgets('one bar per region (FR-STA-02)', (tester) async {
    await openStats(tester, seed: twoVisits);

    expect(find.text('Europe'), findsOneWidget);
    expect(find.text('1 of 4'), findsOneWidget); // France
    expect(find.text('1 of 2'), findsOneWidget); // Japan, in Asia
    // Africa and the Antarctic: one country each, none visited.
    expect(find.text('0 of 1'), findsNWidgets(2));
    // One bar per region plus the headline bar.
    expect(find.byType(LinearProgressIndicator), findsNWidgets(5));
  });

  testWidgets('highlights (FR-STA-03)', (tester) async {
    await openStats(tester, seed: twoVisits);

    expect(find.text('Japan'), findsOneWidget); // Most recent trip.
    expect(find.text('March 14, 2026'), findsOneWidget);
    expect(find.text('2019'), findsOneWidget); // First trip.
    expect(find.text('1'), findsOneWidget); // Wishlist size.
  });

  testWidgets('deleting a visit updates the headline (AC-STA-01)', (
    tester,
  ) async {
    final app = await openStats(tester, seed: twoVisits);
    expect(find.text('of 8 · 25.0%'), findsOneWidget);

    await app.container.read(travelRepositoryProvider).remove('FRA');
    await tester.pumpAndSettle();

    expect(find.text('of 8 · 12.5%'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^1 of 8')), findsOneWidget);
  });

  testWidgets('numbers count up when the screen opens (FR-STA-04)', (
    tester,
  ) async {
    final app = await pumpApp(tester, prefs: returningUser);
    await twoVisits(app);
    app.container.read(routerProvider).go('/stats');
    await tester.pump(); // First frame of the count-up.
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('of 8 · 25.0%'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('of 8 · 25.0%'), findsOneWidget);
  });

  testWidgets('with reduced motion the final numbers show at once '
      '(NFR-09)', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final app = await pumpApp(tester, prefs: returningUser);
    await twoVisits(app);
    app.container.read(routerProvider).go('/stats');
    await tester.pump();
    await tester.pump();

    expect(find.text('2'), findsOneWidget);
    expect(find.text('of 8 · 25.0%'), findsOneWidget);
  });

  testWidgets('reads in Arabic, with bars filling from the right', (
    tester,
  ) async {
    await openStats(tester, seed: twoVisits, prefs: {'locale': 'ar'});

    expect(find.text('من 8 · 25.0%'), findsOneWidget);
    expect(find.text('أوروبا'), findsOneWidget);
    final bar = tester.element(find.byType(LinearProgressIndicator).first);
    expect(Directionality.of(bar), TextDirection.rtl);
  });
}
