import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/travel_entry.dart';

/// A wishlist entry's priority and target year, for example
/// High priority · Target year 2027.
String wishlistSummary(AppLocalizations l10n, TravelEntry entry) => [
  switch (entry.priority ?? WishlistPriority.medium) {
    WishlistPriority.high => l10n.priorityHigh,
    WishlistPriority.medium => l10n.priorityMedium,
    WishlistPriority.low => l10n.priorityLow,
  },
  if (entry.targetYear != null) l10n.detailsTargetYear('${entry.targetYear}'),
].join(' · ');

/// 1 to 5 stars, read out as "4 of 5 stars". Filled stars keep a dark
/// outline, since amber alone is too faint on light surfaces (PRD 1.4).
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 20});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.onSurfaceVariant;
    return Semantics(
      label: AppLocalizations.of(context).detailsRating(rating),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var star = 1; star <= 5; star++)
              Stack(
                children: [
                  if (star <= rating)
                    Icon(
                      Icons.star_rounded,
                      size: size,
                      color: BrandColors.stampAmber,
                    ),
                  Icon(Icons.star_outline_rounded, size: size, color: outline),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
