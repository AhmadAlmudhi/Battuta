/// A signed-in account. Guests have none.
class AuthUser {
  const AuthUser({required this.uid, this.email});

  final String uid;
  final String? email;

  @override
  bool operator ==(Object other) =>
      other is AuthUser && other.uid == uid && other.email == email;

  @override
  int get hashCode => Object.hash(uid, email);
}

/// Why an account action failed; each maps to a message in PRD section 8.6.
enum AuthFailure {
  invalidCredentials,
  emailInUse,
  invalidEmail,
  weakPassword,
  tooManyRequests,
  network,
  unknown,
}

class AuthException implements Exception {
  const AuthException(this.failure);

  final AuthFailure failure;

  @override
  String toString() => 'AuthException(${failure.name})';
}

/// Email and password accounts, the only sign-in method in 1.0 (D-8).
/// Methods throw [AuthException].
abstract interface class AuthRepository {
  /// The current account, then every change; null for a guest. A session
  /// survives restarts and reloads until sign-out (FR-AUTH-08).
  Stream<AuthUser?> authStateChanges();

  Future<void> signIn({required String email, required String password});

  Future<void> signUp({required String email, required String password});

  /// Sends a reset link. Succeeds even for unknown emails, so the form
  /// never reveals which emails have accounts.
  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}
