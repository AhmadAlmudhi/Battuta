import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/format/formatters.dart';
import '../../../../core/widgets/note_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../countries/domain/country.dart';
import '../../domain/travel_entry.dart';
import '../travel_actions.dart';
import '../travel_forms.dart';
import '../travel_providers.dart';
import 'travel_summary.dart';

/// The country's save actions on its details screen (FR-DET-04): Mark as
/// visited and Add to wishlist side by side when it isn't saved, otherwise
/// a card with its status, Edit, and Remove.
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
      // Equal halves, as tall as the taller label.
      AsyncData() => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FilledButton.icon(
                style: _tall,
                onPressed: () => showVisitForm(context, country: country),
                icon: const Icon(Icons.check_rounded),
                label: Text(l10n.detailsMarkVisited),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                style: _tall,
                onPressed: () => showWishlistForm(context, country: country),
                icon: const Icon(Icons.bookmark_add_outlined),
                label: Text(l10n.detailsAddToWishlist),
              ),
            ),
          ],
        ),
      ),
      _ => const SizedBox(height: 48),
    };
  }
}

/// The main actions are full-width and at least 48 dp tall.
const _tall = ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(0, 48)));

/// A saved country's status in its color, Stamp Amber for Visited or teal
/// for Wishlist, with the visit date or wishlist details, rating, and notes.
/// Edit and Remove sit in its corner; a wishlist country can be marked as
/// visited.
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
    final accent = visited ? scheme.secondary : scheme.primary;
    final background = Color.alphaBlend(
      visited
          ? scheme.secondary.withValues(alpha: 0.16)
          : scheme.primaryContainer.withValues(alpha: 0.45),
      scheme.surfaceContainerLow,
    );

    final details = [
      if (visited && entry.visitedOn != null)
        l10n.detailsVisitedOn(context.formatDate(entry.visitedOn!)),
      if (!visited) wishlistSummary(l10n, entry),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 4, 16),
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
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
                IconButton(
                  tooltip: l10n.detailsEdit,
                  onPressed: () => visited
                      ? showVisitForm(context, country: country, entry: entry)
                      : showWishlistForm(
                          context,
                          country: country,
                          entry: entry,
                        ),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: l10n.detailsRemove,
                  onPressed: () => removeWithUndo(
                    context,
                    ref,
                    country,
                    message: (l10n, name) => l10n.detailsRemoved(name),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            if (visited && entry.rating != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 52, top: 4),
                child: RatingStars(rating: entry.rating!),
              ),
            if (entry.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 12, end: 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: BorderDirectional(
                      start: BorderSide(color: accent, width: 3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 12,
                      top: 2,
                      bottom: 2,
                    ),
                    child: NoteText(
                      entry.notes,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            if (!visited)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 16, end: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: _tall,
                    onPressed: () =>
                        showVisitForm(context, country: country, entry: entry),
                    icon: const Icon(Icons.check_rounded),
                    label: Text(l10n.detailsMarkVisited),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
