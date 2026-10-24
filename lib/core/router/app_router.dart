import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/account_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/countries/presentation/country_details_screen.dart';
import '../../features/countries/presentation/explore_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/settings/presentation/settings_controller.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/travels/presentation/travels_screen.dart';
import '../../l10n/app_localizations.dart';
import '../layout/app_shell.dart';
import '../widgets/app_title.dart';
import '../widgets/message_view.dart';
import '../widgets/screen_title.dart';
import '../widgets/up_button.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Routes from PRD section 5.2. Every route is a real URL on web (FR-PLT-03).
///
/// Detail screens open with `context.push` so the in-app Back button returns
/// to the previous screen. URL reflection for imperative navigation is on, so
/// pushed screens still show their own URL; every route is deep-linkable.
final routerProvider = Provider<GoRouter>((ref) {
  GoRouter.optionURLReflectsImperativeAPIs = true;

  final onboardingDone = ValueNotifier(
    ref.read(settingsProvider).onboardingDone,
  );
  ref.listen(
    settingsProvider.select((settings) => settings.onboardingDone),
    (_, done) => onboardingDone.value = done,
  );
  ref.onDispose(onboardingDone.dispose);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/explore',
    refreshListenable: onboardingDone,
    redirect: (context, state) =>
        redirectFor(state.uri, onboardingDone: onboardingDone.value),
    errorBuilder: (context, state) => const _PageNotFoundScreen(),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/explore'),
      GoRoute(
        path: '/welcome',
        builder: (context, state) =>
            WelcomeScreen(from: state.uri.queryParameters['from']),
      ),
      StatefulShellRoute(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        navigatorContainerBuilder: (context, navigationShell, children) =>
            BranchStack(
              currentIndex: navigationShell.currentIndex,
              children: children,
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/travels',
                builder: (context, state) => TravelsScreen(
                  tab: TravelsTab.fromQuery(state.uri.queryParameters['tab']),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/country/:code',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            CountryDetailsScreen(code: state.pathParameters['code']!),
      ),
      GoRoute(
        path: '/account',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AccountScreen(),
        routes: [
          GoRoute(
            path: 'sign-in',
            builder: (context, state) => const SignInScreen(),
          ),
          GoRoute(
            path: 'sign-up',
            builder: (context, state) => const SignUpScreen(),
          ),
          GoRoute(
            path: 'reset',
            builder: (context, state) => const ResetPasswordScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Until the user makes a first choice, every screen except Welcome and
/// sign-in leads to Welcome, which then returns to the page they opened
/// (FR-ONB-01). Afterwards Welcome is never shown again (FR-ONB-02).
@visibleForTesting
String? redirectFor(Uri uri, {required bool onboardingDone}) {
  final path = uri.path;
  final isWelcome = path == '/welcome';
  final isAccount = path == '/account' || path.startsWith('/account/');

  if (onboardingDone) return isWelcome ? '/explore' : null;
  if (isWelcome || isAccount) return null;

  final from = uri.toString();
  final keepTarget = path != '/' && path != '/explore';
  return Uri(
    path: '/welcome',
    queryParameters: keepTarget ? {'from': from} : null,
  ).toString();
}

class _PageNotFoundScreen extends StatelessWidget {
  const _PageNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScreenTitle(
      screen: l10n.pageNotFoundTitle,
      child: Scaffold(
        appBar: AppBar(
          leading: upButton(context, fallback: '/explore'),
          title: AppTitle(screen: l10n.pageNotFoundTitle),
        ),
        body: MessageView(
          icon: Icons.explore_off_rounded,
          title: l10n.pageNotFoundTitle,
          message: l10n.pageNotFoundBody,
          actionLabel: l10n.countryNotFoundBack,
          onAction: () => context.go('/explore'),
        ),
      ),
    );
  }
}
