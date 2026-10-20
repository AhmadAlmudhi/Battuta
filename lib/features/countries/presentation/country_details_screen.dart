import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/window_size.dart';
import '../../../core/widgets/message_view.dart';
import '../../../core/widgets/placeholder_body.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../core/widgets/up_button.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/country.dart';
import 'country_providers.dart';
import 'widgets/country_card.dart';
import 'widgets/flag_image.dart';

/// Country details, opened at /country/:code. For now it shows the header;
/// facts and actions come with the details feature.
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
            body: ContentWidth(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Header(country: country),
                  const SizedBox(height: 24),
                  const PlaceholderBody(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Large flag, animated in from the Explore card, with the common and
/// official names (FR-DET-01).
class _Header extends StatelessWidget {
  const _Header({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320, maxHeight: 214),
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: Hero(
              tag: flagHeroTag(country.code),
              child: FlagImage(country: country),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          country.name(arabic: arabic),
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          country.officialName(arabic: arabic),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
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
