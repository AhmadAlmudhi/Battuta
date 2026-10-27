import 'package:battuta/core/router/app_router.dart';
import 'package:battuta/features/travels/presentation/travel_providers.dart';
import 'package:battuta/features/world_map/domain/map_projection.dart';
import 'package:battuta/features/world_map/domain/map_regions.dart';
import 'package:battuta/features/world_map/domain/map_view.dart';
import 'package:battuta/features/world_map/presentation/widgets/map_country_card.dart';
import 'package:battuta/features/world_map/presentation/widgets/world_map_card.dart';
import 'package:battuta/features/world_map/presentation/world_map_painter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

// Inland points in degrees.
const japan = (138.3, 36.3);
const france = (2.5, 46.5);

void main() {
  Future<TestApp> seed(
    WidgetTester tester, {
    Map<String, Object>? prefs,
  }) async {
    final app = await pumpApp(tester, prefs: {...returningUser, ...?prefs});
    final repo = app.container.read(travelRepositoryProvider);
    await repo.saveVisit('FRA', visitedOn: DateTime(2019, 7, 2));
    await repo.saveVisit('JPN', visitedOn: DateTime(2024, 3, 14));
    await repo.saveWishlist('SAU', targetYear: 2027);
    return app;
  }

  Future<TestApp> openStats(
    WidgetTester tester, {
    Map<String, Object>? prefs,
  }) async {
    final app = await seed(tester, prefs: prefs);
    await app.goTo(tester, '/stats');
    return app;
  }

  WorldMapPainter painter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.descendant(
                  of: find.byKey(WorldMapCard.mapKey),
                  matching: find.byWidgetPredicate(
                    (widget) =>
                        widget is CustomPaint &&
                        widget.painter is WorldMapPainter,
                  ),
                ),
              )
              .painter!
          as WorldMapPainter;

  Rect mapRect(WidgetTester tester) =>
      tester.getRect(find.byKey(WorldMapCard.mapKey));

  /// Where a place is on screen in the map's current view.
  Offset onMap(WidgetTester tester, (double, double) place) {
    final rect = mapRect(tester);
    final (x, y) = MapFrame.project(place.$1, place.$2);
    final (vx, vy) = painter(tester).view.toView(x, y, rect.width, rect.height);
    return rect.topLeft + Offset(vx, vy);
  }

  final page = find.byWidgetPredicate(
    (widget) =>
        widget is Scrollable && widget.axisDirection == AxisDirection.down,
  );
  double pageOffset(WidgetTester tester) =>
      tester.state<ScrollableState>(page).position.pixels;

  Finder button(String tooltip) => find.byTooltip(tooltip);

  /// Views match to within floating-point rounding.
  Matcher isView(MapView expected) => isA<MapView>()
      .having((view) => view.scale, 'scale', closeTo(expected.scale, 1e-9))
      .having(
        (view) => view.centerX,
        'centerX',
        closeTo(expected.centerX, 1e-9),
      )
      .having(
        (view) => view.centerY,
        'centerY',
        closeTo(expected.centerY, 1e-9),
      );

  /// Taps a region chip, scrolling the chip row to it first: on a phone the
  /// last chips start off screen.
  Future<void> tapChip(WidgetTester tester, String label) async {
    final chip = find.widgetWithText(ChoiceChip, label);
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
  }

  group('zoom and pan', () {
    testWidgets('Zoom in zooms, and Reset view flies back to the world '
        '(FR-MAP-16, FR-MAP-18, AC-MAP-14)', (tester) async {
      await openStats(tester);
      expect(button('Reset view'), findsNothing);

      await tester.tap(button('Zoom in'));
      await tester.pumpAndSettle();
      expect(painter(tester).view.scale, 2);

      await tester.tap(button('Reset view'));
      await tester.pump(); // The flight's first frame.
      await tester.pump(const Duration(milliseconds: 300));
      expect(painter(tester).view.scale, inExclusiveRange(1, 2));
      await tester.pumpAndSettle();
      expect(painter(tester).view, MapView.world);
      expect(button('Reset view'), findsNothing);
    });

    testWidgets('zoom stops at 1× and 8×', (tester) async {
      await openStats(tester);
      IconButton zoom(IconData icon) =>
          tester.widget(find.widgetWithIcon(IconButton, icon));

      expect(zoom(Icons.remove_rounded).onPressed, isNull);
      for (var i = 0; i < 3; i++) {
        await tester.tap(button('Zoom in'));
        await tester.pumpAndSettle();
      }
      expect(painter(tester).view.scale, 8);
      expect(zoom(Icons.add_rounded).onPressed, isNull);
    });

    testWidgets('at 1×, the mouse wheel scrolls the page; with Ctrl it zooms '
        '(FR-MAP-16, AC-MAP-13)', (tester) async {
      await openStats(tester);
      final mouse = TestPointer(1, PointerDeviceKind.mouse);
      final center = mapRect(tester).center;
      await tester.sendEventToBinding(mouse.hover(center));

      await tester.sendEventToBinding(mouse.scroll(const Offset(0, 120)));
      await tester.pumpAndSettle();
      expect(pageOffset(tester), greaterThan(0));
      expect(painter(tester).view, MapView.world);

      final scrolled = pageOffset(tester);
      final mapCenter = mapRect(tester).center;
      await tester.sendEventToBinding(mouse.hover(mapCenter));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, -120)));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(painter(tester).view.scale, greaterThan(1));
      expect(pageOffset(tester), scrolled);
    });

    testWidgets('pinching zooms toward the fingers (AC-MAP-12)', (
      tester,
    ) async {
      await openStats(tester);
      final europe = onMap(tester, france);

      final first = await tester.startGesture(europe - const Offset(20, 0));
      final second = await tester.startGesture(europe + const Offset(20, 0));
      await tester.pump();
      for (var step = 1; step <= 4; step++) {
        await first.moveTo(europe - Offset(20.0 + 10 * step, 0));
        await second.moveTo(europe + Offset(20.0 + 10 * step, 0));
        await tester.pump();
      }
      await first.up();
      await second.up();
      await tester.pumpAndSettle();

      final view = painter(tester).view;
      expect(view.scale, closeTo(3, 0.1));
      // France stays under the fingers.
      expect((onMap(tester, france) - europe).distance, lessThan(2));
    });

    testWidgets('at 1× a drag scrolls the page; once zoomed in it pans the '
        'map instead (FR-MAP-17)', (tester) async {
      await openStats(tester);
      final center = mapRect(tester).center;

      await tester.dragFrom(center, const Offset(0, -80));
      await tester.pumpAndSettle();
      expect(pageOffset(tester), greaterThan(0));
      expect(painter(tester).view, MapView.world);

      await tester.drag(page, const Offset(0, 500));
      await tester.pumpAndSettle();
      await tester.tap(button('Zoom in'));
      await tester.pumpAndSettle();
      final before = painter(tester).view;
      final offset = pageOffset(tester);

      await tester.dragFrom(mapRect(tester).center, const Offset(0, 40));
      await tester.pumpAndSettle();
      expect(painter(tester).view.centerY, lessThan(before.centerY));
      expect(pageOffset(tester), offset);
    });

    testWidgets('a double tap zooms in where it lands; two slow taps don\'t '
        '(FR-MAP-16)', (tester) async {
      await openStats(tester);
      final spot = onMap(tester, japan);

      // Taps a second apart are two taps.
      final slow = await tester.createGesture();
      await slow.down(spot);
      await slow.up(timeStamp: const Duration(seconds: 1));
      await slow.down(spot, timeStamp: const Duration(seconds: 2));
      await slow.up(timeStamp: const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(painter(tester).view, MapView.world);

      await tester.tapAt(spot);
      await tester.tapAt(spot);
      await tester.pumpAndSettle();
      expect(painter(tester).view.scale, 2);
      expect((onMap(tester, japan) - spot).distance, lessThan(1));
    });

    testWidgets('+ and − zoom, and the arrows pan by the compass in both '
        'languages (FR-MAP-19)', (tester) async {
      for (final locale in ['en', 'ar']) {
        await openStats(tester, prefs: {'locale': locale});
        await tester.tapAt(onMap(tester, (-25, -15))); // Focus, on the ocean.
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.equal);
        await tester.pumpAndSettle();
        final zoomed = painter(tester).view;
        expect(zoomed.scale, 2, reason: locale);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
        expect(painter(tester).view.centerX, lessThan(zoomed.centerX));

        await tester.sendKeyEvent(LogicalKeyboardKey.minus);
        await tester.pumpAndSettle();
        expect(painter(tester).view.scale, 1, reason: locale);
      }
    });
  });

  group('region focus', () {
    testWidgets('a chip flies to its region, fades the rest, and sums the '
        'region up; All flies back (FR-MAP-21 to 24, AC-MAP-15)', (
      tester,
    ) async {
      await openStats(tester);

      await tapChip(tester, 'Europe');
      await tester.pump(); // The flight's first frame.
      await tester.pump(const Duration(milliseconds: 300));
      expect(painter(tester).fade, inExclusiveRange(0, 1));
      await tester.pumpAndSettle();

      final rect = mapRect(tester);
      final europe = MapView.fit(
        regionFrame('Europe')!,
        width: rect.width,
        height: rect.height,
      );
      expect(painter(tester).view, isView(europe));
      expect(painter(tester).fade, 1);
      expect(
        find.text('Europe · 1 visited · 0 on your wishlist'),
        findsOneWidget,
      );

      await tapChip(tester, 'All');
      await tester.pumpAndSettle();
      expect(painter(tester).view, MapView.world);
      expect(painter(tester).fade, 0);
      expect(find.textContaining('on your wishlist ·'), findsNothing);
      expect(find.textContaining('Europe ·'), findsNothing);
    });

    testWidgets('faded countries can still be selected (AC-MAP-16)', (
      tester,
    ) async {
      await openStats(tester);
      await tapChip(tester, 'Asia');
      await tester.pumpAndSettle();

      final paris = onMap(tester, france);
      expect(mapRect(tester).contains(paris), isTrue);
      await tester.tapAt(paris);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(MapCountryCard),
          matching: find.text('France'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping a region bar scrolls the map into view and flies '
        'there; the Antarctic bar has no region (FR-MAP-25, AC-MAP-17)', (
      tester,
    ) async {
      await openStats(tester);
      await tester.drag(page, const Offset(0, -400));
      await tester.pumpAndSettle();
      // The top of the map has scrolled off the screen.
      expect(mapRect(tester).top, lessThan(0));

      await tester.tap(find.bySemanticsLabel('Antarctic, 0 of 1'));
      await tester.pumpAndSettle();
      expect(painter(tester).fade, 0);

      await tester.tap(find.bySemanticsLabel('Africa, 0 of 1'));
      await tester.pumpAndSettle();
      expect(mapRect(tester).top, greaterThanOrEqualTo(0));
      expect(painter(tester).fade, 1);
      expect(
        find.text('Africa · 0 visited · 0 on your wishlist'),
        findsOneWidget,
      );
    });
  });

  group('reveal', () {
    /// Opens Stats and pumps frames without moving the clock until the map
    /// has its data, so the reveal is still at its start.
    Future<void> openWithoutSettling(WidgetTester tester) async {
      final app = await seed(tester);
      app.container.read(routerProvider).go('/stats');
      for (var frame = 0; frame < 20; frame++) {
        await tester.pump();
        if (find.byKey(WorldMapCard.mapKey).evaluate().isNotEmpty) return;
      }
      fail('The map never appeared.');
    }

    testWidgets('visited countries fill one by one, oldest visit first, and '
        'the reveal ends within 1.5 seconds (AC-MAP-18, FR-MAP-27)', (
      tester,
    ) async {
      await openWithoutSettling(tester);
      expect(painter(tester).motion?.fills, {'FRA': 0.0, 'JPN': 0.0});

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      final fills = painter(tester).motion!.fills;
      expect(fills['FRA'], greaterThan(fills['JPN']!));

      await tester.pump(const Duration(milliseconds: 1300));
      expect(painter(tester).motion, isNull);
    });

    testWidgets('once played, it doesn\'t play again this session '
        '(AC-MAP-19)', (tester) async {
      final app = await openStats(tester);
      expect(painter(tester).motion, isNull);

      await app.goTo(tester, '/explore');
      app.container.read(routerProvider).go('/stats');
      await tester.pump();
      expect(painter(tester).motion, isNull);
    });

    testWidgets('with reduced motion the final map shows at once, and region '
        'flights jump (AC-MAP-20, NFR-09)', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await openWithoutSettling(tester);
      expect(painter(tester).motion, isNull);

      await tester.pumpAndSettle();
      await tapChip(tester, 'Europe');
      await tester.pump();
      expect(painter(tester).fade, 1);
      expect(painter(tester).view.isZoomed, isTrue);
    });

    testWidgets('tapping the map during the reveal skips to the end '
        '(FR-MAP-31)', (tester) async {
      await openWithoutSettling(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(painter(tester).motion, isNotNull);

      await tester.tapAt(onMap(tester, japan));
      await tester.pump();

      expect(painter(tester).motion, isNull);
      expect(find.byType(MapCountryCard), findsNothing);
    });
  });
}
