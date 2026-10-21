import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/country.dart';
import '../domain/country_repository.dart';
import 'country_api_client.dart';
import 'country_parser.dart';

/// Loads the raw snapshot JSON. In the app this reads the bundled asset.
typedef SnapshotLoader = Future<String> Function();

class CountryRepositoryImpl implements CountryRepository {
  CountryRepositoryImpl(this._db, this._loadSnapshot, [this._api]);

  final AppDatabase _db;
  final SnapshotLoader _loadSnapshot;

  /// Null when the build has no API key; refresh then always fails and the
  /// app keeps the bundled data.
  final CountryApiClient? _api;

  @override
  Future<void> ensureSeeded() async {
    // Data saved before a country was left out still has it (D-12).
    await (_db.delete(
      _db.countries,
    )..where((row) => row.code.isIn(excludedCountryCodes))).go();
    final snapshot = jsonDecode(await _loadSnapshot()) as Map<String, Object?>;
    final bundledAt = snapshot['fetchedAt'] as int;
    final localAt = await dataFetchedAt();
    if (localAt != null && localAt.millisecondsSinceEpoch >= bundledAt) return;

    await _replaceAll(
      _parseAll(snapshot['objects'] as List<Object?>),
      fetchedAt: bundledAt,
    );
  }

  @override
  Future<DateTime?> dataFetchedAt() async {
    final latest = _db.countries.fetchedAt.max();
    final row = await (_db.selectOnly(
      _db.countries,
    )..addColumns([latest])).getSingle();
    final millis = row.read(latest);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  @override
  Future<void> refresh({required DateTime now}) async {
    final api = _api;
    if (api == null) {
      throw const CountryApiException(CountryApiFailure.invalidKey);
    }
    final countries = _parseAll(await api.fetchAll());
    if (countries.isEmpty) {
      throw const CountryApiException(CountryApiFailure.unexpected);
    }
    await _replaceAll(countries, fetchedAt: now.millisecondsSinceEpoch);
  }

  @override
  Stream<List<Country>> watchAll() {
    final query = _db.select(_db.countries)
      ..orderBy([(t) => OrderingTerm.asc(t.nameEn)]);
    return query.watch().map((rows) => rows.map(_toCountry).toList());
  }

  @override
  Future<Country?> findByCode(String code) async {
    final query = _db.select(_db.countries)
      ..where((t) => t.code.equals(code.toUpperCase()));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toCountry(row);
  }

  static List<Country> _parseAll(List<Object?> records) => [
    for (final record in records)
      if (record is Map<String, Object?>) ?parseCountry(record),
  ];

  /// Replaces every country row in one transaction (PRD section 8.2, rule 4).
  Future<void> _replaceAll(List<Country> countries, {required int fetchedAt}) =>
      _db.transaction(() async {
        await _db.delete(_db.countries).go();
        await _db.batch((batch) {
          batch.insertAll(_db.countries, [
            for (final country in countries) _toCompanion(country, fetchedAt),
          ]);
        });
      });

  static CountriesCompanion _toCompanion(Country country, int fetchedAt) =>
      CountriesCompanion.insert(
        code: country.code,
        alpha2: country.alpha2,
        nameEn: country.nameEn,
        nameOfficialEn: country.nameOfficialEn,
        nameAr: Value(country.nameAr),
        nameOfficialAr: Value(country.nameOfficialAr),
        region: country.region,
        subregion: Value(country.subregion),
        capital: Value(country.capital),
        population: country.population,
        areaKm2: Value(country.areaKm2),
        languages: country.languages,
        currencies: country.currencies,
        borders: country.borders,
        timezones: country.timezones,
        mapsUrl: Value(country.mapsUrl),
        flagAlt: Value(country.flagAlt),
        flagColor: Value(country.flagColor),
        fetchedAt: fetchedAt,
      );

  static Country _toCountry(CountryRow row) => Country(
    code: row.code,
    alpha2: row.alpha2,
    nameEn: row.nameEn,
    nameOfficialEn: row.nameOfficialEn,
    nameAr: row.nameAr,
    nameOfficialAr: row.nameOfficialAr,
    region: row.region,
    subregion: row.subregion,
    capital: row.capital,
    population: row.population,
    areaKm2: row.areaKm2,
    languages: row.languages,
    currencies: row.currencies,
    borders: row.borders,
    timezones: row.timezones,
    mapsUrl: row.mapsUrl,
    flagAlt: row.flagAlt,
    flagColor: row.flagColor,
  );
}
