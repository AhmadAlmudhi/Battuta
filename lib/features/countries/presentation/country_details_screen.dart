import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/network/connectivity.dart';
import '../../../core/platform/link_launcher.dart';
import '../../../core/theme/contrast.dart';
import '../../../core/widgets/message_view.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../core/widgets/up_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../travels/presentation/widgets/travel_action_area.dart';
import '../../travels/presentation/widgets/visit_stamp.dart';
import '../domain/country.dart';
import 'country_providers.dart';
import 'region_names.dart';
import 'widgets/country_card.dart';
import 'widgets/flag_image.dart';

/// Country details at /country/:code (PRD section 6.3).
class CountryDetailsScreen extends ConsumerWidget {
  const CountryDetailsScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final country = ref.watch(countryByCodeProvider(code));

    return country.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const CountryNotFoundScreen(),
      data: (country) {
        if (country == null) return const CountryNotFoundScreen();
        final name = country.name(arabic: arabic);
        return ScreenTitle(
          screen: name,
          child: Scaffold(
            appBar: AppBar(
              leading: upButton(context, fallback: '/explore'),
              title: Text(name),
            ),
            body: Align(
              alignment: AlignmentDirectional.topCenter,
              child: ConstrainedBox(
                // A readable column, also on wide screens.
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _Header(country: country),
                    const SizedBox(height: 16),
                    TravelActionArea(country: country),
                    const SizedBox(height: 24),
                    _Facts(country: country),
                    const SizedBox(height: 24),
                    _Neighbors(country: country),
                    const SizedBox(height: 16),
                    _OpenInMaps(country: country),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Large flag, animated in from the Explore card or a neighbor chip, with
/// the common and official names (FR-DET-01) and the visit stamp.
class _Header extends StatelessWidget {
  const _Header({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    // Tinted with the flag's dominant color, but only as far as text keeps
    // WCAG AA contrast (FR-DET-07).
    final flagColor = parseHexColor(country.flagColor);
    final background = flagColor == null
        ? scheme.surfaceContainerLow
        : tintWithinContrast(
            surface: scheme.surfaceContainerLow,
            tint: flagColor,
            foregrounds: [scheme.onSurface, scheme.onSurfaceVariant],
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320, maxHeight: 214),
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: flagHeroTag(country.code),
                        child: FlagImage(country: country),
                      ),
                    ),
                    PositionedDirectional(
                      end: -20,
                      bottom: -20,
                      child: VisitStamp(countryCode: country.code),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              country.name(arabic: arabic),
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              country.officialName(arabic: arabic),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Key facts in the app language; a missing value reads Not available
/// (FR-DET-02).
class _Facts extends StatelessWidget {
  const _Facts({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String list(List<String> items) => items.isEmpty
        ? l10n.commonNotAvailable
        : items.join(l10n.listSeparator);

    final facts = <(String, String, bool)>[
      (l10n.detailsCapital, country.capital ?? l10n.commonNotAvailable, false),
      (l10n.detailsRegion, regionName(l10n, country.region), false),
      (
        l10n.detailsSubregion,
        country.subregion == null
            ? l10n.commonNotAvailable
            : subregionName(l10n, country.subregion!),
        false,
      ),
      (
        l10n.detailsPopulation,
        context.formatInteger(country.population),
        false,
      ),
      (
        l10n.detailsArea,
        country.areaKm2 == null
            ? l10n.commonNotAvailable
            : l10n.detailsAreaValue(context.formatDecimal(country.areaKm2!)),
        false,
      ),
      (l10n.detailsLanguages, list(country.languages), false),
      (
        l10n.detailsCurrencies,
        list([
          for (final currency in country.currencies)
            currency.symbol == null
                ? currency.name
                : '${currency.name} (${currency.symbol})',
        ]),
        false,
      ),
      // UTC offsets read left to right in both languages.
      (l10n.detailsTimezones, list(country.timezones), true),
    ];

    final theme = Theme.of(context);
    return _Section(
      title: l10n.detailsFacts,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              for (final (label, value, ltr) in facts)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ltr
                            ? Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  value,
                                  style: theme.textTheme.bodyLarge,
                                  textDirection: TextDirection.ltr,
                                ),
                              )
                            : Text(value, style: theme.textTheme.bodyLarge),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Neighboring countries as chips; each opens that country (FR-DET-03).
class _Neighbors extends ConsumerWidget {
  const _Neighbors({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final all = ref.watch(countriesProvider).valueOrNull ?? const [];
    final byCode = {for (final c in all) c.code: c};
    final neighbors = [
      for (final code in country.borders) ?byCode[code],
    ]..sort((a, b) => a.name(arabic: arabic).compareTo(b.name(arabic: arabic)));

    return _Section(
      title: l10n.detailsNeighbors,
      child: neighbors.isEmpty
          ? Text(
              l10n.detailsNoLandBorders,
              style: Theme.of(context).textTheme.bodyLarge,
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final neighbor in neighbors)
                  ActionChip(
                    avatar: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Hero(
                        tag: flagHeroTag(neighbor.code),
                        child: FlagImage(
                          country: neighbor,
                          fit: BoxFit.cover,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                    avatarBoxConstraints: const BoxConstraints.tightFor(
                      width: 24,
                      height: 16,
                    ),
                    label: Text(neighbor.name(arabic: arabic)),
                    onPressed: () => context.push('/country/${neighbor.code}'),
                  ),
              ],
            ),
    );
  }
}

/// Opens the map in a new tab on web or the maps app on mobile; disabled
/// while offline (FR-DET-05).
class _OpenInMaps extends ConsumerWidget {
  const _OpenInMaps({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = country.mapsUrl;
    if (url == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final online = ref.watch(isOnlineProvider).valueOrNull ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: online
              ? () => ref.read(linkLauncherProvider)(Uri.parse(url))
              : null,
          icon: const Icon(Icons.map_outlined),
          label: Text(l10n.detailsOpenInMaps),
        ),
        if (!online)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.detailsOpenInMapsOffline,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      child,
    ],
  );
}

/// Shown for an unknown country code (FR-DET-06, AC-DET-04).
class CountryNotFoundScreen extends StatelessWidget {
  const CountryNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScreenTitle(
      screen: l10n.countryNotFoundTitle,
      child: Scaffold(
        appBar: AppBar(leading: upButton(context, fallback: '/explore')),
        body: MessageView(
          icon: Icons.public_off_rounded,
          title: l10n.countryNotFoundTitle,
          message: l10n.countryNotFoundBody,
          actionLabel: l10n.countryNotFoundBack,
          onAction: () => context.go('/explore'),
        ),
      ),
    );
  }
}
