import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../countries/domain/country.dart';
import 'travel_providers.dart';

/// Removes the country's entry at once and offers Undo for 4 seconds
/// (FR-TRV-07, AC-TRV-03). [message] builds the snack bar text from the
/// country's name.
Future<void> removeWithUndo(
  BuildContext context,
  WidgetRef ref,
  Country country, {
  required String Function(AppLocalizations l10n, String name) message,
}) async {
  final l10n = AppLocalizations.of(context);
  final arabic = Localizations.localeOf(context).languageCode == 'ar';
  final messenger = ScaffoldMessenger.of(context);
  final repository = ref.read(travelRepositoryProvider);

  final removed = await repository.remove(country.code);
  if (removed == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message(l10n, country.name(arabic: arabic))),
        duration: const Duration(seconds: 4),
        // With an action, snack bars stay until tapped unless told not to.
        persist: false,
        action: SnackBarAction(
          label: l10n.commonUndo,
          onPressed: () => repository.restore(removed),
        ),
      ),
    );
}

/// Marks [countryCodes] as visited at once, from Explore's quick select
/// (FR-EXP-13), and offers Undo for 4 seconds, which puts every country
/// back as it was: unsaved, or on the Wishlist with its details.
Future<void> markVisitedWithUndo(
  BuildContext context,
  WidgetRef ref,
  Set<String> countryCodes,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final repository = ref.read(travelRepositoryProvider);

  final before = await repository.markVisited(countryCodes);
  if (before.isEmpty) return;
  if (!kIsWeb) unawaited(HapticFeedback.lightImpact());
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.exploreMarkedVisited(before.length)),
        duration: const Duration(seconds: 4),
        persist: false,
        action: SnackBarAction(
          label: l10n.commonUndo,
          onPressed: () async {
            for (final MapEntry(key: code, value: entry) in before.entries) {
              if (entry == null) {
                await repository.remove(code);
              } else {
                await repository.restore(entry);
              }
            }
          },
        ),
      ),
    );
}
