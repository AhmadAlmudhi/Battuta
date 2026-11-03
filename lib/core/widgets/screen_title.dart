import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'warm_up_scope.dart';

/// Sets the browser tab title to the screen name in the app language, for
/// example Japan · Battuta (FR-PLT-07), unless it's inside a [WarmUpScope].
class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.screen, required this.child});

  final String screen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // A screen drawn only to warm up shaders mustn't rename the tab.
    if (WarmUpScope.isWarmingUp(context)) return child;
    final l10n = AppLocalizations.of(context);
    return Title(
      title: l10n.pageTitle(screen, l10n.appName),
      color: Theme.of(context).colorScheme.primary,
      child: child,
    );
  }
}
