import 'package:flutter/material.dart';

import '../../../../core/format/formatters.dart';
import '../../../../core/widgets/note_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../countries/presentation/region_names.dart';
import '../../../countries/presentation/widgets/country_card.dart';
import '../../../countries/presentation/widgets/flag_image.dart';
import '../../domain/travel_entry.dart';
import '../../domain/travel_list.dart';
import 'travel_summary.dart';

/// One row in My travels: round flag, name, the rating or priority with
/// the region and date or target year, and the start of the notes, with
/// Edit and Delete in a menu (FR-TRV-07).
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
    final scheme = theme.colorScheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final entry = item.entry;
    final country = item.country;
    final name = country.name(arabic: arabic);
    final visited = entry.status == TravelStatus.visited;
    // A missing date or year is left out, not spelled out.
    final details = [
      regionName(l10n, country.region),
      if (visited && entry.visitedOn != null)
        context.formatDate(entry.visitedOn!),
      if (!visited && entry.targetYear != null)
        l10n.detailsTargetYear('${entry.targetYear}'),
    ].join(' · ');
    final note = entry.notes.split('\n').first.trim();

    return Material(
      color: scheme.surfaceContainerLow,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 4, 12),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 48,
                child: Material(
                  color: scheme.surfaceContainerHighest,
                  clipBehavior: Clip.antiAlias,
                  shape: CircleBorder(
                    side: BorderSide(color: scheme.outlineVariant),
                  ),
                  child: Hero(
                    tag: flagHeroTag(country.code),
                    // The circle opens into the details header's frame.
                    flightShuttleBuilder: (_, animation, _, _, _) =>
                        FlagFlight(country: country, progress: animation),
                    child: FlagImage(
                      country: country,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (visited && entry.rating != null)
                          RatingStars(rating: entry.rating!, size: 14),
                        if (!visited)
                          _PriorityPill(
                            priority: entry.priority ?? WishlistPriority.medium,
                          ),
                        Text(
                          details,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (note.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: NoteText(
                          note,
                          maxLines: 1,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
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

/// A wishlist priority as a small pill: soft red for High, teal for
/// Medium, and grey for Low, with the same arrows as the form.
class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.priority});

  final WishlistPriority priority;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (icon, label, background, foreground) = switch (priority) {
      WishlistPriority.high => (
        Icons.keyboard_double_arrow_up_rounded,
        l10n.priorityHighShort,
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      WishlistPriority.medium => (
        Icons.drag_handle_rounded,
        l10n.priorityMediumShort,
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      WishlistPriority.low => (
        Icons.keyboard_double_arrow_down_rounded,
        l10n.priorityLowShort,
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
    };
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: background,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(6, 2, 8, 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
  Widget build(BuildContext context) => ColoredBox(
    // The group's rounded panel clips the corners.
    color: color,
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
