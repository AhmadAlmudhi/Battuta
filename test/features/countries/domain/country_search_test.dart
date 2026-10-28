import 'package:battuta/features/countries/data/country_parser.dart';
import 'package:battuta/features/countries/domain/country_search.dart';
import 'package:battuta/features/countries/domain/explore_filter_options.dart';
import 'package:battuta/features/countries/domain/explore_query.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_countries.dart';

void main() {
  final index = CountrySearchIndex(testCountries);

  List<String> codes(ExploreQuery query, {bool arabic = false}) => [
    for (final country in index.apply(query, arabic: arabic)) country.code,
  ];

  group('search (FR-EXP-04)', () {
    test('matches the English common name, case-insensitively (AC-EXP-01)', () {
      expect(codes(const ExploreQuery(search: 'sau')), ['SAU']);
      expect(codes(const ExploreQuery(search: 'JAPAN')), ['JPN']);
    });

    test('matches the English official name', () {
      expect(codes(const ExploreQuery(search: 'federal republic')), ['DEU']);
    });

    test('matches the Arabic name in any app language (AC-EXP-02)', () {
      expect(codes(const ExploreQuery(search: 'سعو')), ['SAU']);
      expect(codes(const ExploreQuery(search: 'سعو'), arabic: true), ['SAU']);
    });

    test('matches after normalization: accents and Arabic letter forms', () {
      expect(codes(const ExploreQuery(search: 'Fránce')), ['FRA']);
      // ة is typed as ه, and أ without hamza.
      expect(codes(const ExploreQuery(search: 'السعوديه')), ['SAU']);
      expect(codes(const ExploreQuery(search: 'المانيا')), ['DEU']);
    });

    test('ranks names that start with the text above names that contain it '
        '(FR-EXP-05)', () {
      // "an" starts "Antarctica"; France, Germany, and Japan only contain
      // it, so they follow in name order.
      expect(codes(const ExploreQuery(search: 'an')), [
        'ATA',
        'FRA',
        'DEU',
        'JPN',
      ]);
    });

    test('an Arabic name counts as starting with the text without ال', () {
      final ranked = codes(
        const ExploreQuery(search: 'سن', sort: CountrySort.nameDesc),
        arabic: true,
      );
      // السنغال starts with سن once ال is dropped; nothing else matches.
      expect(ranked, ['SEN']);
    });

    test('ignores surrounding spaces and returns everything when empty', () {
      expect(codes(const ExploreQuery(search: '  ')), hasLength(8));
    });
  });

  group('filters (FR-EXP-06, FR-EXP-07)', () {
    test('OR within a field', () {
      expect(codes(const ExploreQuery(regions: {'Asia', 'Africa'})), [
        'JPN',
        'SAU',
        'SEN',
      ]);
    });

    test('AND across fields: Europe and French (AC-EXP-03)', () {
      expect(
        codes(const ExploreQuery(regions: {'Europe'}, language: 'French')),
        ['BEL', 'FRA'],
      );
    });

    test('subregion, language, and currency', () {
      expect(codes(const ExploreQuery(subregions: {'Western Europe'})), [
        'BEL',
        'FRA',
        'DEU',
      ]);
      expect(codes(const ExploreQuery(currency: 'EUR')), hasLength(4));
      expect(codes(const ExploreQuery(currency: 'JPY')), ['JPN']);
    });

    test('a country with no subregion is excluded by a subregion filter', () {
      expect(
        codes(const ExploreQuery(subregions: {'Western Europe'})),
        isNot(contains('ATA')),
      );
    });

    test('no match gives an empty list (AC-EXP-04)', () {
      expect(
        codes(const ExploreQuery(regions: {'Asia'}, currency: 'EUR')),
        isEmpty,
      );
    });

    test('counts active filters', () {
      expect(const ExploreQuery().activeFilterCount, 0);
      expect(
        const ExploreQuery(
          regions: {'Asia', 'Europe'},
          subregions: {'Western Europe'},
          language: 'French',
          currency: 'EUR',
        ).activeFilterCount,
        5,
      );
    });
  });

  group('sort (FR-EXP-08)', () {
    test('Most visited is the default: arrivals, most first, then the '
        'countries without a figure by name', () {
      expect(const ExploreQuery().sort, CountrySort.mostVisited);
      final ranked = CountrySearchIndex(
        testCountries,
        arrivals: const {'JPN': 30, 'FRA': 90, 'ESP': 60},
      );
      expect(
        [
          for (final country in ranked.apply(
            const ExploreQuery(),
            arabic: false,
          ))
            country.code,
        ],
        ['FRA', 'ESP', 'JPN', 'ATA', 'BEL', 'DEU', 'SAU', 'SEN'],
      );
    });

    test('name A to Z and Z to A in English', () {
      expect(codes(const ExploreQuery(sort: CountrySort.nameAsc)), [
        'ATA',
        'BEL',
        'FRA',
        'DEU',
        'JPN',
        'SAU',
        'SEN',
        'ESP',
      ]);
      expect(
        codes(const ExploreQuery(sort: CountrySort.nameDesc)).first,
        'ESP',
      );
    });

    test('name order follows the Arabic names in Arabic', () {
      final arabic = codes(const ExploreQuery(), arabic: true);
      // إسبانيا sorts first: إ normalizes to ا, and س comes before ل.
      expect(arabic.first, 'ESP');
      expect(arabic.last, 'FRA');
    });

    test('population high to low and low to high', () {
      expect(
        codes(const ExploreQuery(sort: CountrySort.populationDesc)).take(3),
        ['JPN', 'DEU', 'FRA'],
      );
      expect(
        codes(const ExploreQuery(sort: CountrySort.populationAsc)).first,
        'ATA',
      );
    });

    test('area largest and smallest first, missing areas last', () {
      final withoutArea = parseCountry(
        apiRecord(
          code: 'XXA',
          alpha2: 'XA',
          name: 'Aaa',
          region: 'Asia',
          area: null,
        ),
      )!;
      final index = CountrySearchIndex([...testCountries, withoutArea]);
      List<String> sorted(CountrySort sort) => [
        for (final country in index.apply(
          ExploreQuery(sort: sort),
          arabic: false,
        ))
          country.code,
      ];

      expect(sorted(CountrySort.areaDesc).first, 'ATA');
      expect(sorted(CountrySort.areaDesc).last, 'XXA');
      expect(sorted(CountrySort.areaAsc).first, 'BEL');
      expect(sorted(CountrySort.areaAsc).last, 'XXA');
    });

    test('with search text, the chosen sort applies within each rank', () {
      expect(
        codes(
          const ExploreQuery(search: 'an', sort: CountrySort.populationDesc),
        ),
        ['ATA', 'JPN', 'DEU', 'FRA'],
      );
    });
  });

  group('filter options', () {
    final options = ExploreFilterOptions.from(testCountries);

    test('lists regions, languages, and currencies from the data', () {
      expect(options.regions, ['Africa', 'Antarctic', 'Asia', 'Europe']);
      expect(options.languages, [
        'Arabic',
        'Dutch',
        'French',
        'German',
        'Japanese',
        'Spanish',
      ]);
      expect(options.currencies.map((c) => c.code), [
        'EUR',
        'JPY',
        'SAR',
        'XOF',
      ]);
    });

    test('offers subregions only for selected regions', () {
      expect(options.subregionsFor({}), isEmpty);
      expect(options.subregionsFor({'Europe'}), [
        'Southern Europe',
        'Western Europe',
      ]);
      expect(options.subregionsFor({'Antarctic'}), isEmpty);
    });
  });
}
