import '../../countries/domain/country.dart';
import '../../countries/domain/search_normalizer.dart';
import 'travel_entry.dart';

/// Order of the Visited tab (FR-TRV-06).
enum VisitedSort { date, name }

/// Order of the Wishlist tab (FR-TRV-06).
enum WishlistSort { priority, name }

/// An entry with its country, as one row in My travels.
class TravelListItem {
  const TravelListItem(this.entry, this.country);

  final TravelEntry entry;
  final Country country;
}

/// Sorting rules for My travels. Names compare after search normalization,
/// so accents and Arabic letter forms don't change the order.
abstract final class TravelListOrder {
  /// Newest visit first, undated visits last; ties by name.
  static List<TravelListItem> visited(
    Iterable<TravelListItem> items,
    VisitedSort sort, {
    required bool arabic,
  }) {
    int byName(TravelListItem a, TravelListItem b) =>
        _nameKey(a, arabic).compareTo(_nameKey(b, arabic));
    return items.toList()..sort(switch (sort) {
      VisitedSort.name => byName,
      VisitedSort.date => (a, b) {
        final x = a.entry.visitedOn, y = b.entry.visitedOn;
        if (x == null || y == null) {
          return x == y ? byName(a, b) : (x == null ? 1 : -1);
        }
        final result = y.compareTo(x);
        return result != 0 ? result : byName(a, b);
      },
    });
  }

  /// High priority first, then the earliest target year (none last); ties
  /// by name.
  static List<TravelListItem> wishlist(
    Iterable<TravelListItem> items,
    WishlistSort sort, {
    required bool arabic,
  }) {
    int byName(TravelListItem a, TravelListItem b) =>
        _nameKey(a, arabic).compareTo(_nameKey(b, arabic));
    return items.toList()..sort(switch (sort) {
      WishlistSort.name => byName,
      WishlistSort.priority => (a, b) {
        final byPriority = _priorityRank(a).compareTo(_priorityRank(b));
        if (byPriority != 0) return byPriority;
        final x = a.entry.targetYear, y = b.entry.targetYear;
        if (x != y) {
          if (x == null) return 1;
          if (y == null) return -1;
          return x.compareTo(y);
        }
        return byName(a, b);
      },
    });
  }

  static int _priorityRank(TravelListItem item) =>
      (item.entry.priority ?? WishlistPriority.medium).index;

  static String _nameKey(TravelListItem item, bool arabic) =>
      normalizeForSearch(item.country.name(arabic: arabic));
}
