import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/layout/window_size.dart';
import '../../../core/widgets/app_title.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../core/widgets/up_button.dart';
import '../../../l10n/app_localizations.dart';
import '../data/sync_engine.dart';
import '../domain/auth_repository.dart';
import 'auth_providers.dart';
import 'widgets/auth_form.dart';

/// Account: an invitation to sign in for guests (FR-AUTH-04), or the
/// signed-in account with sync status, Sync now, and Sign out (FR-AUTH-05).
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authUserProvider).valueOrNull;
    return ScreenTitle(
      screen: l10n.accountTitle,
      child: Scaffold(
        appBar: AppBar(
          leading: upButton(context, fallback: '/explore'),
          title: AppTitle(screen: l10n.accountTitle),
        ),
        body: ContentWidth(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (user == null)
                const _GuestCard()
              else
                _AccountCard(user: user),
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

class _GuestCard extends StatelessWidget {
  const _GuestCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.accountGuestTitle, style: theme.textTheme.titleMedium),
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
    );
  }
}

class _AccountCard extends ConsumerWidget {
  const _AccountCard({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final sync = ref.watch(syncControllerProvider);
    final syncing = sync.phase == SyncPhase.syncing;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.accountSignedInAs,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              user.email ?? '',
              style: theme.textTheme.titleMedium,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 12),
            _SyncStatus(state: sync),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: syncing
                      ? null
                      : () =>
                            ref.read(syncControllerProvider.notifier).syncNow(),
                  icon: const Icon(Icons.sync_rounded),
                  label: Text(l10n.accountSyncNow),
                ),
                OutlinedButton.icon(
                  onPressed: () => _confirmSignOut(context, ref),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.accountSignOut),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Sign out asks first, and warns about changes not yet backed up
  /// (FR-AUTH-06).
  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(syncControllerProvider.notifier);
    final unsynced = await controller.unsyncedChanges();
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(l10n.accountSignOutTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.accountSignOutBody),
              if (unsynced > 0) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.accountSignOutUnsynced(unsynced),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.accountSignOut),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await controller.signOut();
    } on AuthException catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(authFailureMessage(l10n, error.failure))),
      );
    }
  }
}

/// Where sync stands, announced to screen readers when it changes.
class _SyncStatus extends StatelessWidget {
  const _SyncStatus({required this.state});

  final SyncState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lastSync = state.lastSyncAt;
    final (Widget icon, String text) = switch (state.phase) {
      SyncPhase.syncing || SyncPhase.guest => (
        const SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        l10n.accountSyncing,
      ),
      SyncPhase.upToDate => (
        Icon(Icons.cloud_done_outlined, color: theme.colorScheme.primary),
        lastSync == null
            ? l10n.accountNotSyncedYet
            : l10n.accountLastSynced(context.formatDateTime(lastSync)),
      ),
      SyncPhase.offline => (
        Icon(
          Icons.cloud_off_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        l10n.accountSyncOffline,
      ),
      SyncPhase.failed => (
        Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
        l10n.accountSyncFailed,
      ),
    };
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          SizedBox.square(dimension: 24, child: Center(child: icon)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
