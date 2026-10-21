import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/format/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../countries/presentation/country_providers.dart';
import '../../../travels/presentation/travel_providers.dart';
import '../../domain/map_hit_tester.dart';
import '../../domain/map_projection.dart';
import '../world_map_colors.dart';
import '../world_map_geometry.dart';
import '../world_map_painter.dart';
import '../world_map_providers.dart';
import 'map_country_card.dart';
import 'map_legend.dart';

/// The world map at the top of Stats (PRD section 6.10): every country
/// colored by status, a card for the selected country, and the legend.
class WorldMapCard extends ConsumerStatefulWidget {
  const WorldMapCard({
    super.key,
    this.header,
    required this.visited,
    required this.wishlist,
  });

  /// The area that draws the map and takes taps, for tests.
  static const mapKey = ValueKey('world-map');

  /// The Stats headline (FR-MAP-02); null in the zero state (FR-STA-05).
  final Widget? header;

  /// Counts for the screen-reader summary (FR-MAP-08).
  final int visited;
  final int wishlist;

  @override
  ConsumerState<WorldMapCard> createState() => _WorldMapCardState();
}

class _WorldMapCardState extends ConsumerState<WorldMapCard> {
  final _focus = FocusNode(debugLabel: 'World map');
  String? _selected;
  String? _hovered;
  Offset? _pointer;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  /// Esc closes the card (FR-MAP-14), also while one of its buttons has
  /// focus.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (_selected == null ||
        event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape) {
      return KeyEventResult.ignored;
    }
    setState(() => _selected = null);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final geometry = ref.watch(worldMapGeometryProvider).valueOrNull;
    final hitTester = ref.watch(mapHitTesterProvider);
    final selected = _selected;

    // Focus only carries Esc; it isn't a control for screen readers.
    return Focus(
      focusNode: _focus,
      onKeyEvent: _onKey,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: geometry == null || hitTester == null
                    ? const _MapPlaceholder()
                    : _map(context, geometry, hitTester),
              ),
              AnimatedSize(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: AlignmentDirectional.topCenter,
                child: selected == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: MapCountryCard(
                          key: ValueKey(selected),
                          code: selected,
                          onClose: () => setState(() => _selected = null),
                        ),
                      ),
              ),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 12, 20, 0),
                child: MapLegend(),
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
    MapHitTester hitTester,
  ) {
    final l10n = AppLocalizations.of(context);
    final colors = WorldMapColors.of(context);
    final statuses = ref.watch(travelStatusesProvider).valueOrNull ?? const {};

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth,
          constraints.maxWidth * geometry.size.height / geometry.size.width,
        );
        final unitsPerDp = geometry.size.width / size.width;
        // The map never mirrors, so positions are physical in both
        // languages (PRD section 10.4).
        String? hit(Offset position) => hitTester.hitTest(
          (x: position.dx * unitsPerDp, y: position.dy * unitsPerDp),
          dotRadius: MapSizes.dotRadius * unitsPerDp,
          reach: 24 * unitsPerDp,
        );

        return Semantics(
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
            child: MouseRegion(
              cursor: _hovered == null
                  ? MouseCursor.defer
                  : SystemMouseCursors.click,
              onHover: (event) => setState(() {
                _hovered = hit(event.localPosition);
                _pointer = event.localPosition;
              }),
              onExit: (_) => setState(() {
                _hovered = null;
                _pointer = null;
              }),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Tapping the ocean or a shape outside the dataset closes the
                // card (FR-MAP-14).
                onTapUp: (details) {
                  _focus.requestFocus();
                  setState(() => _selected = hit(details.localPosition));
                },
                child: SizedBox.fromSize(
                  key: WorldMapCard.mapKey,
                  size: size,
                  child: Stack(
                    children: [
                      RepaintBoundary(
                        child: CustomPaint(
                          size: size,
                          painter: WorldMapBasePainter(
                            geometry: geometry,
                            colors: colors,
                          ),
                        ),
                      ),
                      CustomPaint(
                        size: size,
                        painter: WorldMapPainter(
                          geometry: geometry,
                          statuses: statuses,
                          colors: colors,
                          selected: _selected,
                          hovered: _hovered,
                        ),
                      ),
                      if ((_hovered, _pointer) case (
                        final code?,
                        final pointer?,
                      ))
                        _HoverLabel(code: code, pointer: pointer, map: size),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
