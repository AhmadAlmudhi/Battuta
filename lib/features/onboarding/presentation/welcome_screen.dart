import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/window_size.dart';
import '../../../core/widgets/panel.dart';
import '../../../core/widgets/screen_title.dart';
import '../../../l10n/app_localizations.dart';
import '../../countries/presentation/country_providers.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/presentation/settings_controller.dart';

/// Shown on first launch only (FR-ONB-01 to 05): the logo among round
/// flags, what the app does, the two ways in, and a language switch.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key, this.from});

  /// The page a first-time visitor opened by URL, opened after they choose.
  final String? from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Start importing the bundled countries while the user reads (PRD 7.1).
    ref.watch(countriesSeededProvider);
    final wide = WindowSizeClass.of(context) == WindowSizeClass.expanded;

    return ScreenTitle(
      screen: l10n.welcomeTitle,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // In its own row, so the page scrolls under it, not behind it.
              const Padding(
                padding: EdgeInsetsDirectional.only(top: 8, end: 8),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _LanguageSwitch(),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: wide
                        // Flags on the start side, the words on the end side.
                        ? ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1000),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: _Hero(width: 440, height: 400),
                                ),
                                const SizedBox(width: 48),
                                Expanded(
                                  child: _Intro(from: from, centered: false),
                                ),
                              ],
                            ),
                          )
                        : ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Column(
                              children: [
                                const _Hero(width: 320, height: 220),
                                const SizedBox(height: 24),
                                _Intro(from: from, centered: true),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The name, the tagline, what the app does, and the two ways in.
class _Intro extends ConsumerWidget {
  const _Intro({required this.from, required this.centered});

  final String? from;

  /// Centered under the logo on narrow screens; along the start edge
  /// beside it on wide ones.
  final bool centered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final align = centered ? TextAlign.center : TextAlign.start;
    const buttonSize = Size.fromHeight(52);
    final buttonText = theme.textTheme.titleSmall;

    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appName,
          textAlign: align,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.appTagline,
          textAlign: align,
          style: theme.textTheme.titleMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 28),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            children: [
              _Point(
                icon: Icons.travel_explore_rounded,
                text: l10n.welcomePointExplore,
              ),
              _Point(
                icon: Icons.approval_rounded,
                text: l10n.welcomePointVisits,
              ),
              _Point(icon: Icons.public_rounded, text: l10n.welcomePointMap),
            ],
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: buttonSize,
            textStyle: buttonText,
          ),
          onPressed: () async {
            await ref.read(settingsProvider.notifier).completeOnboarding();
            if (context.mounted) context.go(from ?? '/explore');
          },
          child: Text(l10n.welcomeContinueAsGuest),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: buttonSize,
            textStyle: buttonText,
          ),
          onPressed: () => context.push('/account/sign-in'),
          child: Text(l10n.welcomeSignIn),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.welcomeNoAccount,
          textAlign: align,
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
      ],
    );
  }
}

/// One thing the app does, led by an icon in a tinted circle.
class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        IconBadge(icon: icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    ),
  );
}

/// Round flags, like the Explore cards, scattered around the logo; they
/// stand for every country. Positions are physical, so switching the
/// language doesn't move them.
const _flags = [
  // (2-letter code, x, y from -1 to 1, diameter on narrow screens)
  ('sa', -0.62, -0.85, 44.0),
  ('jp', -0.04, -1.0, 30.0),
  ('br', 0.55, -0.8, 40.0),
  ('ma', 0.98, -1.0, 28.0),
  ('ca', 1.0, -0.12, 34.0),
  ('ke', 0.72, 0.66, 42.0),
  ('in', 0.18, 1.0, 32.0),
  ('gr', -0.42, 0.92, 38.0),
  ('kr', -1.0, 0.24, 36.0),
  ('mx', -0.9, -0.3, 30.0),
];

/// The logo among the flags. The logo lands like the passport stamp, then
/// the flags appear one by one (PRD 10.2); with reduced motion everything
/// is there at once.
class _Hero extends StatelessWidget {
  const _Hero({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    // Flags and logo grow with the space on wide screens.
    final scale = width / 320;
    final logo = _Logo(size: 104 * scale);

    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            for (final (i, (code, x, y, size)) in _flags.indexed)
              Align(
                alignment: Alignment(x, y),
                child: still
                    ? _Flag(code: code, size: size * scale)
                    : _Flag(code: code, size: size * scale)
                          .animate(delay: (450 + 70 * i).ms)
                          .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                          .scaleXY(
                            begin: 0.6,
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                          ),
              ),
            Center(
              child: still
                  ? logo
                  : logo
                        .animate()
                        .fadeIn(duration: 200.ms)
                        .scaleXY(
                          begin: 1.6,
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        )
                        .rotate(
                          begin: -0.03,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The app icon: a cream passport stamp with an amber globe on Lagoon Teal
/// (PRD 1.4), with rounded corners like a home-screen icon.
class _Logo extends StatelessWidget {
  const _Logo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size * 0.24),
      boxShadow: const [
        BoxShadow(
          blurRadius: 24,
          offset: Offset(0, 8),
          color: Color(0x40000000),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: Image.asset('assets/images/battuta_logo.jpg', fit: BoxFit.cover),
    ),
  );
}

/// A decorative round flag with a hairline edge, so white flags stand out.
class _Flag extends StatelessWidget {
  const _Flag({required this.code, required this.size});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    foregroundDecoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Theme.of(context).colorScheme.outlineVariant,
        width: 0.5,
      ),
    ),
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          blurRadius: 6,
          offset: Offset(0, 2),
          color: Color(0x26000000),
        ),
      ],
    ),
    child: ClipOval(
      child: Image.asset(
        'assets/flags/$code.png',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    ),
  );
}

/// Switches between English and Arabic before the user starts (FR-ONB-05).
/// It names the other language in its own script.
class _LanguageSwitch extends ConsumerWidget {
  const _LanguageSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return Tooltip(
      message: l10n.settingsLanguage,
      child: TextButton.icon(
        onPressed: () => ref
            .read(settingsProvider.notifier)
            .setLanguage(arabic ? AppLanguage.en : AppLanguage.ar),
        icon: const Icon(Icons.translate_rounded),
        label: Text(
          arabic ? l10n.settingsLanguageEnglish : l10n.settingsLanguageArabic,
        ),
      ),
    );
  }
}
