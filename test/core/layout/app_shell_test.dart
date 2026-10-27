import 'package:battuta/core/layout/app_shell.dart';
import 'package:battuta/features/countries/presentation/widgets/country_card.dart';
import 'package:battuta/features/settings/domain/app_settings.dart';
import 'package:battuta/features/settings/presentation/settings_controller.dart';
import 'package:battuta/features/travels/presentation/travel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  final bar = find.byType(FloatingNavBar);

  /// The top edge of the bar's pill.
  double barTop(WidgetTester tester) => tester
      .getTopLeft(find.descendant(of: bar, matching: find.byType(Material)))
      .dy;

  /// The sliding highlight behind the selected tab.
  Rect highlight(WidgetTester tester) => tester.getRect(
    find.descendant(
      of: bar,
      matching: find.byType(AnimatedPositionedDirectional),
    ),
  );

  testWidgets('the bar floats above the bottom edge, and its highlight slides '
      'to the selected tab', (tester) async {
    await pumpApp(tester, prefs: returningUser);

    final pill = tester.getRect(
      find.descendant(of: bar, matching: find.byType(Material)),
    );
    expect(pill.bottom, 915 - 12);
    expect(pill.left, 16);
    expect(
      highlight(tester).center.dx,
      moreOrLessEquals(tester.getCenter(find.text('Explore')).dx, epsilon: 1),
    );

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(
      highlight(tester).center.dx,
      moreOrLessEquals(tester.getCenter(find.text('Stats')).dx, epsilon: 1),
    );
  });

  testWidgets('the tabs and the highlight mirror in Arabic', (tester) async {
    final app = await pumpApp(tester, prefs: returningUser);
    await app.container
        .read(settingsProvider.notifier)
        .setLanguage(AppLanguage.ar);
    await tester.pumpAndSettle();

    final explore = tester.getCenter(find.text('استكشف'));
    expect(
      explore.dx,
      greaterThan(tester.getCenter(find.text('الإحصاءات')).dx),
    );
    expect(
      highlight(tester).center.dx,
      moreOrLessEquals(explore.dx, epsilon: 1),
    );
  });

  testWidgets('pages scroll behind the bar, and their last items scroll clear '
      'of it', (tester) async {
    await pumpApp(tester, prefs: returningUser);

    await tester.drag(find.byType(GridView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    final cards = find.byType(CountryCard);
    final lastBottom = tester.getBottomLeft(cards.last).dy;
    expect(lastBottom, lessThanOrEqualTo(barTop(tester)));
    // The grid itself reaches under the bar.
    expect(
      tester.getBottomLeft(find.byType(GridView)).dy,
      greaterThan(barTop(tester)),
    );
  });

  testWidgets('the Undo snack bar floats above the bar', (tester) async {
    final app = await pumpApp(tester, prefs: returningUser);
    await app.container.read(travelRepositoryProvider).saveVisit('FRA');
    await app.goTo(tester, '/travels');

    await tester.tap(find.byTooltip('Options for France'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    final snackBar = tester.getRect(find.byType(SnackBar));
    expect(snackBar.bottom, lessThanOrEqualTo(barTop(tester)));
    expect(find.text('Undo'), findsOneWidget);
  });
}
