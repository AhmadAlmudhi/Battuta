import 'package:flutter/widgets.dart';

/// Material 3 window size classes that decide the layout (FR-PLT-02).
enum WindowSizeClass {
  /// Under 600 dp: bottom navigation bar, 2-column grid, bottom sheets.
  compact,

  /// 600 to 839 dp: bottom navigation bar, 3 to 4 columns, dialogs.
  medium,

  /// 840 dp and wider: navigation rail, up to 6 columns, dialogs.
  expanded;

  static WindowSizeClass fromWidth(double width) => switch (width) {
    < 600 => compact,
    < 840 => medium,
    _ => expanded,
  };

  static WindowSizeClass of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);
}

/// Content is centered with a maximum width of 1,200 dp (FR-PLT-02).
const maxContentWidth = 1200.0;

class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxContentWidth),
      child: child,
    ),
  );
}
