import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current time. Tests override it so date rules, such as "not in the
/// future", don't depend on the day the tests run.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
