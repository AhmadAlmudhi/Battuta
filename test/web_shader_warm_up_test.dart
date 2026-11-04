import 'package:battuta/features/countries/presentation/country_details_screen.dart';
import 'package:battuta/features/countries/presentation/widgets/country_card.dart';
import 'package:battuta/web_shader_warm_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

void main() {
  setUp(debugResetWebShaderWarmUp);

  // The warm-up's layer counts as offstage to finders.
  final details = find.byType(CountryDetailsScreen, skipOffstage: false);
  final pickedCard = find.byWidgetPredicate(
    (widget) => widget is CountryCard && widget.selected == true,
    skipOffstage: false,
  );

  Future<TestApp> openExplore(WidgetTester tester) => pumpApp(
    tester,
    prefs: returningUser,
    overrides: [shaderWarmUpEnabledProvider.overrideWithValue(true)],
  );

  /// Pumps in 100 ms steps for up to [seconds], and returns which of
  /// [finders] showed up in any frame, calling [whileShown] in those frames.
  Future<Set<Finder>> watch(
    WidgetTester tester,
    List<Finder> finders, {
    double seconds = 4,
    void Function(Finder shown)? whileShown,
  }) async {
    final seen = <Finder>{};
    for (var t = 0; t < seconds * 10; t++) {
      await tester.pump(const Duration(milliseconds: 100));
      for (final finder in finders) {
        if (finder.evaluate().isEmpty) continue;
        seen.add(finder);
        whileShown?.call(finder);
      }
    }
    return seen;
  }

  testWidgets('once the app is idle, it draws Country details and quick '
      'select cards for a frame each, unseen, then goes away (D-14)', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await openExplore(tester);
    expect(details, findsNothing);

    var checked = false;
    final seen = await watch(
      tester,
      [details, pickedCard],
      whileShown: (shown) {
        if (shown != details) return;
        // It mustn't rename the tab or reach screen readers.
        final titles = [
          for (final title in tester.widgetList<Title>(
            find.byType(Title, skipOffstage: false),
          ))
            title.title,
        ];
        expect(titles, isNot(contains('France · Battuta')));
        expect(
          find.bySemanticsLabel(RegExp('French Republic'), skipOffstage: false),
          findsNothing,
        );
        checked = true;
      },
    );

    expect(seen, {details, pickedCard});
    expect(checked, isTrue);
    // Gone, and it doesn't come back during this visit.
    expect(details, findsNothing);
    expect(pickedCard, findsNothing);
    expect(await watch(tester, [details], seconds: 5), isEmpty);
    semantics.dispose();
  });

  testWidgets('it waits while a finger is on the screen', (tester) async {
    await openExplore(tester);
    // On the logo, where pressing does nothing.
    final finger = await tester.startGesture(const Offset(206, 28));

    expect(await watch(tester, [details]), isEmpty);

    await finger.up();
    expect(await watch(tester, [details]), {details});
  });

  testWidgets('it stays off unless enabled, as everywhere but the web', (
    tester,
  ) async {
    await pumpApp(tester, prefs: returningUser);

    expect(await watch(tester, [details]), isEmpty);
  });
}
