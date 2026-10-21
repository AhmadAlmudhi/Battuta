import 'dart:io';

import 'package:battuta/core/database/app_database.dart';
import 'package:battuta/features/countries/data/country_api_client.dart';
import 'package:battuta/features/countries/data/country_repository_impl.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_countries.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = inMemoryDatabase());
  tearDown(() => db.close());

  CountryRepositoryImpl repository({
    int bundledAt = 1,
    CountryApiClient? api,
  }) => CountryRepositoryImpl(
    db,
    () async => testSnapshotJson(fetchedAt: bundledAt),
    api,
  );

  group('ensureSeeded', () {
    test(
      'imports the real bundled snapshot: 253 records, 249 countries',
      () async {
        final repo = CountryRepositoryImpl(
          db,
          () => File('assets/data/countries_snapshot.json').readAsString(),
        );

        await repo.ensureSeeded();
        final countries = await repo.watchAll().first;

        // 4 disputed territories have no ISO codes and are skipped (D-3).
        // Israel is left out of the snapshot and the app (D-12).
        expect(countries, hasLength(249));
        expect(await repo.findByCode('ISR'), isNull);
        expect((await repo.findByCode('PSE'))?.borders, isNot(contains('ISR')));
        expect(
          countries.map((c) => c.nameEn).toList(),
          orderedEquals([...countries.map((c) => c.nameEn)]..sort()),
        );
        final saudi = await repo.findByCode('sau');
        expect(saudi?.nameAr, isNotNull);
        expect(saudi?.nameOfficialAr, isNotNull);
        expect((await repo.findByCode('JPN'))?.borders, isEmpty);
      },
    );

    test('imports once and leaves existing data alone', () async {
      await repository(bundledAt: 100).ensureSeeded();
      await db
          .update(db.countries)
          .write(const CountriesCompanion(population: Value(42)));

      await repository(bundledAt: 100).ensureSeeded();

      final row = await (db.select(
        db.countries,
      )..where((t) => t.code.equals('FRA'))).getSingle();
      expect(row.population, 42);
    });

    test(
      'removes a country left out after the data was saved (D-12)',
      () async {
        await repository(bundledAt: 100).ensureSeeded();
        await db
            .into(db.countries)
            .insert(
              CountriesCompanion.insert(
                code: 'ISR',
                alpha2: 'il',
                nameEn: 'Israel',
                nameOfficialEn: 'State of Israel',
                region: 'Asia',
                population: 1,
                languages: const [],
                currencies: const [],
                borders: const [],
                timezones: const [],
                fetchedAt: 100,
              ),
            );

        await repository(bundledAt: 100).ensureSeeded();

        expect(await repository().findByCode('ISR'), isNull);
        expect(
          await db.select(db.countries).get(),
          hasLength(testRecords.length),
        );
      },
    );

    test('replaces older local data with a newer bundled snapshot, as after '
        'a redeploy (PRD 8.2, rule 7)', () async {
      await repository(bundledAt: 100).ensureSeeded();
      await db
          .update(db.countries)
          .write(const CountriesCompanion(population: Value(42)));

      await repository(bundledAt: 200).ensureSeeded();

      final rows = await db.select(db.countries).get();
      expect(rows.every((row) => row.population != 42), isTrue);
      expect(rows.every((row) => row.fetchedAt == 200), isTrue);
    });

    test(
      'keeps refreshed data that is newer than the bundled snapshot',
      () async {
        await repository(bundledAt: 100).ensureSeeded();
        await db
            .update(db.countries)
            .write(
              const CountriesCompanion(
                population: Value(42),
                fetchedAt: Value(500),
              ),
            );

        await repository(bundledAt: 200).ensureSeeded();

        final rows = await db.select(db.countries).get();
        expect(rows.every((row) => row.population == 42), isTrue);
      },
    );
  });

  group('refresh', () {
    test('replaces all countries with API data and records the time', () async {
      final api = fakeApiClient(
        (_) => apiPage([testRecords.first], total: 1, more: false),
      );
      final repo = repository(api: api);
      await repo.ensureSeeded();

      final now = DateTime(2026, 10, 20, 12);
      await repo.refresh(now: now);

      final countries = await repo.watchAll().first;
      expect(countries.map((c) => c.code), ['FRA']);
      expect(await repo.dataFetchedAt(), now);
    });

    test('a failed page keeps the previous data (rule 4)', () async {
      final api = fakeApiClient(
        (request) => request.queryParameters['offset'] == '0'
            ? apiPage([testRecords.first], total: 300, more: true)
            : (status: 500, body: null),
      );
      final repo = repository(api: api);
      await repo.ensureSeeded();

      await expectLater(
        repo.refresh(now: DateTime(2026)),
        throwsA(isA<CountryApiException>()),
      );
      expect(await repo.watchAll().first, hasLength(testRecords.length));
      expect(
        await repo.dataFetchedAt(),
        DateTime.fromMillisecondsSinceEpoch(1),
      );
    });

    test('fails without an API key and keeps the data', () async {
      final repo = repository();
      await repo.ensureSeeded();

      await expectLater(
        repo.refresh(now: DateTime(2026)),
        throwsA(
          isA<CountryApiException>().having(
            (e) => e.failure,
            'failure',
            CountryApiFailure.invalidKey,
          ),
        ),
      );
      expect(await repo.watchAll().first, hasLength(testRecords.length));
    });
  });

  test('dataFetchedAt is null before the first import', () async {
    expect(await repository().dataFetchedAt(), isNull);
  });

  test('findByCode returns null for an unknown code', () async {
    final repo = repository();
    await repo.ensureSeeded();
    expect(await repo.findByCode('XYZ'), isNull);
  });

  test('upgrading from schema 1 rebuilds countries and keeps travel '
      'entries', () async {
    final legacy = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) {
          raw.execute('''
            CREATE TABLE countries (
              code TEXT NOT NULL PRIMARY KEY, alpha2 TEXT NOT NULL,
              name_en TEXT NOT NULL, name_official_en TEXT NOT NULL,
              name_ar TEXT NULL, search_en TEXT NOT NULL, search_ar TEXT NULL,
              region TEXT NOT NULL, subregion TEXT NULL, capital TEXT NULL,
              population INTEGER NOT NULL, area_km2 REAL NULL,
              languages TEXT NOT NULL, currencies TEXT NOT NULL,
              borders TEXT NOT NULL, timezones TEXT NOT NULL,
              maps_url TEXT NULL, flag_alt TEXT NULL, flag_color TEXT NULL,
              fetched_at INTEGER NOT NULL)''');
          raw.execute('CREATE INDEX countries_region ON countries (region)');
          raw.execute(
            '''
            CREATE TABLE travel_entries (
              country_code TEXT NOT NULL PRIMARY KEY, status TEXT NOT NULL,
              visited_on TEXT NULL, rating INTEGER NULL, priority TEXT NULL,
              target_year INTEGER NULL, notes TEXT NOT NULL DEFAULT '',
              created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL,
              is_deleted INTEGER NOT NULL DEFAULT 0, synced_at INTEGER NULL)''',
          );
          raw.execute(
            "INSERT INTO countries VALUES ('FRA', 'fr', 'France', 'France', "
            "NULL, 'france', NULL, 'Europe', NULL, NULL, 1, NULL, '[]', "
            "'[]', '[]', '[]', NULL, NULL, NULL, 1)",
          );
          raw.execute(
            "INSERT INTO travel_entries (country_code, status, created_at, "
            "updated_at) VALUES ('FRA', 'visited', 1, 1)",
          );
          raw.execute('PRAGMA user_version = 1');
        },
      ),
    );
    addTearDown(legacy.close);

    expect(await legacy.select(legacy.countries).get(), isEmpty);
    final entries = await legacy.select(legacy.travelEntries).get();
    expect(entries.single.countryCode, 'FRA');

    final repo = CountryRepositoryImpl(legacy, () async => testSnapshotJson());
    await repo.ensureSeeded();
    expect(await repo.watchAll().first, hasLength(testRecords.length));
  });
}
