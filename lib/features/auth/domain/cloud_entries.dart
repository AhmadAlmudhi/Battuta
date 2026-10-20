import 'sync_entry.dart';

/// Why a cloud operation failed.
enum CloudFailure {
  /// No connection or the service is unreachable.
  network,

  /// The security rules refused the write, for example because the cloud
  /// copy is newer than the one being uploaded.
  rejected,

  unknown,
}

class CloudException implements Exception {
  const CloudException(this.failure);

  final CloudFailure failure;

  @override
  String toString() => 'CloudException(${failure.name})';
}

/// One batch of cloud changes from the live listener.
class CloudChanges {
  const CloudChanges({required this.entries, required this.fromServer});

  /// Entries added or changed since the last batch, confirmed by the server.
  final List<SyncEntry> entries;

  /// True once the server has confirmed this view, so it is current.
  final bool fromServer;
}

/// A user's entries in the cloud, at users/{uid}/entries/{countryCode}
/// (PRD section 8.4). Methods throw [CloudException].
abstract interface class CloudEntries {
  /// Every entry, read from the server and never from a cache, so a failed
  /// read can't be mistaken for an empty account (FR-SYNC-03).
  Future<List<SyncEntry>> fetchAll(String uid);

  /// Writes the entries in one atomic batch.
  Future<void> upsertAll(String uid, List<SyncEntry> entries);

  /// Live changes, starting with the current entries (FR-SYNC-05).
  Stream<CloudChanges> watch(String uid);
}
