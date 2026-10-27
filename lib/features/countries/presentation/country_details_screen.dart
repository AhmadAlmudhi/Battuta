import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/layout/window_size.dart';
import '../../../core/network/connectivity.dart';
import '../../../core/platform/link_launcher.dart';
import '../../../core/theme/contrast.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/message_view.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../core/widgets/panel.dart';
import '../../../core/widgets/up_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../travels/presentation/widgets/travel_action_area.dart';
import '../../travels/presentation/widgets/visit_stamp.dart';
import '../domain/country.dart';
import '../domain/time_zones.dart';
import 'country_providers.dart';
import 'region_names.dart';
import 'widgets/country_card.dart';
import 'widgets/flag_image.dart';

/// Country details at /country/:code (PRD section 6.3): a header tinted
/// with the flag's color, the save actions, key facts, and neighbors. On
/// expanded screens the header and actions get a column of their own beside
/// the facts.
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
        final scheme = Theme.of(context).colorScheme;
        return ScreenTitle(
          screen: name,
          child: Scaffold(
            // The header's tint runs up behind the app bar, which turns
            // solid once the page scrolls under it.
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              leading: upButton(context, fallback: '/explore'),
              title: AppTitle(screen: name),
              backgroundColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.scrolledUnder)
                    ? scheme.surfaceContainer
                    : Colors.transparent,
              ),
              surfaceTintColor: Colors.transparent,
            ),
            body: WindowSizeClass.of(context) == WindowSizeClass.expanded
                ? _WideLayout(country: country)
                : _NarrowLayout(country: country),
          ),
        );
      },
    );
  }
}

/// One column: the header across the full width, then the rest in a
/// readable column.
class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    Widget column(Widget child, {double inset = 16}) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: inset),
          child: child,
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _Header(country: country, top: MediaQuery.paddingOf(context).top),
        column(TravelActionArea(country: country)),
        const SizedBox(height: 32),
        column(_Facts(country: country)),
        const SizedBox(height: 32),
        // The neighbors scroll sideways to the screen's edges.
        column(_Neighbors(country: country), inset: 0),
      ],
    );
  }
}

