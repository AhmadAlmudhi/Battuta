// Fetches the full country dataset from REST Countries v5 and writes the
// bundled snapshot (PRD section 8.2).
//
// Usage: dart run tool/fetch_snapshot.dart
//
// Reads RC_API_KEY from env.json, or from the RC_API_KEY environment variable
// in CI. Costs 3 API requests.
import 'dart:convert';
import 'dart:io';

const _baseUrl = 'https://api.restcountries.com/countries/v5';
const _pageSize = 100;
const _outputPath = 'assets/data/countries_snapshot.json';

/// Must match the fields the app parses in `CountryDto.fromApi`.
const responseFields = [
  'codes.alpha_2',
  'codes.alpha_3',
  'names.common',
  'names.official',
  'names.translations',
  'capitals',
  'region',
  'subregion',
  'borders',
  'area.kilometers',
  'population',
  'languages',
  'currencies',
  'timezones',
  'links.google_maps',
  'flag.description',
  'flag.colors.dominant',
];

Future<void> main() async {
  final apiKey = _readApiKey();
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  final objects = <Object?>[];

  try {
    var offset = 0;
    while (true) {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'limit': '$_pageSize',
          'offset': '$offset',
          'response_fields': responseFields.join(','),
        },
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
      final page = data['objects'] as List<Object?>;
      final meta = data['meta'] as Map<String, Object?>;
      objects.addAll(page.map(_trim));
      stdout.writeln('Fetched ${objects.length} of ${meta['total']}');

      if (meta['more'] != true || page.isEmpty) break;
      offset += _pageSize;
    }
  } finally {
    client.close();
  }

  final snapshot = {
    'fetchedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    'source': _baseUrl,
    'objects': objects,
  };
  final file = File(_outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(jsonEncode(snapshot));
  stdout.writeln('Wrote ${objects.length} records to $_outputPath');
}

/// Keeps only the Arabic translation and drops API metadata, which cuts the
/// snapshot size by most of its weight without changing the record shape.
Object? _trim(Object? record) {
  if (record is! Map<String, Object?>) return record;
  final trimmed = Map<String, Object?>.of(record)..remove('_meta');
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
