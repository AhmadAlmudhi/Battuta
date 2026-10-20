import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/screen_title.dart';
import '../../../core/widgets/up_button.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/auth_repository.dart';
import 'auth_providers.dart';
import 'widgets/auth_form.dart';

/// Request a password-reset email (FR-AUTH-03).
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  AuthFailure? _failure;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordReset(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    } on AuthException catch (error) {
      if (mounted) setState(() => _failure = error.failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ScreenTitle(
      screen: l10n.resetPasswordTitle,
      child: Scaffold(
        appBar: AppBar(
          leading: upButton(context, fallback: '/account/sign-in'),
          title: Text(l10n.resetPasswordTitle),
        ),
        body: Form(
          key: _form,
          child: AuthPage(
            children: [
              Text(l10n.authResetIntro, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 24),
              EmailField(
                controller: _email,
                enabled: !_busy,
                textInputAction: TextInputAction.done,
                onSubmitted: _submit,
              ),
              const SizedBox(height: 24),
              if (_failure != null) ...[
                FormErrorText(authFailureMessage(l10n, _failure!)),
                const SizedBox(height: 12),
              ],
              if (_sent) ...[
                // Worded so it never reveals whether the email has an
                // account.
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.authResetSent,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              BusyButton(
                label: l10n.authSendResetLink,
                busy: _busy,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go('/account/sign-in'),
                child: Text(l10n.authBackToSignIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
