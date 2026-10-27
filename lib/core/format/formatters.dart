import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Western digits (0 to 9) for dates in Arabic too (D-5). Flutter's Arabic
/// date data defaults to Arabic-Indic digits; numbers already use Western
/// digits. Call before the app starts, so Material's own dates, such as in
/// the date picker, follow it as well.
void useWesternDigits() => DateFormat.useNativeDigitsByDefaultFor('ar', false);

/// Numbers and dates in the app language, with Western digits in both
/// languages (D-5).
extension LocaleFormatting on BuildContext {
  String get _localeTag => Localizations.localeOf(this).toLanguageTag();

  /// 68,000,000
  String formatInteger(num value) =>
      NumberFormat.decimalPattern(_localeTag).format(value);

  /// 35.3M or 35.3 مليون: three significant digits, for figures read at a
  /// glance (FR-DET-02).
  String formatCompact(num value) => (NumberFormat.compact(
    locale: _localeTag,
  )..significantDigits = 3).format(value);

  /// Up to 2 decimals for small values, such as an area of 0.44 km².
  String formatDecimal(num value) =>
      NumberFormat('#,##0.##', _localeTag).format(value);

  /// One decimal place, such as 4.8 for 4.8% (FR-STA-01).
  String formatPercent(num value) =>
      NumberFormat('#,##0.0', _localeTag).format(value);

  /// 14 March 2026, or 14 مارس 2026.
  String formatDate(DateTime date) =>
      DateFormat.yMMMMd(_localeTag).format(date);

  /// Mar 14, 2026 2:05 PM, in the app language.
  String formatDateTime(DateTime dateTime) =>
      DateFormat.yMMMd(_localeTag).add_jm().format(dateTime);
}
