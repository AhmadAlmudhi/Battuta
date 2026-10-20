import '../../../core/database/app_database.dart';
import '../domain/travel_entry.dart';
import '../domain/travel_repository.dart';

class TravelRepositoryImpl implements TravelRepository {
  TravelRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<Map<String, TravelStatus>> watchStatuses() {
    final entries = _db.travelEntries;
    final query = _db.selectOnly(entries)
      ..addColumns([entries.countryCode, entries.status])
      ..where(entries.isDeleted.equals(false));
    return query.watch().map(
      (rows) => {
        for (final row in rows)
          row.read(entries.countryCode)!: row.readWithConverter(
            entries.status,
          )!,
      },
    );
  }
}
