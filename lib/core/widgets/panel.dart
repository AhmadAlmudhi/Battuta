import 'package:flutter/material.dart';

/// A flat, tinted panel with a hairline edge and 16 dp corners, which holds
/// grouped content on Country details, My travels, and Stats (PRD 10.1).
/// It is a [Material], so ink from rows inside it shows, and it clips them
/// to its corners.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: child,
    );
  }
}

/// An icon in a tinted circle, at the head of a fact or a highlight.
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: scheme.onPrimaryContainer),
    );
  }
}
