import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../countries/domain/country.dart';
import '../../domain/travel_entry.dart';
import '../travel_actions.dart';
import '../travel_forms.dart';
import '../travel_providers.dart';
import 'travel_summary.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final visited = entry.status == TravelStatus.visited;

    final details = [
      if (visited && entry.visitedOn != null)
        l10n.detailsVisitedOn(context.formatDate(entry.visitedOn!)),
      if (!visited) wishlistSummary(l10n, entry),
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
              RatingStars(rating: entry.rating!),
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
                  onPressed: () => removeWithUndo(
                    context,
                    ref,
                    country,
                    message: (l10n, name) => l10n.detailsRemoved(name),
                  ),
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
