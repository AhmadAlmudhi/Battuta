import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/country.dart';

/// A country's bundled flag, decoded at its display size (NFR-03). Flags
/// never mirror in right-to-left layouts.
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

  /// The width of the bundled images; decoding larger only wastes memory.
  static const _assetWidth = 320;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final pixels =
          constraints.maxWidth * MediaQuery.devicePixelRatioOf(context);
      final arabic = Localizations.localeOf(context).languageCode == 'ar';
      return Image.asset(
        country.flagAsset,
        fit: fit,
        cacheWidth: pixels.isFinite
            ? math.min(pixels.ceil(), _assetWidth)
            : null,
        excludeFromSemantics: excludeFromSemantics,
        semanticLabel:
            country.flagAlt ??
            AppLocalizations.of(
              context,
            ).flagLabel(country.name(arabic: arabic)),
        errorBuilder: (context, _, _) => _FlagPlaceholder(country.alpha2),
      );
    },
  );
}

class _FlagPlaceholder extends StatelessWidget {
  const _FlagPlaceholder(this.alpha2);

  final String alpha2;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
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
  }
}