/// Two columns: the header and actions on the start side, which stay put,
/// and the facts and neighbors beside them (FR-PLT-02).
class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 8;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1160),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 420,
              child: ListView(
                // The facts column owns the primary scroll controller.
                primary: false,
                padding: EdgeInsetsDirectional.fromSTEB(24, top, 12, 24),
                children: [
                  _Header(country: country, panel: true),
                  const SizedBox(height: 16),
                  TravelActionArea(country: country),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsetsDirectional.fromSTEB(12, top, 24, 32),
                children: [
                  _Facts(country: country),
                  const SizedBox(height: 32),
                  _Neighbors(country: country, inset: 0, wrap: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The large flag, animated in from an Explore card or a neighbor, with the
/// visit stamp, the names, the region, and Open in Maps (FR-DET-01,
/// FR-DET-05). Its background is tinted with the flag's dominant color and
/// fades into the page (FR-DET-07); in a [panel] it fades into a card.
class _Header extends ConsumerWidget {
  const _Header({required this.country, this.top = 0, this.panel = false});

  final Country country;

  /// Room for the app bar it extends behind.
  final double top;
  final bool panel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final end = panel ? scheme.surfaceContainerLow : scheme.surface;
    // Only as much tint as keeps the text, and the app bar's title, at
    // WCAG AA.
    final flagColor = parseHexColor(country.flagColor);
    final tint = flagColor == null
        ? scheme.surfaceContainerHigh
        : tintWithinContrast(
            surface: end,
            tint: flagColor,
            foregrounds: [
              scheme.onSurface,
              scheme.onSurfaceVariant,
              scheme.primary,
            ],
          );
    final name = country.name(arabic: arabic);
    final officialName = country.officialName(arabic: arabic);
    final mapsUrl = country.mapsUrl;
    final online = ref.watch(isOnlineProvider).valueOrNull ?? true;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: panel ? BorderRadius.circular(24) : null,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tint, tint, end],
          stops: const [0, 0.55, 1],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, top + 16, 24, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 320,
                    maxHeight: 214,
                  ),
                  child: AspectRatio(
                    aspectRatio: 3 / 2,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Hero(
                            tag: flagHeroTag(country.code),
                            child: FramedFlag(country: country, radius: 10),
                          ),
                        ),
                        PositionedDirectional(
                          end: -20,
                          bottom: -20,
                          child: VisitStamp(
                            countryCode: country.code,
                            landOnArrival: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                // Japan's official name is Japan.
                if (officialName.toLowerCase() != name.toLowerCase()) ...[
                  const SizedBox(height: 4),
                  Text(
                    officialName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RegionPill(country: country),
                    if (mapsUrl != null)
                      FilledButton.tonalIcon(
                        onPressed: online
                            ? () => ref.read(linkLauncherProvider)(
                                Uri.parse(mapsUrl),
                              )
                            : null,
                        icon: const Icon(Icons.map_outlined),
                        label: Text(l10n.detailsOpenInMaps),
                      ),
                  ],
                ),
                if (mapsUrl != null && !online)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.detailsOpenInMapsOffline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The region and subregion as a tag, for example Asia · Western Asia
/// (FR-DET-02). A missing subregion is left out.
class _RegionPill extends StatelessWidget {
  const _RegionPill({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final subregion = country.subregion;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: scheme.surface.withValues(alpha: 0.7),
        shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 16, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.public_rounded,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                [
                  regionName(l10n, country.region),
                  if (subregion != null) subregionName(l10n, subregion),
                ].join(' · '),
                style: theme.textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Key facts in the app language (FR-DET-02): the capital, population, and
/// area as tiles to read at a glance, then languages, currencies, and time
/// zones in full. A missing value reads Not available.
class _Facts extends StatelessWidget {
  const _Facts({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String list(List<String> items) => items.isEmpty
        ? l10n.commonNotAvailable
        : items.join(l10n.listSeparator);
    final area = country.areaKm2;
    // A long list of time zones shows as its range.
    final zones = byUtcOffset(country.timezones);
    final zonesValue = zones.length > 2
        ? '${zones.first} – ${zones.last}'
        : list(zones);

    return _Section(
      title: l10n.detailsFacts,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _FactTile(
                    icon: Icons.location_city_rounded,
                    label: l10n.detailsCapital,
                    value: country.capital ?? l10n.commonNotAvailable,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FactTile(
                    icon: Icons.groups_rounded,
                    label: l10n.detailsPopulation,
                    value: context.formatCompact(country.population),
                    exact: context.formatInteger(country.population),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FactTile(
                    icon: Icons.straighten_rounded,
                    label: l10n.detailsArea,
                    value: area == null
                        ? l10n.commonNotAvailable
                        : l10n.detailsAreaValue(context.formatCompact(area)),
                    exact: area == null
                        ? null
                        : l10n.detailsAreaValue(context.formatDecimal(area)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _FactList(
            rows: [
              (
                Icons.translate_rounded,
                l10n.detailsLanguages,
                list(country.languages),
                null,
                false,
              ),
              (
                Icons.payments_outlined,
                l10n.detailsCurrencies,
                list([
                  for (final currency in country.currencies)
                    currency.symbol == null
                        ? currency.name
                        : '${currency.name} (${currency.symbol})',
                ]),
                null,
                false,
              ),
              // UTC offsets read left to right in both languages.
              (
                Icons.schedule_rounded,
                l10n.detailsTimezones,
                zonesValue,
                zones.length > 2
                    ? l10n.detailsTimezoneCount(zones.length)
                    : null,
                true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A fact to read at a glance, such as 35.3M, with its [exact] value under
/// it when that differs.
class _FactTile extends StatelessWidget {
  const _FactTile({
    required this.icon,
    required this.label,
    required this.value,
    this.exact,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? exact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return MergeSemantics(
      child: Panel(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBadge(icon: icon),
              const SizedBox(height: 10),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (exact case final exact? when exact != value)
                Text(
                  exact,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Facts with longer values, one per row: icon, label, value, and a
/// detail. Values marked left to right keep that order in Arabic too.
class _FactList extends StatelessWidget {
  const _FactList({required this.rows});

  final List<(IconData, String, String, String?, bool)> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Panel(
      child: Column(
        children: [
          for (final (i, (icon, label, value, detail, ltr))
              in rows.indexed) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 56,
                color: scheme.outlineVariant.withValues(alpha: 0.6),
              ),
            MergeSemantics(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconBadge(icon: icon),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            value,
                            style: theme.textTheme.bodyLarge,
                            textDirection: ltr ? TextDirection.ltr : null,
                          ),
                          if (detail != null)
                            Text(
                              detail,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Neighboring countries as round flags, like the Explore cards; each opens
/// that country (FR-DET-03). They scroll sideways in one row, or [wrap]
/// onto more rows where there's room.
class _Neighbors extends ConsumerWidget {
  const _Neighbors({required this.country, this.inset = 16, this.wrap = false});

  final Country country;

  /// The page's side padding, which the sideways row scrolls into.
  final double inset;
  final bool wrap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final all = ref.watch(countriesProvider).valueOrNull ?? const [];
    final byCode = {for (final c in all) c.code: c};
    final neighbors = [
      for (final code in country.borders) ?byCode[code],
    ]..sort((a, b) => a.name(arabic: arabic).compareTo(b.name(arabic: arabic)));
    final padding = EdgeInsets.symmetric(horizontal: inset);

    return _Section(
      title: l10n.detailsNeighbors,
      titlePadding: padding,
      child: switch (neighbors) {
        [] => Padding(
          padding: padding,
          child: Row(
            children: [
              Icon(
                Icons.water_rounded,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.detailsNoLandBorders,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        _ when wrap => Padding(
          padding: padding,
          child: Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              for (final neighbor in neighbors) _Neighbor(country: neighbor),
            ],
          ),
        ),
        _ => SizedBox(
          height: _Neighbor.height(context),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: padding,
            itemCount: neighbors.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _Neighbor(country: neighbors[i]),
          ),
        ),
      },
    );
  }
}

/// A neighbor's round flag and name. Its flag opens into the header of the
/// country it opens, as from an Explore card.
class _Neighbor extends StatelessWidget {
  const _Neighbor({required this.country});

  final Country country;

  static const _flag = 64.0;

  /// Room for the flag and two lines of name, scaled with the text size.
  static double height(BuildContext context) =>
      _flag + 22 + MediaQuery.textScalerOf(context).scale(32);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return SizedBox(
      // Narrow enough that on a phone the next flag peeks in at the edge,
      // which shows the row scrolls.
      width: 80,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/country/${country.code}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              SizedBox.square(
                dimension: _flag,
                child: Material(
                  color: scheme.surfaceContainerHighest,
                  clipBehavior: Clip.antiAlias,
                  shape: CircleBorder(
                    side: BorderSide(color: scheme.outlineVariant),
                  ),
                  child: Hero(
                    tag: flagHeroTag(country.code),
                    flightShuttleBuilder: (_, animation, _, _, _) =>
                        FlagFlight(country: country, progress: animation),
                    child: FlagImage(
                      country: country,
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                country.name(arabic: arabic),
                style: theme.textTheme.labelMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.titlePadding = EdgeInsets.zero,
  });

  final String title;
  final Widget child;
  final EdgeInsets titlePadding;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: titlePadding,
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
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
        appBar: AppBar(
          leading: upButton(context, fallback: '/explore'),
          title: AppTitle(screen: l10n.countryNotFoundTitle),
        ),
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
