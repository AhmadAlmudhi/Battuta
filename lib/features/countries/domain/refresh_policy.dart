/// When country data may be fetched from the API (PRD section 8.2, NFR-13).
abstract final class RefreshPolicy {
  /// Data older than this refreshes automatically, and automatic refresh is
  /// attempted at most this often per device.
  static const staleAfter = Duration(days: 7);

  /// Manual refresh calls the API at most this often per device.
  static const manualCooldown = Duration(minutes: 60);

  static bool isStale(DateTime? fetchedAt, DateTime now) =>
      fetchedAt == null || _elapsed(fetchedAt, now) > staleAfter;

  static bool canAutoRefresh(DateTime? lastAttempt, DateTime now) =>
      lastAttempt == null || _elapsed(lastAttempt, now) >= staleAfter;

  static bool canManualRefresh(DateTime? lastAttempt, DateTime now) =>
      lastAttempt == null || _elapsed(lastAttempt, now) >= manualCooldown;

  /// A time in the future means the device clock moved back; treat it as long
  /// ago so a wrong clock never blocks refreshes for good.
  static Duration _elapsed(DateTime since, DateTime now) =>
      since.isAfter(now) ? const Duration(days: 365) : now.difference(since);
}
