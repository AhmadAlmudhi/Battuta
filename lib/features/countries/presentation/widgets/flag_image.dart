import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/country.dart';

/// A country's bundled flag. Flags never mirror in right-to-left layouts.
///
/// Every flag decodes once at its bundled size, 320 px wide, so each place
/// it appears shares one decoded image. A flag in flight between screens
/// changes size every frame; decoding at the display size would decode it
/// again each frame and leave the flight empty.
///
/// Shows the 2-letter code when the image is missing, for example for a
/// country added by a data refresh after the build.
class FlagImage extends StatelessWidget {
  const FlagImage({
    super.key,
    required this.country,
    this.fit = BoxFit.contain,
    this.excludeFromSemantics = false,
  });

  final Country country;
  final BoxFit fit;

  /// True where the country name is already read out, as on a card.
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return Image.asset(
      country.flagAsset,
      fit: fit,
      excludeFromSemantics: excludeFromSemantics,
      semanticLabel:
          country.flagAlt ??
          AppLocalizations.of(context).flagLabel(country.name(arabic: arabic)),
      errorBuilder: (context, _, _) => _FlagPlaceholder(country.alpha2),
    );
  }
}

/// A flag drawn like a printed card (PRD section 10.1): in its own shape,
/// as large as the space allows, with rounded corners, a hairline edge so
/// white flags stand out, and a soft shadow.
class FramedFlag extends StatelessWidget {
  const FramedFlag({
    super.key,
    required this.country,
    this.radius = 6,
    this.excludeFromSemantics = false,
  });

  final Country country;
  final double radius;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    // Laid out at the full width and its own height, then scaled down to
    // fit, so the frame hugs the flag whatever its shape.
    builder: (context, constraints) => Center(
      child: FittedBox(
        child: SizedBox(
          width: constraints.maxWidth,
          child: _Frame(
            corners: BorderRadius.circular(radius),
            child: FlagImage(
              country: country,
              excludeFromSemantics: excludeFromSemantics,
            ),
          ),
        ),
      ),
    ),
  );
}

/// A flag flying between an Explore card's circle, at 0, and its framed
/// shape on Country details, at 1 (PRD section 10.2). The circle opens into
/// the flag's own shape as it flies, and the frame fades in; on the way
/// back the same happens in reverse.
class FlagFlight extends StatefulWidget {
  const FlagFlight({
    super.key,
    required this.country,
    required this.progress,
    this.radius = 10,
  });

  final Country country;

  /// The flight's eased progress, which also moves and sizes this widget.
  final Animation<double> progress;

  /// The corner radius of the FramedFlag it becomes.
  final double radius;

  @override
  State<FlagFlight> createState() => _FlagFlightState();
}

class _FlagFlightState extends State<FlagFlight> {
  /// The flag's width over its height, once its image is known.
  double? _aspect;
  ImageStream? _stream;
  bool _resolving = false;

  late final _listener = ImageStreamListener((info, _) {
    _aspect = info.image.width / info.image.height;
    info.dispose();
    if (mounted && !_resolving) setState(() {});
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The card already decoded this image, so the size arrives at once.
    final stream = AssetImage(
      widget.country.flagAsset,
    ).resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _resolving = true;
    _stream = stream..addListener(_listener);
    _resolving = false;
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.progress,
    builder: (context, _) => LayoutBuilder(
      builder: (context, box) {
        final t = widget.progress.value.clamp(0.0, 1.0);
        final aspect = _aspect ?? 3 / 2;
        final circle = math.min(box.maxWidth, box.maxHeight);
        // Where the flag ends: its own shape, fitted to the space, with the
        // corners FramedFlag gets after scaling it down.
        final width = math.min(box.maxWidth, box.maxHeight * aspect);
        final radius = widget.radius * math.min(1.0, width / box.maxWidth);
        return Center(
          child: SizedBox.fromSize(
            size: Size.lerp(
              Size.square(circle),
              Size(width, width / aspect),
              t,
            ),
            child: _Frame(
              corners: BorderRadius.circular(
                lerpDouble(circle / 2, radius, t)!,
              ),
              strength: t,
              child: FlagImage(
                country: widget.country,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// The printed-card look: rounded corners, a soft shadow, and a hairline
/// edge so white flags stand out. [strength] fades the shadow and edge.
class _Frame extends StatelessWidget {
  const _Frame({required this.corners, required this.child, this.strength = 1});

  final BorderRadius corners;
  final double strength;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: corners,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.16 * strength),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: corners,
          border: Border.all(
            color: scheme.onSurface.withValues(alpha: 0.12 * strength),
            width: 0.5,
          ),
        ),
        child: ClipRRect(borderRadius: corners, child: child),
      ),
    );
  }
}

class _FlagPlaceholder extends StatelessWidget {
  const _FlagPlaceholder(this.alpha2);

  final String alpha2;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final box = ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Text(
          alpha2.toUpperCase(),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
    // In a FramedFlag the height is open, so take a typical flag's shape.
    return LayoutBuilder(
      builder: (context, constraints) => constraints.hasBoundedHeight
          ? box
          : AspectRatio(aspectRatio: 3 / 2, child: box),
    );
  }
}
