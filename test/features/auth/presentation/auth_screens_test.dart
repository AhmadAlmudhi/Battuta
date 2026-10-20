import 'package:battuta/core/router/app_router.dart';
import 'package:battuta/features/auth/domain/auth_repository.dart';
import 'package:battuta/features/auth/presentation/auth_providers.dart';
import 'package:battuta/features/travels/presentation/travel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump_app.dart';

void main() {
  const email = 'traveler@example.com';
  final user = AuthUser(uid: FakeAuthRepository.uidFor(email), email: email);

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  /// Entries on the device, read straight from the database.
  Future<int> deviceEntries(TestApp app) async =>
      (await app.db.select(app.db.travelEntries).get()).length;

  String location(TestApp app) => app.container
      .read(routerProvider)
      .routerDelegate
      .currentConfiguration
      .uri
      .toString();

  Future<void> signIn(
    WidgetTester tester, {
    String password = 'password',
  }) async {
    await tester.enterText(field('Email'), email);
    await tester.enterText(field('Password'), password);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
  }

  group('sign in (FR-AUTH-02)', () {
    testWidgets('checks the fields before calling the server', (tester) async {
      final app = await pumpApp(tester, prefs: returningUser);
      await app.goTo(tester, '/account/sign-in');

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
    });

    testWidgets('wrong credentials show the message and change nothing '
        '(AC-AUTH-02)', (tester) async {
      final app = await pumpApp(tester, prefs: returningUser);
      app.auth.accounts[email] = 'password';
      await app.container.read(travelRepositoryProvider).saveVisit('FRA');
      await app.goTo(tester, '/account/sign-in');

      await signIn(tester, password: 'wrong-password');

      expect(find.text('Email or password is incorrect.'), findsOneWidget);
      expect(app.cloud.uploads, isEmpty);
      expect(await deviceEntries(app), 1);
    });

    testWidgets('a network failure shows the connection message', (
      tester,
    ) async {
      final app = await pumpApp(tester, prefs: returningUser);
      app.auth.failNext = AuthFailure.network;
      await app.goTo(tester, '/account/sign-in');

      await signIn(tester);

      expect(
        find.text('No connection. Check your network and try again.'),
        findsOneWidget,
      );
    });

    testWidgets('signing in merges guest entries and returns to Account '
        '(FR-SYNC-01)', (tester) async {
      final app = await pumpApp(tester, prefs: returningUser);
      app.auth.accounts[email] = 'password';
      await app.container.read(travelRepositoryProvider).saveVisit('FRA');
      await app.goTo(tester, '/account');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      await signIn(tester);

      expect(location(app), '/account');
      expect(find.text(email), findsOneWidget);
      expect(find.textContaining('Last synced'), findsOneWidget);
      expect(app.cloud.entriesOf(user.uid).keys, ['FRA']);
    });

    testWidgets('from Welcome, signing in lands on Explore (FR-ONB-03)', (
      tester,
    ) async {
      final app = await pumpApp(tester);
      app.auth.accounts[email] = 'password';
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      await signIn(tester);

      expect(location(app), '/explore');
      expect(find.text('France'), findsOneWidget);
    });

    testWidgets('the password can be shown and hidden (FR-AUTH-09)', (
      tester,
    ) async {
      final app = await pumpApp(tester, prefs: returningUser);
      await app.goTo(tester, '/account/sign-in');

      bool obscured() => tester
          .widget<EditableText>(
            find.descendant(
              of: field('Password'),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText;
      expect(obscured(), isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(obscured(), isFalse);
    });
  });

  group('create account (FR-AUTH-01)', () {
    Future<TestApp> openSignUp(WidgetTester tester) async {
      final app = await pumpApp(tester, prefs: returningUser);
      await app.goTo(tester, '/account/sign-up');
      return app;
    }

    testWidgets('passwords must match (AC-AUTH-01)', (tester) async {
      await openSignUp(tester);
      await tester.enterText(field('Email'), email);
      await tester.enterText(field('Password'), 'long-enough');
      await tester.enterText(field('Confirm password'), 'different!');
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();

      expect(find.text("Passwords don't match."), findsOneWidget);
    });

    testWidgets('passwords need at least 8 characters', (tester) async {
      await openSignUp(tester);
      await tester.enterText(field('Email'), email);
      await tester.enterText(field('Password'), 'short');
      await tester.enterText(field('Confirm password'), 'short');
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 8 characters.'),
        findsOneWidget,
      );
    });

    testWidgets('an email already in use shows its message', (tester) async {
      final app = await openSignUp(tester);
      app.auth.accounts[email] = 'existing';
      await tester.enterText(field('Email'), email);
      await tester.enterText(field('Password'), 'long-enough');
      await tester.enterText(field('Confirm password'), 'long-enough');
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();

      expect(
        find.text('An account already exists for this email.'),
        findsOneWidget,
      );
    });

    testWidgets('a new account signs in and backs up guest entries', (
      tester,
    ) async {
      final app = await openSignUp(tester);
      await app.container.read(travelRepositoryProvider).saveWishlist('JPN');
      await tester.enterText(field('Email'), email);
      await tester.enterText(field('Password'), 'long-enough');
      await tester.enterText(field('Confirm password'), 'long-enough');
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();

      expect(find.text(email), findsOneWidget);
      expect(app.cloud.entriesOf(user.uid).keys, ['JPN']);
    });
  });

  testWidgets('reset password sends a link without revealing accounts '
      '(FR-AUTH-03)', (tester) async {
    final app = await pumpApp(tester, prefs: returningUser);
    await app.goTo(tester, '/account/reset');

    await tester.enterText(field('Email'), 'nobody@example.com');
    await tester.tap(find.widgetWithText(FilledButton, 'Send reset link'));
    await tester.pumpAndSettle();

    expect(app.auth.resetRequests, ['nobody@example.com']);
    expect(
      find.text(
        'If an account exists for this email, a reset link is on its way.',
      ),
      findsOneWidget,
    );
  });

  group('signed in (FR-AUTH-05, FR-AUTH-06)', () {
    testWidgets('Sync now uploads and updates the last sync time '
        '(FR-SYNC-07)', (tester) async {
      final app = await pumpApp(tester, prefs: returningUser, signedIn: user);
      await app.goTo(tester, '/account');
      expect(find.text(email), findsOneWidget);

      await app.container.read(travelRepositoryProvider).saveVisit('FRA');
      await tester.tap(find.text('Sync now'));
      await tester.pumpAndSettle();

      expect(app.cloud.entriesOf(user.uid).keys, ['FRA']);
      expect(find.textContaining('Last synced'), findsOneWidget);
    });

    testWidgets('sign out asks first, then clears the device and shows the '
        'guest card (AC-AUTH-03)', (tester) async {
      final app = await pumpApp(tester, prefs: returningUser, signedIn: user);
      await app.container.read(travelRepositoryProvider).saveVisit('FRA');
      await tester.pumpAndSettle();
      await app.goTo(tester, '/account');

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Sign out?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Sign out'));
      await tester.pumpAndSettle();

      expect(find.text('Back up your travels'), findsOneWidget);
      expect(await deviceEntries(app), 0);
      // The cloud copy stays (D-4).
      expect(app.cloud.entriesOf(user.uid).keys, ['FRA']);

      await app.goTo(tester, '/travels');
      expect(find.text('No visits yet'), findsOneWidget);
    });

    testWidgets('after a session ends without Sign out, another account '
        'signing in never receives the first account\'s entries', (
      tester,
    ) async {
      final app = await pumpApp(tester, prefs: returningUser, signedIn: user);
      await app.container.read(travelRepositoryProvider).saveVisit('FRA');
      await tester.pumpAndSettle();
      expect(app.cloud.entriesOf(user.uid).keys, ['FRA']);

      // The session ends on its own, for example after a password change
      // on another device: no Sign out, so nothing was cleared yet.
      await app.auth.signOut();
      await tester.pumpAndSettle();

      const other = 'other@example.com';
      app.auth.accounts[other] = 'password';
      await app.auth.signIn(email: other, password: 'password');
      await tester.pumpAndSettle();

      expect(app.cloud.entriesOf(FakeAuthRepository.uidFor(other)), isEmpty);
      expect(await deviceEntries(app), 0);
      expect(app.cloud.entriesOf(user.uid).keys, ['FRA']);
    });

    testWidgets('sign out warns about changes not backed up yet', (
      tester,
    ) async {
      final app = await pumpApp(tester, prefs: returningUser, signedIn: user);
      await tester.pumpAndSettle();
      app.connectivity.online = false;
      await tester.pumpAndSettle();
      await app.container.read(travelRepositoryProvider).saveVisit('FRA');
      await tester.pumpAndSettle();
      await app.goTo(tester, '/account');

      expect(
        find.text(
          "You're offline. Changes will upload when you're back online.",
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(
        find.text("1 change hasn't been backed up yet and will be lost."),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(app.container.read(syncControllerProvider).phase.name, 'offline');
    });
  });
}
