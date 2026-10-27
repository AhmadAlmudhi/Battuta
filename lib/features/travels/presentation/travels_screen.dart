import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_shell.dart';
import '../../../core/widgets/message_view.dart';
import '../../../core/widgets/panel.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../l10n/app_localizations.dart';
import '../../countries/presentation/region_names.dart';
import '../domain/travel_entry.dart';
import '../domain/travel_list.dart';
import 'travel_actions.dart';
import 'travel_forms.dart';
import 'travel_providers.dart';
import 'travels_controller.dart';
import 'widgets/travel_entry_tile.dart';

/// The two tabs of My travels; the URL names the Wishlist tab
/// (/travels?tab=wishlist), so each tab can be bookmarked (PRD 5.2).
enum TravelsTab {
  visited,
  wishlist;

  static TravelsTab fromQuery(String? value) =>
      value == 'wishlist' ? wishlist : visited;

  String get location =>
      this == wishlist ? '/travels?tab=wishlist' : '/travels';
}

/// My travels: Visited and Wishlist (PRD section 6.4).
class TravelsScreen extends ConsumerStatefulWidget {
  const TravelsScreen({super.key, this.tab = TravelsTab.visited});

  final TravelsTab tab;

  @override
  ConsumerState<TravelsScreen> createState() => _TravelsScreenState();
}

