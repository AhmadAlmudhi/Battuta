import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App bar leading button for screens that can be opened directly by URL.
///
/// When there is a screen to return to, the app bar shows its usual Back
/// button. When the screen was opened by URL with nothing underneath, this
/// goes up to [fallback] instead, so the user is never stuck.
Widget? upButton(BuildContext context, {required String fallback}) {
  if (Navigator.of(context).canPop()) return null;
  return IconButton(
    icon: const BackButtonIcon(),
    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    onPressed: () => context.go(fallback),
  );
}
