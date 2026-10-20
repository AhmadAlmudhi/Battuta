import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_shell.dart';
import '../../../core/widgets/message_view.dart';
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
                  _SearchField(
                    controller: _search,
                    onChanged: _onSearchChanged,
                    onClear: _clearSearch,
                  ),
                  if (value.regions.length > 1 || query.regions.isNotEmpty)
                    _RegionChips(
                      regions: value.regions,
                      selected: query.regions,
                    ),
                  TabBar(
                    controller: _tabs,
                    tabs: [
                      Tab(text: l10n.travelsVisitedTab(value.visitedTotal)),
                      Tab(text: l10n.travelsWishlistTab(value.wishlistTotal)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabs,
                      children: [
                        for (final tab in TravelsTab.values)
                          _EntryList(
                            tab: tab,
                            items: [
                              for (final item
                                  in tab == TravelsTab.visited
                                      ? value.visited
                                      : value.wishlist)
                                if (!_swiped.contains(item.country.code)) item,
                            ],
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

/// Region filters, OR within the field (FR-TRV-08).
class _RegionChips extends ConsumerWidget {
  const _RegionChips({required this.regions, required this.selected});

  final List<String> regions;
  final Set<String> selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // A selected region stays offered even if its last entry was deleted,
    // so it can still be cleared.
    final shown = {...regions, ...selected}.toList()..sort();
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
                label: Text(regionName(l10n, region)),
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
    required this.items,
    required this.total,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onSwipeDelete,
    required this.onClearFilters,
  });

  final TravelsTab tab;
  final List<TravelListItem> items;
  final int total;
  final ValueChanged<TravelListItem> onOpen;
  final ValueChanged<TravelListItem> onEdit;
  final ValueChanged<TravelListItem> onDelete;
  final ValueChanged<TravelListItem> onSwipeDelete;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
    if (items.isEmpty) {
      return MessageView(
        icon: Icons.search_off_rounded,
        title: l10n.travelsNoMatchesTitle,
        message: '',
        actionLabel: l10n.travelsClearFilters,
        onAction: onClearFilters,
      );
    }
    return ListView.separated(
      // Keeps each tab's scroll position when switching tabs.
      key: PageStorageKey(tab),
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return TravelEntryTile(
          key: ValueKey(item.country.code),
          item: item,
          onOpen: () => onOpen(item),
          onEdit: () => onEdit(item),
          onDelete: () => onDelete(item),
          onSwipeDelete: () => onSwipeDelete(item),
        );
      },
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
