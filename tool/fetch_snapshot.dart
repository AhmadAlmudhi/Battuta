// Fetches the full country dataset from REST Countries v5 and writes the
// bundled snapshot (PRD section 8.2).
//
// Usage: dart run tool/fetch_snapshot.dart
//
// Reads RC_API_KEY from env.json, or from the RC_API_KEY environment variable
// in CI. Costs 3 API requests. Leaves out the countries the app excludes
// (D-12). Exits with an error, writing nothing, when a page is missing or the
// records no longer parse, because production deploys ship the snapshot
// without review (PRD section 12.3).
import 'dart:convert';
import 'dart:io';

import 'package:battuta/features/countries/data/country_parser.dart';
import 'package:battuta/features/countries/data/rest_countries.dart';

const _outputPath = 'assets/data/countries_snapshot.json';

/// A few below the 249 countries in the dataset today (D-3): a country or
/// two joining or leaving passes, and a response in a shape the parser
/// doesn't expect doesn't.
const _minimumCountries = 240;

Future<void> main() async {
  final apiKey = _readApiKey();
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  final objects = <Object?>[];
  var fetched = 0;
  int? total;

  try {
    for (var page = 0; page < restCountriesMaxPages; page++) {
      final uri = Uri.parse(restCountriesBaseUrl).replace(
        queryParameters: restCountriesPageQuery(page * restCountriesPageSize),
      );
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        stderr.writeln('Request failed (${response.statusCode}): $body');
        exit(1);
      }

      final data =
          (jsonDecode(body) as Map<String, Object?>)['data']
              as Map<String, Object?>;
      final records = data['objects'] as List<Object?>;
      final meta = data['meta'] as Map<String, Object?>;
      fetched += records.length;
      if (meta['total'] case final int count) total ??= count;
      objects.addAll(records.where(_kept).map(_trim));
      stdout.writeln('Fetched $fetched of $total');

      if (meta['more'] != true || records.isEmpty) break;
    }
  } finally {
    client.close();
  }

  // Like the app's refresh, a short dataset counts as a failure (rule 4).
  if (total != null && fetched < total) {
    stderr.writeln('Got $fetched of $total records.');
    exit(1);
  }
  final countries = [
    for (final record in objects)
      if (record is Map<String, Object?>) ?parseCountry(record),
  ];
  if (countries.length < _minimumCountries) {
    stderr.writeln(
      'Only ${countries.length} records parse as countries; '
      'expected at least $_minimumCountries.',
    );
    exit(1);
  }

  final snapshot = {
    'fetchedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    'source': restCountriesBaseUrl,
    'objects': objects,
  };
  final file = File(_outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(jsonEncode(snapshot));
  stdout.writeln(
    'Wrote ${objects.length} records (${countries.length} countries) to '
    '$_outputPath',
  );
}

bool _kept(Object? record) => !excludedCountryCodes.contains(
  (((record as Map<String, Object?>)['codes'] as Map?)?['alpha_3'] as String?)
      ?.toUpperCase(),
);

/// Keeps only the Arabic translation and drops API metadata, which cuts the
/// snapshot size by most of its weight without changing the record shape.
/// Also drops the borders and currencies the app leaves out (D-12).
Object? _trim(Object? record) {
  if (record is! Map<String, Object?>) return record;
  final trimmed = Map<String, Object?>.of(record)..remove('_meta');
  if (trimmed['borders'] case final List<Object?> borders) {
    trimmed['borders'] = [
      for (final border in borders)
        if (!excludedCountryCodes.contains(border)) border,
    ];
  }
  if (trimmed['currencies'] case final List<Object?> currencies) {
    trimmed['currencies'] = [
      for (final currency in currencies)
        if (!excludedCurrencyCodes.contains((currency as Map?)?['code']))
          currency,
    ];
  }
  final names = trimmed['names'];
  if (names is Map<String, Object?>) {
    final translations = names['translations'];
    trimmed['names'] = {
      ...names,
      'translations': {
        if (translations is Map<String, Object?> && translations['ara'] != null)
          'ara': translations['ara'],
      },
    };
  }
  return trimmed;
}

String _readApiKey() {
  final fromEnv = Platform.environment['RC_API_KEY'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

  final envFile = File('env.json');
  if (envFile.existsSync()) {
    final env = jsonDecode(envFile.readAsStringSync()) as Map<String, Object?>;
    final key = env['RC_API_KEY'];
    if (key is String && key.isNotEmpty) return key;
  }
  stderr.writeln('RC_API_KEY not found in env.json or the environment.');
  exit(1);
}
