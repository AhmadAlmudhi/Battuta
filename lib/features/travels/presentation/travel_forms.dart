import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/format/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/adaptive_modal.dart';
import '../../../l10n/app_localizations.dart';
import '../../countries/domain/country.dart';
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

    return _FormFrame(
      title: l10n.visitFormTitle(widget.country.name(arabic: arabic)),
      canSave: _canSave,
      onSave: _save,
      children: [
        _Label(l10n.visitFormDate),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_rounded),
              label: Text(
                _date == null
                    ? l10n.visitFormAddDate
                    : context.formatDate(_date!),
              ),
            ),
            if (_date != null)
              IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: l10n.visitFormClearDate,
                onPressed: () => setState(() => _date = null),
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
        const SizedBox(height: 20),
        _Label(l10n.visitFormRating),
        _RatingInput(
          value: _rating,
          onChanged: (rating) => setState(() => _rating = rating),
        ),
        const SizedBox(height: 20),
        _NotesField(controller: _notes, onChanged: () => setState(() {})),
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

  bool get _canSave => TravelValidation.isNotesValid(_notes.text) && !_saving;

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
    final years = TravelValidation.targetYears(ref.read(clockProvider)());

    return _FormFrame(
      title: l10n.wishlistFormTitle(widget.country.name(arabic: arabic)),
      canSave: _canSave,
      onSave: _save,
      children: [
        _Label(l10n.wishlistFormPriority),
        SegmentedButton<WishlistPriority>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: WishlistPriority.high,
              label: Text(l10n.priorityHighShort),
            ),
            ButtonSegment(
              value: WishlistPriority.medium,
              label: Text(l10n.priorityMediumShort),
            ),
            ButtonSegment(
              value: WishlistPriority.low,
              label: Text(l10n.priorityLowShort),
            ),
          ],
          selected: {_priority},
          onSelectionChanged: (selection) =>
              setState(() => _priority = selection.single),
        ),
        const SizedBox(height: 20),
        _Label(l10n.wishlistFormTargetYear),
        // A list of allowed years, so the year can't be out of range.
        DropdownMenu<int?>(
          initialSelection: _targetYear,
          expandedInsets: EdgeInsets.zero,
          menuHeight: 320,
          onSelected: (year) => setState(() => _targetYear = year),
          dropdownMenuEntries: [
            DropdownMenuEntry(
              value: null,
              label: l10n.wishlistFormNoTargetYear,
            ),
            for (final year in years)
              DropdownMenuEntry(value: year, label: '$year'),
          ],
        ),
        const SizedBox(height: 20),
        _NotesField(controller: _notes, onChanged: () => setState(() {})),
      ],
    );
  }
}

/// Title, scrolling fields, and Cancel and Save. Ctrl+Enter or Cmd+Enter
/// saves from anywhere in the form, since Enter adds a line in the notes
/// (FR-PLT-05).
class _FormFrame extends StatelessWidget {
  const _FormFrame({
    required this.title,
    required this.canSave,
    required this.onSave,
    required this.children,
  });

  final String title;
  final bool canSave;
  final VoidCallback onSave;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): onSave,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): onSave,
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: canSave ? onSave : null,
                child: Text(l10n.commonSave),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

/// Up to 500 characters, counted live. Longer text isn't cut off; it shows
/// the rule and blocks Save instead (PRD section 8.6).
class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      minLines: 3,
      maxLines: 6,
      maxLength: TravelValidation.notesMaxLength,
      maxLengthEnforcement: MaxLengthEnforcement.none,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        labelText: l10n.formNotes,
        hintText: l10n.formNotesHint,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
        errorText: TravelValidation.isNotesValid(controller.text)
            ? null
            : l10n.validationNotesTooLong,
      ),
    );
  }
}

/// 1 to 5 stars, optional. Selecting the current rating again clears it.
class _RatingInput extends StatelessWidget {
  const _RatingInput({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var star = 1; star <= 5; star++)
          IconButton(
            tooltip: l10n.detailsRating(star),
            isSelected: value != null && star <= value!,
            onPressed: () => onChanged(value == star ? null : star),
            icon: Icon(Icons.star_outline_rounded, color: scheme.outline),
            // Amber alone is too faint on light surfaces (PRD 1.4), so the
            // filled star keeps a dark outline.
            selectedIcon: Stack(
              children: [
                const Icon(Icons.star_rounded, color: BrandColors.stampAmber),
                Icon(
                  Icons.star_outline_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        if (value != null)
          TextButton(
            onPressed: () => onChanged(null),
            child: Text(l10n.visitFormClearRating),
          ),
      ],
    );
  }
}
