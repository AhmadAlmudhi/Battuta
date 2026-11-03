import 'package:flutter/widgets.dart';

/// Marks a subtree that is drawn hidden only so the browser compiles the
/// shaders it uses before they are needed (see `WebShaderWarmUp`). Screens
/// inside it leave the browser tab title alone.
class WarmUpScope extends InheritedWidget {
  const WarmUpScope({super.key, required super.child});

  /// Whether [context] is inside a warm-up.
  static bool isWarmingUp(BuildContext context) =>
      context.getInheritedWidgetOfExactType<WarmUpScope>() != null;

  @override
  bool updateShouldNotify(WarmUpScope oldWidget) => false;
}
