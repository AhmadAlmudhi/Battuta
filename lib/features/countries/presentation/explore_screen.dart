import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_shell.dart';
import '../../../core/layout/window_size.dart';
import '../../../core/network/connectivity.dart';
import '../../../core/widgets/message_view.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../l10n/app_localizations.dart';
import '../../travels/presentation/travel_providers.dart';
import '../data/country_refresher.dart';
import '../domain/explore_query.dart';
import 'country_providers.dart';
import 'explore_controller.dart';
import 'widgets/country_card.dart';
import 'widgets/country_grid.dart';
import 'widgets/explore_filter_panel.dart';

/// Whether the grid entrance has played this session (PRD 10.2: first load
/// only).
final _entrancePlayedProvider = StateProvider<bool>((ref) => false);

/// Explore: every country in a grid with search, filters, and sort
/// (PRD section 6.2).
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  late final _search = TextEditingController(
    text: ref.read(exploreQueryProvider).search,
  );
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  /// Results update 300 ms after typing stops (FR-EXP-03).
  void _onSearchChanged(String text) {
    setState(() {}); // Shows or hides the clear button.
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => ref.read(exploreQueryProvider.notifier).setSearch(text),
    );
  }

  void _clearSearch() {
    _debounce?.cancel();
    _search.clear();
    setState(() {});
    ref.read(exploreQueryProvider.notifier).setSearch('');
  }

  void _clearAll() {
    _debounce?.cancel();
    _search.clear();
    ref.read(exploreQueryProvider.notifier).clearAll();
  }

  /// Pull to refresh and Refresh data (FR-EXP-11). A download takes a
  /// moment, so the screen says so while it runs.
  Future<void> _refresh() async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await ref
        .read(countryRefresherProvider)
        .refreshManually(
          onStart: () => messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                // Stays until the result replaces it, even when slow pages
                // run to their timeouts.
                duration: const Duration(minutes: 3),
                content: Row(
                  children: [
                    SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.inversePrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Text(l10n.exploreRefreshing)),
                  ],
                ),
              ),
            ),
        );
    if (!mounted) return;
    final message = switch (outcome) {
      RefreshOutcome.refreshed => l10n.exploreRefreshed,
      RefreshOutcome.upToDate => l10n.exploreUpToDate,
      RefreshOutcome.offline ||
      RefreshOutcome.failed => l10n.exploreRefreshFailed,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final query = ref.watch(exploreQueryProvider);
    final results = ref.watch(exploreResultsProvider(arabic));
    final statuses = ref.watch(travelStatusesProvider).valueOrNull ?? const {};
    final online = ref.watch(isOnlineProvider).valueOrNull ?? true;

    return ScreenTitle(
      screen: l10n.navExplore,
      child: TabScaffold(
        title: l10n.navExplore,
        actions: [if (kIsWeb) _MoreMenu(onRefresh: _refresh)],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!online) const _OfflineBanner(),
            _Toolbar(
              search: _search,
              query: query,
              onSearchChanged: _onSearchChanged,
              onClearSearch: _clearSearch,
            ),
            Expanded(
              child: results.when(
                loading: () => const _SkeletonGrid(),
                error: (_, _) => MessageView(
                  icon: Icons.error_outline_rounded,
                  title: l10n.exploreLoadError,
                  message: '',
                ),
                data: (countries) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ResultCount(count: countries.length),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refresh,
                        child: _CrossFade(
                          // A new query cross-fades the results instead of
                          // jumping (PRD 10.2); badge changes don't.
                          childKey: ValueKey(query),
                          child: countries.isEmpty
                              ? _EmptyResults(onClear: _clearAll)
                              : CountryGrid(
                                  countries: countries,
                                  statuses: statuses,
                                  playEntrance: _takeEntrance(),
                                  onOpen: (country) =>
                                      context.push('/country/${country.code}'),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// True only for the first grid built this session.
  bool _takeEntrance() {
    if (ref.read(_entrancePlayedProvider)) return false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(_entrancePlayedProvider.notifier).state = true;
    });
    return true;
  }
}

class _Toolbar extends ConsumerWidget {
  const _Toolbar({
    required this.search,
    required this.query,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  final TextEditingController search;
  final ExploreQuery query;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filterCount = query.activeFilterCount;
    final filtersTooltip = filterCount == 0
        ? l10n.exploreFilters
        : l10n.exploreFiltersActive(filterCount);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 4),
      child: Row(
        children: [
          Expanded(
            // Esc clears the search, so the clear button can stay out of
            // the Tab order: Tab goes from search to Filters (AC-PLT-04).
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape): () {
                  if (search.text.isNotEmpty) onClearSearch();
                },
              },
              child: TextField(
                controller: search,
                onChanged: onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.exploreSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: search.text.isEmpty
                      ? null
                      : ExcludeFocusTraversal(
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded),
                            tooltip: l10n.exploreClearSearch,
                            onPressed: onClearSearch,
                          ),
                        ),
                  filled: true,
                  isDense: true,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Badge(
            isLabelVisible: filterCount > 0,
            label: Text('$filterCount'),
            offset: const Offset(-4, 4),
            child: filterCount > 0
                ? IconButton.filledTonal(
                    icon: const Icon(Icons.tune_rounded),
                    tooltip: filtersTooltip,
                    onPressed: () => showExploreFilters(context),
                  )
                : IconButton(
                    icon: const Icon(Icons.tune_rounded),
                    tooltip: filtersTooltip,
                    onPressed: () => showExploreFilters(context),
                  ),
          ),
          _SortMenu(selected: query.sort),
        ],
      ),
    );
  }
}

