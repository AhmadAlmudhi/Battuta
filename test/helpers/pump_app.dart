import 'package:battuta/app.dart';
import 'package:battuta/core/database/app_database.dart';
import 'package:battuta/core/database/database_provider.dart';
import 'package:battuta/core/network/connectivity.dart';
import 'package:battuta/core/router/app_router.dart';
import 'package:battuta/features/countries/presentation/country_providers.dart';
import 'package:battuta/features/settings/presentation/settings_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';
import 'test_countries.dart';

/// The app under test, with the real repositories on an in-memory database
/// seeded from [testRecords]. Only the network and connectivity are fake.
class TestApp {
  TestApp._(this.container, this.db, this.connectivity, this.refresher);

  final ProviderContainer container;
  final AppDatabase db;
  final FakeConnectivity connectivity;
  final FakeRefresher refresher;

  Future<void> goTo(WidgetTester tester, String location) async {
    container.read(routerProvider).go(location);
    await tester.pumpAndSettle();
  }
}

Future<TestApp> pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  Size size = const Size(412, 915),
  bool online = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(prefs);
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final connectivity = FakeConnectivity(online: online);
  final refresher = FakeRefresher();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(
        await SharedPreferences.getInstance(),
      ),
      appDatabaseProvider.overrideWithValue(db),
      snapshotLoaderProvider.overrideWithValue(() async => testSnapshotJson()),
      connectivityServiceProvider.overrideWithValue(connectivity),
      countryRefresherProvider.overrideWithValue(refresher),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const BattutaApp()),
  );
  await tester.pumpAndSettle();
  return TestApp._(container, db, connectivity, refresher);
}

/// Saved settings for a returning user, so tests start on Explore.
const returningUser = {'onboarding_done': true};
