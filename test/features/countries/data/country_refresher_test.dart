import 'package:battuta/features/countries/data/country_api_client.dart';
import 'package:battuta/features/countries/data/country_refresher.dart';
import 'package:battuta/features/countries/domain/country.dart';
import 'package:battuta/features/countries/domain/country_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepository implements CountryRepository {
  DateTime? fetchedAt;
  CountryApiException? failWith;
  int refreshCalls = 0;

  @override
  Future<DateTime?> dataFetchedAt() async => fetchedAt;

  @override
  Future<void> refresh({required DateTime now}) async {
    refreshCalls++;
    await Future<void>.delayed(Duration.zero);
    if (failWith case final error?) throw error;
    fetchedAt = now;
  }

  @override
  Future<void> ensureSeeded() async {}

  @override
  Future<Country?> findByCode(String code) async => null;

  @override
  Stream<List<Country>> watchAll() => const Stream.empty();
}

void main() {
  final now = DateTime(2026, 10, 20, 12);
  late _FakeRepository repository;
  late SharedPreferences prefs;
  late bool online;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = _FakeRepository();
    online = true;
  });

  CountryRefresher refresher() => CountryRefresher(
    repository: repository,
    prefs: prefs,
    isOnline: () async => online,
    now: () => now,
  );

  group('refreshIfStale', () {
    test('refreshes data older than 7 days and records the attempt', () async {
      repository.fetchedAt = now.subtract(const Duration(days: 8));

      expect(await refresher().refreshIfStale(), RefreshOutcome.refreshed);
      expect(repository.refreshCalls, 1);
      expect(prefs.getInt('auto_refresh_at'), now.millisecondsSinceEpoch);
    });

    test('leaves fresh data alone', () async {
      repository.fetchedAt = now.subtract(const Duration(days: 2));

      expect(await refresher().refreshIfStale(), RefreshOutcome.upToDate);
      expect(repository.refreshCalls, 0);
    });

    test('does not retry within 7 days of a failed attempt (NFR-13)', () async {
      repository
        ..fetchedAt = now.subtract(const Duration(days: 30))
        ..failWith = const CountryApiException(CountryApiFailure.forbidden);

      expect(await refresher().refreshIfStale(), RefreshOutcome.failed);
      expect(await refresher().refreshIfStale(), RefreshOutcome.upToDate);
      expect(repository.refreshCalls, 1);
    });

    test('waits for a connection without using up the attempt', () async {
      repository.fetchedAt = now.subtract(const Duration(days: 8));
      online = false;

      expect(await refresher().refreshIfStale(), RefreshOutcome.offline);
      expect(repository.refreshCalls, 0);
      expect(prefs.getInt('auto_refresh_at'), isNull);

      online = true;
      expect(await refresher().refreshIfStale(), RefreshOutcome.refreshed);
    });
  });

  group('refreshManually', () {
    test('calls the API, then answers up to date for 60 minutes '
        '(rule 5)', () async {
      final refresher0 = refresher();
      expect(await refresher0.refreshManually(), RefreshOutcome.refreshed);
      expect(await refresher0.refreshManually(), RefreshOutcome.upToDate);
      expect(repository.refreshCalls, 1);
    });

    test('says when the download starts, and not when it answers up to '
        'date', () async {
      final refresher0 = refresher();
      final callsAtStart = <int>[];

      await refresher0.refreshManually(
        onStart: () => callsAtStart.add(repository.refreshCalls),
      );
      await refresher0.refreshManually(onStart: () => callsAtStart.add(-1));

      // Once, just before the API call.
      expect(callsAtStart, [0]);
    });

    test('reports failures and keeps the data', () async {
      repository.failWith = const CountryApiException(
        CountryApiFailure.network,
      );
      expect(await refresher().refreshManually(), RefreshOutcome.failed);
    });

    test('reports offline without calling the API', () async {
      online = false;
      var started = false;
      expect(
        await refresher().refreshManually(onStart: () => started = true),
        RefreshOutcome.offline,
      );
      expect(repository.refreshCalls, 0);
      expect(started, isFalse);
    });
  });

  test('overlapping refreshes share one API call', () async {
    repository.fetchedAt = now.subtract(const Duration(days: 8));
    final refresher0 = refresher();

    final outcomes = await Future.wait([
      refresher0.refreshIfStale(),
      refresher0.refreshManually(),
    ]);

    expect(outcomes, everyElement(RefreshOutcome.refreshed));
    expect(repository.refreshCalls, 1);
  });

  test('joining a download under way counts as its start', () async {
    final refresher0 = refresher();
    var started = 0;

    final outcomes = await Future.wait([
      refresher0.refreshManually(onStart: () => started++),
      refresher0.refreshManually(onStart: () => started++),
    ]);

    expect(outcomes, everyElement(RefreshOutcome.refreshed));
    expect(repository.refreshCalls, 1);
    expect(started, 2);
  });
}
