import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the device has a network connection. A connection doesn't
/// guarantee the internet is reachable, so callers still handle request
/// failures.
abstract interface class ConnectivityService {
  Future<bool> isOnline();

  /// The current state first, then every change.
  Stream<bool> watchOnline();
}

/// Uses connectivity_plus; on web it follows the browser's online and
/// offline events.
class PluginConnectivityService implements ConnectivityService {
  final _connectivity = Connectivity();

  @override
  Future<bool> isOnline() async =>
      _isOnline(await _connectivity.checkConnectivity());

  @override
  Stream<bool> watchOnline() async* {
    yield await isOnline();
    yield* _connectivity.onConnectivityChanged.map(_isOnline);
  }

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => PluginConnectivityService(),
);

/// True while online. Read it as `valueOrNull ?? true`, so the offline banner
/// never flashes before the first check.
final isOnlineProvider = StreamProvider<bool>(
  (ref) => ref.watch(connectivityServiceProvider).watchOnline().distinct(),
);
