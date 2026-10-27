import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/format/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/adaptive_modal.dart';
import '../../../l10n/app_localizations.dart';
import '../../countries/domain/country.dart';
import '../../countries/presentation/widgets/flag_image.dart';
import '../domain/travel_entry.dart';
import '../domain/travel_validation.dart';
import 'travel_providers.dart';

/// Opens the visit form (FR-TRV-01). Pass the current [entry] to edit a visit
/// or to turn a wishlist entry into a visit, keeping its notes (FR-TRV-03).
/// Completes with true when saved.
Future<bool> showVisitForm(
  BuildContext context, {
  required Country country,
  TravelEntry? entry,
}) async =>
    await showAdaptiveModal<bool>(
      context,
      builder: (_) => VisitForm(country: country, entry: entry),
    ) ??
    false;

/// Opens the wishlist form (FR-TRV-04). Completes with true when saved.
Future<bool> showWishlistForm(
  BuildContext context, {
  required Country country,
  TravelEntry? entry,
}) async =>
    await showAdaptiveModal<bool>(
      context,
      builder: (_) => WishlistForm(country: country, entry: entry),
    ) ??
    false;

class VisitForm extends ConsumerStatefulWidget {
  const VisitForm({super.key, required this.country, this.entry});

  final Country country;
  final TravelEntry? entry;

  @override
  ConsumerState<VisitForm> createState() => _VisitFormState();
}

class _VisitFormState extends ConsumerState<VisitForm> {
  late final bool _editingVisit = widget.entry?.status == TravelStatus.visited;
  late DateTime? _date = _editingVisit ? widget.entry!.visitedOn : null;
  late int? _rating = _editingVisit ? widget.entry!.rating : null;
  late final _notes = TextEditingController(text: widget.entry?.notes ?? '');
  bool _saving = false;

  DateTime get _now => ref.read(clockProvider)();
  bool get _dateValid => TravelValidation.isVisitDateValid(_date, _now);
  bool get _notesValid => TravelValidation.isNotesValid(_notes.text);
  bool get _canSave => _dateValid && _notesValid && !_saving;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = _now;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      currentDate: now,
      firstDate: DateTime(1900),
      // Later dates can be picked so the rule can explain itself
      // (AC-TRV-01) instead of the picker silently refusing them.
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    await ref
        .read(travelRepositoryProvider)
        .saveVisit(
          widget.country.code,
          visitedOn: _date,
          rating: _rating,
          notes: _notes.text.trim(),
        );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final now = _now;
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    bool isDay(DateTime day) =>
        _date != null && DateUtils.isSameDay(_date, day);
    // Today and Yesterday are one tap; any other day comes from the calendar.
    final picked = _date != null && !isDay(today) && !isDay(yesterday);

    return _FormFrame(
      country: widget.country,
      title: l10n.visitFormTitle(widget.country.name(arabic: arabic)),
      canSave: _canSave,
      onSave: _save,
      children: [
        _Label(
          l10n.visitFormDate,
          clear: l10n.visitFormClearDate,
          onClear: _date == null ? null : () => setState(() => _date = null),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (day, label) in [
              (today, l10n.visitFormToday),
              (yesterday, l10n.visitFormYesterday),
            ])
              ChoiceChip(
                label: Text(label),
                selected: isDay(day),
                showCheckmark: false,
                // Choosing the selected day again clears it.
                onSelected: (selected) =>
                    setState(() => _date = selected ? day : null),
              ),
            ChoiceChip(
              avatar: const Icon(Icons.calendar_today_rounded),
              label: Text(
                picked ? context.formatDate(_date!) : l10n.visitFormAddDate,
              ),
              selected: picked,
              showCheckmark: false,
              onSelected: (_) => _pickDate(),
            ),
          ],
        ),
        if (!_dateValid)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                l10n.validationVisitDateFuture,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        _Label(
          l10n.visitFormRating,
          clear: l10n.visitFormClearRating,
          onClear: _rating == null
              ? null
              : () => setState(() => _rating = null),
        ),
        _RatingInput(
          value: _rating,
          onChanged: (rating) => setState(() => _rating = rating),
        ),
        const SizedBox(height: 24),
        _Label(l10n.formNotes),
        _NotesField(
          controller: _notes,
          hint: l10n.visitFormNotesHint,
          onChanged: () => setState(() {}),
        ),
      ],
    );
  }
}

class WishlistForm extends ConsumerStatefulWidget {
  const WishlistForm({super.key, required this.country, this.entry});

  final Country country;
  final TravelEntry? entry;

  @override
  ConsumerState<WishlistForm> createState() => _WishlistFormState();
}

class _WishlistFormState extends ConsumerState<WishlistForm> {
  late WishlistPriority _priority =
      widget.entry?.priority ?? WishlistPriority.medium;
  late int? _targetYear = widget.entry?.targetYear;
  late final _notes = TextEditingController(text: widget.entry?.notes ?? '');
  bool _saving = false;

  /// The chosen year's chip, scrolled into view when the form opens.
  final _chosenYear = GlobalKey();

