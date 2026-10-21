import 'dart:math';

import '../../travels/domain/travel_entry.dart';

/// When each part of the reveal runs (FR-MAP-26 to 29), in milliseconds:
/// each visited country fills over 400 ms, 60 ms apart, or closer so that
/// every fill ends within 1.2 seconds; then the wishlist hatching fades in
/// over 300 ms.
class RevealSchedule {
  RevealSchedule(this.fills)
    : gap = fills < 2 ? 0 : min(60, (fillsWithin - fillDuration) / (fills - 1));

  static const fillDuration = 400.0;
  static const fillsWithin = 1200.0;
  static const hatchingDuration = 300.0;

  /// How many countries fill.
  final int fills;

  /// Between the starts of two fills.
  final double gap;

  double get fillsEnd => fills == 0 ? 0 : (fills - 1) * gap + fillDuration;

  /// The whole reveal, at most 1.5 seconds.
  double get duration => fillsEnd + hatchingDuration;

  /// How far the fill at [index] has come at [ms], from 0 to 1, before
  /// easing.
  double fill(int index, double ms) =>
      ((ms - index * gap) / fillDuration).clamp(0.0, 1.0);

  /// How far the hatching has faded in at [ms], from 0 to 1, before easing.
  double hatching(double ms) =>
      ((ms - fillsEnd) / hatchingDuration).clamp(0.0, 1.0);
}

/// Visited countries in the order they fill: oldest visit first, undated
/// visits last (FR-MAP-27). Ties keep the entries' order.
List<String> revealOrder(Iterable<TravelEntry> entries) {
  final visits = [
    for (final entry in entries)
      if (entry.status == TravelStatus.visited) entry,
  ];
  final indexed = [for (final (i, entry) in visits.indexed) (i, entry)];
  indexed.sort((a, b) {
    final (dateA, dateB) = (a.$2.visitedOn, b.$2.visitedOn);
    if (dateA == null || dateB == null) {
      if (dateA != dateB) return dateA == null ? 1 : -1;
      return a.$1.compareTo(b.$1);
    }
    final byDate = dateA.compareTo(dateB);
    return byDate != 0 ? byDate : a.$1.compareTo(b.$1);
  });
  return [for (final (_, entry) in indexed) entry.countryCode];
}
