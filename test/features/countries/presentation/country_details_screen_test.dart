import 'package:battuta/features/countries/presentation/widgets/country_card.dart';
import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:battuta/features/travels/presentation/travel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

/// Tall enough that the whole details screen is built without scrolling.
const _tall = Size(412, 2400);

void main() {
  Future<TestApp> openDetails(
    WidgetTester tester,
    String code, {
    Map<String, Object> prefs = const {},
  }) async {
    final app = await pumpApp(
      tester,
      prefs: {...returningUser, ...prefs},
      size: _tall,
    );
    await app.goTo(tester, '/country/$code');
    return app;
  }

  Finder saveButton() => find.widgetWithText(FilledButton, 'Save');
  bool enabled(Finder button) =>
      widgetOf<FilledButton>(button).onPressed != null;

  group('facts (FR-DET-02)', () {
    testWidgets('formats values for the app language', (tester) async {
      await openDetails(tester, 'FRA');

      expect(find.text('Paris'), findsOneWidget);
      // Region and subregion share the header's tag.
      expect(find.text('Europe · Western Europe'), findsOneWidget);
      // At a glance, with the exact figure under it.
      expect(find.text('68M'), findsOneWidget);
      expect(find.text('68,000,000'), findsOneWidget);
      expect(find.text('552K km²'), findsOneWidget);
      expect(find.text('551,695 km²'), findsOneWidget);
      expect(find.text('French'), findsWidgets);
      expect(find.text('Euro'), findsOneWidget);
    });

    testWidgets('many time zones show as their range, west to east', (
      tester,
    ) async {
      await openDetails(tester, 'FRA');

      expect(find.text('UTC-10:00 – UTC+12:00'), findsOneWidget);
      expect(find.text('4 time zones'), findsOneWidget);
    });

    testWidgets('the official name shows only when it differs', (tester) async {
      await openDetails(tester, 'FRA');
      expect(find.text('French Republic'), findsOneWidget);

      await openDetails(tester, 'JPN');
      // Japan's official name is Japan.
      expect(find.text('Japan'), findsOneWidget);
    });

    testWidgets('a missing value reads Not available', (tester) async {
      await openDetails(tester, 'ATA');

      // No capital, languages, or currencies. The missing subregion is left
      // out of the region tag.
      expect(find.text('Not available'), findsNWidgets(3));
      expect(find.text('Antarctic'), findsOneWidget);
    });

    testWidgets('reads in Arabic, right to left', (tester) async {
      await openDetails(tester, 'FRA', prefs: {'locale': 'ar'});

      expect(find.text('العاصمة'), findsOneWidget);
      expect(find.text('أوروبا · أوروبا الغربية'), findsOneWidget);
      expect(find.text('551,695 كم²'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('العاصمة'))),
        TextDirection.rtl,
      );
    });
  });

  testWidgets('the facts sit beside the header on expanded screens, and '
      'below it on phones (FR-PLT-02)', (tester) async {
    await openDetails(tester, 'FRA');
    expect(
      tester.getTopLeft(find.text('Facts')).dy,
      greaterThan(tester.getBottomLeft(find.text('French Republic')).dy),
    );

    final app = await pumpApp(
      tester,
      prefs: returningUser,
      size: const Size(1280, 900),
    );
    await app.goTo(tester, '/country/FRA');
    expect(
      tester.getTopLeft(find.text('Facts')).dx,
      greaterThan(tester.getTopRight(find.text('French Republic')).dx),
    );
    expect(
      tester.getTopLeft(find.text('Facts')).dy,
      lessThan(tester.getTopLeft(find.text('France')).dy),
    );
  });

  group('neighbors (FR-DET-03)', () {
    testWidgets('an island country has no land borders (AC-DET-03)', (
      tester,
    ) async {
      await openDetails(tester, 'JPN');
      expect(find.text('No land borders'), findsOneWidget);
    });

    testWidgets('a neighbor\'s flag opens that country, and Back returns '
        '(AC-DET-02)', (tester) async {
      await pumpApp(tester, prefs: returningUser, size: _tall);
      await tester.tap(
        find.ancestor(
          of: find.text('France'),
          matching: find.byType(CountryCard),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Spain'));
      await tester.pumpAndSettle();
      expect(appBarOf('Spain'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(appBarOf('France'), findsOneWidget);
    });
  });

  group('visit form (FR-TRV-01, FR-TRV-02)', () {
    testWidgets('Mark as visited, then Save: the stamp lands, the actions '
        'update, and Explore shows the badge (G-2, flow 7.2)', (tester) async {
      final haptics = <String?>[];
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments as String?);
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      final app = await openDetails(tester, 'FRA');

      await tester.tap(find.text('Mark as visited'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('4 of 5 stars'));
      await tester.pump();
      // The chosen rating gets its word.
      expect(find.text('Great'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Paris in spring');
      await tester.tap(saveButton());
      await tester.pumpAndSettle();

      expect(find.text('VISITED'), findsOneWidget);
      expect(find.text('Visited'), findsOneWidget);
      expect(find.byTooltip('Edit'), findsOneWidget);
      expect(find.byTooltip('Remove'), findsOneWidget);
      expect(find.text('Paris in spring'), findsOneWidget);
      expect(haptics, ['HapticFeedbackType.lightImpact']);

      final entry = app.container.read(travelEntryProvider('FRA')).valueOrNull;
      expect(entry?.rating, 4);
      expect(entry?.status, TravelStatus.visited);

      await app.goTo(tester, '/explore');
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('France'),
            matching: find.byType(CountryCard),
          ),
          matching: find.byIcon(Icons.check_rounded),
        ),
        findsOneWidget,
      );
    });

    testWidgets("tomorrow's date disables Save with the rule (AC-TRV-01)", (
      tester,
    ) async {
      await openDetails(tester, 'FRA');
      await tester.tap(find.text('Mark as visited'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pick a date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('21')); // testNow is 20 October 2026.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // The picked date shows on the chip.
      expect(find.text('October 21, 2026'), findsOneWidget);
      expect(find.text("Visit date can't be in the future."), findsOneWidget);
      expect(enabled(saveButton()), isFalse);

      await tester.tap(find.text('Clear date'));
      await tester.pumpAndSettle();
      expect(enabled(saveButton()), isTrue);
    });

    testWidgets('notes over 500 characters block Save (PRD 8.6)', (
      tester,
    ) async {
      await openDetails(tester, 'FRA');
      await tester.tap(find.text('Mark as visited'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'a' * 501);
      await tester.pump();

      expect(find.text('Notes can be up to 500 characters.'), findsOneWidget);
      expect(enabled(saveButton()), isFalse);
    });

    testWidgets('the notes count shows only near the limit', (tester) async {
      await openDetails(tester, 'FRA');
      await tester.tap(find.text('Mark as visited'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'a' * 399);
      await tester.pump();
      expect(find.text('399/500'), findsNothing);

      await tester.enterText(find.byType(TextField), 'a' * 450);
      await tester.pump();
      expect(find.text('450/500'), findsOneWidget);
    });

    testWidgets('Close saves nothing', (tester) async {
      final app = await openDetails(tester, 'FRA');
      await tester.tap(find.text('Mark as visited'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(
        app.container.read(travelEntryProvider('FRA')).valueOrNull,
        isNull,
      );
      expect(find.text('Mark as visited'), findsOneWidget);
    });
  });

  group('wishlist (FR-TRV-03, FR-TRV-04)', () {
    testWidgets('Add to wishlist with a priority and target year', (
      tester,
    ) async {
      await openDetails(tester, 'JPN');

      final semantics = tester.ensureSemantics();
      await tester.tap(find.text('Add to wishlist'));
      await tester.pumpAndSettle();
      // Medium and Any time to begin with.
      expect(
        tester.getSemantics(find.text('Medium')),
        isSemantics(isSelected: true),
      );
      expect(
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Any time')),
        isA<ChoiceChip>().having((chip) => chip.selected, 'selected', isTrue),
      );
      await tester.tap(find.text('High'));
      await tester.tap(find.widgetWithText(ChoiceChip, '2027'));
      await tester.pump();
      expect(
        tester.getSemantics(find.text('High')),
        isSemantics(isSelected: true),
      );
      await tester.tap(saveButton());
      await tester.pumpAndSettle();

      expect(find.text('On your wishlist'), findsOneWidget);
      expect(find.text('High priority · Target year 2027'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('marking a wishlist country as visited keeps its notes '
        '(AC-TRV-02)', (tester) async {
      final app = await openDetails(tester, 'JPN');
      await app.container
          .read(travelRepositoryProvider)
          .saveWishlist('JPN', notes: 'See the cherry blossoms');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mark as visited'));
      await tester.pumpAndSettle();
      expect(find.text('See the cherry blossoms'), findsWidgets);
      await tester.tap(saveButton());
      await tester.pumpAndSettle();

      expect(find.text('Visited'), findsOneWidget);
      expect(find.text('See the cherry blossoms'), findsOneWidget);
    });
  });

  group('remove', () {
    testWidgets('Undo within 4 seconds brings the entry back unchanged '
        '(FR-TRV-07, AC-TRV-03)', (tester) async {
      final app = await openDetails(tester, 'FRA');
      final repo = app.container.read(travelRepositoryProvider);
      await repo.saveVisit('FRA', rating: 5, notes: 'Lovely');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Remove'));
      await tester.pumpAndSettle();
      expect(find.text('Mark as visited'), findsOneWidget);
      expect(find.text('France removed.'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Lovely'), findsOneWidget);
      final entry = app.container.read(travelEntryProvider('FRA')).valueOrNull;
      expect(entry?.rating, 5);
    });

    testWidgets('the Undo message closes by itself after 4 seconds', (
      tester,
    ) async {
      final app = await openDetails(tester, 'FRA');
      await app.container.read(travelRepositoryProvider).saveVisit('FRA');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Remove'));
      await tester.pumpAndSettle();
      expect(find.text('France removed.'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('France removed.'), findsNothing);
    });
  });

  group('Open in Maps (FR-DET-05)', () {
    testWidgets('opens the map link', (tester) async {
      final app = await openDetails(tester, 'FRA');

      await tester.tap(find.text('Open in Maps'));
      await tester.pumpAndSettle();

      expect(app.launchedLinks, [Uri.parse('https://goo.gl/maps/france')]);
    });

    testWidgets('is disabled while offline', (tester) async {
      final app = await openDetails(tester, 'FRA');
      app.connectivity.online = false;
      await tester.pumpAndSettle();

      final button = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text('Open in Maps'),
          matching: find.bySubtype<ButtonStyleButton>(),
        ),
      );
      expect(button.onPressed, isNull);
      expect(find.text('Maps needs a connection.'), findsOneWidget);
    });

    testWidgets('is hidden when the country has no map link', (tester) async {
      await openDetails(tester, 'JPN');
      expect(find.text('Open in Maps'), findsNothing);
    });
  });
}

/// The single widget [finder] matches.
T widgetOf<T extends Widget>(Finder finder) =>
    finder.evaluate().single.widget as T;
