import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import 'auth_gateway.dart';

class SupabaseAuthGateway implements AuthGateway {
  SupabaseAuthGateway(this._client);

  final SupabaseClient _client;

  @override
  bool get available => true;

  @override
  AuthUser? get currentUser => _mapUser(_client.auth.currentUser);

  @override
  Stream<AuthUser?> get authStateChanges => _client.auth.onAuthStateChange.map(
    (state) => _mapUser(state.session?.user),
  );

  @override
  Future<AuthSubmission> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return AuthSubmission(user: _mapUser(response.user));
    } on AuthException catch (error) {
      throw AuthFailure(_errorCode(error));
    } catch (_) {
      throw const AuthFailure('network');
    }
  }

  @override
  Future<AuthSubmission> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return AuthSubmission(
        user: response.session == null ? null : _mapUser(response.user),
        emailConfirmationRequired: response.session == null,
      );
    } on AuthException catch (error) {
      throw AuthFailure(_errorCode(error));
    } catch (_) {
      throw const AuthFailure('network');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut(scope: SignOutScope.local);
    } on AuthException catch (error) {
      throw AuthFailure(_errorCode(error));
    } catch (_) {
      throw const AuthFailure('network');
    }
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      isAdmin: user.appMetadata['user_role'] == 'admin',
    );
  }

  String _errorCode(AuthException error) {
    return switch (error.code) {
      'invalid_credentials' => 'invalid_credentials',
      'email_not_confirmed' => 'email_not_confirmed',
      'user_already_exists' => 'user_already_exists',
      'weak_password' => 'weak_password',
      'over_request_rate_limit' || 'over_email_send_rate_limit' => 'rate_limit',
      _ when error.statusCode == null => 'network',
      _ => 'unknown',
    };
  }
}
