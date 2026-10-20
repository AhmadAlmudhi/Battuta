import 'package:dio/dio.dart';

import 'rest_countries.dart';

/// Why a REST Countries request failed (PRD section 8.1).
enum CountryApiFailure {
  /// No connection, a timeout, or a browser block such as a missing allowed
  /// origin.
  network,

  /// 401: the API key is missing or invalid.
  invalidKey,

  /// 403: the quota is used up after the grace period, or the key refuses
  /// this origin.
  forbidden,

  /// 429: more than 20 requests in 10 seconds.
  rateLimited,

  /// 410: the API version was retired.
  retiredVersion,

  /// Any other status, or a response with an unexpected shape.
  unexpected,
}

class CountryApiException implements Exception {
  const CountryApiException(this.failure, [this.statusCode]);

  final CountryApiFailure failure;
  final int? statusCode;

  @override
  String toString() =>
      'CountryApiException(${failure.name}'
      '${statusCode == null ? '' : ', $statusCode'})';
}

/// Fetches the full country dataset. Only the country repository uses it;
/// no screen calls the API directly (PRD section 8.2, rule 6).
class CountryApiClient {
  CountryApiClient(this._dio);

  /// A client for the given key. The key goes in an interceptor so it is
  /// never part of a URL or log line. Tests pass an [adapter] in place of the
  /// network.
  factory CountryApiClient.withKey(
    String apiKey, {
    HttpClientAdapter? adapter,
  }) {
    final dio =
        Dio(
            BaseOptions(
              baseUrl: restCountriesBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              responseType: ResponseType.json,
            ),
          )
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                options.headers['Authorization'] = 'Bearer $apiKey';
                handler.next(options);
              },
            ),
          );
    if (adapter != null) dio.httpClientAdapter = adapter;
    return CountryApiClient(dio);
  }

  final Dio _dio;

  /// Every record, page by page. Throws [CountryApiException] if any page
  /// fails, so callers never see a partial dataset (rule 4).
  Future<List<Map<String, Object?>>> fetchAll() async {
    final records = <Map<String, Object?>>[];
    int? total;
    for (var page = 0; page < restCountriesMaxPages; page++) {
      final data = await _fetchPage(page * restCountriesPageSize);
      final objects = data['objects'];
      final meta = data['meta'];
      if (objects is! List || meta is! Map) {
        throw const CountryApiException(CountryApiFailure.unexpected);
      }
      total ??= meta['total'] is int ? meta['total'] as int : null;
      records.addAll(objects.whereType<Map<String, Object?>>());
      if (meta['more'] != true || objects.isEmpty) break;
    }
    // A short dataset would silently drop countries, so treat it as a failure.
    if (records.isEmpty || (total != null && records.length < total)) {
      throw const CountryApiException(CountryApiFailure.unexpected);
    }
    return records;
  }

  Future<Map<String, Object?>> _fetchPage(int offset) async {
    try {
      final response = await _dio.get<Object?>(
        '',
        queryParameters: restCountriesPageQuery(offset),
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! Map<String, Object?>) {
        throw const CountryApiException(CountryApiFailure.unexpected);
      }
      return data;
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  static CountryApiException _mapError(DioException error) {
    final status = error.response?.statusCode;
    if (status == null) {
      return const CountryApiException(CountryApiFailure.network);
    }
    final failure = switch (status) {
      401 => CountryApiFailure.invalidKey,
      403 => CountryApiFailure.forbidden,
      429 => CountryApiFailure.rateLimited,
      410 => CountryApiFailure.retiredVersion,
      _ => CountryApiFailure.unexpected,
    };
    return CountryApiException(failure, status);
  }
}
