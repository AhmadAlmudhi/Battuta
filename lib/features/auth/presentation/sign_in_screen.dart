import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/screen_title.dart';
import '../../../core/widgets/up_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/auth_repository.dart';
import 'auth_providers.dart';
import 'widgets/auth_form.dart';

/// After signing in or creating an account, a first-time user lands on
/// Explore (FR-ONB-03); anyone else returns to Account.
Future<void> goAfterSignIn(BuildContext context, WidgetRef ref) async {
  TextInput.finishAutofillContext();
  if (!ref.read(settingsProvider).onboardingDone) {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (context.mounted) context.go('/explore');
  } else if (context.mounted) {
    context.go('/account');
  }
}

/// Sign in with email and password (FR-AUTH-02).
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  AuthFailure? _failure;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
          .signIn(email: _email.text.trim(), password: _password.text);
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
    return ScreenTitle(
      screen: l10n.signInTitle,
      child: Scaffold(
        appBar: AppBar(
          leading: upButton(context, fallback: '/account'),
          title: Text(l10n.signInTitle),
        ),
        body: Form(
          key: _form,
          child: AutofillGroup(
            child: AuthPage(
              children: [
                EmailField(controller: _email, enabled: !_busy),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _password,
                  label: l10n.authPassword,
                  enabled: !_busy,
                  validator: (value) =>
                      AuthValidators.passwordRequired(l10n, value),
                  onSubmitted: _submit,
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: _busy
                        ? null
                        : () => context.push('/account/reset'),
                    child: Text(l10n.authForgotPassword),
                  ),
                ),
                if (_failure != null) ...[
                  FormErrorText(authFailureMessage(l10n, _failure!)),
                  const SizedBox(height: 12),
                ],
                BusyButton(
                  label: l10n.signInTitle,
                  busy: _busy,
                  onPressed: _submit,
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(l10n.authNoAccount),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => context.push('/account/sign-up'),
                      child: Text(l10n.authCreateAccount),
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
