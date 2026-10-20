import 'package:firebase_auth/firebase_auth.dart';

import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  Stream<AuthUser?> authStateChanges() => _auth.authStateChanges().map(
    (user) => user == null ? null : AuthUser(uid: user.uid, email: user.email),
  );

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(
        () =>
            _auth.signInWithEmailAndPassword(email: email, password: password),
      );

  @override
  Future<void> signUp({required String email, required String password}) =>
      _guard(
        () => _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
      );

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email));

  @override
  Future<void> signOut() => _guard(_auth.signOut);

  static Future<void> _guard(Future<Object?> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      throw AuthException(authFailureFromCode(error.code));
    }
  }
}

/// Firebase Authentication error codes to failures (PRD section 8.6).
AuthFailure authFailureFromCode(String code) => switch (code) {
  'invalid-credential' ||
  'wrong-password' ||
  'user-not-found' ||
  'invalid-login-credentials' => AuthFailure.invalidCredentials,
  'email-already-in-use' => AuthFailure.emailInUse,
  'invalid-email' => AuthFailure.invalidEmail,
  'weak-password' => AuthFailure.weakPassword,
  'too-many-requests' => AuthFailure.tooManyRequests,
  'network-request-failed' => AuthFailure.network,
  _ => AuthFailure.unknown,
};
