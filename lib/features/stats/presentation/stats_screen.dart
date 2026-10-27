import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/layout/app_shell.dart';
import '../../../core/widgets/message_view.dart';
import '../../../core/widgets/panel.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../l10n/app_localizations.dart';
import '../../countries/domain/country.dart';
import '../../countries/presentation/region_names.dart';
import '../../countries/presentation/widgets/flag_image.dart';
import '../../travels/presentation/travels_screen.dart';
import '../../world_map/domain/map_regions.dart';
import '../../world_map/presentation/widgets/world_map_card.dart';
import '../../world_map/presentation/world_map_providers.dart';
import '../domain/travel_stats.dart';
import 'stats_providers.dart';

/// Digits of equal width, so counting numbers don't shift (PRD 10.1).
const _tabular = [FontFeature.tabularFigures()];

/// Stats tab: the world map, and progress overall and by region (PRD
/// sections 6.5 and 6.10).
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  /// Keeps the map's state when the first visit replaces the zero state,
  /// and lets a region bar scroll it into view.
  final _mapCard = GlobalKey();

  /// Selects [region] on the map and scrolls the map into view
  /// (FR-MAP-25).
  void _showRegion(String region) {
    ref.read(mapRegionProvider.notifier).state = region;
    final map = _mapCard.currentContext;
    if (map == null) return;
    Scrollable.ensureVisible(
      map,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(travelStatsProvider);

    return ScreenTitle(
      screen: l10n.navStats,
      // A tap anywhere else on the page closes the map's country card
      // (FR-MAP-14). Buttons and the map handle their own taps first, and a
      // scroll isn't a tap.
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: (details) =>
            WorldMapCard.tapOutside(_mapCard, details.globalPosition),
        child: TabScaffold(
          title: l10n.navStats,
          body: switch (stats) {
            // No visits: the map, then an invitation instead of the headline
            // and empty bars (FR-STA-05).
            AsyncData(:final value) when value.visited == 0 => _StatsList(
              children: [
                WorldMapCard(
                  key: _mapCard,
                  visited: 0,
                  wishlist: value.wishlistSize,
                  total: value.total,
                ),
                MessageView(
                  icon: Icons.public_rounded,
                  title: l10n.statsEmptyTitle,
                  message: l10n.statsEmptyBody,
                  actionLabel: l10n.travelsExplore,
                  onAction: () => context.go('/explore'),
                ),
              ],
            ),
            AsyncData(:final value) => _StatsBody(
              stats: value,
              mapCard: _mapCard,
              onShowRegion: _showRegion,
            ),
            AsyncError() => MessageView(
              icon: Icons.error_outline_rounded,
              title: l10n.exploreLoadError,
              message: '',
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({
    required this.stats,
    required this.mapCard,
    required this.onShowRegion,
  });

  final TravelStats stats;
  final GlobalKey mapCard;
  final ValueChanged<String> onShowRegion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    // Most visited first. The Antarctic isn't on the map, so it comes last.
    int offMap(RegionProgress progress) =>
        regionFrame(progress.region) == null ? 1 : 0;
    final regions = [...stats.regions]
      ..sort((a, b) {
        final map = offMap(a).compareTo(offMap(b));
        if (map != 0) return map;
        final share = b.fraction.compareTo(a.fraction);
        if (share != 0) return share;
        return regionName(l10n, a.region).compareTo(regionName(l10n, b.region));
      });

    return _StatsList(
      children: [
        WorldMapCard(
          key: mapCard,
          header: _Headline(stats: stats),
          visited: stats.visited,
          wishlist: stats.wishlistSize,
          total: stats.total,
        ),
        const SizedBox(height: 24),
        Text(l10n.statsByRegion, style: title),
        const SizedBox(height: 12),
        Panel(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final region in regions)
                  _RegionRow(
                    progress: region,
                    onTap: regionFrame(region.region) == null
                        ? null
                        : () => onShowRegion(region.region),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(l10n.statsHighlights, style: title),
        const SizedBox(height: 12),
        _Highlights(stats: stats),
      ],
    );
  }
}

/// The Stats column, up to 720 dp wide.
class _StatsList extends StatelessWidget {
  const _StatsList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: ListView(padding: const EdgeInsets.all(16), children: children),
    ),
  );
}

/// The top of the map card: the visited count out of the dataset total,
/// then the share of the world and the wishlist size as tags, for example
/// 16 / 249, 6.4% of the world, 12 on your wishlist (FR-STA-01, FR-MAP-02).
class _Headline extends StatelessWidget {
  const _Headline({required this.stats});

  final TravelStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final total = context.formatInteger(stats.total);

    // Screen readers get the final figures, not the counting ones, apart
    // from the map card around it.
    return Semantics(
      container: true,
      label: l10n.statsHeadlineLabel(
        context.formatInteger(stats.visited),
        total,
        context.formatPercent(stats.share * 100),
      ),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statsCountriesVisited,
              style: theme.textTheme.labelLarge?.copyWith(color: muted),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                _CountUp(
                  value: stats.visited.toDouble(),
                  builder: (context, value) => Text(
                    context.formatInteger(value.round()),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: _tabular,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.statsOutOfTotal(total),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: muted,
                    fontFeatures: _tabular,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CountUp(
                  value: stats.share * 100,
                  builder: (context, value) => _Tag(
                    icon: Icons.public_rounded,
                    label: l10n.statsWorldShare(context.formatPercent(value)),
                    visited: true,
                  ),
                ),
                _Tag(
                  icon: Icons.bookmark_rounded,
                  label: l10n.statsWishlistCount(
                    context.formatInteger(stats.wishlistSize),
                  ),
                  visited: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A tag under the headline, in the colors of Country details' status
/// card: amber for visited, teal for the wishlist.
class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label, required this.visited});

  final IconData icon;
  final String label;
  final bool visited;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = visited ? scheme.secondary : scheme.primary;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: visited
            ? scheme.secondary.withValues(alpha: 0.16)
            : scheme.primaryContainer.withValues(alpha: 0.45),
        shape: StadiumBorder(
          side: BorderSide(color: accent.withValues(alpha: 0.4)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 10, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: visited ? scheme.secondary : scheme.primaryContainer,
              ),
              child: Icon(
                icon,
                size: 14,
                color: visited ? scheme.onSecondary : scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: _tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One region's visited countries out of its total, and their share
/// (FR-STA-02). Tapping it shows the region on the map (FR-MAP-25), which
/// the icon at its end hints at.
class _RegionRow extends StatelessWidget {
  const _RegionRow({required this.progress, this.onTap});

  final RegionProgress progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final count = l10n.statsRegionCount(
      context.formatInteger(progress.visited),
      context.formatInteger(progress.total),
    );
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  regionName(l10n, progress.region),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                l10n.statsRegionProgress(
                  count,
                  context.formatPercent(progress.fraction * 100),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontFeatures: _tabular,
                ),
              ),
              const SizedBox(width: 8),
              // Rows that can't show their region on the map keep the
              // space, so the figures line up.
              if (onTap == null)
                const SizedBox(width: 18)
              else
                Icon(Icons.map_outlined, size: 18, color: scheme.primary),
            ],
          ),
          const SizedBox(height: 8),
          _ProgressBar(value: progress.fraction, height: 10),
        ],
      ),
    );
    final label = l10n.statsRegionLabel(
      regionName(l10n, progress.region),
      count,
    );
    // Each row is its own node, so a screen reader doesn't read a plain row
    // as the whole panel around the tappable ones.
    if (onTap == null) {
      return Semantics(
        container: true,
        label: label,
        child: ExcludeSemantics(child: content),
      );
    }
    return Semantics(
      container: true,
      label: label,
      button: true,
      onTap: onTap,
      onTapHint: l10n.statsShowOnMap,
      child: ExcludeSemantics(
        child: InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

/// A Stamp Amber bar that fills from the start edge, right to left in
/// Arabic (PRD 1.4, RTL checklist).
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.height});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _CountUp(
      value: value,
      builder: (context, value) => LinearProgressIndicator(
        value: value,
        minHeight: height,
        borderRadius: BorderRadius.circular(height / 2),
        color: scheme.secondary,
        backgroundColor: scheme.surfaceContainerHighest,
      ),
    );
  }
}

/// Most recent trip, first trip, regions visited, and wishlist size
/// (FR-STA-03), as tiles: two to a row on phones, four on wider screens.
/// The most recent trip opens its country, and the wishlist size opens the
/// Wishlist.
class _Highlights extends StatelessWidget {
  const _Highlights({required this.stats});

  final TravelStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final latest = stats.latestTrip;
    final regionsVisited = stats.regions.where((r) => r.visited > 0).length;

    final tiles = [
      _HighlightTile(
        leading: latest == null
            ? const IconBadge(icon: Icons.flight_land_rounded)
            : _RoundFlag(country: latest.country),
        label: l10n.statsLatestTrip,
        value: latest?.country.name(arabic: arabic) ?? l10n.commonNotAvailable,
        detail: latest == null
            ? l10n.statsNoDates
            : context.formatDate(latest.date),
        onTap: latest == null
            ? null
            : () => context.push('/country/${latest.country.code}'),
      ),
      _HighlightTile(
        leading: const IconBadge(icon: Icons.history_rounded),
        label: l10n.statsFirstTrip,
        value: stats.firstTripYear?.toString() ?? l10n.commonNotAvailable,
        detail: stats.firstTripYear == null ? l10n.statsNoDates : null,
      ),
      _HighlightTile(
        leading: const IconBadge(icon: Icons.public_rounded),
        label: l10n.statsRegionsVisited,
        value: l10n.statsRegionCount(
          context.formatInteger(regionsVisited),
          context.formatInteger(stats.regions.length),
        ),
      ),
      _HighlightTile(
        leading: const IconBadge(icon: Icons.bookmark_border_rounded),
        label: l10n.statsWishlistSize,
        value: context.formatInteger(stats.wishlistSize),
        onTap: () => context.go(TravelsTab.wishlist.location),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = constraints.maxWidth >= 560 ? 4 : 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var start = 0; start < tiles.length; start += perRow) ...[
              if (start > 0) const SizedBox(height: 12),
              // Tiles in a row share the tallest one's height.
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = start; i < start + perRow; i++) ...[
                      if (i > start) const SizedBox(width: 12),
                      Expanded(child: tiles[i]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// A highlight in the style of Country details' fact tiles. Tiles that
/// open something show an arrow at their top end.
class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.leading,
    required this.label,
    required this.value,
    this.detail,
    this.onTap,
  });

  final Widget leading;
  final String label;
  final String value;
  final String? detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              leading,
              const Spacer(),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: _tabular,
            ),
          ),
          if (detail != null)
            Text(
              detail!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
    return Panel(
      child: MergeSemantics(
        child: onTap == null
            ? content
            : Semantics(
                button: true,
                child: InkWell(onTap: onTap, child: content),
              ),
      ),
    );
  }
}

/// The most recent trip's flag, round like the flags in My travels, with a
/// hairline edge so white flags stand out.
class _RoundFlag extends StatelessWidget {
  const _RoundFlag({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    foregroundDecoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Theme.of(context).colorScheme.outlineVariant,
        width: 0.5,
      ),
    ),
    child: ClipOval(
      child: FlagImage(
        country: country,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      ),
    ),
  );
}

/// Animates from zero to [value] when it first appears, and to each new
/// value after that: about 800 ms, ease-out-cubic (PRD 10.2). Shows the
/// value at once when reduced motion is on (NFR-09).
class _CountUp extends StatelessWidget {
  const _CountUp({required this.value, required this.builder});

  final double value;
  final Widget Function(BuildContext context, double value) builder;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 800),
    curve: Curves.easeOutCubic,
    builder: (context, value, _) => builder(context, value),
  );
}
