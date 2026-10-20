import 'package:freezed_annotation/freezed_annotation.dart';

part 'country.freezed.dart';
part 'country.g.dart';

/// A country or territory from the dataset (PRD section 8.1).
@freezed
abstract class Country with _$Country {
  const Country._();

  const factory Country({
    /// 3-letter ISO code, for example SAU. Primary key and route parameter.
    required String code,

    /// Lowercase 2-letter ISO code, used for the flag asset.
    required String alpha2,
    required String nameEn,
    required String nameOfficialEn,
    String? nameAr,
    String? nameOfficialAr,
    required String region,
    String? subregion,
    String? capital,
    required int population,
    double? areaKm2,
    @Default([]) List<String> languages,
    @Default([]) List<Currency> currencies,

    /// 3-letter codes of neighboring countries; empty for no land borders.
    @Default([]) List<String> borders,
    @Default([]) List<String> timezones,
    String? mapsUrl,
    String? flagAlt,

    /// Dominant flag color as hex, for example #006C35.
    String? flagColor,
  }) = _Country;

  /// The name in the app language, falling back to English (PRD section 10.4).
  String name({required bool arabic}) => arabic ? (nameAr ?? nameEn) : nameEn;

  String officialName({required bool arabic}) =>
      arabic ? (nameOfficialAr ?? nameOfficialEn) : nameOfficialEn;

  /// Bundled 320 px flag, from `tool/fetch_flags.dart` (PRD section 11.4).
  String get flagAsset => 'assets/flags/$alpha2.png';
}

@freezed
abstract class Currency with _$Currency {
  const factory Currency({
    required String code,
    required String name,
    String? symbol,
  }) = _Currency;

  factory Currency.fromJson(Map<String, Object?> json) =>
      _$CurrencyFromJson(json);
}
