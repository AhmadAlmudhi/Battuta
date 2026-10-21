import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/layout/app_shell.dart';
import '../../../core/widgets/message_view.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../l10n/app_localizations.dart';
import '../../countries/presentation/region_names.dart';
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
    final theme = Theme.of(context);
    final regions = [...stats.regions]
      ..sort(
        (a, b) =>
            regionName(l10n, a.region).compareTo(regionName(l10n, b.region)),
      );

    return _StatsList(
      children: [
        WorldMapCard(
          key: mapCard,
          header: _Headline(stats: stats),
          visited: stats.visited,
          wishlist: stats.wishlistSize,
        ),
        const SizedBox(height: 24),
        Text(l10n.statsByRegion, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (final region in regions)
                  _RegionRow(
                    progress: region,
                    // The Antarctic has no frame on the map.
                    onTap: regionFrame(region.region) == null
                        ? null
                        : () => onShowRegion(region.region),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(l10n.statsHighlights, style: theme.textTheme.titleMedium),
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

/// The top of the map card, for example: 16, of 250 · 6.4% · 12 on your
/// wishlist (FR-STA-01, FR-MAP-02).
class _Headline extends StatelessWidget {
  const _Headline({required this.stats});

  final TravelStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final total = context.formatInteger(stats.total);
    final wishlist = context.formatInteger(stats.wishlistSize);

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
            Text(l10n.statsCountriesVisited, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
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
            _CountUp(
              value: stats.share * 100,
              builder: (context, value) => Text(
                l10n.statsOfTotal(
                  total,
                  context.formatPercent(value),
                  wishlist,
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFeatures: _tabular,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One region's visited countries out of its total (FR-STA-02). Tapping it
/// shows the region on the map (FR-MAP-25).
class _RegionRow extends StatelessWidget {
  const _RegionRow({required this.progress, this.onTap});

  final RegionProgress progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final count = l10n.statsRegionCount(
      context.formatInteger(progress.visited),
      context.formatInteger(progress.total),
    );
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  regionName(l10n, progress.region),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              Text(
                count,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFeatures: _tabular,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _ProgressBar(value: progress.fraction, height: 8),
        ],
      ),
    );
    final label = l10n.statsRegionLabel(
      regionName(l10n, progress.region),
      count,
    );
    // Each row is its own node, so a screen reader doesn't read a plain row
    // as the whole card around the tappable ones.
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
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: content,
        ),
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

/// Wishlist size, most recent trip, and first trip (FR-STA-03).
class _Highlights extends StatelessWidget {
  const _Highlights({required this.stats});

  final TravelStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final latest = stats.latestTrip;

    final cards = [
      _HighlightCard(
        icon: Icons.bookmark_border_rounded,
        label: l10n.statsWishlistSize,
        value: context.formatInteger(stats.wishlistSize),
      ),
      _HighlightCard(
        icon: Icons.flight_land_rounded,
        label: l10n.statsLatestTrip,
        value: latest?.country.name(arabic: arabic) ?? l10n.commonNotAvailable,
        detail: latest == null
            ? l10n.statsNoDates
            : context.formatDate(latest.date),
      ),
      _HighlightCard(
        icon: Icons.history_rounded,
        label: l10n.statsFirstTrip,
        value: stats.firstTripYear?.toString() ?? l10n.commonNotAvailable,
        detail: stats.firstTripYear == null ? l10n.statsNoDates : null,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= 560
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: cards[i]),
                  ],
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  cards[i],
                ],
              ],
            ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.icon,
    required this.label,
    required this.value,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: secondary),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFeatures: _tabular,
                ),
              ),
              if (detail != null) Text(detail!, style: secondary),
            ],
          ),
        ),
      ),
    );
  }
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
