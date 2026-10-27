import 'package:flutter/material.dart';

import '../layout/window_size.dart';

/// Opens [builder] as a bottom sheet on compact screens and as a dialog on
/// wider ones (FR-PLT-02). Esc closes either (FR-PLT-05).
Future<T?> showAdaptiveModal<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  if (WindowSizeClass.of(context) == WindowSizeClass.compact) {
    return showModalBottomSheet<T>(
      context: context,
      // Above the floating tab bar, which would otherwise cover the sheet's
      // bottom, where Save is.
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        // Keeps the form above the on-screen keyboard.
        padding: EdgeInsetsDirectional.fromSTEB(
          24,
          0,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: builder(context),
      ),
    );
  }
  return showDialog<T>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: builder(context),
        ),
      ),
    ),
  );
}
