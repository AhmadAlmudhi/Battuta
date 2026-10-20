import 'package:freezed_annotation/freezed_annotation.dart';

import '../../travels/domain/travel_entry.dart';

part 'sync_entry.freezed.dart';

/// A travel entry as it is synced: every stored field, including the soft
/// delete flag, with times as epoch milliseconds so local and cloud copies
/// compare exactly (PRD sections 8.3 and 8.4).
@freezed
abstract class SyncEntry with _$SyncEntry {
  const factory SyncEntry({
    required String countryCode,
    required TravelStatus status,

    /// ISO date (YYYY-MM-DD), exactly as stored.
    String? visitedOn,
    int? rating,
    WishlistPriority? priority,
    int? targetYear,
    @Default('') String notes,
    required int createdAt,
    required int updatedAt,
    @Default(false) bool isDeleted,
  }) = _SyncEntry;
}

/// Conflict rules for sync (PRD section 7.3, D-6).
abstract final class SyncRules {
  /// Whether a cloud copy replaces the local one: always when there is no
  /// local copy, otherwise when it is newer or equally new. On equal times
  /// the cloud wins, so every device settles on the same value. A newer
  /// deletion wins over an older edit like any other change.
  static bool cloudWins({
    required SyncEntry? local,
    required SyncEntry cloud,
  }) => local == null || cloud.updatedAt >= local.updatedAt;
}
