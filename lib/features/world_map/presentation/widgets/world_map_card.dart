import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/format/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../countries/presentation/country_providers.dart';
import '../../../countries/presentation/region_names.dart';
import '../../../travels/domain/travel_entry.dart';
import '../../../travels/presentation/travel_providers.dart';
import '../../domain/map_projection.dart';
import '../../domain/map_regions.dart';
import '../../domain/map_replay.dart';
import '../../domain/map_reveal.dart';
import '../../domain/map_view.dart';
import '../map_image_sharer.dart';
import '../map_share_image.dart';
import '../world_map_colors.dart';
import '../world_map_geometry.dart';
import '../world_map_painter.dart';
import '../world_map_providers.dart';
import 'map_country_card.dart';
import 'map_legend.dart';

/// Whether the reveal has played this session (FR-MAP-26).
final _revealPlayedProvider = StateProvider<bool>((ref) => false);

/// Region flights and Reset view (PRD section 10.2).
const _flightDuration = Duration(milliseconds: 600);

/// Zooming with the buttons, the keys, or a double tap.
const _stepDuration = Duration(milliseconds: 250);

/// The longest change animation: a new visit spreading from the tap point
/// (FR-MAP-32).
const _changeDuration = Duration(milliseconds: 500);

/// The world map at the top of Stats (PRD section 6.10): every country
/// colored by status, zoom and region focus, a card for the selected
/// country, and the legend.
class WorldMapCard extends ConsumerStatefulWidget {
  const WorldMapCard({
    super.key,
    this.header,
    required this.visited,
    required this.wishlist,
    required this.total,
  });

  /// The area that draws the map and takes taps, for tests.
  static const mapKey = ValueKey('world-map');

  /// Closes the selected country's card after a tap at [position], in
  /// global coordinates, unless the tap was on the card itself (FR-MAP-14).
  /// Stats calls this for taps on the page outside the map; the map's own
  /// taps never reach it.
  static void tapOutside(GlobalKey card, Offset position) {
    if (card.currentState case final _WorldMapCardState state) {
      state._tapOutside(position);
    }
  }

  /// The Stats headline (FR-MAP-02); null in the zero state (FR-STA-05).
  final Widget? header;

  /// Counts for the screen-reader summary (FR-MAP-08) and the shared image
  /// (FR-MAP-41).
  final int visited;
  final int wishlist;
  final int total;

  @override
  ConsumerState<WorldMapCard> createState() => _WorldMapCardState();
}

