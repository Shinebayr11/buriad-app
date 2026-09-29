import 'auth_gateway.dart';

class UnavailableAuthGateway implements AuthGateway {
  const UnavailableAuthGateway();

  @override
  bool get available => false;

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream.empty();

  @override
  Future<AuthSubmission> register({
    required String email,
    required String password,
  }) => throw const AuthFailure('not_configured');

  @override
  Future<AuthSubmission> signIn({
    required String email,
    required String password,
  }) => throw const AuthFailure('not_configured');

  @override
  Future<void> signOut() async {}
}
