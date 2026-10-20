import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/country.dart';
import '../domain/country_repository.dart';
import '../domain/search_normalizer.dart';
import 'country_parser.dart';

/// Loads the raw snapshot JSON. In the app this reads the bundled asset.
typedef SnapshotLoader = Future<String> Function();

class CountryRepositoryImpl implements CountryRepository {
  CountryRepositoryImpl(this._db, this._loadSnapshot);

  final AppDatabase _db;
  final SnapshotLoader _loadSnapshot;

  @override
  Future<void> ensureSeeded() async {
    final count = await _db.countries.count().getSingle();
    if (count > 0) return;

    final snapshot = jsonDecode(await _loadSnapshot()) as Map<String, Object?>;
    final fetchedAt = snapshot['fetchedAt'] as int;
    final countries = [
      for (final object in snapshot['objects'] as List<Object?>)
        ?parseCountry(object as Map<String, Object?>),
    ];
    await replaceAll(countries, fetchedAt: fetchedAt);
  }

  /// Replaces every country row in one transaction (PRD section 8.2, rule 4).
  Future<void> replaceAll(List<Country> countries, {required int fetchedAt}) =>
      _db.transaction(() async {
        await _db.delete(_db.countries).go();
        await _db.batch((batch) {
          batch.insertAll(_db.countries, [
            for (final country in countries) _toCompanion(country, fetchedAt),
          ]);
        });
      });

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

  static CountriesCompanion _toCompanion(Country country, int fetchedAt) =>
      CountriesCompanion.insert(
        code: country.code,
        alpha2: country.alpha2,
        nameEn: country.nameEn,
        nameOfficialEn: country.nameOfficialEn,
        nameAr: Value(country.nameAr),
        // One normalized name per line, so ranking can check each name's start.
        searchEn: [
          country.nameEn,
          country.nameOfficialEn,
        ].map(normalizeForSearch).join('\n'),
        searchAr: Value(
          country.nameAr == null ? null : normalizeForSearch(country.nameAr!),
        ),
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
