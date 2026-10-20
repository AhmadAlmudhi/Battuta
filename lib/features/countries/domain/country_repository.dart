import 'country.dart';

abstract interface class CountryRepository {
  /// Imports the bundled snapshot when the local database has no countries
  /// yet (PRD section 8.2, rule 2). Makes no API call.
  Future<void> ensureSeeded();

  /// All countries, sorted by English name. Emits again after a refresh.
  Stream<List<Country>> watchAll();

  Future<Country?> findByCode(String code);
}
