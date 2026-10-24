import 'package:battuta/features/settings/presentation/about_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<TestApp> openSettings(WidgetTester tester) async {
    final app = await pumpApp(
      tester,
      prefs: returningUser,
      size: const Size(412, 1400),
    );
    await app.goTo(tester, '/settings');
    return app;
  }

  testWidgets('About shows the version, the data date, and the sources of '
      'the country data and the map (FR-SET-04)', (tester) async {
    await openSettings(tester);

    expect(find.text('0.1.0 (1)'), findsOneWidget);
    expect(find.text('Updated October 1, 2026'), findsOneWidget);
    expect(
      find.text('Country data and flags from REST Countries'),
      findsOneWidget,
    );
    expect(
      find.text(
        'World map from Natural Earth. Disputed borders are shown as Saudi '
        'Arabia recognizes them.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the data source opens restcountries.com', (tester) async {
    final app = await openSettings(tester);

    await tester.tap(find.text('Data source'));
    await tester.pumpAndSettle();

    expect(app.launchedLinks, [Uri.parse('https://restcountries.com')]);
  });

  testWidgets('the map data opens naturalearthdata.com', (tester) async {
    final app = await openSettings(tester);

    await tester.tap(find.text('Map data'));
    await tester.pumpAndSettle();

    expect(app.launchedLinks, [Uri.parse('https://www.naturalearthdata.com')]);
  });

  testWidgets('Open-source licenses opens the licenses page', (tester) async {
    await openSettings(tester);

    await tester.tap(find.text('Open-source licenses'));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('About reads in Arabic', (tester) async {
    final app = await pumpApp(
      tester,
      prefs: {...returningUser, 'locale': 'ar'},
      size: const Size(412, 1400),
    );
    await app.goTo(tester, '/settings');

    expect(find.text('حول التطبيق'), findsOneWidget);
    expect(find.text('حُدّثت في 1 أكتوبر 2026'), findsOneWidget);
    expect(find.text('بيانات الخريطة'), findsOneWidget);
  });

  test('the font\'s license is registered', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    addTearDown(LicenseRegistry.reset);
    registerFontLicenses();

    final packages = {
      for (final entry in await LicenseRegistry.licenses.toList())
        ...entry.packages,
    };

    expect(packages, contains('Alexandria'));
  });
}
