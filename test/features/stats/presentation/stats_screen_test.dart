import 'package:battuta/core/router/app_router.dart';
import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:battuta/features/travels/presentation/travel_providers.dart';
import 'package:battuta/features/world_map/presentation/widgets/world_map_card.dart';
import 'package:battuta/features/world_map/presentation/world_map_painter.dart';
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

  testWidgets('no visits shows the map and the zero state, not the headline '
      'or empty bars (AC-STA-02)', (tester) async {
    await openStats(
      tester,
      seed: (app) =>
          app.container.read(travelRepositoryProvider).saveWishlist('JPN'),
    );

    expect(find.byKey(WorldMapCard.mapKey), findsOneWidget);
    final map = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byKey(WorldMapCard.mapKey),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is WorldMapPainter,
        ),
      ),
    );
    expect((map.painter! as WorldMapPainter).statuses, {
      'JPN': TravelStatus.wishlist,
    });
    expect(find.text('No countries visited yet'), findsOneWidget);
    expect(find.text('Countries visited'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.tap(find.text('Explore countries'));
    await tester.pumpAndSettle();
    expect(appBarOf('Explore'), findsOneWidget);
  });

  testWidgets('the headline shows visited out of the dataset total, with the '
      'share to one decimal and the wishlist as tags (FR-STA-01, FR-MAP-02)', (
    tester,
  ) async {
    await openStats(tester, seed: twoVisits);

    // The test dataset has 8 countries: 2 of 8 is 25.0%.
    expect(find.text('2'), findsOneWidget);
    expect(find.text('/ 8'), findsOneWidget);
    expect(find.text('25.0% of the world'), findsOneWidget);
    expect(find.text('1 on your wishlist'), findsOneWidget);
    expect(
      find.bySemanticsLabel('2 of 8 countries visited, 25.0 percent'),
      findsOneWidget,
    );
  });

  testWidgets('one bar per region, most visited first and the Antarctic '
      'last (FR-STA-02)', (tester) async {
    await openStats(tester, seed: twoVisits);

    // The map has a Europe chip too, so rows are found by their labels.
    expect(find.bySemanticsLabel('Europe, 1 of 4'), findsOneWidget);
    final france = find.text('1 of 4 · 25.0%');
    final japan = find.text('1 of 2 · 50.0%'); // In Asia.
    expect(france, findsOneWidget);
    expect(japan, findsOneWidget);
    // Africa and the Antarctic: one country each, none visited.
    final none = find.text('0 of 1 · 0.0%');
    expect(none, findsNWidgets(2));
    // One bar per region; the map card replaced the headline bar.
    expect(find.byType(LinearProgressIndicator), findsNWidgets(4));

    double top(Finder finder) => tester.getTopLeft(finder).dy;
    expect(top(japan), lessThan(top(france)));
    expect(top(france), lessThan(top(none.first)));
    // Africa, then the Antarctic, which isn't on the map: its row has no
    // map icon and isn't a button.
    expect(
      top(find.bySemanticsLabel('Africa, 0 of 1')),
      lessThan(top(find.bySemanticsLabel('Antarctic, 0 of 1'))),
    );
    expect(find.byIcon(Icons.map_outlined), findsNWidgets(3));
  });

  testWidgets('highlights (FR-STA-03)', (tester) async {
    await openStats(tester, seed: twoVisits);
    // They come after the map and the region bars.
    await tester.scrollUntilVisible(
      find.text('First trip'),
      200,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );

    expect(find.text('Japan'), findsOneWidget); // Most recent trip.
    expect(find.text('March 14, 2026'), findsOneWidget);
    expect(find.text('2019'), findsOneWidget); // First trip.
    // Europe and Asia, of the test dataset's 4 regions.
    expect(find.text('2 of 4'), findsOneWidget);
    expect(find.text('1'), findsOneWidget); // Wishlist size.
  });

  testWidgets('highlights are two to a row on phones and four on wide '
      'screens', (tester) async {
    double top(String label) => tester.getTopLeft(find.text(label)).dy;
    const labels = [
      'Most recent trip',
      'First trip',
      'Regions visited',
      'On your wishlist',
    ];

    // Tall enough that every tile is built.
    final app = await pumpApp(
      tester,
      prefs: returningUser,
      size: const Size(412, 2400),
    );
    await twoVisits(app);
    await app.goTo(tester, '/stats');
    expect(top(labels[0]), top(labels[1]));
    expect(top(labels[2]), greaterThan(top(labels[1])));
    expect(top(labels[2]), top(labels[3]));

    tester.view.physicalSize = const Size(1280, 2400);
    await tester.pumpAndSettle();
    expect({for (final label in labels) top(label)}, hasLength(1));
  });

  testWidgets('the most recent trip opens its country, and the wishlist '
      'opens the Wishlist (FR-STA-03)', (tester) async {
    final app = await openStats(tester, seed: twoVisits);
    final scrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    await tester.scrollUntilVisible(
      find.text('On your wishlist'),
      200,
      scrollable: scrollable,
    );

    await tester.tap(find.text('Japan'));
    await tester.pumpAndSettle();
    expect(appBarOf('Japan'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('On your wishlist'));
    await tester.pumpAndSettle();
    expect(
      app.container
          .read(routerProvider)
          .routerDelegate
          .currentConfiguration
          .uri
          .toString(),
      '/travels?tab=wishlist',
    );
  });

  testWidgets('deleting a visit updates the headline (AC-STA-01)', (
    tester,
  ) async {
    final app = await openStats(tester, seed: twoVisits);
    expect(find.text('25.0% of the world'), findsOneWidget);

    await app.container.read(travelRepositoryProvider).remove('FRA');
    await tester.pumpAndSettle();

    expect(find.text('12.5% of the world'), findsOneWidget);
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
    expect(find.text('25.0% of the world'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('25.0% of the world'), findsOneWidget);
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
    expect(find.text('25.0% of the world'), findsOneWidget);
  });

  testWidgets('reads in Arabic, with bars filling from the right', (
    tester,
  ) async {
    await openStats(tester, seed: twoVisits, prefs: {'locale': 'ar'});

    expect(find.text('25.0% من العالم'), findsOneWidget);
    expect(find.text('1 في قائمة أمنياتك'), findsOneWidget);
    expect(find.bySemanticsLabel('أوروبا، 1 من 4'), findsOneWidget);
    final bar = tester.element(find.byType(LinearProgressIndicator).first);
    expect(Directionality.of(bar), TextDirection.rtl);
  });
}
