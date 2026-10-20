import 'dart:async';
import 'dart:convert';

import 'package:battuta/core/database/app_database.dart';
import 'package:battuta/features/auth/domain/auth_repository.dart';
import 'package:battuta/features/auth/domain/cloud_entries.dart';
import 'package:battuta/features/auth/domain/sync_entry.dart';
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

/// Email and password accounts in memory.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthUser? signedIn}) : _user = signedIn {
    if (signedIn?.email case final email?) accounts[email] = 'password';
  }

  /// Email to password.
  final accounts = <String, String>{};
  final resetRequests = <String>[];

  /// The next call fails with this, once.
  AuthFailure? failNext;

  AuthUser? _user;
  final _changes = StreamController<AuthUser?>.broadcast();

  static String uidFor(String email) => 'uid-$email';

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    _throwIfFailing();
    if (accounts[email] != password) {
      throw const AuthException(AuthFailure.invalidCredentials);
    }
    _set(AuthUser(uid: uidFor(email), email: email));
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    _throwIfFailing();
    if (accounts.containsKey(email)) {
      throw const AuthException(AuthFailure.emailInUse);
    }
    accounts[email] = password;
    _set(AuthUser(uid: uidFor(email), email: email));
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    _throwIfFailing();
    resetRequests.add(email);
  }

  @override
  Future<void> signOut() async => _set(null);

  void _set(AuthUser? user) {
    _user = user;
    _changes.add(user);
  }

  void _throwIfFailing() {
    final failure = failNext;
    failNext = null;
    if (failure != null) throw AuthException(failure);
  }
}

/// Cloud entries in memory. Like the real security rules, an upload may
/// not move an entry's updatedAt backwards.
class FakeCloudEntries implements CloudEntries {
  /// uid to country code to entry.
  final data = <String, Map<String, SyncEntry>>{};
  final uploads = <List<SyncEntry>>[];

  /// While set, reads or writes fail like this.
  CloudFailure? failFetch;
  CloudFailure? failUpload;

  final _listeners = <String, StreamController<CloudChanges>>{};

  Map<String, SyncEntry> entriesOf(String uid) => data[uid] ?? const {};

  @override
  Future<List<SyncEntry>> fetchAll(String uid) async {
    if (failFetch case final failure?) throw CloudException(failure);
    return [...entriesOf(uid).values];
  }

  @override
  Future<void> upsertAll(String uid, List<SyncEntry> entries) async {
    if (failUpload case final failure?) throw CloudException(failure);
    final docs = data.putIfAbsent(uid, () => {});
    final stale = entries.any(
      (e) => (docs[e.countryCode]?.updatedAt ?? -1) > e.updatedAt,
    );
    if (stale) throw const CloudException(CloudFailure.rejected);
    for (final entry in entries) {
      docs[entry.countryCode] = entry;
    }
    uploads.add(entries);
    _listeners[uid]?.add(CloudChanges(entries: entries, fromServer: true));
  }

  @override
  Stream<CloudChanges> watch(String uid) {
    late final StreamController<CloudChanges> controller;
    controller = StreamController<CloudChanges>.broadcast(
      onListen: () => controller.add(
        CloudChanges(entries: [...entriesOf(uid).values], fromServer: true),
      ),
    );
    _listeners[uid] = controller;
    return controller.stream;
  }

  /// A change saved by another device.
  void changeFromAnotherDevice(String uid, SyncEntry entry) {
    data.putIfAbsent(uid, () => {})[entry.countryCode] = entry;
    _listeners[uid]?.add(CloudChanges(entries: [entry], fromServer: true));
  }
}
