import 'package:flutter/material.dart';

import '../../../core/layout/app_shell.dart';
import '../../../core/widgets/placeholder_body.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../l10n/app_localizations.dart';

/// My travels tab: Visited and Wishlist. Built in the My travels feature.
class TravelsScreen extends StatelessWidget {
  const TravelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScreenTitle(
      screen: l10n.navTravels,
      child: TabScaffold(title: l10n.navTravels, body: const PlaceholderBody()),
    );
  }
}
