import 'dart:convert';
import 'dart:io';

import 'package:battuta/features/countries/data/country_parser.dart';
import 'package:battuta/features/countries/data/tourism_arrivals.dart';
import 'package:battuta/features/countries/data/world_bank_tourism.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> row(String code, Object date, num? value) => {
  'countryiso3code': code,
  'date': '$date',
  'value': value,
};

void main() {
  group('latestArrivals (PRD 8.8)', () {
    test('takes each country\'s most recent figure', () {
      final latest = latestArrivals(
        [
          row('FRA', 2018, 211),
          row('FRA', 2019, 217.9),
          row('ESP', 2019, null),
          row('ESP', 2017, 121),
        ],
        {'FRA', 'ESP'},
      );

      expect(latest, {
        'FRA': (year: 2019, arrivals: 218),
        'ESP': (year: 2017, arrivals: 121),
      });
    });

    test('skips the pandemic years and figures before 2012', () {
      final latest = latestArrivals(
        [
          row('JPN', 2021, 0.2),
          row('JPN', 2020, 4),
          row('JPN', 2019, 32),
          row('SEN', 2011, 1),
        ],
        {'JPN', 'SEN'},
      );

      expect(latest, {'JPN': (year: 2019, arrivals: 32)});
    });

    test('leaves out regions, other countries, and records it can\'t read', () {
      final latest = latestArrivals(
        [
          row('WLD', 2019, 1460),
          row('ISR', 2019, 4.6),
          {'countryiso3code': 'FRA', 'date': 'soon', 'value': 1},
          'not a record',
          row('FRA', 2019, 218),
        ],
        {'FRA'},
      );

      expect(latest, {'FRA': (year: 2019, arrivals: 218)});
    });
  });

  test('the bundled figures are for dataset countries, most first', () {
    final snapshot =
        jsonDecode(
              File('assets/data/countries_snapshot.json').readAsStringSync(),
            )
            as Map<String, Object?>;
    final codes = {
      for (final record in snapshot['objects'] as List<Object?>)
        ?parseCountry(record as Map<String, Object?>)?.code,
    };

    expect(tourismArrivals.length, greaterThan(150));
    expect(codes.containsAll(tourismArrivals.keys), isTrue);
    final figures = tourismArrivals.values.toList();
    expect(figures, [...figures]..sort((a, b) => b.compareTo(a)));
  });
}
