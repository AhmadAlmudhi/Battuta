import 'package:battuta/features/countries/presentation/widgets/flag_image.dart';
import 'package:battuta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_countries.dart';

void main() {
  testWidgets('a flying flag opens from the card\'s circle into its framed '
      'shape, and closes back (PRD 10.2)', (tester) async {
    final japan = testCountries.singleWhere((c) => c.code == 'JPN');
    final progress = AnimationController(vsync: const TestVSync());
    addTearDown(progress.dispose);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(
          child: SizedBox(
            width: 300,
            height: 200,
            child: FlagFlight(country: japan, progress: progress),
          ),
        ),
      ),
    );
    ClipRRect clip() => tester.widget(find.byType(ClipRRect));
    Size shape() => tester.getSize(find.byType(ClipRRect));

    // On the card: a circle as wide as the space is tall.
    expect(shape(), const Size(200, 200));
    expect(clip().borderRadius, BorderRadius.circular(100));

    // Halfway: between the two.
    progress.value = 0.5;
    await tester.pump();
    expect(shape(), const Size(250, 200));

    // On Country details: the 3:2 flag fills the space with FramedFlag's
    // corners.
    progress.value = 1;
    await tester.pump();
    expect(shape(), const Size(300, 200));
    expect(clip().borderRadius, BorderRadius.circular(10));

    progress.value = 0;
    await tester.pump();
    expect(shape(), const Size(200, 200));
  });
}
