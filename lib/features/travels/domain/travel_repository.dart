import 'travel_entry.dart';

/// Visited and Wishlist entries (PRD sections 6.4 and 8.3). Every change is
/// written to the device first (NFR-05) and bumps `updatedAt` for sync.
abstract interface class TravelRepository {
  /// The status of every saved country, keyed by country code. Soft-deleted
  /// entries are left out. Used for the Explore badges (FR-EXP-02).
  Stream<Map<String, TravelStatus>> watchStatuses();

  /// The entry for one country, or null when it isn't saved.
  Stream<TravelEntry?> watchEntry(String countryCode);

  /// Every saved entry, Visited and Wishlist, for My travels (FR-TRV-05).
  Stream<List<TravelEntry>> watchEntries();

  /// Saves the country as Visited. A wishlist entry becomes Visited and its
  /// wishlist fields are cleared (FR-TRV-03); pass its notes to keep them.
  Future<void> saveVisit(
    String countryCode, {
    DateTime? visitedOn,
    int? rating,
    String notes = '',
  });

  /// Saves the country on the Wishlist (FR-TRV-04).
  Future<void> saveWishlist(
    String countryCode, {
    WishlistPriority priority = WishlistPriority.medium,
    int? targetYear,
    String notes = '',
  });

  /// Soft-deletes the entry so the deletion can sync (FR-SYNC-06), and
  /// returns it for Undo. Null when the country isn't saved.
  Future<TravelEntry?> remove(String countryCode);

  /// Brings back an entry removed by [remove] with the same values. Its
  /// update time moves on, so the restore wins over the deletion in sync.
  Future<void> restore(TravelEntry entry);
}
