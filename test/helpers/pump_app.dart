import 'package:battuta/app.dart';
import 'package:battuta/core/router/app_router.dart';
import 'package:battuta/features/countries/domain/country.dart';
import 'package:battuta/features/countries/presentation/country_providers.dart';
import 'package:battuta/features/settings/presentation/settings_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const testCountries = [
  Country(
    code: 'FRA',
    alpha2: 'fr',
    nameEn: 'France',
    nameOfficialEn: 'French Republic',
    nameAr: 'فرنسا',
    region: 'Europe',
    population: 68000000,
  ),
  Country(
    code: 'JPN',
    alpha2: 'jp',
    nameEn: 'Japan',
    nameOfficialEn: 'Japan',
    nameAr: 'اليابان',
    region: 'Asia',
    population: 124000000,
  ),
];

/// Pumps the full app with fake country data and the given saved settings.
/// Returns the container so tests can navigate and read state.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  Size size = const Size(400, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(prefs);
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(
        await SharedPreferences.getInstance(),
      ),
      countriesSeededProvider.overrideWith((ref) async {}),
      countriesProvider.overrideWith((ref) => Stream.value(testCountries)),
      countryByCodeProvider.overrideWith(
        (ref, code) async =>
            testCountries.where((c) => c.code == code).firstOrNull,
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const BattutaApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

extension AppNavigation on ProviderContainer {
  Future<void> goTo(WidgetTester tester, String location) async {
    read(routerProvider).go(location);
    await tester.pumpAndSettle();
  }
}
