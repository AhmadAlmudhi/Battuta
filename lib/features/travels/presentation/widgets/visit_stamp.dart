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
/// that was already visited shows the stamp still.
class VisitStamp extends ConsumerStatefulWidget {
  const VisitStamp({super.key, required this.countryCode});

  final String countryCode;

  @override
  ConsumerState<VisitStamp> createState() => _VisitStampState();
}

class _VisitStampState extends ConsumerState<VisitStamp>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    value: _isVisited(ref.read(travelEntryProvider(widget.countryCode)))
        ? 1
        : 0,
  );

  static bool _isVisited(AsyncValue<TravelEntry?> entry) =>
      entry.valueOrNull?.status == TravelStatus.visited;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEntryChanged(
    AsyncValue<TravelEntry?>? previous,
    AsyncValue<TravelEntry?> next,
  ) {
    final now = _isVisited(next);
    // The first value is what was already saved: show it without landing.
    if (previous == null || previous.isLoading) {
      _controller.value = now ? 1 : 0;
      return;
    }
    if (_isVisited(previous) == now) return;
    if (!now) {
      _controller.value = 0;
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
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

    final scale = Tween<double>(
      begin: 1.6,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    final turn = Tween<double>(
      begin: -20,
      end: -12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    final opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.35),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => _controller.value == 0
          ? const SizedBox.shrink()
          : Opacity(
              opacity: opacity.value,
              child: Transform.rotate(
                angle: turn.value * math.pi / 180,
                child: Transform.scale(scale: scale.value, child: child),
              ),
            ),
      child: _StampFace(year: year),
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
