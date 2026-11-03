import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/widgets/warm_up_scope.dart';
import 'features/countries/domain/country.dart';
import 'features/countries/presentation/country_details_screen.dart';
import 'features/countries/presentation/explore_controller.dart';
import 'features/countries/presentation/widgets/country_card.dart';
import 'features/countries/presentation/widgets/flag_image.dart';
import 'features/travels/domain/travel_entry.dart';

/// Once per visit: compiled shaders last until the page closes.
bool _warmedUp = false;

/// Lets a test run the warm-up again.
@visibleForTesting
void debugResetWebShaderWarmUp() => _warmedUp = false;

/// Whether the warm-up runs: on web only, where the browser compiles each
/// graphics shader the first time it's used. Android and iOS get Flutter's
/// shaders compiled ahead of time. Tests turn it on.
final shaderWarmUpEnabledProvider = Provider<bool>((ref) => kIsWeb);

/// Draws, over [child] but too faint to see and once per visit, what
/// opening a country draws the first time (PRD D-14): Country details in
/// its page transition, a flag's flight between a card and the header, and
/// Explore's cards in quick select and under a transition. The browser
/// compiles their shaders then, which takes up to half a second without a
/// GPU, instead of freezing on the first tap.
///
/// It draws one group a frame, and only while nothing animates and no
/// pointer has moved for a moment, so the work lands where nobody sees it.
/// The world map isn't included: drawn this way it needs other shaders than
/// on screen, and loading it early made Stats' first frame slower.
class WebShaderWarmUp extends ConsumerStatefulWidget {
  const WebShaderWarmUp({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<WebShaderWarmUp> createState() => _WebShaderWarmUpState();
}

class _WebShaderWarmUpState extends ConsumerState<WebShaderWarmUp> {
  static const _groups = 2;
  static const _quietFor = Duration(milliseconds: 600);

  /// The group drawn this frame, or null.
  int? _group;
  int _next = 0;
  Timer? _timer;

  /// No pointer is pressed, and none has moved or pressed for [_quietFor].
  bool _quiet = false;
  Timer? _quietTimer;
  final _pressed = <int>{};

  late final bool _enabled =
      !_warmedUp && ref.read(shaderWarmUpEnabledProvider);

  @override
  void initState() {
    super.initState();
    if (!_enabled) return;
    _listen(true);
    _onPointer(null);
    // After Explore's first frames and its entrance.
    _wait(const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _quietTimer?.cancel();
    _listen(false);
    super.dispose();
  }

  bool _listening = false;

  /// Follows every pointer in the app, to know when nobody is touching it.
  void _listen(bool listen) {
    if (listen == _listening) return;
    _listening = listen;
    final router = GestureBinding.instance.pointerRouter;
    listen
        ? router.addGlobalRoute(_onPointer)
        : router.removeGlobalRoute(_onPointer);
  }

  void _onPointer(PointerEvent? event) {
    switch (event) {
      case PointerDownEvent():
        _pressed.add(event.pointer);
      case PointerUpEvent() || PointerCancelEvent():
        _pressed.remove(event!.pointer);
    }
    _quiet = false;
    _quietTimer?.cancel();
    _quietTimer = Timer(_quietFor, () => _quiet = _pressed.isEmpty);
  }

  void _wait(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, _drawNext);
  }

  void _drawNext() {
    if (!mounted) return;
    final still = SchedulerBinding.instance.transientCallbackCount == 0;
    if (!_quiet || !still || _sample == null) {
      _wait(const Duration(milliseconds: 300));
      return;
    }
    setState(() => _group = _next++);
    // Once it's painted, take it away and wait for the next quiet moment.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _group = null);
      if (_next < _groups) {
        _wait(const Duration(milliseconds: 100));
      } else {
        _warmedUp = true;
        _quietTimer?.cancel();
        _listen(false);
      }
    });
  }

  /// The first country Explore shows, whose flag is already decoded, so
  /// the warm-up draws it at once.
  Country? get _sample {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return ref.read(exploreResultsProvider(arabic)).valueOrNull?.firstOrNull;
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      // On top, not underneath: the browser's graphics library drops what a
      // later full-screen background covers before drawing it, so a covered
      // warm-up would compile nothing.
      Positioned.fill(
        child: switch ((_group, _group == null ? null : _sample)) {
          (0, final sample?) => _Hidden(child: _DetailsGroup(country: sample)),
          (_?, final sample?) => _Hidden(child: _CardsGroup(country: sample)),
          _ => const SizedBox.shrink(),
        },
      ),
    ],
  );
}

/// Drawn at 1/255 opacity for one frame, too faint to see, and out of reach
/// of taps, focus, screen readers, hero flights, and the tab title. Its
/// animations are held still and it draws as with reduced motion, so
/// screens show their finished state at once.
class _Hidden extends StatelessWidget {
  const _Hidden({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Opacity(
      opacity: 1 / 255,
      child: ExcludeSemantics(
        child: ExcludeFocus(
          child: HeroMode(
            enabled: false,
            child: TickerMode(
              enabled: false,
              child: WarmUpScope(
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(disableAnimations: true),
                  child: Material(
                    type: MaterialType.transparency,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Country details early and late in the page transition, which also draws
/// the page underneath leaving, and settled; and a flag at three points of
/// its flight.
class _DetailsGroup extends StatelessWidget {
  const _DetailsGroup({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    Widget page(double progress) {
      final screen = CountryDetailsScreen(code: country.code);
      if (progress == 1 || route is! PageRoute) return screen;
      final at = AlwaysStoppedAnimation<double>(progress);
      return Theme.of(
        context,
      ).pageTransitionsTheme.buildTransitions(route, context, at, at, screen);
    }

    return Stack(
      children: [
        for (final progress in [0.15, 0.85, 1.0])
          Positioned.fill(child: page(progress)),
        for (final (i, progress) in [0.15, 0.5, 0.85].indexed)
          Positioned(
            left: 0,
            top: 120.0 * i,
            width: 240,
            height: 160,
            child: FlagFlight(
              country: country,
              progress: AlwaysStoppedAnimation(progress),
            ),
          ),
      ],
    );
  }
}

/// Explore's cards in quick select, one picked and one visited and faded,
/// also as the page underneath a transition.
class _CardsGroup extends StatelessWidget {
  const _CardsGroup({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    // Wrapped, so they never overflow a narrow screen.
    final cards = Wrap(
      children: [
        for (final (status, selected) in [
          (null, true),
          (TravelStatus.visited, false),
          (TravelStatus.wishlist, false),
        ])
          SizedBox.square(
            dimension: 180,
            child: CountryCard(
              country: country,
              status: status,
              selected: selected,
              onTap: () {},
            ),
          ),
      ],
    );
    final route = ModalRoute.of(context);
    if (route is! PageRoute) return cards;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cards,
        Theme.of(context).pageTransitionsTheme.buildTransitions(
          route,
          context,
          const AlwaysStoppedAnimation(1),
          const AlwaysStoppedAnimation(0.5),
          cards,
        ),
      ],
    );
  }
}
