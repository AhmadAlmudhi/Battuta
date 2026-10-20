import 'package:battuta/core/database/app_database.dart';
import 'package:battuta/features/countries/data/country_refresher.dart';
import 'package:battuta/features/countries/presentation/widgets/country_card.dart';
import 'package:battuta/features/settings/domain/app_settings.dart';
import 'package:battuta/features/settings/presentation/settings_controller.dart';
import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Finder card(String name) =>
      find.ancestor(of: find.text(name), matching: find.byType(CountryCard));

  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  group('grid (FR-EXP-01)', () {
    testWidgets('shows every country in 2 columns on a phone', (tester) async {
      await pumpApp(tester, prefs: returningUser);

      expect(find.text('8 countries'), findsOneWidget);
      // Name order: Antarctica, Belgium | France, Germany | ...
      final antarctica = tester.getTopLeft(card('Antarctica'));
      final belgium = tester.getTopLeft(card('Belgium'));
      final france = tester.getTopLeft(card('France'));
      expect(belgium.dy, antarctica.dy);
      expect(belgium.dx, greaterThan(antarctica.dx));
      expect(france.dy, greaterThan(antarctica.dy));
      expect(france.dx, antarctica.dx);
    });

    testWidgets('shows at least 4 columns in a 1,440 px window (AC-PLT-02)', (
      tester,
    ) async {
      await pumpApp(tester, prefs: returningUser, size: const Size(1440, 900));

      final firstRow = tester.getTopLeft(card('Antarctica')).dy;
      for (final name in ['Belgium', 'France', 'Germany']) {
        expect(tester.getTopLeft(card(name)).dy, firstRow, reason: name);
      }
    });

    testWidgets('shows region names in Arabic', (tester) async {
      await pumpApp(tester, prefs: {...returningUser, 'locale': 'ar'});

      expect(find.text('أوروبا'), findsWidgets);
      expect(find.text('Europe'), findsNothing);
    });

    testWidgets('marks visited and wishlist countries (FR-EXP-02)', (
      tester,
    ) async {
      final app = await pumpApp(tester, prefs: returningUser);
      await app.db.batch((batch) {
        batch.insertAll(app.db.travelEntries, [
          TravelEntriesCompanion.insert(
            countryCode: 'FRA',
            status: TravelStatus.visited,
            createdAt: 1,
            updatedAt: 1,
          ),
          TravelEntriesCompanion.insert(
            countryCode: 'JPN',
            status: TravelStatus.wishlist,
            createdAt: 1,
            updatedAt: 1,
          ),
        ]);
      });
      await tester.pumpAndSettle();

      Finder badge(String name, IconData icon) =>
          find.descendant(of: card(name), matching: find.byIcon(icon));
      expect(badge('France', Icons.check_rounded), findsOneWidget);
      expect(badge('Japan', Icons.bookmark_rounded), findsOneWidget);
      expect(badge('Germany', Icons.check_rounded), findsNothing);
    });
  });

  group('search (FR-EXP-03, FR-EXP-04)', () {
    testWidgets('filters 300 ms after typing stops (AC-EXP-01)', (
      tester,
    ) async {
      await pumpApp(tester, prefs: returningUser);

      await tester.enterText(find.byType(TextField), 'sau');
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('8 countries'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('1 country'), findsOneWidget);
      expect(card('Saudi Arabia'), findsOneWidget);
      expect(card('Belgium'), findsNothing);
    });

    testWidgets('finds Saudi Arabia from سعو in Arabic (AC-EXP-02)', (
      tester,
    ) async {
      await pumpApp(tester, prefs: {...returningUser, 'locale': 'ar'});
      await search(tester, 'سعو');

      expect(find.text('السعودية'), findsOneWidget);
      expect(find.text('دولة واحدة'), findsOneWidget);
    });

    testWidgets('Esc clears the search', (tester) async {
      await pumpApp(tester, prefs: returningUser);
      await search(tester, 'sau');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('8 countries'), findsOneWidget);
    });

    testWidgets('no match shows the empty state, and Clear filters brings '
        'everything back (AC-EXP-04)', (tester) async {
      await pumpApp(tester, prefs: returningUser);
      await search(tester, 'zzz');

      expect(find.text('No countries match.'), findsOneWidget);
      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();

      expect(find.text('8 countries'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '',
      );
    });
  });

  group('filters (FR-EXP-06, FR-EXP-07)', () {
    testWidgets('Europe and French leaves Belgium and France, with a live '
        'count (AC-EXP-03)', (tester) async {
      await pumpApp(tester, prefs: returningUser);

      await tester.tap(find.byTooltip('Filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Europe'));
      await tester.pumpAndSettle();
      expect(find.text('Show 4 countries'), findsOneWidget);

      // Subregions appear once a region is selected.
      expect(find.widgetWithText(FilterChip, 'Western Europe'), findsOneWidget);

      await tester.tap(find.byType(DropdownMenu<String?>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(MenuItemButton, 'French'));
      await tester.pumpAndSettle();
      expect(find.text('Show 2 countries'), findsOneWidget);

      await tester.tap(find.text('Show 2 countries'));
      await tester.pumpAndSettle();
      expect(card('Belgium'), findsOneWidget);
      expect(card('France'), findsOneWidget);
      expect(card('Senegal'), findsNothing);
      expect(find.byTooltip('Filters, 2 active'), findsOneWidget);
    });

    testWidgets('Clear all removes every filter', (tester) async {
      await pumpApp(tester, prefs: returningUser);
      await tester.tap(find.byTooltip('Filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Asia'));
      await tester.pumpAndSettle();
      expect(find.text('Show 2 countries'), findsOneWidget);

      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();
      expect(find.text('Show 8 countries'), findsOneWidget);
    });

    testWidgets('filters stay applied after visiting another tab '
        '(FR-EXP-09, AC-EXP-06)', (tester) async {
      await pumpApp(tester, prefs: returningUser);
      await tester.tap(find.byTooltip('Filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Asia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show 2 countries'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();

      expect(find.text('2 countries'), findsOneWidget);
    });
  });

  testWidgets('sorts by population, high to low (FR-EXP-08)', (tester) async {
    await pumpApp(tester, prefs: returningUser);

    await tester.tap(find.byTooltip('Sort'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Population, high to low'));
    await tester.pumpAndSettle();

    final japan = tester.getTopLeft(card('Japan'));
    final germany = tester.getTopLeft(card('Germany'));
    expect(japan.dy, germany.dy);
    expect(japan.dx, lessThan(germany.dx));
    expect(tester.getTopLeft(card('France')).dy, greaterThan(japan.dy));
  });

  testWidgets('Back from a country keeps the search (AC-PLT-03)', (
    tester,
  ) async {
    await pumpApp(tester, prefs: returningUser);
    await search(tester, 'ja');

    await tester.tap(card('Japan'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Japan'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('1 country'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'ja',
    );
  });

  testWidgets('Tab from the search field moves focus to Filters '
      '(AC-PLT-04)', (tester) async {
    await pumpApp(tester, prefs: returningUser);
    await search(tester, 'a'); // The clear button must not take the focus.

    await tester.tap(find.byType(TextField));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    final filters = find.byIcon(Icons.tune_rounded);
    expect(Focus.of(tester.element(filters)).hasPrimaryFocus, isTrue);
  });

  group('offline and refresh', () {
    testWidgets('offline on a fresh install shows every bundled country with '
        'the banner (FR-EXP-10, AC-EXP-05)', (tester) async {
      final app = await pumpApp(tester, prefs: returningUser, online: false);

      expect(find.text("You're offline. Showing saved data."), findsOneWidget);
      expect(find.text('8 countries'), findsOneWidget);

      app.connectivity.online = true;
      await tester.pumpAndSettle();
      expect(find.text("You're offline. Showing saved data."), findsNothing);
    });

    testWidgets('pull to refresh reports the outcome (FR-EXP-11)', (
      tester,
    ) async {
      final app = await pumpApp(tester, prefs: returningUser);

      await tester.fling(card('Antarctica'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(app.refresher.manualCalls, 1);
      expect(find.text('Data is up to date.'), findsOneWidget);

      app.refresher.manualOutcome = RefreshOutcome.failed;
      await tester.fling(card('Antarctica'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();
      expect(
        find.text("Couldn't refresh. Showing saved data."),
        findsOneWidget,
      );
    });
  });

  group('country details header (FR-DET-01)', () {
    testWidgets('shows the flag, common name, and official name', (
      tester,
    ) async {
      await pumpApp(tester, prefs: returningUser);
      await tester.tap(card('France'));
      await tester.pumpAndSettle();

      expect(find.text('French Republic'), findsOneWidget);
      expect(find.byType(Hero), findsOneWidget);
    });

    testWidgets('shows the Arabic official name in Arabic', (tester) async {
      final app = await pumpApp(tester, prefs: returningUser);
      await app.container
          .read(settingsProvider.notifier)
          .setLanguage(AppLanguage.ar);
      await app.goTo(tester, '/country/SAU');

      expect(find.text('المملكة العربية السعودية'), findsOneWidget);
    });
  });
}
