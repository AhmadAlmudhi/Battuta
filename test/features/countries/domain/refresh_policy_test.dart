import 'package:battuta/features/countries/domain/refresh_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 20, 12);

  test('data is stale after 7 days (PRD 8.2, rule 3)', () {
    expect(RefreshPolicy.isStale(null, now), isTrue);
    expect(
      RefreshPolicy.isStale(now.subtract(const Duration(days: 7)), now),
      isFalse,
    );
    expect(
      RefreshPolicy.isStale(
        now.subtract(const Duration(days: 7, minutes: 1)),
        now,
      ),
      isTrue,
    );
  });

  test('automatic refresh is attempted at most once every 7 days (NFR-13)', () {
    expect(RefreshPolicy.canAutoRefresh(null, now), isTrue);
    expect(
      RefreshPolicy.canAutoRefresh(now.subtract(const Duration(days: 6)), now),
      isFalse,
    );
    expect(
      RefreshPolicy.canAutoRefresh(now.subtract(const Duration(days: 7)), now),
      isTrue,
    );
  });

  test('manual refresh calls the API at most once per 60 minutes (rule 5)', () {
    expect(RefreshPolicy.canManualRefresh(null, now), isTrue);
    expect(
      RefreshPolicy.canManualRefresh(
        now.subtract(const Duration(minutes: 59)),
        now,
      ),
      isFalse,
    );
    expect(
      RefreshPolicy.canManualRefresh(
        now.subtract(const Duration(minutes: 60)),
        now,
      ),
      isTrue,
    );
  });

  test('a time in the future, from a clock moved back, never blocks', () {
    final future = now.add(const Duration(days: 30));
    expect(RefreshPolicy.isStale(future, now), isTrue);
    expect(RefreshPolicy.canAutoRefresh(future, now), isTrue);
    expect(RefreshPolicy.canManualRefresh(future, now), isTrue);
  });
}
