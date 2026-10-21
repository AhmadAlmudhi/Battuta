import 'package:battuta/app.dart';
import 'package:battuta/core/clock.dart';
import 'package:battuta/core/database/app_database.dart';
import 'package:battuta/core/database/database_provider.dart';
import 'package:battuta/core/network/connectivity.dart';
import 'package:battuta/core/platform/link_launcher.dart';
import 'package:battuta/core/router/app_router.dart';
import 'package:battuta/features/auth/domain/auth_repository.dart';
import 'package:battuta/features/auth/presentation/auth_providers.dart';
import 'package:battuta/features/countries/presentation/country_providers.dart';
import 'package:battuta/features/settings/presentation/settings_controller.dart';
import 'package:battuta/features/world_map/presentation/world_map_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';
import 'test_countries.dart';
import 'test_world_map.dart';

/// The app under test, with the real repositories on an in-memory database
/// seeded from [testRecords]. Only the network and connectivity are fake.
class TestApp {
  TestApp._(
    this.container,
    this.db,
    this.connectivity,
    this.refresher,
    this.launchedLinks,
    this.auth,
    this.cloud,
  );

  final ProviderContainer container;
  final AppDatabase db;
  final FakeConnectivity connectivity;
  final FakeRefresher refresher;

  /// Links the app asked to open, such as Open in Maps.
  final List<Uri> launchedLinks;

  final FakeAuthRepository auth;
  final FakeCloudEntries cloud;

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
  AuthUser? signedIn,
  FakeCloudEntries? cloud,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(prefs);
  PackageInfo.setMockInitialValues(
    appName: 'battuta',
    packageName: 'battuta',
    version: '0.1.0',
    buildNumber: '1',
    buildSignature: '',
  );
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final connectivity = FakeConnectivity(online: online);
  final refresher = FakeRefresher();
  final launchedLinks = <Uri>[];
  final auth = FakeAuthRepository(signedIn: signedIn);
  final cloudEntries = cloud ?? FakeCloudEntries();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(
        await SharedPreferences.getInstance(),
      ),
      appDatabaseProvider.overrideWithValue(db),
      snapshotLoaderProvider.overrideWithValue(
        () async =>
            testSnapshotJson(fetchedAt: testDataDate.millisecondsSinceEpoch),
      ),
      connectivityServiceProvider.overrideWithValue(connectivity),
      countryRefresherProvider.overrideWithValue(refresher),
      clockProvider.overrideWithValue(() => testNow),
      linkLauncherProvider.overrideWithValue((uri) async {
        launchedLinks.add(uri);
        return true;
      }),
      authRepositoryProvider.overrideWithValue(auth),
      cloudEntriesProvider.overrideWithValue(cloudEntries),
      worldMapLoaderProvider.overrideWithValue(() async => testWorldMap),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const BattutaApp()),
  );
  await tester.pumpAndSettle();
  return TestApp._(
    container,
    db,
    connectivity,
    refresher,
    launchedLinks,
    auth,
    cloudEntries,
  );
}

/// "Now" in widget tests, so date rules don't depend on the day tests run.
final testNow = DateTime(2026, 10, 20, 12);

/// When the test country data was fetched.
final testDataDate = DateTime(2026, 10, 1);

/// Saved settings for a returning user, so tests start on Explore.
const returningUser = {'onboarding_done': true};
