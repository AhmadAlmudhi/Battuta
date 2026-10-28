import 'dart:math' as math;

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

/// An Explore card (FR-EXP-01, FR-EXP-02): the flag filling a circle, the
/// name and region over its lower part on a dark gradient, and a badge on
/// its edge for saved countries. On web, hovering lifts it.
///
/// In quick select (FR-EXP-13) the badge shows whether the card is picked,
/// and a picked card shrinks a little inside a teal ring. A visited country
/// can't be picked, so it fades and keeps its badge.
class CountryCard extends StatefulWidget {
  const CountryCard({
    super.key,
    required this.country,
    required this.status,
    required this.onTap,
    this.selected,
    this.onLongPress,
  });

  final Country country;
  final TravelStatus? status;
  final VoidCallback? onTap;

  /// Whether the card is picked in quick select; null outside it.
  final bool? selected;
  final VoidCallback? onLongPress;

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
    final selecting = widget.selected != null;
    final picked = widget.selected ?? false;
    final visitedWhileSelecting =
        selecting && widget.status == TravelStatus.visited;
    final still = MediaQuery.disableAnimationsOf(context);

    return MergeSemantics(
      child: Semantics(
        checked: selecting && !visitedWhileSelecting ? picked : null,
        enabled: visitedWhileSelecting ? false : null,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final diameter = math.min(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            // Where the circle's edge crosses its top end diagonal, for the
            // badge.
            final corner = diameter / 2 * (1 - math.sqrt1_2);
            return Center(
              child: AnimatedScale(
                scale: picked
                    ? 0.9
                    : _hovered && !still
                    ? 1.03
                    : 1,
                duration: still
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: visitedWhileSelecting ? 0.4 : 1,
                  duration: still
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  child: SizedBox.square(
                    dimension: diameter,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Material(
                            color: scheme.surfaceContainerHighest,
                            elevation: _hovered ? 6 : 1,
                            clipBehavior: Clip.antiAlias,
                            shape: CircleBorder(
                              side: BorderSide(
                                color: picked || _hovered
                                    ? scheme.primary
                                    : scheme.outlineVariant,
                                width: picked
                                    ? 4
                                    : _hovered
                                    ? 2
                                    : 1,
                              ),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Hero(
                                  tag: flagHeroTag(country.code),
                                  // Both ways, the circle opens into the
                                  // flag's framed shape as it flies, or closes
                                  // back into it.
                                  flightShuttleBuilder:
                                      (_, animation, _, _, _) => FlagFlight(
                                        country: country,
                                        progress: animation,
                                      ),
                                  child: FlagImage(
                                    country: country,
                                    fit: BoxFit.cover,
                                    excludeFromSemantics: true,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: _Caption(
                                    name: country.name(arabic: arabic),
                                    region: regionName(l10n, country.region),
                                    diameter: diameter,
                                  ),
                                ),
                                // Above the flag, so the ripple shows over it.
                                Material(
                                  type: MaterialType.transparency,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: widget.onTap,
                                    onLongPress: widget.onLongPress,
                                    onHover: (hovered) =>
                                        setState(() => _hovered = hovered),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (selecting && !visitedWhileSelecting)
                          PositionedDirectional(
                            top: corner - _StatusBadge.size / 2,
                            end: corner - _StatusBadge.size / 2,
                            child: _PickBadge(picked: picked),
                          )
                        else if (widget.status case final status?)
                          PositionedDirectional(
                            top: corner - _StatusBadge.size / 2,
                            end: corner - _StatusBadge.size / 2,
                            child: _StatusBadge(status: status),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Quick select's badge: a teal check when the card is picked, an empty
/// ring when it isn't (FR-EXP-13).
class _PickBadge extends StatelessWidget {
  const _PickBadge({required this.picked});

  final bool picked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: _StatusBadge.size,
      height: _StatusBadge.size,
      decoration: BoxDecoration(
        color: picked ? scheme.primary : scheme.surface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: picked ? scheme.surface : scheme.outline,
          width: 2,
        ),
      ),
      child: picked
          ? Icon(Icons.check_rounded, size: 18, color: scheme.onPrimary)
          : null,
    );
  }
}

/// The name and region in white at the bottom of the circle, over a dark
/// gradient that fades out above them, inset so the text stays clear of
/// the curve.
///
/// The caption is the same height on every card, with room for two lines
/// of name, so names and regions line up across a row.
class _Caption extends StatelessWidget {
  const _Caption({
    required this.name,
    required this.region,
    required this.diameter,
  });

  final String name;
  final String region;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).textTheme;
    final scaler = MediaQuery.textScalerOf(context);
    // Two lines of name and one of region, at the type scale's line heights.
    final text = scaler.scale(20) * 2 + scaler.scale(16);
    final bottom = diameter * 0.11;
    final fade = diameter * 0.18;
    final height = fade + text + bottom;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // From clear to dark enough for white text on white flags
            // where the text starts (WCAG AA), and a little darker below.
            colors: [
              Colors.black.withValues(alpha: 0),
              Colors.black.withValues(alpha: 0.55),
              Colors.black.withValues(alpha: 0.7),
            ],
            stops: [0, fade / height, 1],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            diameter * 0.14,
            0,
            diameter * 0.14,
            bottom,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: styles.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                region,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: styles.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A check in Stamp Amber for Visited, or a bookmark in teal for Wishlist,
/// ringed in the page color like a status dot (FR-EXP-02).
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TravelStatus status;

  static const size = 30.0;

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
        l10n.exploreWishlist,
      ),
    };
    return Semantics(
      label: label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.surface, width: 2),
        ),
        child: Icon(icon, size: 16, color: foreground),
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
    final circle = LayoutBuilder(
      builder: (context, constraints) => Center(
        child: SizedBox.square(
          dimension: math.min(constraints.maxWidth, constraints.maxHeight),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );

    if (MediaQuery.disableAnimationsOf(context)) return circle;
    return circle
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: scheme.surface.withValues(alpha: 0.6),
        );
  }
}
