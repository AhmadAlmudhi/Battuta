import 'package:battuta/features/countries/presentation/country_details_screen.dart';
import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:battuta/features/travels/presentation/travel_forms.dart';
import 'package:battuta/features/travels/presentation/travel_providers.dart';
import 'package:battuta/features/world_map/domain/map_projection.dart';
import 'package:battuta/features/world_map/presentation/widgets/map_country_card.dart';
import 'package:battuta/features/world_map/presentation/widgets/world_map_card.dart';
import 'package:battuta/features/world_map/presentation/world_map_colors.dart';
import 'package:battuta/features/world_map/presentation/world_map_painter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

// Inland points in degrees, clear of coasts and borders. Brazil isn't in the
// test dataset.
const japan = (138.3, 36.3);
const spain = (-4.0, 40.0);
const saudiArabia = (44.0, 23.0);
const brazil = (-52.0, -10.0);
const ocean = (-25.0, -15.0);

/// A desktop browser window, where the map is 672 dp wide.
const desktop = Size(1280, 900);

void main() {
  Future<TestApp> openStats(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
    bool online = true,
    Size size = const Size(412, 915),
  }) async {
    final app = await pumpApp(
      tester,
      prefs: {...returningUser, ...prefs},
      online: online,
      size: size,
    );
    final repo = app.container.read(travelRepositoryProvider);
    await repo.saveVisit('FRA', visitedOn: DateTime(2019, 7, 2));
    await repo.saveVisit('JPN', visitedOn: DateTime(2024, 3, 14));
    await repo.saveWishlist('SAU', targetYear: 2027);
    await app.goTo(tester, '/stats');
    return app;
  }

  /// Where a place is on screen. The map never mirrors.
  Offset onMap(WidgetTester tester, (double, double) place) {
    final rect = tester.getRect(find.byKey(WorldMapCard.mapKey));
    final (x, y) = MapFrame.project(place.$1, place.$2);
    return rect.topLeft + Offset(x, y) * (rect.width / MapFrame.width);
  }

  Future<void> tapOnMap(WidgetTester tester, (double, double) place) async {
    await tester.tapAt(onMap(tester, place));
    await tester.pumpAndSettle();
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

  Finder inCard(String text) => find.descendant(
    of: find.byType(MapCountryCard),
    matching: find.text(text),
  );

  testWidgets('every country is colored by its status, and changes show at '
      'once (FR-MAP-01, FR-MAP-04, AC-MAP-03)', (tester) async {
    final app = await openStats(tester);

    expect(painter(tester).statuses, {
      'FRA': TravelStatus.visited,
      'JPN': TravelStatus.visited,
      'SAU': TravelStatus.wishlist,
    });

    await app.container.read(travelRepositoryProvider).remove('JPN');
    await tester.pumpAndSettle();
    expect(painter(tester).statuses, isNot(contains('JPN')));
  });

  testWidgets('the header is the Stats headline with the wishlist size, and '
      'there is no other headline (AC-MAP-02)', (tester) async {
    await openStats(tester);

    final card = find.byType(WorldMapCard);
    expect(
      find.descendant(
        of: card,
        matching: find.text('of 8 · 25.0% · 1 on your wishlist'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('Countries visited')),
      findsOneWidget,
    );
    expect(find.text('Countries visited'), findsOneWidget);
  });

  testWidgets('the legend explains the colors and the dots (FR-MAP-03)', (
    tester,
  ) async {
    await openStats(tester);

    for (final label in [
      'Visited',
      'Wishlist',
      'Not yet',
      'Small countries appear as dots',
    ]) {
      expect(
        find.descendant(
          of: find.byType(WorldMapCard),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('the map shows offline (AC-MAP-04)', (tester) async {
    await openStats(tester, online: false);

    expect(find.byKey(WorldMapCard.mapKey), findsOneWidget);
    expect(painter(tester).statuses, hasLength(3));
  });

  testWidgets('dark mode uses the dark map colors (FR-MAP-06)', (tester) async {
    await openStats(tester, prefs: {'theme_mode': 'dark'});

    expect(painter(tester).colors, WorldMapColors.dark);
  });

  testWidgets('tapping a visited country opens its card, with its visit date '
      '(FR-MAP-12, AC-MAP-09)', (tester) async {
    await openStats(tester);

    await tapOnMap(tester, japan);

    expect(painter(tester).selected, 'JPN');
    expect(inCard('Japan'), findsOneWidget);
    expect(inCard('Visited on March 14, 2024'), findsOneWidget);
    expect(inCard('Edit'), findsOneWidget);
    expect(inCard('Open details'), findsOneWidget);
    expect(inCard('Mark as visited'), findsNothing);
  });

  testWidgets('Open details opens the country (AC-MAP-10)', (tester) async {
    await openStats(tester);
    await tapOnMap(tester, japan);

    await tester.tap(inCard('Open details'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is CountryDetailsScreen && widget.code == 'JPN',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a country that isn\'t saved offers the same forms as Country '
      'details (FR-MAP-13)', (tester) async {
    await openStats(tester);
    await tapOnMap(tester, spain);

    expect(inCard('Spain'), findsOneWidget);
    expect(inCard('Not visited yet'), findsOneWidget);
    expect(inCard('Add to wishlist'), findsOneWidget);

    await tester.tap(inCard('Mark as visited'));
    await tester.pumpAndSettle();
    expect(find.byType(VisitForm), findsOneWidget);
  });

  testWidgets('a wishlist country shows its target year and offers Mark as '
      'visited and Edit (FR-MAP-13)', (tester) async {
    await openStats(tester);
    await tapOnMap(tester, saudiArabia);

    expect(inCard('On your wishlist · Target year 2027'), findsOneWidget);
    expect(inCard('Mark as visited'), findsOneWidget);
    expect(inCard('Edit'), findsOneWidget);
    expect(inCard('Add to wishlist'), findsNothing);
  });

  testWidgets('tapping the ocean or pressing Esc closes the card '
      '(FR-MAP-14)', (tester) async {
    await openStats(tester);

    await tapOnMap(tester, japan);
    expect(find.byType(MapCountryCard), findsOneWidget);
    await tapOnMap(tester, ocean);
    expect(find.byType(MapCountryCard), findsNothing);

    await tapOnMap(tester, japan);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(MapCountryCard), findsNothing);
    expect(painter(tester).selected, isNull);
  });

  testWidgets('tapping the selected country again, or the page outside the '
      'map, closes the card (FR-MAP-14)', (tester) async {
    await openStats(tester);
    // Taps a second or more apart, so they aren't a double tap, which zooms.
    final spot = onMap(tester, japan);
    final taps = await tester.createGesture();
    Future<void> tapJapan(int second) async {
      await taps.down(spot, timeStamp: Duration(seconds: second));
      await taps.up(timeStamp: Duration(seconds: second));
      await tester.pumpAndSettle();
    }

    await tapJapan(1);
    expect(find.byType(MapCountryCard), findsOneWidget);
    await tapJapan(2);
    expect(find.byType(MapCountryCard), findsNothing);
    expect(painter(tester).selected, isNull);

    await tapJapan(3);
    // A tap on the card itself keeps it open.
    await tester.tap(inCard('Japan'));
    await tester.pumpAndSettle();
    expect(find.byType(MapCountryCard), findsOneWidget);

    await tester.tap(find.text('Countries visited'));
    await tester.pumpAndSettle();
    expect(find.byType(MapCountryCard), findsNothing);
  });

  testWidgets('scrolling the page leaves the card open', (tester) async {
    await openStats(tester);
    await tapOnMap(tester, japan);

    await tester.drag(find.text('Countries visited'), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(find.byType(MapCountryCard), findsOneWidget);
  });

  testWidgets('shapes of countries outside the dataset can\'t be selected '
      '(FR-MAP-07)', (tester) async {
    await openStats(tester);

    await tapOnMap(tester, brazil);

    expect(find.byType(MapCountryCard), findsNothing);
  });

  testWidgets('on web, hovering highlights a country and shows its name '
      '(AC-MAP-11)', (tester) async {
    await openStats(tester, size: desktop);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(onMap(tester, spain));
    await tester.pump();

    expect(painter(tester).hovered, 'ESP');
    expect(
      find.descendant(
        of: find.byKey(WorldMapCard.mapKey),
        matching: find.text('Spain'),
      ),
      findsOneWidget,
    );

    await mouse.moveTo(onMap(tester, ocean));
    await tester.pump();
    expect(painter(tester).hovered, isNull);
  });

  testWidgets('screen readers get one summary and a View as list action '
      '(FR-MAP-08)', (tester) async {
    await openStats(tester);

    expect(
      find.bySemanticsLabel(
        'World map: 2 countries visited, 1 on your wishlist',
      ),
      findsOneWidget,
    );

    final summary = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            (widget.properties.label?.startsWith('World map') ?? false),
      ),
    );
    final actions = summary.properties.customSemanticsActions!;
    expect(actions.keys.single.label, 'View as list');
    actions.values.single();
    await tester.pumpAndSettle();
    expect(find.text('Visited (2)'), findsOneWidget);
  });

  testWidgets('in Arabic the map doesn\'t mirror, but the card does '
      '(PRD 10.4)', (tester) async {
    await openStats(tester, prefs: {'locale': 'ar'});

    await tapOnMap(tester, japan);

    expect(painter(tester).selected, 'JPN');
    expect(inCard('اليابان'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(MapCountryCard))),
      TextDirection.rtl,
    );
  });
}
