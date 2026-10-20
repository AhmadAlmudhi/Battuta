import 'dart:convert';
import 'dart:io';

import 'package:battuta/core/database/app_database.dart';
import 'package:battuta/features/countries/data/country_repository_impl.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
  });

  tearDown(() => db.close());

  group('CountryRepositoryImpl', () {
    test('imports the bundled snapshot on first launch', () async {
      var loads = 0;
      final repository = CountryRepositoryImpl(db, () async {
        loads++;
        return File('assets/data/countries_snapshot.json').readAsString();
      });

      await repository.ensureSeeded();
      final countries = await repository.watchAll().first;

      expect(loads, 1);
      // The snapshot has 254 records; 4 disputed territories have no ISO
      // codes and are skipped, leaving the PRD's total of 250 (D-3).
      expect(countries, hasLength(250));
      expect(
        countries.map((c) => c.nameEn).toList(),
        orderedEquals([...countries.map((c) => c.nameEn)]..sort()),
      );

      final saudi = await repository.findByCode('sau');
      expect(saudi?.nameAr, isNotNull);
      expect(saudi?.region, 'Asia');

      final japan = await repository.findByCode('JPN');
      expect(japan?.borders, isEmpty);
    });

    test('does not import again once data exists', () async {
      var loads = 0;
      final repository = CountryRepositoryImpl(db, () async {
        loads++;
        return File('assets/data/countries_snapshot.json').readAsString();
      });

      await repository.ensureSeeded();
      await repository.ensureSeeded();

      expect(loads, 1);
    });

    test('stores normalized search fields', () async {
      final repository = CountryRepositoryImpl(
        db,
        () async => jsonEncode({
          'fetchedAt': 1,
          'objects': [
            {
              'names': {
                'common': 'Côte d\'Ivoire',
                'official': 'Republic of Côte d\'Ivoire',
                'translations': {
                  'ara': {'common': 'ساحل العاج'},
                },
              },
              'codes': {'alpha_2': 'CI', 'alpha_3': 'CIV'},
              'region': 'Africa',
              'population': 1,
            },
          ],
        }),
      );

      await repository.ensureSeeded();
      final row = await db.select(db.countries).getSingle();

      expect(row.searchEn, 'cote d\'ivoire\nrepublic of cote d\'ivoire');
      expect(row.searchAr, 'ساحل العاج');
      expect(row.fetchedAt, 1);
    });

    test('returns null for an unknown code', () async {
      final repository = CountryRepositoryImpl(
        db,
        () async => jsonEncode({'fetchedAt': 1, 'objects': []}),
      );
      expect(await repository.findByCode('XYZ'), isNull);
    });
  });
}
