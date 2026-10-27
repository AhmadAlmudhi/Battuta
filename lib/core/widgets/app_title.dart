import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'battuta_logo.dart';

/// The app bar title on every screen: the logo, with the app's name, Battuta
/// or بطوطة, centered by the theme (FR-PLT-09).
///
/// Screen readers also hear [screen], the page's own name, as the browser tab
/// title gives it (FR-PLT-07), so they still know where they are.
class AppTitle extends StatelessWidget {
  const AppTitle({super.key, this.screen});

  final String? screen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      header: true,
      label: switch (screen) {
        final screen? => l10n.pageTitle(screen, l10n.appName),
        null => l10n.appName,
      },
      child: const ExcludeSemantics(child: BattutaLogo()),
    );
  }
}
