import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/app_title.dart';
import 'window_size.dart';

/// One of the three main tabs: its icons and label.
typedef NavItem = ({IconData icon, IconData selectedIcon, String label});

/// The three main tabs: a floating bar on compact and medium screens, a side
/// navigation rail on expanded screens (FR-PLT-02).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _select(int index) => navigationShell.goBranch(
    index,
    // Selecting the current tab again returns to its first screen.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final List<NavItem> items = [
      (
        icon: Icons.explore_outlined,
        selectedIcon: Icons.explore_rounded,
        label: l10n.navExplore,
      ),
      (
        icon: Icons.luggage_outlined,
        selectedIcon: Icons.luggage_rounded,
        label: l10n.navTravels,
      ),
      (
        icon: Icons.insights_outlined,
        selectedIcon: Icons.insights_rounded,
        label: l10n.navStats,
      ),
    ];

    if (WindowSizeClass.of(context) == WindowSizeClass.expanded) {
      // The rail floats on a tinted panel, like the bar on phones.
      return Scaffold(
        body: Row(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 0, 12),
              child: Material(
                color: scheme.surfaceContainerLow,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: NavigationRail(
                  backgroundColor: Colors.transparent,
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _select,
                  labelType: NavigationRailLabelType.all,
                  indicatorColor: scheme.primaryContainer,
                  selectedIconTheme: IconThemeData(
                    color: scheme.onPrimaryContainer,
                  ),
                  unselectedIconTheme: IconThemeData(
                    color: scheme.onSurfaceVariant,
                  ),
                  selectedLabelTextStyle: _labelStyle(context, selected: true),
                  unselectedLabelTextStyle: _labelStyle(
                    context,
                    selected: false,
                  ),
                  destinations: [
                    for (final item in items)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      // Pages scroll behind the floating bar; the body's bottom padding
      // includes it, so their last items can scroll clear of it.
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: FloatingNavBar(
        items: items,
        selectedIndex: navigationShell.currentIndex,
        onSelected: _select,
      ),
    );
  }
}

TextStyle? _labelStyle(BuildContext context, {required bool selected}) {
  final theme = Theme.of(context);
  return theme.textTheme.labelMedium?.copyWith(
    color: selected
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant,
    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
  );
}

/// The tab bar on compact and medium screens: a rounded pill floating 12 dp
/// above the bottom edge and 16 dp from the sides, at most 480 dp wide. A
/// teal highlight slides behind the selected tab, and mirrors in Arabic.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const height = 64.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 300);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Material(
              color: scheme.surfaceContainer,
              elevation: 6,
              shadowColor: Colors.black.withValues(alpha: 0.4),
              clipBehavior: Clip.antiAlias,
              shape: StadiumBorder(
                side: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: SizedBox(
                height: height,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth / items.length;
                      return Stack(
                        children: [
                          AnimatedPositionedDirectional(
                            duration: duration,
                            curve: Curves.easeOutCubic,
                            start: width * selectedIndex,
                            width: width,
                            top: 0,
                            bottom: 0,
                            child: DecoratedBox(
                              decoration: ShapeDecoration(
                                shape: const StadiumBorder(),
                                color: scheme.primaryContainer,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              for (final (i, item) in items.indexed)
                                Expanded(
                                  child: _NavButton(
                                    item: item,
                                    index: i,
                                    count: items.length,
                                    selected: i == selectedIndex,
                                    onTap: () => onSelected(i),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.index,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final int index;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    // Read like the tabs of Material's own bar: "Explore, Tab 1 of 3".
    return Semantics(
      container: true,
      selected: selected,
      button: true,
      hint: MaterialLocalizations.of(
        context,
      ).tabLabel(tabIndex: index + 1, tabCount: count),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? item.selectedIcon : item.icon, color: color),
            const SizedBox(height: 2),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _labelStyle(
                context,
                selected: selected,
              )?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps every tab alive but shows only the current one. Inactive tabs stop
/// their animations and take no part in hero flights, so a flag hidden in
/// another tab never flies to a details screen.
class BranchStack extends StatelessWidget {
  const BranchStack({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => IndexedStack(
    index: currentIndex,
    children: [
      for (var i = 0; i < children.length; i++)
        HeroMode(
          enabled: i == currentIndex,
          child: TickerMode(enabled: i == currentIndex, child: children[i]),
        ),
    ],
  );
}

/// Scaffold for a main tab: the app's name, the Account button every tab
/// has, and centered content.
class TabScaffold extends StatelessWidget {
  const TabScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  /// The tab's name, for screen readers (FR-PLT-09).
  final String title;
  final Widget body;

  /// Shown before the Account button.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: AppTitle(screen: title),
      actions: [
        ...actions,
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          tooltip: AppLocalizations.of(context).accountTitle,
          onPressed: () => context.push('/account'),
        ),
      ],
    ),
    body: ContentWidth(child: body),
  );
}
