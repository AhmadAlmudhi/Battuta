import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_shell.dart';
import '../../../core/widgets/message_view.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../l10n/app_localizations.dart';
import 'country_providers.dart';

/// Explore tab. For now a plain list that proves the data and routes work;
/// the grid, search, filters, and sort come with the Explore feature.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final countries = ref.watch(countriesProvider);

    return ScreenTitle(
      screen: l10n.navExplore,
      child: TabScaffold(
        title: l10n.navExplore,
        body: countries.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => MessageView(
            icon: Icons.error_outline_rounded,
            title: l10n.exploreLoadError,
            message: '',
          ),
          data: (countries) => ListView.builder(
            itemCount: countries.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: Text(l10n.exploreCountryCount(countries.length)),
                );
              }
              final country = countries[index - 1];
              return ListTile(
                title: Text(country.name(arabic: arabic)),
                subtitle: Text(country.region),
                onTap: () => context.push('/country/${country.code}'),
              );
            },
          ),
        ),
      ),
    );
  }
}
