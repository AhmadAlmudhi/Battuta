import 'country.dart';

abstract interface class CountryRepository {
  /// Imports the bundled snapshot when the local database is empty or holds
  /// older data than the snapshot, as after a redeploy (PRD section 8.2,
  /// rules 2 and 7). Makes no API call.
  Future<void> ensureSeeded();

  /// All countries, sorted by English name. Emits again after a refresh.
  Stream<List<Country>> watchAll();

  Future<Country?> findByCode(String code);

  /// When the local data was fetched: the snapshot time or the last refresh.
  /// Null before the first import.
  Future<DateTime?> dataFetchedAt();

  /// Replaces all countries with fresh API data in one transaction, or
  /// throws and keeps the current data (rule 4).
  Future<void> refresh({required DateTime now});
}
