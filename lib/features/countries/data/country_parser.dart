import '../domain/country.dart';

/// Parses one REST Countries v5 record, as returned by the API and stored in
/// the bundled snapshot (field mapping in PRD section 8.1).
///
/// The API uses empty strings for missing values, so they are read as null.
/// Returns null for records without ISO codes (a few disputed territories),
/// because the app keys routes, flags, and entries by code.
Country? parseCountry(Map<String, Object?> json) {
  final codes = _map(json['codes']);
  final code = _string(codes['alpha_3'])?.toUpperCase();
  final alpha2 = _string(codes['alpha_2'])?.toLowerCase();
  final names = _map(json['names']);
  final nameEn = _string(names['common']);
  if (code == null || alpha2 == null || nameEn == null) return null;

  final arabic = _map(_map(names['translations'])['ara']);
  final flag = _map(json['flag']);

  return Country(
    code: code,
    alpha2: alpha2,
    nameEn: nameEn,
    nameOfficialEn: _string(names['official']) ?? nameEn,
    nameAr: _string(arabic['common']),
    nameOfficialAr: _string(arabic['official']),
    region: _string(json['region']) ?? 'Other',
    subregion: _string(json['subregion']),
    capital: _primaryCapital(json['capitals']),
    population: _number(json['population'])?.toInt() ?? 0,
    areaKm2: _number(_map(json['area'])['kilometers'])?.toDouble(),
    languages: [
      for (final language in _list(json['languages']))
        ?_string(_map(language)['name']),
    ],
    currencies: [
      for (final currency in _list(json['currencies']).map(_map))
        if (_string(currency['code']) case final currencyCode?)
          Currency(
            code: currencyCode,
            name: _string(currency['name']) ?? currencyCode,
            symbol: _string(currency['symbol']),
          ),
    ],
    borders: [for (final border in _list(json['borders'])) ?_string(border)],
    timezones: [for (final zone in _list(json['timezones'])) ?_string(zone)],
    mapsUrl: _string(_map(json['links'])['google_maps']),
    flagAlt: _string(flag['description']),
    flagColor: _string(_map(flag['colors'])['dominant']),
  );
}

/// The capital marked primary, else the first one listed.
String? _primaryCapital(Object? value) {
  final capitals = _list(value).map(_map).toList();
  final primary = capitals.where(
    (capital) => _map(capital['attributes'])['primary'] == true,
  );
  final chosen = primary.isNotEmpty ? primary.first : capitals.firstOrNull;
  return chosen == null ? null : _string(chosen['name']);
}

Map<String, Object?> _map(Object? value) =>
    value is Map<String, Object?> ? value : const {};

List<Object?> _list(Object? value) => value is List<Object?> ? value : const [];

String? _string(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

num? _number(Object? value) => value is num ? value : null;
