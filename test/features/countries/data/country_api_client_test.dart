import 'package:battuta/features/countries/data/country_api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_countries.dart';

void main() {
  Matcher failsWith(CountryApiFailure failure) => throwsA(
    isA<CountryApiException>().having((e) => e.failure, 'failure', failure),
  );

  test('fetches every page with the key in the header (PRD 8.1)', () async {
    final requests = <RequestOptions>[];
    final records = List.generate(
      250,
      (i) => apiRecord(
        code: 'C$i',
        alpha2: 'c$i',
        name: 'Country $i',
        region: 'Asia',
      ),
    );
    final client = fakeApiClient((request) {
      final offset = int.parse(request.queryParameters['offset'] as String);
      final page = records.skip(offset).take(100).toList();
      return apiPage(page, total: 250, more: offset + 100 < 250);
    }, requests: requests);

    final result = await client.fetchAll();

    expect(result, hasLength(250));
    expect(requests, hasLength(3)); // NFR-13: at most 3 per refresh.
    expect(requests.map((r) => r.queryParameters['offset']), [
      '0',
      '100',
      '200',
    ]);
    expect(requests.first.headers['Authorization'], 'Bearer test-key');
    expect(requests.first.queryParameters['limit'], '100');
    expect(
      requests.first.queryParameters['response_fields'],
      contains('names.translations'),
    );
    expect(requests.first.uri.toString(), isNot(contains('test-key')));
  });

  test('maps 401, 403, 429, and 410 to typed failures', () async {
    for (final (status, failure) in [
      (401, CountryApiFailure.invalidKey),
      (403, CountryApiFailure.forbidden),
      (429, CountryApiFailure.rateLimited),
      (410, CountryApiFailure.retiredVersion),
      (500, CountryApiFailure.unexpected),
    ]) {
      final client = fakeApiClient((_) => (status: status, body: {}));
      await expectLater(client.fetchAll(), failsWith(failure));
    }
  });

  test('maps a connection failure to network', () async {
    final client = fakeApiClient((_) => networkFailure);
    await expectLater(client.fetchAll(), failsWith(CountryApiFailure.network));
  });

  test('rejects a response with an unexpected shape', () async {
    final client = fakeApiClient((_) => (status: 200, body: {'oops': true}));
    await expectLater(
      client.fetchAll(),
      failsWith(CountryApiFailure.unexpected),
    );
  });

  test('rejects a dataset shorter than the reported total', () async {
    final client = fakeApiClient(
      (_) => apiPage([testRecords.first], total: 250, more: false),
    );
    await expectLater(
      client.fetchAll(),
      failsWith(CountryApiFailure.unexpected),
    );
  });

  test('stops after 5 pages even if the API keeps saying more', () async {
    final requests = <RequestOptions>[];
    final client = fakeApiClient(
      (_) => apiPage([testRecords.first], total: 5, more: true),
      requests: requests,
    );

    expect(await client.fetchAll(), hasLength(5));
    expect(requests, hasLength(5));
  });
}
