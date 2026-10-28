import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/layout/window_size.dart';
import '../../../travels/domain/travel_entry.dart';
import '../../domain/country.dart';
import 'country_card.dart';

/// Columns for the Explore grid (FR-EXP-01, FR-PLT-02): 2 on compact
/// screens, 3 to 4 on medium screens, and 4 to 6 on expanded screens.
int exploreGridColumns(WindowSizeClass size, double contentWidth) =>
    switch (size) {
      WindowSizeClass.compact => 2,
      WindowSizeClass.medium => contentWidth < 720 ? 3 : 4,
      WindowSizeClass.expanded => (contentWidth / 190).floor().clamp(4, 6),
    };

const _padding = 16.0;
const _spacing = 12.0;

class CountryGrid extends StatelessWidget {
  const CountryGrid({
    super.key,
    required this.countries,
    required this.statuses,
    required this.onOpen,
    this.selected,
    this.onToggle,
    this.onLongPress,
    this.playEntrance = false,
  });

  final List<Country> countries;
  final Map<String, TravelStatus> statuses;
  final ValueChanged<Country> onOpen;

  /// The countries picked in quick select, or null outside it (FR-EXP-13).
  /// While selecting, a tap picks or unpicks a card instead of opening it,
  /// and visited countries can't be picked.
  final Set<String>? selected;
  final ValueChanged<Country>? onToggle;

  /// Starts quick select from a card on touch screens.
  final ValueChanged<Country>? onLongPress;

  /// Fade the first visible cards in on the first Explore load (PRD 10.2).
  final bool playEntrance;

  @override
  Widget build(BuildContext context) {
    final size = WindowSizeClass.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = exploreGridColumns(size, constraints.maxWidth);
        return GridView.builder(
          // Pull to refresh needs the grid to scroll even when it is short.
          physics: const AlwaysScrollableScrollPhysics(),
          // The bottom padding includes the floating tab bar.
          padding: EdgeInsets.fromLTRB(
            _padding,
            4,
            _padding,
            _padding + MediaQuery.paddingOf(context).bottom,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: _spacing,
            crossAxisSpacing: _spacing,
            // Round cards fill square tiles.
            childAspectRatio: 1,
          ),
          itemCount: countries.length,
          itemBuilder: (context, index) {
            final country = countries[index];
            return _Entrance(
              key: ValueKey(country.code),
              index: index,
              play: playEntrance && index < columns * 4,
              child: CountryCard(
                country: country,
                status: statuses[country.code],
                selected: selected?.contains(country.code),
                onTap: switch (selected) {
                  null => () => onOpen(country),
                  _ when statuses[country.code] == TravelStatus.visited => null,
                  _ => () => onToggle?.call(country),
                },
                onLongPress: onLongPress == null
                    ? null
                    : () => onLongPress!(country),
              ),
            );
          },
        );
      },
    );
  }
}

/// Cards fade in and rise 16 dp in a 40 ms stagger, 250 ms each. Whether a
/// card animates is fixed when it first appears, so later rebuilds never
/// replay or cut the animation.
class _Entrance extends StatefulWidget {
  const _Entrance({
    super.key,
    required this.index,
    required this.play,
    required this.child,
  });

  final int index;
  final bool play;
  final Widget child;

  @override
  State<_Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<_Entrance> {
  late final bool _play = widget.play;

  @override
  Widget build(BuildContext context) {
    if (!_play || MediaQuery.disableAnimationsOf(context)) return widget.child;
    return widget.child
        .animate(delay: (40 * widget.index).ms)
        .fadeIn(duration: 250.ms, curve: Curves.easeOut)
        .moveY(begin: 16, end: 0, duration: 250.ms, curve: Curves.easeOut);
  }
}
