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

/// An Explore card: the flag, the name in the app language, the region, and
/// a badge for saved countries (FR-EXP-01, FR-EXP-02). On web, hovering
/// lifts the card.
class CountryCard extends StatefulWidget {
  const CountryCard({
    super.key,
    required this.country,
    required this.status,
    required this.onTap,
  });

  final Country country;
  final TravelStatus? status;
  final VoidCallback onTap;

  /// The card's height below the flag for 2 lines of name and the region
  /// row, scaled with the text size so nothing clips at 130% (NFR-08).
  static double infoHeight(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return scaler.scale(40) + scaler.scale(16) + _badgePadding * 2 + 24;
  }

  @override
  State<CountryCard> createState() => _CountryCardState();
}

class _CountryCardState extends State<CountryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final country = widget.country;

    return MergeSemantics(
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: scheme.surfaceContainerLow,
        elevation: _hovered ? 3 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _hovered
                ? scheme.primary.withValues(alpha: 0.5)
                : scheme.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        child: InkWell(
          onTap: widget.onTap,
          onHover: (hovered) => setState(() => _hovered = hovered),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 3 / 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                  child: AnimatedScale(
                    scale: _hovered && !MediaQuery.disableAnimationsOf(context)
                        ? 1.04
                        : 1,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: Hero(
                      tag: flagHeroTag(country.code),
                      child: FramedFlag(
                        country: country,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        country.name(arabic: arabic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // The region row sits at the bottom, level across a
                      // row of cards, whether the name takes 1 line or 2.
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              regionName(l10n, country.region),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (widget.status case final status?) ...[
                            const SizedBox(width: 6),
                            _StatusBadge(status: status),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Space above and below a badge's label.
const _badgePadding = 3.0;

/// Visited in Stamp Amber or Wishlist in teal, with its icon (FR-EXP-02).
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TravelStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
        l10n.exploreWishlist,
      ),
    };
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          6,
          _badgePadding,
          8,
          _badgePadding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
      color: scheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 3 / 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
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
