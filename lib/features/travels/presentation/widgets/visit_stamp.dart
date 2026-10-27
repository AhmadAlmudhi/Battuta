import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/travel_entry.dart';
import '../travel_providers.dart';

/// The passport stamp over a visited country's flag (PRD section 10.2).
///
/// When the country becomes visited while the screen is open, the stamp
/// lands: it scales from 1.6 to 1 with a slight turn over about 600 ms, and
/// Android and iOS give a light haptic tap (FR-TRV-02, FR-PLT-08). A country
/// that was already visited shows the stamp still, unless [landOnArrival].
class VisitStamp extends ConsumerStatefulWidget {
  const VisitStamp({
    super.key,
    required this.countryCode,
    this.delay = Duration.zero,
    this.landOnArrival = false,
  });

  final String countryCode;

  /// How long the stamp waits before landing, so the map's color spread
  /// can finish first (FR-MAP-32).
  final Duration delay;

  /// Whether the stamp of a country that was already visited lands once the
  /// screen has finished arriving, after the flag's flight from the previous
  /// screen, instead of riding in with it. The stamp also fades out as the
  /// screen leaves, so it never floats where the flag flew away from. A
  /// screen that is already there, such as one opened from a link, shows
  /// the stamp still.
  final bool landOnArrival;

  @override
  ConsumerState<VisitStamp> createState() => _VisitStampState();
}

class _VisitStampState extends ConsumerState<VisitStamp>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600) + widget.delay,
  );

  /// The screen's transition, followed when [VisitStamp.landOnArrival].
  Animation<double>? _route;

  /// Whether the screen was still arriving when the stamp was built, and is
  /// yet to finish.
  bool _arriving = false;

  /// Whether a saved visit waits for the screen to arrive before landing.
  bool _landingOnArrival = false;

  bool _leaving = false;

  /// Whether what was already saved has been shown.
  bool _started = false;

  static bool _isVisited(AsyncValue<TravelEntry?> entry) =>
      entry.valueOrNull?.status == TravelStatus.visited;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (widget.landOnArrival) {
      final route = ModalRoute.of(context);
      _route = route?.animation?..addStatusListener(_onRouteStatus);
      // On the first frame of its entrance a screen is built offstage, as if
      // it had arrived, so heroes can find where they land.
      _arriving =
          route != null && (route.offstage || !route.animation!.isCompleted);
    }
    _showSaved(_isVisited(ref.read(travelEntryProvider(widget.countryCode))));
  }

  @override
  void dispose() {
    _route?.removeStatusListener(_onRouteStatus);
    _controller.dispose();
    super.dispose();
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status.isCompleted) {
      _arriving = false;
      if (_landingOnArrival) {
        _landingOnArrival = false;
        _land();
      }
    }
    final leaving = status == AnimationStatus.reverse;
    if (leaving != _leaving) setState(() => _leaving = leaving);
  }

  /// Shows what was already saved: still, or landing once the screen has
  /// arrived.
  void _showSaved(bool visited) {
    _landingOnArrival = visited && _arriving;
    _controller.value = visited && !_arriving ? 1 : 0;
  }

  void _land() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  void _onEntryChanged(
    AsyncValue<TravelEntry?>? previous,
    AsyncValue<TravelEntry?> next,
  ) {
    final now = _isVisited(next);
    if (previous == null || previous.isLoading) {
      _showSaved(now);
      return;
    }
    if (_isVisited(previous) == now) return;
    _landingOnArrival = false;
    if (!now) {
      _controller.value = 0;
      return;
    }
    _land();
    if (!kIsWeb) HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(travelEntryProvider(widget.countryCode), _onEntryChanged);
    final year = ref
        .watch(travelEntryProvider(widget.countryCode))
        .valueOrNull
        ?.visitedOn
        ?.year;

    // The landing runs after the delay.
    final start =
        widget.delay.inMicroseconds / _controller.duration!.inMicroseconds;
    final scale = Tween<double>(begin: 1.6, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, 1, curve: Curves.easeOutBack),
      ),
    );
    final turn = Tween<double>(begin: -20, end: -12).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, 1, curve: Curves.easeOut),
      ),
    );
    final opacity = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, start + (1 - start) * 0.35),
    );

    return AnimatedOpacity(
      opacity: _leaving ? 0 : 1,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 150),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => _controller.value <= start
            ? const SizedBox.shrink()
            : Opacity(
                opacity: opacity.value,
                child: Transform.rotate(
                  angle: turn.value * math.pi / 180,
                  child: Transform.scale(scale: scale.value, child: child),
                ),
              ),
        child: _StampFace(year: year),
      ),
    );
  }
}

/// Passport Cream with a Stamp Amber ring and Deep Ink text, readable over
/// any flag (PRD section 1.4).
class _StampFace extends StatelessWidget {
  const _StampFace({this.year});

  final int? year;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: BrandColors.passportCream,
        border: Border.all(color: BrandColors.stampAmber, width: 5),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x33000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.public_rounded,
            color: BrandColors.deepInk,
            size: 22,
          ),
          Text(
            AppLocalizations.of(context).stampVisited,
            style: text.labelSmall?.copyWith(
              color: BrandColors.deepInk,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (year != null)
            Text(
              '$year',
              style: text.labelSmall?.copyWith(color: BrandColors.deepInk),
            ),
        ],
      ),
    );
  }
}
