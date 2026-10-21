import 'package:battuta/features/countries/data/country_parser.dart';
import 'package:battuta/features/countries/domain/country.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _record({
  Map<String, Object?> codes = const {'alpha_2': 'AF', 'alpha_3': 'AFG'},
  Object? capitals,
  Object? borders = const ['IRN', 'PAK'],
  Object? currencies,
  Object? translations,
  Object? links = const {'google_maps': 'https://goo.gl/maps/x'},
}) => {
  'names': {
    'common': 'Afghanistan',
    'official': 'Islamic Republic of Afghanistan',
    'translations':
        translations ??
        {
          'ara': {'common': 'أفغانستان', 'official': 'جمهورية'},
        },
  },
  'codes': codes,
  'capitals':
      capitals ??
      [
        {
          'attributes': {'primary': true},
          'name': 'Kabul',
        },
      ],
  'flag': {
    'colors': {'dominant': '#d43e34'},
    'description': 'Three vertical bands.',
  },
  'region': 'Asia',
  'subregion': 'Southern Asia',
  'area': {'kilometers': 652230},
  'borders': borders,
  'currencies':
      currencies ??
      [
        {'code': 'AFN', 'name': 'Afghan afghani', 'symbol': '؋'},
      ],
  'languages': [
    {'name': 'Dari'},
    {'name': 'Pashto'},
  ],
  'links': links,
  'population': 43844000,
  'timezones': ['UTC+04:30'],
};

void main() {
  group('parseCountry', () {
    test('maps every field (PRD section 8.1)', () {
      final country = parseCountry(_record())!;

      expect(country.code, 'AFG');
      expect(country.alpha2, 'af');
      expect(country.nameEn, 'Afghanistan');
      expect(country.nameOfficialEn, 'Islamic Republic of Afghanistan');
      expect(country.nameAr, 'أفغانستان');
      expect(country.region, 'Asia');
      expect(country.subregion, 'Southern Asia');
      expect(country.capital, 'Kabul');
      expect(country.population, 43844000);
      expect(country.areaKm2, 652230);
      expect(country.languages, ['Dari', 'Pashto']);
      expect(country.currencies, [
        const Currency(code: 'AFN', name: 'Afghan afghani', symbol: '؋'),
      ]);
      expect(country.borders, ['IRN', 'PAK']);
      expect(country.timezones, ['UTC+04:30']);
      expect(country.mapsUrl, 'https://goo.gl/maps/x');
      expect(country.flagAlt, 'Three vertical bands.');
      expect(country.flagColor, '#d43e34');
      expect(country.flagAsset, 'assets/flags/af.png');
      expect(country.nameOfficialAr, 'جمهورية');
      expect(country.officialName(arabic: true), 'جمهورية');
    });

    test('skips records without ISO codes, such as Abkhazia', () {
      expect(
        parseCountry(_record(codes: {'alpha_2': '', 'alpha_3': ''})),
        isNull,
      );
    });

    test('leaves Israel out, including from neighbors\' borders (D-12)', () {
      expect(
        parseCountry(_record(codes: {'alpha_2': 'IL', 'alpha_3': 'ISR'})),
        isNull,
      );
      final palestine = parseCountry(
        _record(
          codes: {'alpha_2': 'PS', 'alpha_3': 'PSE'},
          borders: ['EGY', 'ISR', 'JOR'],
        ),
      );
      expect(palestine!.borders, ['EGY', 'JOR']);
    });

    test('leaves out the Israeli currency (D-12)', () {
      final palestine = parseCountry(
        _record(
          codes: {'alpha_2': 'PS', 'alpha_3': 'PSE'},
          currencies: [
            {'code': 'EGP', 'name': 'Egyptian pound', 'symbol': 'E£'},
            {'code': 'ILS', 'name': 'Israeli new shekel', 'symbol': '₪'},
            {'code': 'JOD', 'name': 'Jordanian dinar', 'symbol': 'JD'},
          ],
        ),
      );
      expect(palestine!.currencies.map((c) => c.code), ['EGP', 'JOD']);
    });

    test('picks the primary capital, else the first', () {
      final bolivia = parseCountry(
        _record(
          capitals: [
            {
              'attributes': {'primary': false},
              'name': 'La Paz',
            },
            {
              'attributes': {'primary': true},
              'name': 'Sucre',
            },
          ],
        ),
      )!;
      expect(bolivia.capital, 'Sucre');

      final noPrimary = parseCountry(
        _record(
          capitals: [
            {'name': 'First'},
            {'name': 'Second'},
          ],
        ),
      )!;
      expect(noPrimary.capital, 'First');
    });

    test('handles missing capitals, borders, and currencies', () {
      final antarctica = parseCountry(
        _record(capitals: const [], borders: null, currencies: const []),
      )!;
      expect(antarctica.capital, isNull);
      expect(antarctica.borders, isEmpty);
      expect(antarctica.currencies, isEmpty);
    });

    test('reads empty strings as missing values', () {
      final country = parseCountry(
        _record(translations: const {}, links: const {'google_maps': ''}),
      )!;
      expect(country.nameAr, isNull);
      expect(country.name(arabic: true), 'Afghanistan');
      expect(country.mapsUrl, isNull);
    });
  });
}
