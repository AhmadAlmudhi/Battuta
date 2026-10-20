import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../features/countries/domain/country.dart';
import '../../features/travels/domain/travel_entry.dart';

part 'app_database.g.dart';

/// Local country data (PRD section 8.3). List-shaped values are JSON text.
///
/// This table is a cache of the bundled snapshot or the last refresh, so a
/// schema change can drop and rebuild it.
@DataClassName('CountryRow')
@TableIndex(name: 'countries_region', columns: {#region})
class Countries extends Table {
  TextColumn get code => text()();
  TextColumn get alpha2 => text()();
  TextColumn get nameEn => text()();
  TextColumn get nameOfficialEn => text()();
  TextColumn get nameAr => text().nullable()();
  TextColumn get nameOfficialAr => text().nullable()();
  TextColumn get region => text()();
  TextColumn get subregion => text().nullable()();
  TextColumn get capital => text().nullable()();
  IntColumn get population => integer()();
  RealColumn get areaKm2 => real().named('area_km2').nullable()();
  TextColumn get languages => text().map(const StringListConverter())();
  TextColumn get currencies => text().map(const CurrencyListConverter())();
  TextColumn get borders => text().map(const StringListConverter())();
  TextColumn get timezones => text().map(const StringListConverter())();
  TextColumn get mapsUrl => text().nullable()();
  TextColumn get flagAlt => text().nullable()();
  TextColumn get flagColor => text().nullable()();

  /// Epoch milliseconds: snapshot time or last refresh.
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column> get primaryKey => {code};
}

/// One entry per country, Visited or Wishlist (PRD section 8.3, D-2).
///
/// `country_code` refers to `countries.code`, but without a foreign key
/// constraint so a country refresh can replace all country rows.
@DataClassName('TravelEntryRow')
@TableIndex(name: 'travel_entries_status', columns: {#status})
class TravelEntries extends Table {
  TextColumn get countryCode => text()();
  TextColumn get status => textEnum<TravelStatus>()();

  /// ISO date (YYYY-MM-DD); visited only.
  TextColumn get visitedOn => text().nullable()();
  IntColumn get rating => integer().nullable()();
  TextColumn get priority => textEnum<WishlistPriority>().nullable()();
  IntColumn get targetYear => integer().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();

  /// Epoch milliseconds.
  IntColumn get createdAt => integer()();

  /// Epoch milliseconds; set on every change and used by the merge.
  IntColumn get updatedAt => integer()();

  /// Soft delete, so deletions can sync. Screens never show deleted rows.
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Null or older than [updatedAt] means the entry needs uploading.
  IntColumn get syncedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {countryCode};
}

@DriftDatabase(tables: [Countries, TravelEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  /// 2: removed `search_en` and `search_ar` (search runs in memory) and
  /// added `name_official_ar`.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Rebuilt empty; the next launch imports the bundled snapshot.
        await m.deleteTable(countries.actualTableName);
        await m.createTable(countries);
        await m.createIndex(countriesRegion);
      }
    },
  );

  /// Workaround for drift 2.34.x on web: a transaction's COMMIT is never
  /// flushed to IndexedDB, so its writes live only in memory and are lost when
  /// the browser closes (drift #3864, fixed in 2.35.1). Drift does flush after
  /// any statement outside a transaction, so one runs after the outermost
  /// transaction. Remove once drift is 2.35.1 or newer.
  @override
  Future<T> transaction<T>(
    Future<T> Function() action, {
    bool requireNew = false,
  }) async {
    final result = await super.transaction(action, requireNew: requireNew);
    if (kIsWeb) await customStatement('SELECT 1');
    return result;
  }

  static QueryExecutor _open() => driftDatabase(
    name: 'battuta',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List<Object?>).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

class CurrencyListConverter extends TypeConverter<List<Currency>, String> {
  const CurrencyListConverter();

  @override
  List<Currency> fromSql(String fromDb) => [
    for (final item in jsonDecode(fromDb) as List<Object?>)
      Currency.fromJson(item as Map<String, Object?>),
  ];

  @override
  String toSql(List<Currency> value) =>
      jsonEncode([for (final currency in value) currency.toJson()]);
}
