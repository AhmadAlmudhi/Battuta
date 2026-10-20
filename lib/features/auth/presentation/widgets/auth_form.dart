import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/auth_repository.dart';

/// A simple shape check; the server has the final say.
final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Field rules from PRD section 8.6.
abstract final class AuthValidators {
  static String? email(AppLocalizations l10n, String? value) =>
      _emailPattern.hasMatch(value?.trim() ?? '') ? null : l10n.validationEmail;

  static String? passwordRequired(AppLocalizations l10n, String? value) =>
      (value ?? '').isEmpty ? l10n.validationPasswordRequired : null;

  /// At least 8 characters (FR-AUTH-01).
  static String? newPassword(AppLocalizations l10n, String? value) =>
      (value ?? '').length < 8 ? l10n.validationPasswordLength : null;
}

/// The message for an account error (PRD section 8.6).
String authFailureMessage(AppLocalizations l10n, AuthFailure failure) =>
    switch (failure) {
      AuthFailure.invalidCredentials => l10n.authErrorInvalidCredentials,
      AuthFailure.emailInUse => l10n.authErrorEmailInUse,
      AuthFailure.invalidEmail => l10n.validationEmail,
      AuthFailure.weakPassword => l10n.validationPasswordLength,
      AuthFailure.tooManyRequests => l10n.authErrorTooManyRequests,
      AuthFailure.network => l10n.authErrorNetwork,
      AuthFailure.unknown => l10n.authErrorUnknown,
    };

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autocorrect: false,
      // Emails read left to right in both languages.
      textDirection: TextDirection.ltr,
      autofillHints: const [AutofillHints.email, AutofillHints.username],
      decoration: InputDecoration(
        labelText: l10n.authEmail,
        prefixIcon: const Icon(Icons.mail_outline_rounded),
        border: const OutlineInputBorder(),
      ),
      validator: (value) => AuthValidators.email(l10n, value),
      onFieldSubmitted: (_) => onSubmitted?.call(),
    );
  }
}

/// A password with a show and hide toggle, and password manager support
/// (FR-AUTH-09).
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.newPassword = false,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;

  /// For sign-up, so password managers offer to save a new password.
  final bool newPassword;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  final bool enabled;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: !_visible,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: widget.textInputAction,
      textDirection: TextDirection.ltr,
      autofillHints: [
        widget.newPassword ? AutofillHints.newPassword : AutofillHints.password,
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _visible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          tooltip: _visible ? l10n.authHidePassword : l10n.authShowPassword,
          onPressed: () => setState(() => _visible = !_visible),
        ),
      ),
      validator: widget.validator,
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
    );
  }
}

/// An error under a form, announced to screen readers.
class FormErrorText extends StatelessWidget {
  const FormErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

/// A full-width primary button that shows progress and disables itself
/// while an action runs (PRD section 10.3).
class BusyButton extends StatelessWidget {
  const BusyButton({
    super.key,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: busy ? null : onPressed,
    child: busy
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label),
  );
}

/// Centered, readable width for the account forms.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: ListView(padding: const EdgeInsets.all(24), children: children),
    ),
  );
}
