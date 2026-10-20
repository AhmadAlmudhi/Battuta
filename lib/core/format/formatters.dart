import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Numbers and dates in the app language. Both locales use Western digits
/// (D-5), which is intl's default for `ar`.
extension LocaleFormatting on BuildContext {
  String get _localeTag => Localizations.localeOf(this).toLanguageTag();

  /// 68,000,000
  String formatInteger(num value) =>
      NumberFormat.decimalPattern(_localeTag).format(value);

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