  bool get _canSave => TravelValidation.isNotesValid(_notes.text) && !_saving;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chosenYear.currentContext case final chip?) {
        Scrollable.ensureVisible(chip, alignment: 0.5);
      }
    });
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    await ref
        .read(travelRepositoryProvider)
        .saveWishlist(
          widget.country.code,
          priority: _priority,
          targetYear: _targetYear,
          notes: _notes.text.trim(),
        );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    // Only the allowed years, so the year can't be out of range.
    final years = [
      null,
      ...TravelValidation.targetYears(ref.read(clockProvider)()),
    ];

    return _FormFrame(
      country: widget.country,
      title: l10n.wishlistFormTitle(widget.country.name(arabic: arabic)),
      canSave: _canSave,
      onSave: _save,
      children: [
        _Label(l10n.wishlistFormPriority),
        Row(
          children: [
            for (final (i, (priority, icon, label)) in [
              (
                WishlistPriority.high,
                Icons.keyboard_double_arrow_up_rounded,
                l10n.priorityHighShort,
              ),
              (
                WishlistPriority.medium,
                Icons.drag_handle_rounded,
                l10n.priorityMediumShort,
              ),
              (
                WishlistPriority.low,
                Icons.keyboard_double_arrow_down_rounded,
                l10n.priorityLowShort,
              ),
            ].indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _PriorityOption(
                  icon: icon,
                  label: label,
                  selected: _priority == priority,
                  onTap: () => setState(() => _priority = priority),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        _Label(l10n.wishlistFormTargetYear),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: years.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final year = years[i];
              return Center(
                child: ChoiceChip(
                  key: year == _targetYear ? _chosenYear : null,
                  label: Text(
                    year == null ? l10n.wishlistFormAnyTime : '$year',
                  ),
                  selected: year == _targetYear,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _targetYear = year),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        _Label(l10n.formNotes),
        _NotesField(
          controller: _notes,
          hint: l10n.wishlistFormNotesHint,
          onChanged: () => setState(() {}),
        ),
      ],
    );
  }
}

/// A form's frame: the country's round flag and the title, a close button,
/// the fields, which scroll, and a full-width Save that stays above the
/// keyboard. Ctrl+Enter or Cmd+Enter saves from anywhere in the form, since
/// Enter adds a line in the notes (FR-PLT-05).
class _FormFrame extends StatelessWidget {
  const _FormFrame({
    required this.country,
    required this.title,
    required this.canSave,
    required this.onSave,
    required this.children,
  });

  final Country country;
  final String title;
  final bool canSave;
  final VoidCallback onSave;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): onSave,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): onSave,
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox.square(
                dimension: 44,
                child: Material(
                  color: scheme.surfaceContainerHighest,
                  clipBehavior: Clip.antiAlias,
                  shape: CircleBorder(
                    side: BorderSide(color: scheme.outlineVariant),
                  ),
                  child: FlagImage(
                    country: country,
                    fit: BoxFit.cover,
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
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.formOptional,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.commonClose,
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
            onPressed: canSave ? onSave : null,
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }
}

/// A section's title, with a [clear] action at its end for sections that
/// can be emptied. The action keeps its space while hidden, so nothing
/// shifts when it appears.
class _Label extends StatelessWidget {
  const _Label(this.text, {this.clear, this.onClear});

  final String text;
  final String? clear;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final title = Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: clear == null ? 10 : 2),
      child: switch (clear) {
        null => title,
        final clear => Row(
          children: [
            Expanded(child: title),
            // Hidden from screen readers too while there's nothing to clear.
            Visibility(
              visible: onClear != null,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TextButton(onPressed: onClear, child: Text(clear)),
            ),
          ],
        ),
      },
    );
  }
}

/// One of the three wishlist priorities, with an arrow for its level.
class _PriorityOption extends StatelessWidget {
  const _PriorityOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        // Outlined when not chosen, so the options show on any surface.
        color: selected ? scheme.primaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Column(
              children: [
                Icon(icon, color: foreground),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w700 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Up to 500 characters. The count shows only near the limit; longer text
/// isn't cut off but shows the rule and blocks Save (PRD section 8.6).
class _NotesField extends StatelessWidget {
  const _NotesField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;

  /// Characters typed before the count appears.
  static const _countFrom = 400;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final corners = BorderRadius.circular(16);
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      minLines: 3,
      maxLines: 6,
      maxLength: TravelValidation.notesMaxLength,
      maxLengthEnforcement: MaxLengthEnforcement.none,
      buildCounter:
          (context, {required currentLength, required isFocused, maxLength}) =>
              currentLength < _countFrom
              ? null
              : Text('$currentLength/$maxLength'),
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: corners,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: corners,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorText: TravelValidation.isNotesValid(controller.text)
            ? null
            : l10n.validationNotesTooLong,
      ),
    );
  }
}

/// 1 to 5 large stars, optional, with a word for the chosen rating.
/// Selecting the current rating again clears it.
class _RatingInput extends StatelessWidget {
  const _RatingInput({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final rating = value;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var star = 1; star <= 5; star++)
              IconButton(
                tooltip: l10n.detailsRating(star),
                iconSize: 36,
                isSelected: rating != null && star <= rating,
                onPressed: () => onChanged(rating == star ? null : star),
                icon: Icon(Icons.star_outline_rounded, color: scheme.outline),
                // Amber alone is too faint on light surfaces (PRD 1.4), so the
                // filled star keeps a dark outline.
                selectedIcon: Stack(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: BrandColors.stampAmber,
                    ),
                    Icon(
                      Icons.star_outline_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
          ],
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            rating == null
                ? l10n.visitFormRateHint
                : l10n.visitFormRatingWord('$rating'),
            style: rating == null
                ? theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  )
                : theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
          ),
        ),
      ],
    );
  }
}
