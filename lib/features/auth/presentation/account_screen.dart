import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/window_size.dart';
import '../../../core/widgets/placeholder_body.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../core/widgets/up_button.dart';
import '../../../l10n/app_localizations.dart';

/// Account screen. Shows the guest view until accounts are built (FR-AUTH-04).
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ScreenTitle(
      screen: l10n.accountTitle,
      child: Scaffold(
        appBar: AppBar(
          leading: upButton(context, fallback: '/explore'),
          title: Text(l10n.accountTitle),
        ),
        body: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.accountGuestTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.accountGuestBody),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.push('/account/sign-in'),
                        child: Text(l10n.accountSignIn),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(l10n.accountSettings),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sign in, create account, and reset password. Built in the accounts feature.
class AuthPlaceholderScreen extends StatelessWidget {
  const AuthPlaceholderScreen({super.key, required this.title});

  final String Function(AppLocalizations l10n) title;

  @override
  Widget build(BuildContext context) {
    final text = title(AppLocalizations.of(context));
    return ScreenTitle(
      screen: text,
      child: Scaffold(
        appBar: AppBar(
          leading: upButton(context, fallback: '/account'),
          title: Text(text),
        ),
        body: const PlaceholderBody(),
      ),
    );
  }
}
