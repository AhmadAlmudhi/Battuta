import 'dart:async';
import 'dart:convert';

import 'package:battuta/core/database/app_database.dart';
import 'package:battuta/core/network/connectivity.dart';
import 'package:battuta/features/countries/data/country_api_client.dart';
import 'package:battuta/features/countries/data/country_refresher.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

AppDatabase inMemoryDatabase() => AppDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);

class FakeConnectivity implements ConnectivityService {
  FakeConnectivity({bool online = true}) : _online = online;

  bool _online;
  final _changes = StreamController<bool>.broadcast();

  set online(bool value) {
    _online = value;
    _changes.add(value);
  }

  @override
  Future<bool> isOnline() async => _online;

  @override
  Stream<bool> watchOnline() async* {
    yield _online;
    yield* _changes.stream;
  }
}

class FakeRefresher implements CountryRefresher {
  RefreshOutcome manualOutcome = RefreshOutcome.upToDate;
  int manualCalls = 0;
  int autoCalls = 0;

  @override
  Future<RefreshOutcome> refreshManually() async {
    manualCalls++;
    return manualOutcome;
  }

  @override
  Future<RefreshOutcome> refreshIfStale() async {
    autoCalls++;
    return RefreshOutcome.upToDate;
  }
}

/// A canned HTTP reply for [fakeApiClient].
typedef FakeReply = ({int status, Object? body});

/// A real [CountryApiClient] whose HTTP calls go to [reply] instead of the
/// network. [requests] records every request made.
CountryApiClient fakeApiClient(
  FakeReply Function(RequestOptions request) reply, {
  List<RequestOptions>? requests,
  String apiKey = 'test-key',
}) {
  return CountryApiClient.withKey(
    apiKey,
    adapter: _FakeAdapter(reply, requests),
  );
}

/// A page of API records in the response shape (PRD section 8.1).
FakeReply apiPage(
  List<Map<String, Object?>> records, {
  required int total,
  required bool more,
}) => (
  status: 200,
  body: {
    'data': {
      'objects': records,
      'meta': {'total': total, 'count': records.length, 'more': more},
    },
  },
);

/// Network failures have no status; [_FakeAdapter] throws for status 0.
const FakeReply networkFailure = (status: 0, body: null);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._reply, this._requests);

  final FakeReply Function(RequestOptions request) _reply;
  final List<RequestOptions>? _requests;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    _requests?.add(options);
    final reply = _reply(options);
    if (reply.status == 0) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    return ResponseBody.fromString(
      jsonEncode(reply.body),
      reply.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
