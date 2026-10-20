import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import 'window_size.dart';

/// The three main tabs: a bottom bar on compact and medium screens, a side
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
    final destinations = [
      (Icons.explore_outlined, Icons.explore_rounded, l10n.navExplore),
      (Icons.luggage_outlined, Icons.luggage_rounded, l10n.navTravels),
      (Icons.insights_outlined, Icons.insights_rounded, l10n.navStats),
    ];

    if (WindowSizeClass.of(context) == WindowSizeClass.expanded) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final (icon, selectedIcon, label) in destinations)
                  NavigationRailDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selectedIcon),
                    label: Text(label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _select,
        destinations: [
          for (final (icon, selectedIcon, label) in destinations)
            NavigationDestination(
              icon: Icon(icon),
              selectedIcon: Icon(selectedIcon),
              label: label,
            ),
        ],
      ),
    );
  }
}

/// Scaffold for a main tab: title, the Account button every tab has, and
/// centered content.
class TabScaffold extends StatelessWidget {
  const TabScaffold({super.key, required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: [
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
