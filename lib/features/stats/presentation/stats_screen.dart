import 'package:flutter/material.dart';

import '../../../core/layout/app_shell.dart';
import '../../../core/widgets/placeholder_body.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../l10n/app_localizations.dart';

/// Stats tab. Built in the Stats feature.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScreenTitle(
      screen: l10n.navStats,
      child: TabScaffold(title: l10n.navStats, body: const PlaceholderBody()),
    );
  }
}
