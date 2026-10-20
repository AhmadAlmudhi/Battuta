import 'package:freezed_annotation/freezed_annotation.dart';

part 'travel_entry.freezed.dart';

/// Stored as text in `travel_entries.status` and in Firestore.
enum TravelStatus { visited, wishlist }

/// Stored as text in `travel_entries.priority` and in Firestore.
enum WishlistPriority { high, medium, low }

/// A user's record for one country, Visited or Wishlist (D-2). Deleted
/// entries never appear here; the repository hides them.
@freezed
abstract class TravelEntry with _$TravelEntry {
  const factory TravelEntry({
    required String countryCode,
    required TravelStatus status,

    /// Date only; visited only.
    DateTime? visitedOn,

    /// 1 to 5; visited only.
    int? rating,

    /// Wishlist only.
    WishlistPriority? priority,

    /// Wishlist only.
    int? targetYear,
    @Default('') String notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TravelEntry;
}
