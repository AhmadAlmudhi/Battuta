import 'package:characters/characters.dart';

/// Validation rules for the visit and wishlist forms (PRD section 8.6).
abstract final class TravelValidation {
  static const notesMaxLength = 500;

  /// Target years run from this year to this many years ahead.
  static const targetYearSpan = 20;

  /// Optional, and not in the future (FR-TRV-01).
  static bool isVisitDateValid(DateTime? date, DateTime now) =>
      date == null || !_dateOnly(date).isAfter(_dateOnly(now));

  /// Counted in characters as people see them, the same way the text field
  /// counts, so an emoji counts once.
  static bool isNotesValid(String notes) =>
      notes.characters.length <= notesMaxLength;

  static List<int> targetYears(DateTime now) => [
    for (var year = now.year; year <= now.year + targetYearSpan; year++) year,
  ];

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
