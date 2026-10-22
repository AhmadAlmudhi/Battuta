import 'dart:math';

import '../../travels/domain/travel_entry.dart';

/// Where the replay is during one step: how far the flight path from the
/// previous country has drawn, and how far the step's country has filled,
/// each from 0 to 1 before easing.
typedef ReplayMoment = ({int step, double path, double fill});

/// The trips "Replay my travels" plays (FR-MAP-35 to 38, FR-MAP-40): dated
/// visits, oldest first, one step each. A step takes 700 ms, or less when
/// the replay would otherwise run longer than 20 seconds.
class ReplayPlan {
  factory ReplayPlan(Iterable<TravelEntry> entries) {
    final dated = [
      for (final entry in entries)
        if (entry.status == TravelStatus.visited && entry.visitedOn != null)
          entry,
    ]..sort((a, b) => a.visitedOn!.compareTo(b.visitedOn!));
    return ReplayPlan._([
      for (final entry in dated)
        (code: entry.countryCode, year: entry.visitedOn!.year),
    ]);
  }

  ReplayPlan._(this.steps)
    : stepDuration = steps.isEmpty ? 0 : min(fullStep, longest / steps.length);

  static const fullStep = 700.0;
  static const longest = 20000.0;

  /// Visits without a date are left out (FR-MAP-35).
  final List<({String code, int year})> steps;

  /// In milliseconds.
  final double stepDuration;

  double get duration => steps.length * stepDuration;

  /// The Replay button shows only with at least 2 dated visits (FR-MAP-40).
  bool get canPlay => steps.length >= 2;

  /// Where the replay is at [ms]. In each step the flight path draws over the
  /// first 45% and the country fills from 35% to the end; the first step has
  /// no path and fills over the whole step (FR-MAP-36).
  ReplayMoment at(double ms) {
    if (steps.isEmpty || ms >= duration) {
      return (step: steps.length, path: 1, fill: 1);
    }
    final step = (ms / stepDuration).floor();
    final t = ms / stepDuration - step;
    if (step == 0) return (step: 0, path: 1, fill: t);
    return (
      step: step,
      path: (t / 0.45).clamp(0.0, 1.0),
      fill: ((t - 0.35) / 0.65).clamp(0.0, 1.0),
    );
  }
}
