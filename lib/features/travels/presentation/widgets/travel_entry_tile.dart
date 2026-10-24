import 'package:flutter/material.dart';

import '../../../../core/format/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../countries/presentation/widgets/country_card.dart';
import '../../../countries/presentation/widgets/flag_image.dart';
import '../../domain/travel_entry.dart';
import '../../domain/travel_list.dart';
import 'travel_summary.dart';

/// One row in My travels: flag, name, and the visit or wishlist details,
/// with Edit and Delete in a menu (FR-TRV-07).
///
/// Swiping toward the end edits and toward the start deletes; both mirror
/// in right-to-left layouts. The menu offers the same actions to mouse and
/// keyboard users (FR-PLT-06).
class TravelEntryTile extends StatelessWidget {
  const TravelEntryTile({
    super.key,
    required this.item,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    required this.onSwipeDelete,
  });

  final TravelListItem item;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Called once the row has slid out; the list must drop it right away.
  final VoidCallback onSwipeDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(item.country.code),
      background: _SwipeAction(
        alignment: AlignmentDirectional.centerStart,
        color: scheme.primaryContainer,
        foreground: scheme.onPrimaryContainer,
        icon: Icons.edit_outlined,
        label: l10n.detailsEdit,
      ),
      secondaryBackground: _SwipeAction(
        alignment: AlignmentDirectional.centerEnd,
        color: scheme.errorContainer,
        foreground: scheme.onErrorContainer,
        icon: Icons.delete_outline_rounded,
        label: l10n.travelsDelete,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false; // Editing keeps the row.
        }
        return true;
      },
      onDismissed: (_) => onSwipeDelete(),
      child: _TileBody(
        item: item,
        onOpen: onOpen,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

class _TileBody extends StatelessWidget {
  const _TileBody({
    required this.item,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final TravelListItem item;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final entry = item.entry;
    final name = item.country.name(arabic: arabic);
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 4, 10),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                height: 40,
                child: Hero(
                  tag: flagHeroTag(item.country.code),
                  child: FramedFlag(
                    country: item.country,
                    radius: 4,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    if (entry.status == TravelStatus.visited)
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            entry.visitedOn == null
                                ? l10n.travelsNoDate
                                : context.formatDate(entry.visitedOn!),
                            style: secondary,
                          ),
                          if (entry.rating != null)
                            RatingStars(rating: entry.rating!, size: 16),
                        ],
                      )
                    else
                      Text(wishlistSummary(l10n, entry), style: secondary),
                  ],
                ),
              ),
              MenuAnchor(
                builder: (context, controller, _) => IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  tooltip: l10n.travelsEntryMenu(name),
                  onPressed: () => controller.isOpen
                      ? controller.close()
                      : controller.open(),
                ),
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                    child: Text(l10n.detailsEdit),
                  ),
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.delete_outline_rounded),
                    onPressed: onDelete,
                    child: Text(l10n.travelsDelete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeAction extends StatelessWidget {
  const _SwipeAction({
    required this.alignment,
    required this.color,
    required this.foreground,
    required this.icon,
    required this.label,
  });

  final AlignmentDirectional alignment;
  final Color color;
  final Color foreground;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: foreground)),
          ],
        ),
      ),
    ),
  );
}