class _TravelsScreenState extends ConsumerState<TravelsScreen>
    with SingleTickerProviderStateMixin {
  late final _tabs = TabController(
    length: TravelsTab.values.length,
    vsync: this,
    initialIndex: widget.tab.index,
  )..addListener(_onTabChanged);
  late final _search = TextEditingController(
    text: ref.read(travelsQueryProvider).search,
  );
  Timer? _debounce;

  /// Rows already swiped away, hidden until the list confirms the deletion.
  /// A dismissed row must leave the tree at once (FR-TRV-07).
  final _swiped = <String>{};

  TravelsTab get _tab => TravelsTab.values[_tabs.index];

  @override
  void didUpdateWidget(TravelsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The URL changed, for example with the browser's Back button.
    if (widget.tab != oldWidget.tab && _tabs.index != widget.tab.index) {
      _tabs.animateTo(widget.tab.index);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;
    setState(() {}); // The sort menu follows the tab.
    if (_tab != widget.tab) context.go(_tab.location);
  }

  void _onSearchChanged(String text) {
    setState(() {}); // Shows or hides the clear button.
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => ref.read(travelsQueryProvider.notifier).setSearch(text),
    );
  }

  void _clearSearch() {
    _debounce?.cancel();
    _search.clear();
    setState(() {});
    ref.read(travelsQueryProvider.notifier).setSearch('');
  }

  void _clearFilters() {
    _clearSearch();
    ref.read(travelsQueryProvider.notifier).clearFilters();
  }

  Future<void> _edit(TravelListItem item) =>
      item.entry.status == TravelStatus.visited
      ? showVisitForm(context, country: item.country, entry: item.entry)
      : showWishlistForm(context, country: item.country, entry: item.entry);

  Future<void> _delete(TravelListItem item) => removeWithUndo(
    context,
    ref,
    item.country,
    message: (l10n, name) => l10n.travelsDeleted(name),
  );

  void _swipeDelete(TravelListItem item) {
    setState(() => _swiped.add(item.country.code));
    _delete(item);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final query = ref.watch(travelsQueryProvider);
    final view = ref.watch(travelsViewProvider(arabic));

    // Once an entry has left the data, its row needs no hiding: an Undo
    // then shows it again.
    ref.listen(travelEntriesProvider, (_, next) {
      final codes = {...?next.valueOrNull?.map((e) => e.countryCode)};
      if (_swiped.any((code) => !codes.contains(code))) {
        setState(() => _swiped.removeWhere((code) => !codes.contains(code)));
      }
    });

    return ScreenTitle(
      screen: l10n.navTravels,
      child: TabScaffold(
        title: l10n.navTravels,
        actions: [_SortMenu(tab: _tab, query: query)],
        body: switch (view) {
          // A readable column on wide screens keeps each row's menu near
          // its name.
          AsyncData(:final value) => Align(
            alignment: AlignmentDirectional.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TabToggle(
                    controller: _tabs,
                    visited: value.visitedTotal,
                    wishlist: value.wishlistTotal,
                  ),
                  _SearchField(
                    controller: _search,
                    onChanged: _onSearchChanged,
                    onClear: _clearSearch,
                  ),
                  if (_tab == TravelsTab.visited
                          ? value.visitedRegions
                          : value.wishlistRegions
                      case final counts
                      when counts.length > 1 || query.regions.isNotEmpty)
                    _RegionChips(counts: counts, selected: query.regions),
                  Expanded(
                    child: TabBarView(
                      controller: _tabs,
                      children: [
                        for (final tab in TravelsTab.values)
                          _EntryList(
                            tab: tab,
                            summary: _summary(l10n, tab, value),
                            groups: _groups(l10n, tab, query, value),
                            total: tab == TravelsTab.visited
                                ? value.visitedTotal
                                : value.wishlistTotal,
                            onOpen: (item) =>
                                context.push('/country/${item.country.code}'),
                            onEdit: _edit,
                            onDelete: _delete,
                            onSwipeDelete: _swipeDelete,
                            onClearFilters: _clearFilters,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

  /// One line about the whole tab, for example 6 countries in 3 regions.
  String _summary(AppLocalizations l10n, TravelsTab tab, TravelsView view) =>
      switch (tab) {
        TravelsTab.visited => l10n.travelsVisitedSummary(
          l10n.exploreCountryCount(view.visitedTotal),
          l10n.travelsRegionCount(view.visitedRegions.length),
        ),
        TravelsTab.wishlist => [
          l10n.exploreCountryCount(view.wishlistTotal),
          if (view.highPriority > 0)
            l10n.travelsHighPriorityCount(view.highPriority),
        ].join(' · '),
      };

  /// The tab's rows under headings: years of visits, or wishlist
  /// priorities. Sorted by name, they form one untitled group (FR-TRV-06).
  List<(String?, List<TravelListItem>)> _groups(
    AppLocalizations l10n,
    TravelsTab tab,
    TravelsQuery query,
    TravelsView view,
  ) {
    bool shown(TravelListItem item) => !_swiped.contains(item.country.code);
    final items = [
      ...(tab == TravelsTab.visited ? view.visited : view.wishlist).where(
        shown,
      ),
    ];
    if (items.isEmpty) return const [];
    return switch (tab) {
      TravelsTab.visited when query.visitedSort == VisitedSort.date => [
        for (final group in TravelListGroups.byYear(items))
          (group.key?.toString() ?? l10n.travelsNoDate, group.items),
      ],
      TravelsTab.wishlist when query.wishlistSort == WishlistSort.priority => [
        for (final group in TravelListGroups.byPriority(items))
          (
            switch (group.key) {
              WishlistPriority.high => l10n.priorityHigh,
              WishlistPriority.medium => l10n.priorityMedium,
              WishlistPriority.low => l10n.priorityLow,
            },
            group.items,
          ),
      ],
      _ => [(null, items)],
    };
  }
}

/// Visited and Wishlist as a pill-shaped toggle, each with its count
/// (FR-TRV-05). It's a TabBar underneath, so swiping the lists still
/// switches tabs.
class _TabToggle extends StatelessWidget {
  const _TabToggle({
    required this.controller,
    required this.visited,
    required this.wishlist,
  });

  final TabController controller;
  final int visited;
  final int wishlist;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pill = BorderRadius.circular(999);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: pill,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: controller,
            indicator: BoxDecoration(
              color: scheme.surface,
              borderRadius: pill,
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            splashBorderRadius: pill,
            labelColor: scheme.onSurface,
            unselectedLabelColor: scheme.onSurfaceVariant,
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: theme.textTheme.labelLarge,
            tabs: [
              _ToggleTab(
                icon: Icons.check_rounded,
                label: l10n.travelsVisited,
                count: visited,
                semantics: l10n.travelsVisitedTab(visited),
              ),
              _ToggleTab(
                icon: Icons.bookmark_rounded,
                label: l10n.travelsWishlist,
                count: wishlist,
                semantics: l10n.travelsWishlistTab(wishlist),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.icon,
    required this.label,
    required this.count,
    required this.semantics,
  });

  final IconData icon;
  final String label;
  final int count;

  /// Read as one label, for example Visited (6).
  final String semantics;

  @override
  Widget build(BuildContext context) => Tab(
    height: 40,
    child: Semantics(
      label: semantics,
      excludeSemantics: true,
      // The tab bar animates the label color; the badge follows it.
      child: Builder(
        builder: (context) {
          final color = DefaultTextStyle.of(context).style.color;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Flexible(child: Text(label, overflow: TextOverflow.fade)),
              const SizedBox(width: 6),
              DecoratedBox(
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: color?.withValues(alpha: 0.12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 1,
                  ),
                  child: Text('$count'),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            if (controller.text.isNotEmpty) onClear();
          },
        },
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.travelsSearchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: controller.text.isEmpty
                ? null
                : ExcludeFocusTraversal(
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      tooltip: l10n.exploreClearSearch,
                      onPressed: onClear,
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
    );
  }
}

/// Region filters for the current tab, each with how many of the tab's
/// countries are in it; OR within the field (FR-TRV-08).
class _RegionChips extends ConsumerWidget {
  const _RegionChips({required this.counts, required this.selected});

  final Map<String, int> counts;
  final Set<String> selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // A selected region stays offered even if its last entry was deleted,
    // or isn't in this tab, so it can still be cleared.
    final shown = {...counts.keys, ...selected}.toList()..sort();
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final region in shown)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: FilterChip(
                label: Text(
                  '${regionName(l10n, region)} ${counts[region] ?? 0}',
                ),
                selected: selected.contains(region),
                onSelected: (_) => ref
                    .read(travelsQueryProvider.notifier)
                    .toggleRegion(region),
              ),
            ),
        ],
      ),
    );
  }
}

class _EntryList extends StatelessWidget {
  const _EntryList({
    required this.tab,
    required this.summary,
    required this.groups,
    required this.total,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onSwipeDelete,
    required this.onClearFilters,
  });

  final TravelsTab tab;
  final String summary;

  /// Rows under their headings; a null heading shows none.
  final List<(String?, List<TravelListItem>)> groups;
  final int total;
  final ValueChanged<TravelListItem> onOpen;
  final ValueChanged<TravelListItem> onEdit;
  final ValueChanged<TravelListItem> onDelete;
  final ValueChanged<TravelListItem> onSwipeDelete;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // An empty tab invites the user to Explore (FR-TRV-09).
    if (total == 0) {
      final visited = tab == TravelsTab.visited;
      return MessageView(
        icon: visited ? Icons.luggage_outlined : Icons.bookmark_border_rounded,
        title: visited
            ? l10n.travelsEmptyVisitedTitle
            : l10n.travelsEmptyWishlistTitle,
        message: visited
            ? l10n.travelsEmptyVisitedBody
            : l10n.travelsEmptyWishlistBody,
        actionLabel: l10n.travelsExplore,
        onAction: () => context.go('/explore'),
      );
    }
    if (groups.isEmpty) {
      return MessageView(
        icon: Icons.search_off_rounded,
        title: l10n.travelsNoMatchesTitle,
        message: '',
        actionLabel: l10n.travelsClearFilters,
        onAction: onClearFilters,
      );
    }
    return ListView(
      // Keeps each tab's scroll position when switching tabs.
      key: PageStorageKey(tab),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 16),
          child: Text(
            summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final (i, (heading, items)) in groups.indexed) ...[
          if (i > 0) const SizedBox(height: 20),
          if (heading != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      heading,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    l10n.exploreCountryCount(items.length),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          _Group(
            children: [
              for (final item in items)
                TravelEntryTile(
                  key: ValueKey(item.country.code),
                  item: item,
                  onOpen: () => onOpen(item),
                  onEdit: () => onEdit(item),
                  onDelete: () => onDelete(item),
                  onSwipeDelete: () => onSwipeDelete(item),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A heading's rows on one rounded panel, divided by lines that start
/// after the flags.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Panel(
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 76,
                color: scheme.outlineVariant.withValues(alpha: 0.6),
              ),
            child,
          ],
        ],
      ),
    );
  }
}

/// Visit date or name for Visited; priority or name for Wishlist
/// (FR-TRV-06).
class _SortMenu extends ConsumerWidget {
  const _SortMenu({required this.tab, required this.query});

  final TravelsTab tab;
  final TravelsQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(travelsQueryProvider.notifier);
    MenuItemButton option(
      String label,
      bool selected,
      VoidCallback onPressed,
    ) => MenuItemButton(
      leadingIcon: Icon(
        Icons.check_rounded,
        color: selected ? null : Colors.transparent,
      ),
      onPressed: onPressed,
      child: Text(label),
    );

    return MenuAnchor(
      builder: (context, menu, _) => IconButton(
        icon: const Icon(Icons.sort_rounded),
        tooltip: l10n.exploreSort,
        onPressed: () => menu.isOpen ? menu.close() : menu.open(),
      ),
      menuChildren: switch (tab) {
        TravelsTab.visited => [
          option(
            l10n.travelsSortByDate,
            query.visitedSort == VisitedSort.date,
            () => controller.setVisitedSort(VisitedSort.date),
          ),
          option(
            l10n.exploreSortNameAsc,
            query.visitedSort == VisitedSort.name,
            () => controller.setVisitedSort(VisitedSort.name),
          ),
        ],
        TravelsTab.wishlist => [
          option(
            l10n.travelsSortByPriority,
            query.wishlistSort == WishlistSort.priority,
            () => controller.setWishlistSort(WishlistSort.priority),
          ),
          option(
            l10n.exploreSortNameAsc,
            query.wishlistSort == WishlistSort.name,
            () => controller.setWishlistSort(WishlistSort.name),
          ),
        ],
      },
    );
  }
}
