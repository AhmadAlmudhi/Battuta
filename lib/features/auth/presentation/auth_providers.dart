import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/network/connectivity.dart';
import '../../settings/presentation/settings_controller.dart';
import '../data/firebase_auth_repository.dart';
import '../data/firestore_cloud_entries.dart';
import '../data/local_sync_store.dart';
import '../data/sync_engine.dart';
import '../domain/auth_repository.dart';
import '../domain/cloud_entries.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(FirebaseAuth.instance),
);

/// The signed-in account; null for a guest.
final authUserProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

final cloudEntriesProvider = Provider<CloudEntries>(
  (ref) => FirestoreCloudEntries(FirebaseFirestore.instance),
);

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    local: LocalSyncStore(ref.watch(appDatabaseProvider)),
    cloud: ref.watch(cloudEntriesProvider),
    prefs: ref.watch(sharedPreferencesProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    now: ref.watch(clockProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
});

/// Sync state for the Account screen. The app keeps this alive from the
/// start, so sync follows the signed-in account everywhere.
final syncControllerProvider = NotifierProvider<SyncController, SyncState>(
  SyncController.new,
);

class SyncController extends Notifier<SyncState> {
  SyncEngine get _engine => ref.read(syncEngineProvider);

  /// The account sync currently follows.
  String? _uid;

  /// A merge-and-start in progress, and the account it is for.
  Future<void>? _starting;
  String? _startingFor;

  @override
  SyncState build() {
    final engine = ref.watch(syncEngineProvider);
    final states = engine.states.listen((next) => state = next);
    ref.onDispose(states.cancel);

    ref.listen(
      authUserProvider,
      (_, next) => _follow(next.valueOrNull),
      fireImmediately: true,
    );
    // A merge that failed for lack of a connection runs again once the
    // device is back online (FR-SYNC-03).
    ref.listen(isOnlineProvider, (_, next) {
      if (next.valueOrNull ?? false) _retryMerge();
    });
    return engine.state;
  }

  Future<void> _follow(AuthUser? user) async {
    if (user?.uid == _uid) return;
    _uid = user?.uid;
    if (user == null) {
      await _engine.stop();
      _engine.setGuest();
      return;
    }
    await _mergeThenStart(user.uid);
  }

  /// Merges on the first sign-in on this device, then starts live sync.
  /// A second call for the same account joins the one in progress.
  Future<void> _mergeThenStart(String uid) {
    if (_startingFor == uid && _starting != null) return _starting!;
    _startingFor = uid;
    return _starting = () async {
      try {
        await _engine.claimDevice(uid);
        if (!_engine.hasMerged(uid)) await _engine.merge(uid);
        if (_uid == uid) await _engine.start(uid);
      } on CloudException {
        // Guest data is unchanged; the merge runs again later. The state
        // already shows the failure.
      } finally {
        if (_startingFor == uid) {
          _starting = null;
          _startingFor = null;
        }
      }
    }();
  }

  void _retryMerge() {
    final uid = _uid;
    if (uid != null && !_engine.hasMerged(uid)) _mergeThenStart(uid);
  }

  /// Sync now (FR-SYNC-07); also retries a merge that hasn't finished.
  Future<void> syncNow() async {
    final uid = _uid;
    if (uid == null) return;
    if (!_engine.hasMerged(uid)) return _mergeThenStart(uid);
    try {
      await _engine.syncNow();
    } on CloudException {
      // Shown in the state.
    }
  }

  /// Local changes not yet backed up, for the sign-out warning.
  Future<int> unsyncedChanges() => _engine.pendingCount();

  /// Signs out and removes the user's entries from the device; the cloud
  /// copy stays (FR-AUTH-06, D-4). Throws [AuthException].
  Future<void> signOut() async {
    final uid = _uid;
    // A merge still downloading could write this account's entries back
    // after they were removed, so it gets a moment to finish first.
    await _starting?.timeout(const Duration(seconds: 10), onTimeout: () {});
    await ref.read(authRepositoryProvider).signOut();
    if (uid != null) await _engine.forgetUser(uid);
  }
}
