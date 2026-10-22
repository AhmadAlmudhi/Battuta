import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:battuta/features/world_map/domain/map_replay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final created = DateTime(2026);
  TravelEntry entry(
    String code, {
    DateTime? on,
    TravelStatus status = TravelStatus.visited,
  }) => TravelEntry(
    countryCode: code,
    status: status,
    visitedOn: on,
    createdAt: created,
    updatedAt: created,
  );

  test('plays dated visits oldest first and leaves out undated ones '
      '(FR-MAP-35, AC-MAP-22)', () {
    final plan = ReplayPlan([
      entry('JPN', on: DateTime(2024, 3, 14)),
      entry('ESP'),
      entry('EGY', on: DateTime(2019, 5, 1)),
      entry('SAU', status: TravelStatus.wishlist),
      entry('TUR', on: DateTime(2021, 8, 9)),
    ]);

    expect(plan.steps, [
      (code: 'EGY', year: 2019),
      (code: 'TUR', year: 2021),
      (code: 'JPN', year: 2024),
    ]);
  });

  test('each step takes 700 ms, shortened to fit 20 seconds (FR-MAP-38)', () {
    List<TravelEntry> visits(int count) => [
      for (var i = 0; i < count; i++)
        entry('C$i', on: DateTime(2000).add(Duration(days: i))),
    ];

    expect(ReplayPlan(visits(3)).stepDuration, 700);
    expect(ReplayPlan(visits(3)).duration, 2100);
    expect(ReplayPlan(visits(50)).stepDuration, 400);
    expect(ReplayPlan(visits(50)).duration, 20000);
  });

  test('the Replay button needs at least 2 dated visits (FR-MAP-40)', () {
    expect(
      ReplayPlan([entry('EGY', on: DateTime(2019)), entry('ESP')]).canPlay,
      isFalse,
    );
    expect(
      ReplayPlan([
        entry('EGY', on: DateTime(2019)),
        entry('TUR', on: DateTime(2021)),
      ]).canPlay,
      isTrue,
    );
  });

  test('each step draws its flight path, then fills its country '
      '(FR-MAP-36)', () {
    final plan = ReplayPlan([
      entry('EGY', on: DateTime(2019)),
      entry('TUR', on: DateTime(2021)),
    ]);

    expect(plan.at(350), (step: 0, path: 1.0, fill: 0.5));
    final early = plan.at(700 + 0.2 * 700);
    expect(early.step, 1);
    expect(early.path, closeTo(0.2 / 0.45, 1e-9));
    expect(early.fill, 0);
    expect(plan.at(700 + 0.9 * 700).path, 1);
    expect(plan.at(1400), (step: 2, path: 1.0, fill: 1.0));
  });
}
