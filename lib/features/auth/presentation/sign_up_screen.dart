import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/screen_title.dart';
import '../../../core/widgets/up_button.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/auth_repository.dart';
import 'auth_providers.dart';
import 'sign_in_screen.dart';
import 'widgets/auth_form.dart';

/// Create an account with email and a password of at least 8 characters,
/// entered twice (FR-AUTH-01).
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  AuthFailure? _failure;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
          .signUp(email: _email.text.trim(), password: _password.text);
      if (mounted) await goAfterSignIn(context, ref);
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
      screen: l10n.signUpTitle,
      child: Scaffold(
        appBar: AppBar(
          leading: upButton(context, fallback: '/account/sign-in'),
          title: Text(l10n.signUpTitle),
        ),
        body: Form(
          key: _form,
          child: AutofillGroup(
            child: AuthPage(
              children: [
                Text(l10n.authSignUpIntro, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 24),
                EmailField(controller: _email, enabled: !_busy),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _password,
                  label: l10n.authPassword,
                  newPassword: true,
                  enabled: !_busy,
                  textInputAction: TextInputAction.next,
                  validator: (value) => AuthValidators.newPassword(l10n, value),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _confirm,
                  label: l10n.authConfirmPassword,
                  newPassword: true,
                  enabled: !_busy,
                  validator: (value) => value == _password.text
                      ? null
                      : l10n.validationPasswordsMatch,
                  onSubmitted: _submit,
                ),
                const SizedBox(height: 24),
                if (_failure != null) ...[
                  FormErrorText(authFailureMessage(l10n, _failure!)),
                  const SizedBox(height: 12),
                ],
                BusyButton(
                  label: l10n.authCreateAccount,
                  busy: _busy,
                  onPressed: _submit,
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(l10n.authHaveAccount),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => context.canPop()
                                ? context.pop()
                                : context.go('/account/sign-in'),
                      child: Text(l10n.signInTitle),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
