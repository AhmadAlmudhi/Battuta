import 'package:battuta/core/router/app_router.dart';
import 'package:battuta/features/countries/presentation/widgets/country_card.dart';
import 'package:battuta/features/settings/domain/app_settings.dart';
import 'package:battuta/features/settings/presentation/settings_controller.dart';
import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:battuta/features/travels/presentation/travel_providers.dart';
import 'package:battuta/features/travels/presentation/widgets/travel_entry_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Finder tile(String name) => find.ancestor(
    of: find.text(name),
    matching: find.byType(TravelEntryTile),
  );

  /// A tab of the Visited and Wishlist toggle, by its label and count.
  Finder tab(String label, int count) => find.descendant(
    of: find.widgetWithText(Tab, label),
    matching: find.text('$count'),
  );

  /// Names of the visible rows, top to bottom.
  List<String> rowOrder(WidgetTester tester, List<String> names) => [...names]
    ..sort(
      (a, b) => tester
          .getTopLeft(tile(a))
          .dy
          .compareTo(tester.getTopLeft(tile(b)).dy),
    );

  /// The entry as the list sees it; the list keeps this provider live.
  TravelEntry? entryFor(TestApp app, String code) => app.container
      .read(travelEntriesProvider)
      .valueOrNull
      ?.where((entry) => entry.countryCode == code)
      .firstOrNull;

  String location(TestApp app) => app.container
      .read(routerProvider)
      .routerDelegate
      .currentConfiguration
      .uri
      .toString();

  Future<TestApp> openTravels(
    WidgetTester tester, {
    Future<void> Function(TestApp app)? seed,
    String path = '/travels',
    Map<String, Object> prefs = const {},
  }) async {
    final app = await pumpApp(tester, prefs: {...returningUser, ...prefs});
    await seed?.call(app);
    await app.goTo(tester, path);
    return app;
  }

  Future<void> seedVisits(TestApp app) async {
    final repo = app.container.read(travelRepositoryProvider);
    await repo.saveVisit('FRA', visitedOn: DateTime(2025, 6, 1), rating: 4);
    await repo.saveVisit('JPN', visitedOn: DateTime(2026, 3, 14));
    await repo.saveVisit('DEU');
    await repo.saveWishlist('SAU', priority: WishlistPriority.high);
  }

  group('tabs (FR-TRV-05, FR-TRV-09)', () {
    testWidgets('empty tabs invite the user to Explore', (tester) async {
      final app = await openTravels(tester);

      expect(tab('Visited', 0), findsOneWidget);
      expect(find.text('No visits yet'), findsOneWidget);
      await tester.tap(tab('Wishlist', 0));
      await tester.pumpAndSettle();
      expect(find.text('Your wishlist is empty'), findsOneWidget);

      await tester.tap(find.text('Explore countries').last);
      await tester.pumpAndSettle();
      expect(location(app), '/explore');
    });

    testWidgets('each tab shows its count', (tester) async {
      await openTravels(tester, seed: seedVisits);

      expect(tab('Visited', 3), findsOneWidget);
      expect(tab('Wishlist', 1), findsOneWidget);
    });

    testWidgets('the Wishlist tab has its own URL (PRD 5.2)', (tester) async {
      final app = await openTravels(
        tester,
        seed: seedVisits,
        path: '/travels?tab=wishlist',
      );
      expect(tile('Saudi Arabia'), findsOneWidget);

      await tester.tap(tab('Visited', 3));
      await tester.pumpAndSettle();
      expect(location(app), '/travels');
      expect(tile('Japan'), findsOneWidget);

      await tester.tap(tab('Wishlist', 1));
      await tester.pumpAndSettle();
      expect(location(app), '/travels?tab=wishlist');
    });
  });

  testWidgets('visits fall under their years with a summary, and rows leave '
      'out a missing date (FR-TRV-06)', (tester) async {
    await openTravels(tester, seed: seedVisits);

    expect(find.text('3 countries in 2 regions'), findsOneWidget);
    // Newest year first, undated last.
    final headings = ['2026', '2025', 'No date'];
    for (final heading in headings) {
      expect(find.text(heading), findsOneWidget);
    }
    expect(
      [for (final h in headings) tester.getTopLeft(find.text(h)).dy],
      orderedEquals(
        [for (final h in headings) tester.getTopLeft(find.text(h)).dy]..sort(),
      ),
    );
    expect(find.text('Europe · June 1, 2025'), findsOneWidget);
    expect(find.text('Europe'), findsOneWidget); // Germany has no date.
    expect(find.text('Date not set'), findsNothing);
  });

  testWidgets('a row shows the first line of its notes', (tester) async {
    await openTravels(
      tester,
      seed: (app) => app.container
          .read(travelRepositoryProvider)
          .saveVisit('FRA', notes: 'Croissants every morning\nand more'),
    );

    expect(find.text('Croissants every morning'), findsOneWidget);
  });

  group('order (FR-TRV-06)', () {
    testWidgets('Visited: newest first, undated last, or by name', (
      tester,
    ) async {
      await openTravels(tester, seed: seedVisits);

      expect(rowOrder(tester, ['France', 'Germany', 'Japan']), [
        'Japan',
        'France',
        'Germany',
      ]);

      await tester.tap(find.byTooltip('Sort'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Name, A to Z'));
      await tester.pumpAndSettle();
      expect(rowOrder(tester, ['France', 'Germany', 'Japan']), [
        'France',
        'Germany',
        'Japan',
      ]);
    });

    testWidgets('Wishlist: priority, then target year', (tester) async {
      await openTravels(
        tester,
        path: '/travels?tab=wishlist',
        seed: (app) async {
          final repo = app.container.read(travelRepositoryProvider);
          await repo.saveWishlist('SEN', priority: WishlistPriority.low);
          await repo.saveWishlist(
            'ESP',
            priority: WishlistPriority.high,
            targetYear: 2028,
          );
          await repo.saveWishlist(
            'SAU',
            priority: WishlistPriority.high,
            targetYear: 2027,
          );
        },
      );

      expect(rowOrder(tester, ['Senegal', 'Spain', 'Saudi Arabia']), [
        'Saudi Arabia',
        'Spain',
        'Senegal',
      ]);
      expect(find.text('High priority'), findsOneWidget);
      expect(find.text('Asia · Target year 2027'), findsOneWidget);
    });
  });

  group('edit and delete (FR-TRV-07)', () {
    testWidgets('Delete in the menu removes the row, and Undo brings it back '
        'unchanged (AC-TRV-03)', (tester) async {
      final app = await openTravels(tester, seed: seedVisits);

      await tester.tap(find.byTooltip('Options for France'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(tile('France'), findsNothing);
      expect(find.text('France deleted.'), findsOneWidget);
      expect(tab('Visited', 2), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(tile('France'), findsOneWidget);
      final entry = entryFor(app, 'FRA');
      expect(entry?.rating, 4);
      expect(entry?.visitedOn, DateTime(2025, 6, 1));
    });

    testWidgets('swiping toward the start deletes', (tester) async {
      await openTravels(tester, seed: seedVisits);

      await tester.drag(tile('France'), const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(tile('France'), findsNothing);
      expect(find.text('France deleted.'), findsOneWidget);
      expect(tab('Visited', 2), findsOneWidget);
    });

    testWidgets('swiping toward the end opens the edit form and keeps the '
        'row', (tester) async {
      await openTravels(tester, seed: seedVisits);

      await tester.drag(tile('France'), const Offset(600, 0));
      await tester.pumpAndSettle();

      expect(find.text('Your visit to France'), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(tile('France'), findsOneWidget);
    });

    testWidgets('swipe directions mirror in Arabic', (tester) async {
      final app = await openTravels(tester, seed: seedVisits);
      await app.container
          .read(settingsProvider.notifier)
          .setLanguage(AppLanguage.ar);
      await tester.pumpAndSettle();

      // In right-to-left layouts the start edge is on the right, so a
      // leftward swipe moves toward the end: it edits.
      await tester.drag(tile('فرنسا'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.text('زيارتك إلى فرنسا'), findsOneWidget);
    });

    testWidgets('Edit in the menu saves changes to the entry', (tester) async {
      final app = await openTravels(tester, seed: seedVisits);

      await tester.tap(find.byTooltip('Options for Japan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('5 of 5 stars'));
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(entryFor(app, 'JPN')?.rating, 5);
    });
  });

  group('search and filter (FR-TRV-08)', () {
    testWidgets('search by name in either language', (tester) async {
      await openTravels(tester, seed: seedVisits);

      await tester.enterText(find.byType(TextField), 'ja');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(tile('Japan'), findsOneWidget);
      expect(tile('France'), findsNothing);

      await tester.enterText(find.byType(TextField), 'فرن');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(tile('France'), findsOneWidget);
      expect(tile('Japan'), findsNothing);
    });

    testWidgets('filter by region, and clear when nothing matches', (
      tester,
    ) async {
      await openTravels(tester, seed: seedVisits);

      // Visited has 1 country in Asia.
      await tester.tap(find.widgetWithText(FilterChip, 'Asia 1'));
      await tester.pumpAndSettle();
      expect(tile('Japan'), findsOneWidget);
      expect(tile('France'), findsNothing);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('No entries match.'), findsOneWidget);

      await tester.tap(find.text('Clear search and filters'));
      await tester.pumpAndSettle();
      expect(tile('France'), findsOneWidget);
      expect(tile('Japan'), findsOneWidget);
    });
  });

  testWidgets('opening an entry shows its country, even while Explore holds '
      'the same flag in another tab', (tester) async {
    // Explore is built first, so its France card exists offstage while
    // France opens from My travels. Both flags share a hero tag; only the
    // visible tab may take part in the flight.
    final app = await pumpApp(tester, prefs: returningUser);
    expect(
      find.ancestor(
        of: find.text('France'),
        matching: find.byType(CountryCard),
      ),
      findsOneWidget,
    );
    await app.container
        .read(travelRepositoryProvider)
        .saveVisit('FRA', rating: 3);
    await tester.tap(find.text('My travels'));
    await tester.pumpAndSettle();

    await tester.tap(tile('France'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(appBarOf('France'), findsOneWidget);
    expect(find.text('Visited'), findsOneWidget);
  });
}
