import 'package:flutter/material.dart';
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
