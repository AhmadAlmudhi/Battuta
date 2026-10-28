import 'package:battuta/core/database/app_database.dart';
import 'package:battuta/core/layout/app_shell.dart';
import 'package:battuta/features/countries/presentation/widgets/country_card.dart';
import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:battuta/features/travels/presentation/travel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Finder card(String name) =>
      find.ancestor(of: find.text(name), matching: find.byType(CountryCard));

  /// The statuses Explore watches for its badges.
  Map<String, TravelStatus> statuses(TestApp app) =>
      app.container.read(travelStatusesProvider).valueOrNull ?? const {};

  Future<TravelEntryRow> row(TestApp app, String code) => (app.db.select(
    app.db.travelEntries,
  )..where((t) => t.countryCode.equals(code))).getSingle();

  Future<TestApp> openExplore(WidgetTester tester) async {
    final app = await pumpApp(tester, prefs: returningUser);
    final repo = app.container.read(travelRepositoryProvider);
    await repo.saveWishlist('JPN', notes: 'Kyoto in autumn');
    await repo.saveVisit('DEU');
    await tester.pumpAndSettle();
    return app;
  }

  testWidgets('Select picks countries, Mark as visited saves them all and '
      'keeps wishlist notes, and Undo puts them back (FR-EXP-13)', (
    tester,
  ) async {
    final app = await openExplore(tester);

    await tester.tap(find.byTooltip('Select countries'));
    await tester.pumpAndSettle();
    expect(find.text("Tap the countries you've visited"), findsOneWidget);
    final mark = find.widgetWithText(FilledButton, 'Mark as visited');
    expect(tester.widget<FilledButton>(mark).onPressed, isNull);

    await tester.tap(card('France'));
    await tester.tap(card('Japan'));
    // Germany is already visited, so it can't be picked.
    await tester.tap(card('Germany'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(mark);
    await tester.pumpAndSettle();
    expect(find.text('2 countries marked as visited.'), findsOneWidget);
    expect(find.text('2 selected'), findsNothing);
    expect(statuses(app), {
      'FRA': TravelStatus.visited,
      'JPN': TravelStatus.visited,
      'DEU': TravelStatus.visited,
    });
    expect((await row(app, 'JPN')).notes, 'Kyoto in autumn');

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(statuses(app), {
      'JPN': TravelStatus.wishlist,
      'DEU': TravelStatus.visited,
    });
  });

  testWidgets('a long press starts selecting with that card picked, and Esc '
      'or Back stops it without leaving Explore', (tester) async {
    await openExplore(tester);

    await tester.longPress(card('France'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsNothing);

    await tester.longPress(card('Spain'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsNothing);
    expect(appBarOf('Explore'), findsOneWidget);
  });

  testWidgets('picks stay while the search changes', (tester) async {
    await openExplore(tester);
    await tester.tap(find.byTooltip('Select countries'));
    await tester.pumpAndSettle();
    await tester.tap(card('France'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'spa');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    await tester.tap(card('Spain'));
    await tester.pumpAndSettle();

    expect(find.text('2 selected'), findsOneWidget);
  });

  testWidgets('the bar floats above the tab bar, and a picked card reads as '
      'checked', (tester) async {
    final semantics = tester.ensureSemantics();
    await openExplore(tester);
    await tester.tap(find.byTooltip('Select countries'));
    await tester.pumpAndSettle();
    await tester.tap(card('France'));
    await tester.pumpAndSettle();

    final bar = tester.getRect(
      find.ancestor(of: find.text('1 selected'), matching: find.byType(Row)),
    );
    final tabBar = tester.getRect(
      find.descendant(
        of: find.byType(FloatingNavBar),
        matching: find.byType(Material),
      ),
    );
    expect(bar.bottom, lessThan(tabBar.top));
    expect(
      tester.getSemantics(card('France')),
      isSemantics(isChecked: true, hasCheckedState: true),
    );
    semantics.dispose();
  });
}
