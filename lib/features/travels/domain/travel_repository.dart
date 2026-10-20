import 'travel_entry.dart';

abstract interface class TravelRepository {
  /// The status of every saved country, keyed by country code. Soft-deleted
  /// entries are left out. Used for the Explore badges (FR-EXP-02).
  Stream<Map<String, TravelStatus>> watchStatuses();
}
