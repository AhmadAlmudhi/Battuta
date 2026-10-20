import 'dart:convert';
import 'dart:io';

import 'package:battuta/features/countries/presentation/region_names.dart';
import 'package:battuta/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every region and subregion in the snapshot has an Arabic name '
      '(G-6: no untranslated text)', () {
    final snapshot =
        jsonDecode(
              File('assets/data/countries_snapshot.json').readAsStringSync(),
            )
            as Map<String, Object?>;
    final records = (snapshot['objects'] as List).cast<Map<String, Object?>>();
    final regions = {for (final r in records) r['region'] as String};
    final subregions = {
      for (final r in records)
        if ((r['subregion'] as String?)?.isNotEmpty ?? false)
          r['subregion'] as String,
    };
    final ar = lookupAppLocalizations(const Locale('ar'));
    final en = lookupAppLocalizations(const Locale('en'));

    for (final region in regions) {
      expect(regionName(ar, region), isNot(region), reason: region);
      expect(regionName(en, region), region);
    }
    for (final subregion in subregions) {
      expect(subregionName(ar, subregion), isNot(subregion), reason: subregion);
      expect(subregionName(en, subregion), subregion);
    }
  });

  test('an unknown region shows as provided', () {
    final ar = lookupAppLocalizations(const Locale('ar'));
    expect(regionName(ar, 'Atlantis'), 'Atlantis');
  });
}
