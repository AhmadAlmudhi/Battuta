import 'dart:async';

import 'package:battuta/core/database/app_database.dart';
import 'package:battuta/features/auth/data/local_sync_store.dart';
import 'package:battuta/features/auth/data/sync_engine.dart';
import 'package:battuta/features/auth/domain/cloud_entries.dart';
import 'package:battuta/features/auth/domain/sync_entry.dart';
import 'package:battuta/features/travels/data/travel_repository_impl.dart';
import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fakes.dart';

const uid = 'uid-1';

SyncEntry entry(
  String code, {
  required int at,
  String notes = '',
  bool deleted = false,
}) => SyncEntry(
  countryCode: code,
  status: TravelStatus.visited,
  notes: notes,
  createdAt: 1,
  updatedAt: at,
  isDeleted: deleted,
);

/// Waits for asynchronous sync work, failing after 2 seconds.
Future<void> eventually(FutureOr<bool> Function() condition) async {
  for (var i = 0; i < 200; i++) {
    if (await condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(await condition(), isTrue, reason: 'condition not met in time');
}

void main() {
  late AppDatabase db;
  late FakeCloudEntries cloud;
  late FakeConnectivity connectivity;
  late SharedPreferences prefs;
  late TravelRepositoryImpl travels;
  late SyncEngine engine;
  late DateTime now;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = inMemoryDatabase();
    cloud = FakeCloudEntries();
    connectivity = FakeConnectivity();
    now = DateTime(2026, 10, 20, 12);
    travels = TravelRepositoryImpl(db, now: () => now);
    engine = SyncEngine(
      local: LocalSyncStore(db),
      cloud: cloud,
      prefs: prefs,
      connectivity: connectivity,
      now: () => now,
    );
  });

  tearDown(() async {
    await engine.dispose();
    await db.close();
  });

  int at(int minutes) =>
      now.add(Duration(minutes: minutes)).millisecondsSinceEpoch;

  Future<Map<String, String>> localNotes() async => {
    for (final row in await db.select(db.travelEntries).get())
      row.countryCode: row.notes,
  };

  group('merge on first sign-in (PRD 7.3)', () {
    test('every row of the merge table', () async {
      // Local only, cloud only, local newer, cloud newer, same time.
      await travels.saveVisit('FRA', notes: 'local only');
      await travels.saveVisit('DEU', notes: 'local newer');
      await travels.saveVisit('ESP', notes: 'local older');
      await travels.saveVisit('BEL', notes: 'local same time');
      final localTime = now.millisecondsSinceEpoch;
      cloud.data[uid] = {
        'JPN': entry('JPN', at: at(-60), notes: 'cloud only'),
        'DEU': entry('DEU', at: localTime - 1, notes: 'cloud older'),
        'ESP': entry('ESP', at: localTime + 1, notes: 'cloud newer'),
        'BEL': entry('BEL', at: localTime, notes: 'cloud same time'),
      };

      await engine.merge(uid);

      final expected = {
        'FRA': 'local only',
        'JPN': 'cloud only',
        'DEU': 'local newer',
        'ESP': 'cloud newer',
        'BEL': 'cloud same time', // A fixed tie-break: the cloud wins.
      };
      expect(await localNotes(), expected);
      expect({
        for (final e in cloud.entriesOf(uid).values) e.countryCode: e.notes,
      }, expected);
      // Local winners went up in one batch.
      expect(cloud.uploads, hasLength(1));
      expect(cloud.uploads.single.map((e) => e.countryCode).toSet(), {
        'FRA',
        'DEU',
      });
      expect(engine.hasMerged(uid), isTrue);
      expect(engine.state.phase, SyncPhase.upToDate);
      expect(engine.state.lastSyncAt, now);
    });

    test('3 guest entries and 2 cloud entries become 5 on both sides '
        '(AC-SYNC-01)', () async {
      for (final code in ['FRA', 'DEU', 'ESP']) {
        await travels.saveVisit(code);
      }
      cloud.data[uid] = {
        'JPN': entry('JPN', at: at(-1)),
        'SAU': entry('SAU', at: at(-1)),
      };

      await engine.merge(uid);

      expect((await localNotes()).keys.toSet(), hasLength(5));
      expect(cloud.entriesOf(uid), hasLength(5));
    });

    test('a failed download changes nothing and the merge can run again '
        '(FR-SYNC-03)', () async {
      await travels.saveVisit('FRA', notes: 'guest');
      cloud.data[uid] = {'JPN': entry('JPN', at: at(-1))};
      cloud.failFetch = CloudFailure.network;

      await expectLater(engine.merge(uid), throwsA(isA<CloudException>()));
      expect(await localNotes(), {'FRA': 'guest'});
      expect(cloud.uploads, isEmpty);
      expect(engine.hasMerged(uid), isFalse);
      expect(engine.state.phase, SyncPhase.failed);

      cloud.failFetch = null;
      await engine.merge(uid);
      expect((await localNotes()).keys.toSet(), {'FRA', 'JPN'});
    });
  });

  group('live sync (FR-SYNC-04 to 06)', () {
    Future<void> startSynced() async {
      await engine.merge(uid);
      await engine.start(uid);
      await eventually(() => engine.state.phase == SyncPhase.upToDate);
    }

    test('a local change uploads automatically', () async {
      await startSynced();

      await travels.saveVisit('ITA', notes: 'new');

      await eventually(() => cloud.entriesOf(uid)['ITA']?.notes == 'new');
      await eventually(() => engine.state.phase == SyncPhase.upToDate);
    });

    test('a change from another device appears without a restart '
        '(AC-SYNC-02)', () async {
      await startSynced();

      cloud.changeFromAnotherDevice(uid, entry('ITA', at: at(1)));

      await eventually(
        () async => await travels.watchEntry('ITA').first != null,
      );
    });

    test(
      'a deletion reaches the cloud as a soft delete (FR-SYNC-06)',
      () async {
        await travels.saveVisit('FRA');
        await startSynced();

        now = now.add(const Duration(minutes: 1));
        await travels.remove('FRA');

        await eventually(() => cloud.entriesOf(uid)['FRA']?.isDeleted ?? false);
      },
    );

    test('changes made offline upload when the connection returns '
        '(AC-SYNC-03)', () async {
      await travels.saveVisit('FRA');
      await startSynced();

      connectivity.online = false;
      await eventually(() => engine.state.phase == SyncPhase.offline);
      now = now.add(const Duration(minutes: 1));
      await travels.remove('FRA');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cloud.entriesOf(uid)['FRA']?.isDeleted, isFalse);

      connectivity.online = true;

      await eventually(() => cloud.entriesOf(uid)['FRA']?.isDeleted ?? false);
      await eventually(() => engine.state.phase == SyncPhase.upToDate);
    });

    test('an upload older than the cloud copy loses, and this device takes '
        'the newer copy (D-6)', () async {
      await travels.saveVisit('FRA', notes: 'first');
      await startSynced();
      connectivity.online = false;
      await eventually(() => engine.state.phase == SyncPhase.offline);

      // Edited here at minute 1 while offline, and on another device at
      // minute 2, which reached the cloud first.
      now = now.add(const Duration(minutes: 1));
      await travels.saveVisit('FRA', notes: 'older edit');
      cloud.data[uid]!['FRA'] = entry('FRA', at: at(1), notes: 'newer edit');

      connectivity.online = true;

      await eventually(() => engine.state.phase == SyncPhase.upToDate);
      expect(cloud.entriesOf(uid)['FRA']?.notes, 'newer edit');
      expect((await localNotes())['FRA'], 'newer edit');
    });
  });

  test('Sync now uploads, downloads, and updates the last sync time '
      '(FR-SYNC-07)', () async {
    await engine.merge(uid);
    await engine.start(uid);
    await travels.saveVisit('FRA');
    cloud.data.putIfAbsent(uid, () => {})['JPN'] = entry('JPN', at: at(1));
    now = now.add(const Duration(hours: 1));

    await engine.syncNow();

    expect(cloud.entriesOf(uid).containsKey('FRA'), isTrue);
    expect(await travels.watchEntry('JPN').first, isNotNull);
    expect(engine.state.lastSyncAt, now);
  });

  test('sign-out clears the device even while live sync is stopping '
      'at the same time', () async {
    // Signing out stops sync twice at once: once when the account changes
    // and once to clear the device. Neither may stop the other.
    await travels.saveVisit('FRA');
    await engine.merge(uid);
    await engine.start(uid);
    await eventually(() => engine.state.phase == SyncPhase.upToDate);

    await Future.wait([engine.stop(), engine.forgetUser(uid)]);

    expect(await db.select(db.travelEntries).get(), isEmpty);
  });

  group('claimDevice: one account never absorbs another', () {
    test('entries owned by another account are removed first', () async {
      await travels.saveVisit('FRA');
      await engine.merge('uid-a');

      await engine.claimDevice('uid-b');

      expect(await db.select(db.travelEntries).get(), isEmpty);
      expect(engine.hasMerged('uid-a'), isFalse);
      // A's copy stays in A's cloud.
      expect(cloud.entriesOf('uid-a').keys, ['FRA']);
    });

    test(
      'the same account keeps its entries, including unsynced ones',
      () async {
        await travels.saveVisit('FRA');
        await engine.merge('uid-a');
        now = now.add(const Duration(minutes: 1));
        await travels.saveVisit('JPN');

        await engine.claimDevice('uid-a');

        expect((await localNotes()).keys.toSet(), {'FRA', 'JPN'});
      },
    );

    test('guest entries are kept for the merge', () async {
      await travels.saveVisit('FRA');

      await engine.claimDevice('uid-a');

      expect((await localNotes()).keys, ['FRA']);
    });
  });

  test('forgetting the user clears the device but keeps the cloud copy '
      '(D-4)', () async {
    await travels.saveVisit('FRA');
    await engine.merge(uid);

    await engine.forgetUser(uid);

    expect(await db.select(db.travelEntries).get(), isEmpty);
    expect(cloud.entriesOf(uid).containsKey('FRA'), isTrue);
    expect(engine.hasMerged(uid), isFalse);
    expect(engine.state.phase, SyncPhase.guest);
    expect(engine.state.lastSyncAt, isNull);
  });
}
