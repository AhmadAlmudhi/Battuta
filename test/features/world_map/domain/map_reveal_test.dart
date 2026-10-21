import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:battuta/features/world_map/domain/map_reveal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('reveal timing (FR-MAP-28, FR-MAP-29)', () {
    test('fills start 60 ms apart and take 400 ms each', () {
      final schedule = RevealSchedule(5);

      expect(schedule.gap, 60);
      expect(schedule.fill(0, 200), 0.5);
      expect(schedule.fill(2, 120), 0);
      expect(schedule.fill(2, 320), 0.5);
      expect(schedule.fillsEnd, 4 * 60 + 400);
    });

    test('with many countries, the gap shrinks so fills end within 1.2 s, '
        'and the whole reveal within 1.5 s', () {
      for (final count in [1, 16, 50, 250]) {
        final schedule = RevealSchedule(count);
        expect(schedule.fillsEnd, lessThanOrEqualTo(1200), reason: '$count');
        expect(schedule.duration, lessThanOrEqualTo(1500), reason: '$count');
      }
      expect(RevealSchedule(16).gap, closeTo(800 / 15, 1e-9));
    });

    test('hatching fades in over 300 ms after the last fill', () {
      final schedule = RevealSchedule(1);

      expect(schedule.hatching(400), 0);
      expect(schedule.hatching(550), 0.5);
      expect(schedule.hatching(700), 1);
      expect(RevealSchedule(0).duration, 300);
    });
  });

  test('countries fill oldest visit first, undated visits last '
      '(FR-MAP-27)', () {
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

    expect(
      revealOrder([
        entry('JPN', on: DateTime(2024, 3, 14)),
        entry('ESP'),
        entry('FRA', on: DateTime(2019, 7, 2)),
        entry('SAU', status: TravelStatus.wishlist),
        entry('DEU', on: DateTime(2019, 7, 2)),
        entry('BEL'),
      ]),
      ['FRA', 'DEU', 'JPN', 'ESP', 'BEL'],
    );
  });
}
