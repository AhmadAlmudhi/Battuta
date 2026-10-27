import 'dart:convert';

import 'package:battuta/features/countries/data/country_parser.dart';
import 'package:battuta/features/countries/domain/country.dart';

/// One REST Countries v5 record in the API's shape, with only the fields the
/// app reads.
Map<String, Object?> apiRecord({
  required String code,
  required String alpha2,
  required String name,
  String? official,
  String? nameAr,
  String? officialAr,
  required String region,
  String? subregion,
  String? capital,
  String? mapsUrl,
  int population = 1000000,
  num? area = 1000,
  List<String> languages = const [],
  List<(String, String)> currencies = const [],
  List<String> borders = const [],
  List<String> timezones = const ['UTC'],
}) => {
  'names': {
    'common': name,
    'official': official ?? name,
    'translations': {
      if (nameAr != null) 'ara': {'common': nameAr, 'official': ?officialAr},
    },
  },
  'codes': {'alpha_2': alpha2, 'alpha_3': code},
  'capitals': [
    if (capital != null)
      {
        'attributes': {'primary': true},
        'name': capital,
      },
  ],
  'flag': const {'colors': {}},
  'region': region,
  'subregion': subregion ?? '',
  'area': {'kilometers': ?area},
  'borders': borders,
  'currencies': [
    for (final (code, name) in currencies)
      {'code': code, 'name': name, 'symbol': ''},
  ],
  'languages': [
    for (final language in languages) {'name': language},
  ],
  'links': {'google_maps': mapsUrl ?? ''},
  'population': population,
  'timezones': timezones,
};

/// A small dataset that covers the acceptance criteria: French is spoken in
/// and outside Europe, Japan has no land borders, and Saudi Arabia has an
/// Arabic name that starts with the article ال.
final testRecords = [
  apiRecord(
    code: 'FRA',
    alpha2: 'FR',
    name: 'France',
    official: 'French Republic',
    nameAr: 'فرنسا',
    officialAr: 'الجمهورية الفرنسية',
    region: 'Europe',
    subregion: 'Western Europe',
    capital: 'Paris',
    mapsUrl: 'https://goo.gl/maps/france',
    population: 68000000,
    area: 551695,
    languages: ['French'],
    currencies: [('EUR', 'Euro')],
    borders: ['BEL', 'DEU', 'ESP'],
    // Overseas France, out of order like the API's list.
    timezones: ['UTC+01:00', 'UTC-10:00', 'UTC+12:00', 'UTC-03:00'],
  ),
  apiRecord(
    code: 'ESP',
    alpha2: 'ES',
    name: 'Spain',
    official: 'Kingdom of Spain',
    nameAr: 'إسبانيا',
    region: 'Europe',
    subregion: 'Southern Europe',
    population: 48000000,
    area: 505992,
    languages: ['Spanish'],
    currencies: [('EUR', 'Euro')],
    borders: ['FRA'],
  ),
  apiRecord(
    code: 'DEU',
    alpha2: 'DE',
    name: 'Germany',
    official: 'Federal Republic of Germany',
    nameAr: 'ألمانيا',
    region: 'Europe',
    subregion: 'Western Europe',
    population: 83000000,
    area: 357114,
    languages: ['German'],
    currencies: [('EUR', 'Euro')],
    borders: ['BEL', 'FRA'],
  ),
  apiRecord(
    code: 'BEL',
    alpha2: 'BE',
    name: 'Belgium',
    official: 'Kingdom of Belgium',
    nameAr: 'بلجيكا',
    region: 'Europe',
    subregion: 'Western Europe',
    population: 11700000,
    area: 30528,
    languages: ['Dutch', 'French', 'German'],
    currencies: [('EUR', 'Euro')],
    borders: ['DEU', 'FRA'],
  ),
  apiRecord(
    code: 'JPN',
    alpha2: 'JP',
    name: 'Japan',
    nameAr: 'اليابان',
    region: 'Asia',
    capital: 'Tokyo',
    subregion: 'Eastern Asia',
    population: 124000000,
    area: 377930,
    languages: ['Japanese'],
    currencies: [('JPY', 'Japanese yen')],
  ),
  apiRecord(
    code: 'SAU',
    alpha2: 'SA',
    name: 'Saudi Arabia',
    official: 'Kingdom of Saudi Arabia',
    nameAr: 'السعودية',
    officialAr: 'المملكة العربية السعودية',
    region: 'Asia',
    subregion: 'Western Asia',
    population: 35000000,
    area: 2149690,
    languages: ['Arabic'],
    currencies: [('SAR', 'Saudi riyal')],
  ),
  apiRecord(
    code: 'SEN',
    alpha2: 'SN',
    name: 'Senegal',
    nameAr: 'السنغال',
    region: 'Africa',
    subregion: 'Western Africa',
    population: 18000000,
    area: 196722,
    languages: ['French'],
    currencies: [('XOF', 'West African CFA franc')],
  ),
  apiRecord(
    code: 'ATA',
    alpha2: 'AQ',
    name: 'Antarctica',
    nameAr: 'القارة القطبية الجنوبية',
    region: 'Antarctic',
    population: 1000,
    area: 14000000,
  ),
];

List<Country> get testCountries => [
  for (final record in testRecords) parseCountry(record)!,
];

String testSnapshotJson({int fetchedAt = 1, List<Object?>? records}) =>
    jsonEncode({'fetchedAt': fetchedAt, 'objects': records ?? testRecords});
