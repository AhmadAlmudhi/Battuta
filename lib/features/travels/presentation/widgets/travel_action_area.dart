import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format/formatters.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../countries/domain/country.dart';
import '../../domain/travel_entry.dart';
import '../travel_forms.dart';
import '../travel_providers.dart';

/// The country's save actions on its details screen (FR-DET-04): Mark as
/// visited and Add to wishlist when it isn't saved, otherwise its status
/// with Edit and Remove.
class TravelActionArea extends ConsumerWidget {
  const TravelActionArea({super.key, required this.country});

  final Country country;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entry = ref.watch(travelEntryProvider(country.code));

    return switch (entry) {
      AsyncData(value: final entry?) => _SavedCard(
        country: country,
        entry: entry,
      ),
      AsyncData() => Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            onPressed: () => showVisitForm(context, country: country),
            icon: const Icon(Icons.check_rounded),
            label: Text(l10n.detailsMarkVisited),
          ),
          OutlinedButton.icon(
            onPressed: () => showWishlistForm(context, country: country),
            icon: const Icon(Icons.bookmark_add_outlined),
            label: Text(l10n.detailsAddToWishlist),
          ),
        ],
      ),
      _ => const SizedBox(height: 40),
    };
  }
}

class _SavedCard extends ConsumerWidget {
  const _SavedCard({required this.country, required this.entry});

  final Country country;
  final TravelEntry entry;

  /// Soft-deletes the entry with a 4-second Undo (FR-TRV-07).
  Future<void> _remove(BuildContext context, WidgetRef ref) async {
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
          content: Text(l10n.detailsRemoved(country.name(arabic: arabic))),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final visited = entry.status == TravelStatus.visited;

    final details = <String>[
      if (visited && entry.visitedOn != null)
        l10n.detailsVisitedOn(context.formatDate(entry.visitedOn!)),
      if (!visited)
        switch (entry.priority ?? WishlistPriority.medium) {
          WishlistPriority.high => l10n.priorityHigh,
          WishlistPriority.medium => l10n.priorityMedium,
          WishlistPriority.low => l10n.priorityLow,
        },
      if (!visited && entry.targetYear != null)
        l10n.detailsTargetYear('${entry.targetYear}'),
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: visited ? scheme.secondary : scheme.primaryContainer,
                  ),
                  child: Icon(
                    visited ? Icons.check_rounded : Icons.bookmark_rounded,
                    color: visited
                        ? scheme.onSecondary
                        : scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visited ? l10n.detailsVisited : l10n.detailsOnWishlist,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (details.isNotEmpty)
                        Text(
                          details.join(' · '),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (visited && entry.rating != null) ...[
              const SizedBox(height: 8),
              _Stars(rating: entry.rating!),
            ],
            if (entry.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(entry.notes, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!visited)
                  FilledButton.icon(
                    onPressed: () =>
                        showVisitForm(context, country: country, entry: entry),
                    icon: const Icon(Icons.check_rounded),
                    label: Text(l10n.detailsMarkVisited),
                  ),
                OutlinedButton.icon(
                  onPressed: () => visited
                      ? showVisitForm(context, country: country, entry: entry)
                      : showWishlistForm(
                          context,
                          country: country,
                          entry: entry,
                        ),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.detailsEdit),
                ),
                TextButton.icon(
                  onPressed: () => _remove(context, ref),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.detailsRemove),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.onSurfaceVariant;
    return Semantics(
      label: AppLocalizations.of(context).detailsRating(rating),
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var star = 1; star <= 5; star++)
              Stack(
                children: [
                  if (star <= rating)
                    const Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: BrandColors.stampAmber,
                    ),
                  Icon(Icons.star_outline_rounded, size: 20, color: outline),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
