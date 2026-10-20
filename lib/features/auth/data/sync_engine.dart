import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/connectivity.dart';
import '../domain/cloud_entries.dart';
import 'local_sync_store.dart';

/// Where sync stands, shown on the Account screen (FR-AUTH-05).
enum SyncPhase {
  /// No account: entries stay on the device.
  guest,

  /// Uploading, downloading, or merging guest data.
  syncing,

  /// Everything is uploaded and the cloud copy is current.
  upToDate,

  /// Changes wait for a connection.
  offline,

  /// The last attempt failed; it is retried on the next trigger.
  failed,
}

class SyncState {
  const SyncState({required this.phase, this.lastSyncAt});

  final SyncPhase phase;

  /// The last successful sync, shown as "Last synced" (PRD 8.5).
  final DateTime? lastSyncAt;

  SyncState copyWith({SyncPhase? phase, DateTime? lastSyncAt}) => SyncState(
    phase: phase ?? this.phase,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
  );
}

/// Keeps a signed-in user's entries in step between the device and the
/// cloud (PRD sections 6.7 and 7.3). Every screen reads the device copy;
/// this only moves changes in the background.
class SyncEngine {
  SyncEngine({
    required LocalSyncStore local,
    required CloudEntries cloud,
    required SharedPreferences prefs,
    required ConnectivityService connectivity,
    DateTime Function()? now,
  }) : _local = local,
       _cloud = cloud,
       _prefs = prefs,
       _connectivity = connectivity,
       _now = now ?? DateTime.now;

  final LocalSyncStore _local;
  final CloudEntries _cloud;
  final SharedPreferences _prefs;
  final ConnectivityService _connectivity;
  final DateTime Function() _now;

  static const _mergedUidsKey = 'merged_uids';
  static const _lastSyncKey = 'last_sync_at';

  /// The account whose entries are on the device; absent for guest data.
  static const _ownerKey = 'local_data_owner';

  final _states = StreamController<SyncState>.broadcast();
  late SyncState _state = SyncState(
    phase: SyncPhase.guest,
    lastSyncAt: _readLastSync(),
  );

  String? _uid;

  /// Whether the server has confirmed the cloud copy since [start].
  bool _cloudConfirmed = false;
  final _subscriptions = <StreamSubscription<Object?>>[];
  Future<void>? _upload;
  bool _uploadAgain = false;

  /// Sync work in progress. [stop] waits for it, so nothing writes to the
  /// device after a sign-out has cleared it (D-4).
  final _work = <Future<void>>{};

  /// Changes at every sign-out; a merge that outlives one is dropped.
  int _epoch = 0;

  SyncState get state => _state;
  Stream<SyncState> get states => _states.stream;

  bool hasMerged(String uid) =>
      _prefs.getStringList(_mergedUidsKey)?.contains(uid) ?? false;

  /// First sign-in on this device: merges guest entries with the cloud
  /// (FR-SYNC-01, PRD 7.3). Nothing on the device changes until the cloud
  /// download has succeeded; if it fails, guest data stays as it is and the
  /// merge runs again later (FR-SYNC-03). Throws [CloudException].
  Future<void> merge(String uid) async {
    final epoch = _epoch;
    _setPhase(SyncPhase.syncing);
    try {
      final cloud = await _cloud.fetchAll(uid);
      // Signed out while downloading: leave the cleared device alone.
      if (epoch != _epoch) return;
      // Cloud copies that win are saved in one transaction; local copies
      // that win stay pending and go up in one batch.
      await _local.applyCloud(cloud);
      final upload = await _local.pending();
      if (upload.isNotEmpty) {
        await _cloud.upsertAll(uid, upload);
        await _local.markSynced(upload);
      }
      await _prefs.setStringList(_mergedUidsKey, [
        ...?_prefs.getStringList(_mergedUidsKey),
        uid,
      ]);
      await _prefs.setString(_ownerKey, uid);
      await _markSynced();
    } on CloudException {
      _setPhase(SyncPhase.failed);
      rethrow;
    }
  }

  /// Before [uid] merges: if the entries on the device belong to another
  /// account, they are removed first, so one account's travels never merge
  /// into another's. This covers a session that ended without Sign out, for
  /// example after a password change on another device. Guest entries, and
  /// the same account signing back in, are kept.
  Future<void> claimDevice(String uid) async {
    final owner = _prefs.getString(_ownerKey);
    if (owner != null && owner != uid) await forgetUser(owner);
  }

  /// Live sync for [uid] until [stop] (FR-SYNC-04 to 06): cloud changes are
  /// applied as they arrive, and local changes upload whenever online.
  Future<void> start(String uid) async {
    await stop();
    _uid = uid;
    _cloudConfirmed = false;
    // Until the server confirms the cloud copy, sync is in progress.
    _setPhase(SyncPhase.syncing);
    await _local.purgeOldDeletions(_now());
    _subscriptions
      ..add(
        _cloud
            .watch(uid)
            .listen(
              (changes) => _track(_applyCloudChanges(uid, changes)),
              onError: (Object _) => _setPhase(SyncPhase.offline),
            ),
      )
      ..add(_local.watchPending().listen((_) => _scheduleUpload()))
      ..add(
        _connectivity.watchOnline().listen((online) {
          if (online) {
            _scheduleUpload();
          } else if (_state.phase != SyncPhase.guest) {
            _setPhase(SyncPhase.offline);
          }
        }),
      );
  }

