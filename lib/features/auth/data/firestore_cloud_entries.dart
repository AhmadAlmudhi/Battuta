import 'package:cloud_firestore/cloud_firestore.dart';

import '../../travels/domain/travel_entry.dart';
import '../domain/cloud_entries.dart';
import '../domain/sync_entry.dart';

/// Cloud entries in Firestore at users/{uid}/entries/{countryCode}. Fields
/// match `travel_entries` in camelCase, without `syncedAt` (PRD 8.4).
class FirestoreCloudEntries implements CloudEntries {
  FirestoreCloudEntries(this._firestore);

  final FirebaseFirestore _firestore;

  /// Firestore allows 500 writes per batch; a user has at most about 250
  /// entries, so this is one batch in practice.
  static const _batchLimit = 450;

  CollectionReference<Map<String, dynamic>> _entries(String uid) =>
      _firestore.collection('users').doc(uid).collection('entries');

  @override
  Future<List<SyncEntry>> fetchAll(String uid) => _guard(() async {
    final snapshot = await _entries(
      uid,
    ).get(const GetOptions(source: Source.server));
    return [for (final doc in snapshot.docs) ?syncEntryFromMap(doc.data())];
  });

  @override
  Future<void> upsertAll(String uid, List<SyncEntry> entries) =>
      _guard(() async {
        for (var i = 0; i < entries.length; i += _batchLimit) {
          final batch = _firestore.batch();
          for (final entry in entries.skip(i).take(_batchLimit)) {
            batch.set(
              _entries(uid).doc(entry.countryCode),
              syncEntryToMap(entry),
            );
          }
          await batch.commit();
        }
      });

  @override
  Stream<CloudChanges> watch(String uid) => _entries(uid)
      .snapshots(includeMetadataChanges: true)
      .map(
        (snapshot) => CloudChanges(
          entries: [
            for (final change in snapshot.docChanges)
              // A write from this device shows up at once with pending
              // writes; only the server-confirmed copy counts as synced.
              if (change.type != DocumentChangeType.removed &&
                  !change.doc.metadata.hasPendingWrites)
                ?syncEntryFromMap(change.doc.data()),
          ],
          fromServer: !snapshot.metadata.isFromCache,
        ),
      )
      .handleError((Object error) => throw _toCloudException(error));

  static Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on Object catch (error) {
      throw _toCloudException(error);
    }
  }

  static CloudException _toCloudException(Object error) =>
      CloudException(switch (error) {
        FirebaseException(code: 'unavailable' || 'deadline-exceeded') =>
          CloudFailure.network,
        FirebaseException(code: 'permission-denied') => CloudFailure.rejected,
        CloudException(:final failure) => failure,
        _ => CloudFailure.unknown,
      });
}

/// Firestore document data for an entry (PRD section 8.4).
Map<String, Object?> syncEntryToMap(SyncEntry entry) => {
  'countryCode': entry.countryCode,
  'status': entry.status.name,
  'visitedOn': entry.visitedOn,
  'rating': entry.rating,
  'priority': entry.priority?.name,
  'targetYear': entry.targetYear,
  'notes': entry.notes,
  'createdAt': entry.createdAt,
  'updatedAt': entry.updatedAt,
  'isDeleted': entry.isDeleted,
};

/// Reads document data written by any version of the app; returns null for
/// data it can't read, so one bad document can't stop sync.
SyncEntry? syncEntryFromMap(Map<String, Object?>? data) {
  if (data == null) return null;
  final code = data['countryCode'];
  final status = TravelStatus.values.asNameMap()[data['status']];
  final createdAt = data['createdAt'];
  final updatedAt = data['updatedAt'];
  if (code is! String ||
      status == null ||
      createdAt is! int ||
      updatedAt is! int) {
    return null;
  }
  final rating = data['rating'];
  final targetYear = data['targetYear'];
  return SyncEntry(
    countryCode: code,
    status: status,
    visitedOn: data['visitedOn'] as String?,
    rating: rating is int ? rating : null,
    priority: WishlistPriority.values.asNameMap()[data['priority']],
    targetYear: targetYear is int ? targetYear : null,
    notes: data['notes'] as String? ?? '',
    createdAt: createdAt,
    updatedAt: updatedAt,
    isDeleted: data['isDeleted'] == true,
  );
}
