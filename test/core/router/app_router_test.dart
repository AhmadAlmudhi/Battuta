import 'package:battuta/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('redirectFor', () {
    String? redirect(String location, {required bool done}) =>
        redirectFor(Uri.parse(location), onboardingDone: done);

    test('sends a first-time user to Welcome', () {
      expect(redirect('/explore', done: false), '/welcome');
      expect(redirect('/', done: false), '/welcome');
    });

    test('keeps a deep link so Welcome can continue to it', () {
      expect(
        redirect('/country/JPN', done: false),
        '/welcome?from=%2Fcountry%2FJPN',
      );
      expect(
        redirect('/travels?tab=wishlist', done: false),
        '/welcome?from=%2Ftravels%3Ftab%3Dwishlist',
      );
    });

    test('lets a first-time user reach Welcome and sign-in', () {
      expect(redirect('/welcome', done: false), isNull);
      expect(redirect('/account/sign-in', done: false), isNull);
    });

    test('never shows Welcome again after the first choice', () {
      expect(redirect('/welcome', done: true), '/explore');
      expect(redirect('/country/JPN', done: true), isNull);
    });
  });
}
