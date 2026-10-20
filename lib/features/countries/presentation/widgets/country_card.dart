import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../travels/domain/travel_entry.dart';
import '../../domain/country.dart';
import '../region_names.dart';
import 'flag_image.dart';

/// Hero tag for a country's flag, shared by the card and the details header
/// (PRD section 10.2).
String flagHeroTag(String code) => 'flag-$code';

/// An Explore card: flag, name in the app language, region, and a badge for
/// saved countries (FR-EXP-01, FR-EXP-02).
class CountryCard extends StatelessWidget {
  const CountryCard({
    super.key,
    required this.country,
    required this.status,
    required this.onTap,
  });

  final Country country;
  final TravelStatus? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';

    return MergeSemantics(
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 3 / 2,
                child: ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Hero(
                          tag: flagHeroTag(country.code),
                          child: FlagImage(
                            country: country,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                      if (status case final status?)
                        PositionedDirectional(
                          top: 6,
                          end: 6,
                          child: _StatusBadge(status: status),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name(arabic: arabic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      regionName(l10n, country.region),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The card's height below the flag for 2 lines of name and 1 of region,
  /// scaled with the text size so nothing clips at 130% (NFR-08).
  static double infoHeight(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return scaler.scale(40) + scaler.scale(16) + 2 + 20;
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TravelStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (icon, background, foreground, label) = switch (status) {
      // Stamp Amber with Deep Ink, as the brand rules require (PRD 1.4).
      TravelStatus.visited => (
        Icons.check_rounded,
        scheme.secondary,
        scheme.onSecondary,
        l10n.exploreVisited,
      ),
      TravelStatus.wishlist => (
        Icons.bookmark_rounded,
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        l10n.exploreOnWishlist,
      ),
    };
    return Semantics(
      label: label,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: foreground),
      ),
    );
  }
}

/// A grey stand-in for a card while the bundled data is first imported
/// (PRD section 10.3).
class CountryCardSkeleton extends StatelessWidget {
  const CountryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget bar(double widthFactor) => FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );

    final card = Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 3 / 2,
            child: ColoredBox(color: scheme.surfaceContainerHighest),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [bar(0.8), const SizedBox(height: 8), bar(0.5)],
            ),
          ),
        ],
      ),
    );

    if (MediaQuery.disableAnimationsOf(context)) return card;
    return card
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: scheme.surface.withValues(alpha: 0.6),
        );
  }
}
