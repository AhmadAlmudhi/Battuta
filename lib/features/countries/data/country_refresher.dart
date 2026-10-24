import 'package:shared_preferences/shared_preferences.dart';

import '../domain/country_repository.dart';
import '../domain/refresh_policy.dart';
import 'country_api_client.dart';

enum RefreshOutcome {
  refreshed,

  /// The data is fresh, or a refresh ran too recently to call the API again.
  upToDate,

  offline,

  /// The API call failed; the previous data is kept.
  failed,
}

/// Decides when to call the API for country data and records each call, so
/// API use stays within the shared quota (PRD section 8.2, NFR-13).
class CountryRefresher {
  CountryRefresher({
    required CountryRepository repository,
    required SharedPreferences prefs,
    required Future<bool> Function() isOnline,
    DateTime Function()? now,
  }) : _repository = repository,
       _prefs = prefs,
       _isOnline = isOnline,
       _now = now ?? DateTime.now;

  final CountryRepository _repository;
  final SharedPreferences _prefs;
  final Future<bool> Function() _isOnline;
  final DateTime Function() _now;

  static const _manualRefreshKey = 'manual_refresh_at';
  static const _autoRefreshKey = 'auto_refresh_at';

  Future<RefreshOutcome>? _inFlight;

  /// Runs in the background on launch when the data is older than 7 days
  /// (rule 3). Attempted at most once every 7 days, even when it fails.
  Future<RefreshOutcome> refreshIfStale() async {
    final now = _now();
    if (!RefreshPolicy.isStale(await _repository.dataFetchedAt(), now) ||
        !RefreshPolicy.canAutoRefresh(_read(_autoRefreshKey), now)) {
      return RefreshOutcome.upToDate;
    }
    return _refresh(_autoRefreshKey, now);
  }

  /// Pull to refresh or Refresh data (FR-EXP-11): calls the API at most once
  /// per 60 minutes, otherwise ends at once as up to date (rule 5).
  ///
  /// [onStart] runs only when the download begins, or has already begun, so
  /// the screen can say that it takes a moment.
  Future<RefreshOutcome> refreshManually({void Function()? onStart}) async {
    final now = _now();
    if (!RefreshPolicy.canManualRefresh(_read(_manualRefreshKey), now)) {
      return RefreshOutcome.upToDate;
    }
    return _refresh(_manualRefreshKey, now, onStart: onStart);
  }

  Future<RefreshOutcome> _refresh(
    String attemptKey,
    DateTime now, {
    void Function()? onStart,
  }) {
    // A refresh already running answers both callers, so overlapping
    // requests never call the API twice.
    if (_inFlight case final running?) {
      onStart?.call();
      return running;
    }
    return _inFlight = () async {
      try {
        if (!await _isOnline()) return RefreshOutcome.offline;
        await _prefs.setInt(attemptKey, now.millisecondsSinceEpoch);
        onStart?.call();
        await _repository.refresh(now: now);
        return RefreshOutcome.refreshed;
      } on CountryApiException {
        return RefreshOutcome.failed;
      } finally {
        _inFlight = null;
      }
    }();
  }

  DateTime? _read(String key) {
    final millis = _prefs.getInt(key);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }
}
