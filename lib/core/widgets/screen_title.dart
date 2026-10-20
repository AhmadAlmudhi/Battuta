import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Sets the browser tab title to the screen name in the app language, for
/// example Japan · Battuta (FR-PLT-07).
class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.screen, required this.child});

  final String screen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Title(
      title: l10n.pageTitle(screen, l10n.appName),
      color: Theme.of(context).colorScheme.primary,
      child: child,
    );
  }
}
