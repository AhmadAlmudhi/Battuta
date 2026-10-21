import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/format/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../countries/domain/country.dart';
import '../../../countries/presentation/country_providers.dart';
import '../../../countries/presentation/widgets/flag_image.dart';
import '../../../travels/domain/travel_entry.dart';
import '../../../travels/presentation/travel_forms.dart';
import '../../../travels/presentation/travel_providers.dart';
import '../../../travels/presentation/widgets/visit_stamp.dart';

/// The card for the country selected on the map (FR-MAP-12, FR-MAP-13): its
/// flag, name, and status, with the same actions and forms as Country
/// details. Remove stays on Country details and My travels.
class MapCountryCard extends ConsumerWidget {
  const MapCountryCard({super.key, required this.code, required this.onClose});

  final String code;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final country = ref.watch(countryByCodeProvider(code)).valueOrNull;
    final entry = ref.watch(travelEntryProvider(code));
    if (country == null || entry is! AsyncData<TravelEntry?>) {
      return const SizedBox.shrink();
    }
    final saved = entry.value;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';

    final status = switch (saved) {
      null => l10n.mapNotVisited,
      TravelEntry(status: TravelStatus.visited, :final visitedOn?) =>
        l10n.detailsVisitedOn(context.formatDate(visitedOn)),
      TravelEntry(status: TravelStatus.visited) => l10n.detailsVisited,
      TravelEntry(:final targetYear?) =>
        '${l10n.detailsOnWishlist} · ${l10n.detailsTargetYear('$targetYear')}',
      TravelEntry() => l10n.detailsOnWishlist,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // The passport stamp lands on the flag after the map's color
                // spread (FR-MAP-32), as it does on Country details.
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: 48,
                        height: 32,
                        child: FlagImage(
                          country: country,
                          fit: BoxFit.cover,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      end: -10,
                      bottom: -12,
                      child: IgnorePointer(
                        child: ExcludeSemantics(
                          child: SizedBox.square(
                            dimension: 32,
                            child: FittedBox(
                              child: VisitStamp(
                                countryCode: code,
                                delay: const Duration(milliseconds: 500),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        country.name(arabic: arabic),
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        status,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  tooltip: l10n.commonClose,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._actions(context, l10n, country, saved),
                TextButton(
                  onPressed: () => context.push('/country/$code'),
                  child: Text(l10n.mapOpenDetails),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _actions(
    BuildContext context,
    AppLocalizations l10n,
    Country country,
    TravelEntry? saved,
  ) {
    Widget markVisited() => FilledButton.icon(
      onPressed: () => showVisitForm(context, country: country, entry: saved),
      icon: const Icon(Icons.check_rounded),
      label: Text(l10n.detailsMarkVisited),
    );
    Widget edit(Future<bool> Function() open) => OutlinedButton.icon(
      onPressed: open,
      icon: const Icon(Icons.edit_outlined),
      label: Text(l10n.detailsEdit),
    );

    return switch (saved?.status) {
      null => [
        markVisited(),
        OutlinedButton.icon(
          onPressed: () => showWishlistForm(context, country: country),
          icon: const Icon(Icons.bookmark_add_outlined),
          label: Text(l10n.detailsAddToWishlist),
        ),
      ],
      TravelStatus.wishlist => [
        markVisited(),
        edit(() => showWishlistForm(context, country: country, entry: saved)),
      ],
      TravelStatus.visited => [
        edit(() => showVisitForm(context, country: country, entry: saved)),
      ],
    };
  }
}
