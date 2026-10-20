import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/layout/window_size.dart';
import '../../../../l10n/app_localizations.dart';
import '../country_providers.dart';
import '../explore_controller.dart';
import '../region_names.dart';

/// Opens the filter panel: a bottom sheet on compact screens, a dialog on
/// wider ones (FR-PLT-02). Esc closes either.
Future<void> showExploreFilters(BuildContext context) {
  if (WindowSizeClass.of(context) == WindowSizeClass.compact) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => const Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 24),
        child: ExploreFilterPanel(),
      ),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: ExploreFilterPanel(),
        ),
      ),
    ),
  );
}

/// Filters apply as they change, so the grid behind and the result count stay
/// live (FR-EXP-07).
class ExploreFilterPanel extends ConsumerWidget {
  const ExploreFilterPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final options = ref.watch(exploreFilterOptionsProvider).valueOrNull;
    final query = ref.watch(exploreQueryProvider);
    final controller = ref.read(exploreQueryProvider.notifier);
    final count =
        ref.watch(exploreResultsProvider(arabic)).valueOrNull?.length ?? 0;
    if (options == null) return const SizedBox.shrink();

    final subregions = options.subregionsFor(query.regions);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.filtersTitle, style: theme.textTheme.titleLarge),
            ),
            TextButton(
              onPressed: query.hasFilters ? controller.clearFilters : null,
              child: Text(l10n.filtersClearAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Section(
                  title: l10n.filtersRegion,
                  child: _ChipGroup(
                    values: options.regions,
                    selected: query.regions,
                    label: (region) => regionName(l10n, region),
                    onToggle: (region) =>
                        controller.toggleRegion(region, options),
                  ),
                ),
                if (subregions.isNotEmpty)
                  _Section(
                    title: l10n.filtersSubregion,
                    child: _ChipGroup(
                      values: subregions,
                      selected: query.subregions,
                      label: (subregion) => subregionName(l10n, subregion),
                      onToggle: controller.toggleSubregion,
                    ),
                  ),
                _Section(
                  title: l10n.filtersLanguage,
                  child: _SearchableSelect(
                    // Rebuilt when the value changes elsewhere, such as by
                    // Clear all, so the field always shows the current value.
                    key: ValueKey(('language', query.language)),
                    value: query.language,
                    anyLabel: l10n.filtersAnyLanguage,
                    entries: [
                      for (final language in options.languages)
                        (value: language, label: language),
                    ],
                    onSelected: controller.setLanguage,
                  ),
                ),
                _Section(
                  title: l10n.filtersCurrency,
                  child: _SearchableSelect(
                    key: ValueKey(('currency', query.currency)),
                    value: query.currency,
                    anyLabel: l10n.filtersAnyCurrency,
                    entries: [
                      for (final currency in options.currencies)
                        (
                          value: currency.code,
                          label: '${currency.name} (${currency.code})',
                        ),
                    ],
                    onSelected: controller.setCurrency,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(l10n.filtersShowResults(count), key: ValueKey(count)),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.values,
    required this.selected,
    required this.label,
    required this.onToggle,
  });

  final List<String> values;
  final Set<String> selected;
  final String Function(String value) label;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final value in values)
        FilterChip(
          label: Text(label(value)),
          selected: selected.contains(value),
          onSelected: (_) => onToggle(value),
        ),
    ],
  );
}

/// A single choice with type-to-filter, for the long language and currency
/// lists (FR-EXP-06). The first entry clears the choice.
class _SearchableSelect extends StatelessWidget {
  const _SearchableSelect({
    super.key,
    required this.value,
    required this.anyLabel,
    required this.entries,
    required this.onSelected,
  });

  final String? value;
  final String anyLabel;
  final List<({String value, String label})> entries;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) => DropdownMenu<String?>(
    initialSelection: value,
    expandedInsets: EdgeInsets.zero,
    enableFilter: true,
    requestFocusOnTap: true,
    menuHeight: 320,
    leadingIcon: const Icon(Icons.search_rounded),
    onSelected: onSelected,
    dropdownMenuEntries: [
      DropdownMenuEntry(value: null, label: anyLabel),
      for (final entry in entries)
        DropdownMenuEntry(value: entry.value, label: entry.label),
    ],
  );
}