  /// Sync now (FR-SYNC-07): uploads pending changes, downloads the cloud
  /// copy, and updates the last sync time. Throws [CloudException].
  Future<void> syncNow() {
    final uid = _uid;
    if (uid == null) return Future.value();
    final work = _syncNow(uid);
    _track(work);
    return work;
  }

  Future<void> _syncNow(String uid) async {
    _setPhase(SyncPhase.syncing);
    try {
      await _uploadPending(uid);
      final cloud = await _cloud.fetchAll(uid);
      if (_uid != uid) return;
      await _local.applyCloud(cloud);
      await _markSynced();
    } on CloudException catch (error) {
      _setPhase(
        error.failure == CloudFailure.network
            ? SyncPhase.offline
            : SyncPhase.failed,
      );
      rethrow;
    }
  }

  /// Number of local changes not yet in the cloud, for the sign-out warning.
  Future<int> pendingCount() async => (await _local.pending()).length;

  /// Stops live sync and waits for work in progress to finish.
  Future<void> stop() async {
    _uid = null;
    // Sign-out can stop sync twice at once, so each call takes the
    // subscriptions out of the list before cancelling them.
    final subscriptions = [..._subscriptions];
    _subscriptions.clear();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    // Cancelling stops new events, but handlers already running continue.
    await Future.wait([
      for (final work in [..._work, ?_upload])
        work.then((_) {}, onError: (Object _) {}),
    ]);
  }

  /// Sign-out: removes the user's entries from the device and forgets that
  /// they were merged here (D-4). The cloud copy stays.
  Future<void> forgetUser(String uid) async {
    _epoch++;
    await stop();
    await _local.clearAll();
    await _prefs.setStringList(_mergedUidsKey, [
      for (final merged in _prefs.getStringList(_mergedUidsKey) ?? <String>[])
        if (merged != uid) merged,
    ]);
    await _prefs.remove(_lastSyncKey);
    await _prefs.remove(_ownerKey);
    _state = const SyncState(phase: SyncPhase.guest);
    _states.add(_state);
  }

  void setGuest() => _setPhase(SyncPhase.guest);

  Future<void> dispose() async {
    await stop();
    await _states.close();
  }

  /// Runs one upload at a time; changes made during an upload go up in the
  /// next one.
  void _scheduleUpload() {
    final uid = _uid;
    if (uid == null) return;
    if (_upload != null) {
      _uploadAgain = true;
      return;
    }
    _upload = () async {
      try {
        do {
          _uploadAgain = false;
          if (!await _connectivity.isOnline()) {
            _setPhase(SyncPhase.offline);
            return;
          }
          final uploaded = await _uploadPending(uid);
          if (_uid == uid && uploaded) await _markSynced();
        } while (_uploadAgain && _uid == uid);
      } on CloudException catch (error) {
        _setPhase(
          error.failure == CloudFailure.network
              ? SyncPhase.offline
              : SyncPhase.failed,
        );
        return;
      } finally {
        _upload = null;
      }
      await _settleIfIdle(uid);
    }();
  }

  void _track(Future<void> work) {
    _work.add(work);
    work.whenComplete(() => _work.remove(work)).ignore();
  }

  Future<void> _applyCloudChanges(String uid, CloudChanges changes) async {
    if (_uid != uid) return;
    await _local.applyCloud(changes.entries);
    if (changes.fromServer) _cloudConfirmed = true;
    await _settleIfIdle(uid);
  }

  /// Reports up to date once the server has confirmed the cloud copy,
  /// nothing waits for upload, and no upload is running.
  Future<void> _settleIfIdle(String uid) async {
    if (_uid != uid || !_cloudConfirmed || _upload != null) return;
    if (_state.phase == SyncPhase.upToDate) return;
    if (!await _connectivity.isOnline()) return;
    if ((await _local.pending()).isEmpty) await _markSynced();
  }

  /// Uploads pending entries in one batch; returns whether anything was
  /// uploaded. If the cloud refuses because another device saved a newer
  /// copy, the newer copies are downloaded and applied, and whatever is
  /// still newer here is uploaded again (D-6).
  Future<bool> _uploadPending(String uid) async {
    final pending = await _local.pending();
    if (pending.isEmpty) return false;
    _setPhase(SyncPhase.syncing);
    try {
      await _cloud.upsertAll(uid, pending);
      await _local.markSynced(pending);
    } on CloudException catch (error) {
      if (error.failure != CloudFailure.rejected) rethrow;
      final cloud = await _cloud.fetchAll(uid);
      if (_uid != uid) return true;
      await _local.applyCloud(cloud);
      final remaining = await _local.pending();
      if (remaining.isNotEmpty) {
        await _cloud.upsertAll(uid, remaining);
        await _local.markSynced(remaining);
      }
    }
    return true;
  }

  Future<void> _markSynced() async {
    final now = _now();
    await _prefs.setInt(_lastSyncKey, now.millisecondsSinceEpoch);
    _state = SyncState(phase: SyncPhase.upToDate, lastSyncAt: now);
    _states.add(_state);
  }

  void _setPhase(SyncPhase phase) {
    if (_state.phase == phase) return;
    _state = _state.copyWith(phase: phase);
    _states.add(_state);
  }

  DateTime? _readLastSync() {
    final millis = _prefs.getInt(_lastSyncKey);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }
}