class _WorldMapCardState extends ConsumerState<WorldMapCard>
    with TickerProviderStateMixin {
  final _cardFocus = FocusNode(debugLabel: 'World map card');
  final _mapFocus = FocusNode(debugLabel: 'World map');

  /// The selected country's card, which taps outside the map leave open.
  final _countryCard = GlobalKey();
  late final _flight = AnimationController(vsync: this)
    ..addStatusListener(_onFlightStatus);
  late final _reveal = AnimationController(vsync: this);
  late final _changes = AnimationController(
    vsync: this,
    duration: _changeDuration,
  );
  late final _replay = AnimationController(vsync: this)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _replayPlan = null);
      }
    });

  String? _selected;
  String? _hovered;

  /// A country whose card was just closed while the pointer is over it. It
  /// shows no hover highlight until the pointer leaves it, so it doesn't
  /// look selected (FR-MAP-14).
  String? _hoverHidden;
  Offset? _pointer;

  /// The view at rest, or where the current flight started.
  MapView _view = MapView.world;
  MapView _flightTo = MapView.world;
  Curve _flightCurve = Curves.easeInOutCubic;

  /// The region whose surroundings fade, and how far, from 0 to 1, at rest
  /// and at the end of the current flight (FR-MAP-23).
  String? _fadedRegion;
  double _fade = 0;
  double _fadeTo = 0;

  Size _viewport = Size.zero;
  double _gestureScale = 1;
  bool _focusedByPointer = false;
  bool _regionRestored = false;

  // The reveal is set up while building and starts after that frame, so the
  // first frame already shows its beginning.
  bool _revealChecked = false;
  bool _revealPending = false;
  List<String> _revealOrder = const [];
  RevealSchedule _schedule = RevealSchedule(0);

  // For telling a double tap from two taps, by the pointer events' times.
  Duration? _downTime;
  Duration? _upTime;
  (Duration, Offset)? _lastTap;

  // Changes made while the map is on screen (FR-MAP-32 to 34): what each
  // country was and became, and where a new visit's fill starts. Set up
  // while building, like the reveal, and started after that frame.
  Map<String, TravelStatus>? _lastStatuses;
  bool _changesPending = false;
  Map<String, ({TravelStatus? from, TravelStatus? to})> _changed = const {};
  Map<String, Offset> _changeOrigins = const {};

  /// Where the selected country was tapped, in map units.
  Offset? _tapPoint;

  /// The replay playing, if any (FR-MAP-35 to 39).
  ReplayPlan? _replayPlan;

  /// Whether Share my map is still drawing or showing its share sheet, so a
  /// second click doesn't share twice.
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _mapFocus.addListener(() {
      setState(() {
        if (!_mapFocus.hasFocus) _focusedByPointer = false;
      });
    });
  }

  @override
  void dispose() {
    _flight.dispose();
    _reveal.dispose();
    _changes.dispose();
    _replay.dispose();
    _mapFocus.dispose();
    _cardFocus.dispose();
    super.dispose();
  }

  double get _flightProgress => _flightCurve.transform(_flight.value);

  MapView get _currentView => _flight.isAnimating
      ? MapView.lerp(_view, _flightTo, _flightProgress)
      : _view;

  double get _currentFade =>
      _flight.isAnimating ? _fade + (_fadeTo - _fade) * _flightProgress : _fade;

  /// Where the view is headed.
  MapView get _targetView => _flight.isAnimating ? _flightTo : _view;

  void _onFlightStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    setState(() {
      _view = _flightTo;
      _fade = _fadeTo;
      if (_fade == 0) _fadedRegion = null;
    });
  }

  /// Stops a flight where it is, so a gesture can take over.
  void _settle() {
    if (!_flight.isAnimating) return;
    final (view, fade) = (_currentView, _currentFade);
    _flight.stop();
    _view = view;
    _fade = _fadeTo = fade;
  }

  void _flyTo(
    MapView target, {
    double? fade,
    Duration duration = _flightDuration,
    Curve curve = Curves.easeInOutCubic,
  }) {
    _settle();
    final fadeTo = fade ?? _fade;
    // With reduced motion, every map animation jumps to its end (NFR-09).
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() {
        _view = target;
        _fade = _fadeTo = fadeTo;
        if (fadeTo == 0) _fadedRegion = null;
      });
      return;
    }
    setState(() {
      _flightTo = target;
      _fadeTo = fadeTo;
      _flightCurve = curve;
    });
    _flight
      ..duration = duration
      ..forward(from: 0);
  }

  /// Flies to [region]'s frame and fades the rest, or back to the world
  /// for null (FR-MAP-22, FR-MAP-23).
  void _showRegion(String? region) {
    if (_viewport.isEmpty) return;
    final frame = region == null ? null : regionFrame(region);
    if (frame == null) {
      _flyTo(MapView.world, fade: 0);
      return;
    }
    setState(() => _fadedRegion = region);
    _flyTo(
      MapView.fit(frame, width: _viewport.width, height: _viewport.height),
      fade: 1,
    );
  }

  void _zoomBy(double factor, {Offset? at}) {
    final point = at ?? _viewport.center(Offset.zero);
    _flyTo(
      _targetView.zoomedBy(
        factor,
        x: point.dx,
        y: point.dy,
        width: _viewport.width,
        height: _viewport.height,
      ),
      duration: _stepDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _panBy(double dx, double dy) => _flyTo(
    _targetView.pannedBy(dx, dy, _viewport.width),
    duration: _stepDuration,
    curve: Curves.easeOutCubic,
  );

  /// Back to the world view, and out of any region focus (FR-MAP-18).
  void _resetView() {
    final region = ref.read(mapRegionProvider.notifier);
    if (region.state != null) {
      // The region listener flies back.
      region.state = null;
    } else {
      _flyTo(MapView.world, fade: 0);
    }
  }

  /// Ends the reveal or the replay, if one is playing, and says whether one
  /// was (FR-MAP-31, FR-MAP-39).
  bool _skipMotion() {
    if (_replay.isAnimating) {
      _replay.value = 1;
      return true;
    }
    if (!_revealPending && !_reveal.isAnimating) return false;
    setState(() => _revealPending = false);
    _reveal.value = 1;
    return true;
  }

  /// Sets up the reveal the first time the map has its data this session
  /// (FR-MAP-26). With reduced motion it counts as played without playing.
  void _prepareReveal(
    WorldMapGeometry geometry,
    Map<String, TravelStatus> statuses,
    List<TravelEntry> entries,
  ) {
    if (_revealChecked) return;
    _revealChecked = true;
    if (ref.read(_revealPlayedProvider)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(_revealPlayedProvider.notifier).state = true;
      if (!_revealPending) return;
      setState(() => _revealPending = false);
      _reveal
        ..duration = Duration(milliseconds: _schedule.duration.round())
        ..forward(from: 0);
    });
    if (MediaQuery.disableAnimationsOf(context)) return;
    final order = [
      for (final code in revealOrder(entries))
        if (geometry.countries.containsKey(code) ||
            geometry.dots.containsKey(code))
          code,
    ];
    if (order.isEmpty && !statuses.containsValue(TravelStatus.wishlist)) {
      return;
    }
    _revealOrder = order;
    _schedule = RevealSchedule(order.length);
    _revealPending = true;
  }

  /// What the painter animates now, if anything: the replay, the reveal, or
  /// a change made while the map is on screen.
  MapMotion? _currentMotion(WorldMapGeometry geometry) {
    if (_replayPlan case final plan? when _replay.isAnimating) {
      return _replayMotion(plan, geometry, _replay.value * plan.duration);
    }
    if (_revealPending || _reveal.isAnimating) {
      final ms = _reveal.value * _schedule.duration;
      return MapMotion(
        fills: {
          for (final (i, code) in _revealOrder.indexed)
            code: Curves.easeOut.transform(_schedule.fill(i, ms)),
        },
        hatching: Curves.easeOut.transform(_schedule.hatching(ms)),
      );
    }
    if (_changesPending || _changes.isAnimating) {
      return _changeMotion(
        _changesPending ? 0 : _changes.value * _changeDuration.inMilliseconds,
      );
    }
    return null;
  }

  /// A country just marked visited fills from the tap point over 500 ms, a
  /// new wishlist country's hatching fades in over 300 ms, and a removed
  /// country's color fades out over 250 ms (FR-MAP-32 to 34).
  MapMotion _changeMotion(double ms) {
    double over(double duration) =>
        Curves.easeOut.transform((ms / duration).clamp(0.0, 1.0));
    return MapMotion(
      fills: {
        for (final MapEntry(:key, :value) in _changed.entries)
          if (value.to == TravelStatus.visited) key: over(500),
      },
      origins: _changeOrigins,
      hatchings: {
        for (final MapEntry(:key, :value) in _changed.entries)
          if (value.to == TravelStatus.wishlist) key: over(300),
      },
      // The old status shows under the new one: a wishlist country being
      // visited keeps its hatching until the amber covers it, and amber
      // fades out under hatching fading in.
      fading: {
        for (final MapEntry(:key, value: (:from, :to)) in _changed.entries)
          if (from != null)
            key: (
              from,
              switch (to) {
                null => 1 - (ms / 250).clamp(0.0, 1.0),
                TravelStatus.visited => 1,
                TravelStatus.wishlist => 1 - over(300),
              },
            ),
      },
    );
  }

  /// The replay at [ms] (FR-MAP-35 to 37): visits fill in order of date,
  /// each after a dotted flight path from the one before. Undated visits and
  /// the wishlist wait for the end, when the map is back to normal.
  MapMotion _replayMotion(
    ReplayPlan plan,
    WorldMapGeometry geometry,
    double ms,
  ) {
    final now = plan.at(ms);
    final steps = plan.steps;
    Offset anchor(String code) => geometry.countries.containsKey(code)
        ? geometry.spreadStart(code)
        : geometry.dots[code] ?? Offset.zero;
    return MapMotion(
      fills: {
        for (final MapEntry(:key, :value)
            in (_lastStatuses ?? const <String, TravelStatus>{}).entries)
          if (value == TravelStatus.visited) key: 0,
        for (final (i, step) in steps.indexed)
          step.code: i < now.step
              ? 1
              : i == now.step
              ? Curves.easeOut.transform(now.fill)
              : 0,
      },
      hatching: 0,
      flight: now.step > 0 && now.step < steps.length && now.path > 0
          ? MapFlight(
              from: anchor(steps[now.step - 1].code),
              to: anchor(steps[now.step].code),
              progress: Curves.easeInOut.transform(now.path),
            )
          : null,
    );
  }

  /// Notices statuses that changed since the last build, so they can
  /// animate (FR-MAP-32 to 34). Changes that arrive while another animation
  /// plays, with reduced motion, or while Stats is hidden just show.
  void _noticeChanges(Map<String, TravelStatus> statuses) {
    final last = _lastStatuses;
    _lastStatuses = statuses;
    if (last == null ||
        identical(last, statuses) ||
        _revealPending ||
        _reveal.isAnimating ||
        _replay.isAnimating ||
        MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      return;
    }
    final changed = {
      for (final code in {...last.keys, ...statuses.keys})
        if (last[code] != statuses[code])
          code: (from: last[code], to: statuses[code]),
    };
    if (changed.isEmpty) return;
    final (selected, tap) = (_selected, _tapPoint);
    _changed = changed;
    _changeOrigins = {
      if (selected != null &&
          tap != null &&
          changed[selected]?.to == TravelStatus.visited)
        selected: tap,
    };
    _changesPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_changesPending) return;
      setState(() => _changesPending = false);
      _changes.forward(from: 0);
    });
  }

  /// Plays the dated visits in order, from the world view (FR-MAP-35).
  void _startReplay(ReplayPlan plan) {
    _skipMotion();
    _changes.value = 1;
    setState(() {
      _changesPending = false;
      _selected = null;
      _tapPoint = null;
      _replayPlan = plan;
    });
    _resetView();
    _replay
      ..duration = Duration(milliseconds: plan.duration.round())
      ..forward(from: 0);
  }

  /// Draws the shared image and hands it to the platform (FR-MAP-41,
  /// FR-MAP-42). [button] anchors the share sheet on iPad.
  Future<void> _shareMap(BuildContext button) async {
    final geometry = ref.read(worldMapGeometryProvider).valueOrNull;
    final statuses = ref.read(travelStatusesProvider).valueOrNull;
    if (_sharing || geometry == null || statuses == null) return;
    _sharing = true;
    try {
      final box = button.findRenderObject() as RenderBox?;
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size;
      final png = await renderMapShareImage(
        geometry: geometry,
        statuses: statuses,
        theme: Theme.of(context),
        direction: Directionality.of(context),
        texts: MapShareTexts.of(
          context,
          visited: widget.visited,
          total: widget.total,
          wishlist: widget.wishlist,
        ),
      );
      if (!mounted) return;
      await ref.read(mapImageSharerProvider)(
        png,
        fileName: 'battuta-map.png',
        origin: origin,
      );
    } finally {
      _sharing = false;
    }
  }

  /// The map point under a point on the map, in dp.
  Offset _mapPoint(Offset position) {
    final (x, y) = _currentView.toMap(
      position.dx,
      position.dy,
      _viewport.width,
      _viewport.height,
    );
    return Offset(x, y);
  }

  /// The selectable country under a point on the map, in dp.
  String? _hit(Offset position) {
    final hitTester = ref.read(mapHitTesterProvider);
    if (hitTester == null || _viewport.isEmpty) return null;
    final point = _mapPoint(position);
    final unitsPerDp = 1 / _currentView.pixelsPerUnit(_viewport.width);
    return hitTester.hitTest(
      (x: point.dx, y: point.dy),
      dotRadius: MapSizes.dotRadius * unitsPerDp,
      reach: 24 * unitsPerDp,
    );
  }

  void _onTapUp(TapUpDetails details) {
    if (_skipMotion()) return;
    _focusedByPointer = true;
    _mapFocus.requestFocus();
    final at = details.localPosition;
    // A second tap close to the first, and soon after, zooms in
    // (FR-MAP-16). Single taps still select at once.
    if ((_lastTap, _downTime) case ((final upAt, final tapAt)?, final down?)
        when down - upAt <= kDoubleTapTimeout &&
            (at - tapAt).distance <= kDoubleTapSlop) {
      _lastTap = null;
      _zoomBy(2, at: at);
      return;
    }
    _lastTap = _upTime == null ? null : (_upTime!, at);
    final hit = _hit(at);
    // Tapping the selected country again closes its card (FR-MAP-14).
    if (hit != null && hit == _selected) {
      _closeCard();
      return;
    }
    setState(() {
      _selected = hit;
      _tapPoint = hit == null ? null : _mapPoint(at);
      _hoverHidden = null;
    });
  }

  /// Closes the selected country's card and clears every highlight on it,
  /// including the hover highlight while the pointer is still over it
  /// (FR-MAP-14).
  void _closeCard() {
    final closed = _selected;
    if (closed == null) return;
    setState(() {
      _selected = null;
      _tapPoint = null;
      if (_hovered == closed) {
        _hovered = null;
        _hoverHidden = closed;
      }
    });
  }

  void _tapOutside(Offset position) {
    final card = _countryCard.currentContext?.findRenderObject();
    if (card is RenderBox &&
        card.hasSize &&
        (card.localToGlobal(Offset.zero) & card.size).contains(position)) {
      return;
    }
    // The map lets go of the keyboard too, so its keys stop zooming and
    // panning it.
    if (_mapFocus.hasFocus) _mapFocus.unfocus();
    _closeCard();
  }

  void _onScaleStart(ScaleStartDetails details) {
    _skipMotion();
    _settle();
    _gestureScale = 1;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final factor = details.scale / _gestureScale;
    _gestureScale = details.scale;
    final focus = details.localFocalPoint;
    setState(() {
      _view = _view
          .pannedBy(
            details.focalPointDelta.dx,
            details.focalPointDelta.dy,
            _viewport.width,
          )
          .zoomedBy(
            factor,
            x: focus.dx,
            y: focus.dy,
            width: _viewport.width,
            height: _viewport.height,
          );
    });
  }

  /// Ctrl or ⌘ with the mouse wheel, or a trackpad pinch, zooms. The plain
  /// wheel is left to the page, which scrolls (FR-MAP-16, FR-MAP-17).
  void _onPointerSignal(PointerSignalEvent event) {
    final keys = HardwareKeyboard.instance;
    final factor = switch (event) {
      PointerScaleEvent(:final scale) => scale,
      PointerScrollEvent(:final scrollDelta)
          when keys.isControlPressed || keys.isMetaPressed =>
        exp(-scrollDelta.dy / 300),
      _ => null,
    };
    if (factor == null) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      _skipMotion();
      _settle();
      setState(() {
        _view = _view.zoomedBy(
          factor,
          x: event.localPosition.dx,
          y: event.localPosition.dy,
          width: _viewport.width,
          height: _viewport.height,
        );
      });
    });
  }

  /// On web, + and − zoom and the arrow keys pan. The arrows follow the
  /// compass in both languages: Left shows more of the west (FR-MAP-19).
  KeyEventResult _onMapKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final step = _viewport.width / 5;
    final action = <LogicalKeyboardKey, VoidCallback>{
      LogicalKeyboardKey.arrowLeft: () => _panBy(step, 0),
      LogicalKeyboardKey.arrowRight: () => _panBy(-step, 0),
      LogicalKeyboardKey.arrowUp: () => _panBy(0, step),
      LogicalKeyboardKey.arrowDown: () => _panBy(0, -step),
      LogicalKeyboardKey.equal: () => _zoomBy(2),
      LogicalKeyboardKey.add: () => _zoomBy(2),
      LogicalKeyboardKey.numpadAdd: () => _zoomBy(2),
      LogicalKeyboardKey.minus: () => _zoomBy(0.5),
      LogicalKeyboardKey.numpadSubtract: () => _zoomBy(0.5),
    }[event.logicalKey];
    if (action == null) return KeyEventResult.ignored;
    setState(() => _focusedByPointer = false);
    action();
    return KeyEventResult.handled;
  }

  /// Esc closes the card (FR-MAP-14), also while one of its buttons has
  /// focus.
  KeyEventResult _onCardKey(FocusNode node, KeyEvent event) {
    if (_selected == null ||
        event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape) {
      return KeyEventResult.ignored;
    }
    _closeCard();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final geometry = ref.watch(worldMapGeometryProvider).valueOrNull;
    final hitTester = ref.watch(mapHitTesterProvider);
    final statuses = ref.watch(travelStatusesProvider).valueOrNull;
    final entries = ref.watch(travelEntriesProvider).valueOrNull;
    final region = ref.watch(mapRegionProvider);
    ref.listen(mapRegionProvider, (_, next) => _showRegion(next));
    final selected = _selected;

    final ready =
        geometry != null &&
        hitTester != null &&
        statuses != null &&
        entries != null;
    final replay = entries == null ? null : ReplayPlan(entries);
    if (ready) {
      _prepareReveal(geometry, statuses, entries);
      _noticeChanges(statuses);
      // A region chosen before this card was built, for example in the
      // zero state.
      if (!_regionRestored) {
        _regionRestored = true;
        if (region != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showRegion(region);
          });
        }
      }
    }

    // Focus only carries Esc; it isn't a control for screen readers.
    return Focus(
      focusNode: _cardFocus,
      onKeyEvent: _onCardKey,
      includeSemantics: false,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.header case final header?)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 16),
                  child: header,
                ),
              _RegionChips(selected: region),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ready
                    ? _map(context, geometry, statuses, region)
                    : const _MapPlaceholder(),
              ),
              // A focused region's counts sit under the map, where they
              // cover none of it (FR-MAP-24).
              _Resizing(
                child: switch ((region, statuses)) {
                  (final region?, final statuses?) when _replayPlan == null =>
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        20,
                        10,
                        20,
                        0,
                      ),
                      child: _RegionSummary(
                        region: region,
                        statuses: statuses,
                        regions: ref.watch(countryRegionsProvider),
                      ),
                    ),
                  _ => const SizedBox(width: double.infinity),
                },
              ),
              _Resizing(
                child: selected == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        key: _countryCard,
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: MapCountryCard(
                          key: ValueKey(selected),
                          code: selected,
                          onClose: _closeCard,
                        ),
                      ),
              ),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
                child: MapLegend(),
              ),
              if (replay != null)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 0),
                  child: switch (_replayPlan) {
                    final plan? => _ReplayBar(
                      plan: plan,
                      progress: _replay,
                      onSkip: _skipMotion,
                    ),
                    null => _MapActions(
                      // Replay is only animation, so reduced motion hides it.
                      canReplay:
                          replay.canPlay &&
                          !MediaQuery.disableAnimationsOf(context),
                      canShare: widget.visited > 0,
                      onReplay: () => _startReplay(replay),
                      onShare: _shareMap,
                    ),
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _map(
    BuildContext context,
    WorldMapGeometry geometry,
    Map<String, TravelStatus> statuses,
    String? region,
  ) {
    final l10n = AppLocalizations.of(context);
    final colors = WorldMapColors.of(context);
    final regions = ref.watch(countryRegionsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth,
          constraints.maxWidth * geometry.size.height / geometry.size.width,
        );
        _viewport = size;
        final focusRing =
            _mapFocus.hasFocus &&
            !_focusedByPointer &&
            FocusManager.instance.highlightMode ==
                FocusHighlightMode.traditional;

        final map = AnimatedBuilder(
          animation: Listenable.merge([_flight, _reveal, _changes, _replay]),
          builder: (context, _) {
            final view = _currentView;
            final faded = _fadedRegion;
            return Stack(
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    size: size,
                    painter: WorldMapBasePainter(
                      geometry: geometry,
                      colors: colors,
                      view: view,
                    ),
                  ),
                ),
                CustomPaint(
                  size: size,
                  painter: WorldMapPainter(
                    geometry: geometry,
                    statuses: statuses,
                    colors: colors,
                    view: view,
                    selected: _selected,
                    hovered: _hovered,
                    motion: _currentMotion(geometry),
                    outside: faded == null
                        ? null
                        : geometry.outside(faded, regions),
                    fade: _currentFade,
                  ),
                ),
                if ((_hovered, _pointer) case (final code?, final pointer?))
                  _HoverLabel(code: code, pointer: pointer, map: size),
              ],
            );
          },
        );

        return SizedBox.fromSize(
          size: size,
          child: Stack(
            children: [
              Semantics(
                container: true,
                label: l10n.mapSemanticsLabel(
                  context.formatInteger(widget.visited),
                  context.formatInteger(widget.wishlist),
                ),
                customSemanticsActions: {
                  CustomSemanticsAction(label: l10n.mapViewAsList): () =>
                      context.go('/travels'),
                },
                child: ExcludeSemantics(
                  child: Focus(
                    focusNode: _mapFocus,
                    onKeyEvent: _onMapKey,
                    child: Listener(
                      onPointerDown: (event) => _downTime = event.timeStamp,
                      onPointerUp: (event) => _upTime = event.timeStamp,
                      onPointerSignal: _onPointerSignal,
                      child: RawGestureDetector(
                        behavior: HitTestBehavior.opaque,
                        gestures: {
                          TapGestureRecognizer:
                              GestureRecognizerFactoryWithHandlers<
                                TapGestureRecognizer
                              >(
                                () => TapGestureRecognizer(debugOwner: this),
                                (recognizer) => recognizer.onTapUp = _onTapUp,
                              ),
                          _MapGestureRecognizer:
                              GestureRecognizerFactoryWithHandlers<
                                _MapGestureRecognizer
                              >(
                                () => _MapGestureRecognizer(
                                  claimsDrags: () => _view.isZoomed,
                                  debugOwner: this,
                                ),
                                (recognizer) => recognizer
                                  ..onStart = _onScaleStart
                                  ..onUpdate = _onScaleUpdate,
                              ),
                        },
                        child: MouseRegion(
                          cursor: _hovered == null
                              ? MouseCursor.defer
                              : SystemMouseCursors.click,
                          onHover: (event) => setState(() {
                            final hit = _hit(event.localPosition);
                            if (hit != _hoverHidden) _hoverHidden = null;
                            _hovered = hit == _hoverHidden ? null : hit;
                            _pointer = event.localPosition;
                          }),
                          onExit: (_) => setState(() {
                            _hovered = null;
                            _hoverHidden = null;
                            _pointer = null;
                          }),
                          child: ClipRect(key: WorldMapCard.mapKey, child: map),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (focusRing)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              // The replay keeps the map clear of controls.
              if (_replayPlan == null)
                PositionedDirectional(
                  bottom: 0,
                  end: 0,
                  child: _ZoomButtons(
                    view: _targetView,
                    onZoomIn: () => _zoomBy(2),
                    onZoomOut: () => _zoomBy(0.5),
                    onReset: _resetView,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Pinches and drags on the map. While the map is zoomed in, it claims a
/// drag as soon as the finger moves, before the page can take it for
/// scrolling (FR-MAP-17). At 1×, the page scrolls as usual.
class _MapGestureRecognizer extends ScaleGestureRecognizer {
  _MapGestureRecognizer({required this.claimsDrags, super.debugOwner});

  final bool Function() claimsDrags;
  final _downAt = <int, Offset>{};

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    _downAt[event.pointer] = event.position;
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent && claimsDrags()) {
      final start = _downAt[event.pointer];
      if (start != null && (event.position - start).distance > kTouchSlop / 2) {
        _downAt.clear();
        resolve(GestureDisposition.accepted);
      }
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _downAt.remove(event.pointer);
    }
    super.handleEvent(event);
  }
}

/// All, then one chip per region (FR-MAP-21).
class _RegionChips extends ConsumerWidget {
  const _RegionChips({required this.selected});

  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final (i, region) in <String?>[null, ...mapRegions].indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            ChoiceChip(
              label: Text(
                region == null ? l10n.mapRegionAll : regionName(l10n, region),
              ),
              selected: region == selected,
              showCheckmark: false,
              onSelected: (_) =>
                  ref.read(mapRegionProvider.notifier).state = region,
            ),
          ],
        ],
      ),
    );
  }
}

/// For example: Europe · 4 visited · 3 on your wishlist (FR-MAP-24).
class _RegionSummary extends StatelessWidget {
  const _RegionSummary({
    required this.region,
    required this.statuses,
    required this.regions,
  });

  final String region;
  final Map<String, TravelStatus> statuses;
  final Map<String, String> regions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    int count(TravelStatus status) => statuses.entries
        .where((entry) => entry.value == status && regions[entry.key] == region)
        .length;
    return Row(
      children: [
        Icon(Icons.public_rounded, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.mapRegionSummary(
              regionName(l10n, region),
              context.formatInteger(count(TravelStatus.visited)),
              context.formatInteger(count(TravelStatus.wishlist)),
            ),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Grows and shrinks with its child, or changes size at once when motion is
/// reduced (NFR-09): AnimatedSize can't run with a zero duration.
class _Resizing extends StatelessWidget {
  const _Resizing({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MediaQuery.disableAnimationsOf(context)
      ? child
      : AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: AlignmentDirectional.topCenter,
          child: child,
        );
}

/// Replay my travels and Share my map, under the legend (FR-MAP-35,
/// FR-MAP-41).
class _MapActions extends StatelessWidget {
  const _MapActions({
    required this.canReplay,
    required this.canShare,
    required this.onReplay,
    required this.onShare,
  });

  final bool canReplay;
  final bool canShare;
  final VoidCallback onReplay;
  final ValueChanged<BuildContext> onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 4,
      children: [
        if (canReplay)
          TextButton.icon(
            onPressed: onReplay,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(l10n.mapReplay),
          ),
        if (canShare)
          Builder(
            builder: (button) => TextButton.icon(
              onPressed: () => onShare(button),
              icon: const Icon(Icons.ios_share_rounded),
              label: Text(l10n.mapShare),
            ),
          ),
      ],
    );
  }
}

/// Takes the place of the actions while the replay plays: the year of the
/// visit it's on, which slides in when it changes, and Skip (FR-MAP-37,
/// FR-MAP-39). Under the map, neither covers a country.
class _ReplayBar extends StatelessWidget {
  const _ReplayBar({
    required this.plan,
    required this.progress,
    required this.onSkip,
  });

  final ReplayPlan plan;
  final Animation<double> progress;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: AnimatedBuilder(
            animation: progress,
            builder: (context, _) {
              final now = plan.at(progress.value * plan.duration);
              final year =
                  plan.steps[min(now.step, plan.steps.length - 1)].year;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  '$year',
                  key: ValueKey(year),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              );
            },
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: onSkip,
          icon: const Icon(Icons.skip_next_rounded),
          label: Text(l10n.mapReplaySkip),
        ),
      ],
    );
  }
}

/// Zoom in and out, and Reset view while zoomed in (FR-MAP-16, FR-MAP-18).
/// Touch targets stay 48 dp around the smaller buttons.
class _ZoomButtons extends StatelessWidget {
  const _ZoomButtons({
    required this.view,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  final MapView view;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget button(IconData icon, String tooltip, VoidCallback? onPressed) =>
        IconButton.filledTonal(
          onPressed: onPressed,
          tooltip: tooltip,
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          icon: Icon(icon),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (view.isZoomed)
          button(Icons.public_rounded, l10n.mapResetView, onReset),
        button(
          Icons.remove_rounded,
          l10n.mapZoomOut,
          view.isZoomed ? onZoomOut : null,
        ),
        button(
          Icons.add_rounded,
          l10n.mapZoomIn,
          view.scale < MapView.maxScale ? onZoomIn : null,
        ),
      ],
    );
  }
}

/// The hovered country's name beside the pointer, on web (FR-MAP-15).
class _HoverLabel extends ConsumerWidget {
  const _HoverLabel({
    required this.code,
    required this.pointer,
    required this.map,
  });

  final String code;
  final Offset pointer;
  final Size map;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(countryByCodeProvider(code)).valueOrNull;
    if (country == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    // On the side of the pointer with more room. Positions are physical, like
    // the map's.
    final toRight = pointer.dx < map.width / 2;
    return Positioned(
      left: toRight ? pointer.dx + 12 : null,
      right: toRight ? null : map.width - pointer.dx + 12,
      top: max(0, pointer.dy - 32),
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              country.name(arabic: arabic),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onInverseSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Holds the map's place until the map file is ready (PRD section 10.3).
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: MapFrame.width / MapFrame.height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