class _SortMenu extends ConsumerWidget {
  const _SortMenu({required this.selected});

  final CountrySort selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      CountrySort.nameAsc: l10n.exploreSortNameAsc,
      CountrySort.nameDesc: l10n.exploreSortNameDesc,
      CountrySort.populationDesc: l10n.exploreSortPopulationDesc,
      CountrySort.populationAsc: l10n.exploreSortPopulationAsc,
      CountrySort.areaDesc: l10n.exploreSortAreaDesc,
      CountrySort.areaAsc: l10n.exploreSortAreaAsc,
    };
    return MenuAnchor(
      builder: (context, controller, _) => IconButton(
        icon: const Icon(Icons.sort_rounded),
        tooltip: l10n.exploreSort,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: [
        for (final MapEntry(key: sort, value: label) in labels.entries)
          MenuItemButton(
            leadingIcon: Icon(
              Icons.check_rounded,
              color: sort == selected ? null : Colors.transparent,
            ),
            onPressed: () =>
                ref.read(exploreQueryProvider.notifier).setSort(sort),
            child: Text(label),
          ),
      ],
    );
  }
}

/// Web has no pull to refresh with a mouse, so refresh lives in a menu
/// (FR-EXP-11, FR-PLT-06).
class _MoreMenu extends StatelessWidget {
  const _MoreMenu({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MenuAnchor(
      builder: (context, controller, _) => IconButton(
        icon: const Icon(Icons.more_vert_rounded),
        tooltip: l10n.exploreMoreOptions,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.refresh_rounded),
          onPressed: onRefresh,
          child: Text(l10n.exploreRefreshData),
        ),
      ],
    );
  }
}

/// Non-blocking, and announced to screen readers when it appears
/// (FR-EXP-10).
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
          child: Row(
            children: [
              Icon(Icons.cloud_off_rounded, size: 20, color: scheme.onSurface),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).exploreOffline,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The count rolls to its new value when filters change (PRD 10.2).
class _ResultCount extends StatelessWidget {
  const _ResultCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.4),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: Text(
          AppLocalizations.of(context).exploreCountryCount(count),
          key: ValueKey(count),
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    ),
  );
}

class _CrossFade extends StatelessWidget {
  const _CrossFade({required this.childKey, required this.child});

  final Key childKey;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200),
    // The outgoing grid has the same flag heroes as the incoming one, so its
    // heroes are switched off to keep tags unique during navigation.
    layoutBuilder: (current, previous) => Stack(
      fit: StackFit.expand,
      children: [
        for (final child in previous) HeroMode(enabled: false, child: child),
        ?current,
      ],
    ),
    child: KeyedSubtree(key: childKey, child: child),
  );
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Scrollable so pull to refresh still works on an empty result.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: MessageView(
            icon: Icons.search_off_rounded,
            title: l10n.exploreEmptyTitle,
            message: l10n.exploreEmptyBody,
            actionLabel: l10n.exploreClearFilters,
            onAction: onClear,
          ),
        ),
      ),
    );
  }
}

/// 8 skeleton cards while the bundled data is first imported (PRD 10.3).
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = exploreGridColumns(
        WindowSizeClass.of(context),
        constraints.maxWidth,
      );
      final tileWidth =
          (constraints.maxWidth - 32 - 12 * (columns - 1)) / columns;
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: tileWidth * 2 / 3 + CountryCard.infoHeight(context),
        ),
        itemCount: 8,
        itemBuilder: (context, _) => const CountryCardSkeleton(),
      );
    },
  );
}
