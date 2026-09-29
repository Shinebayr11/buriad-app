import 'dart:async';

import 'package:buriad_ug/auth/auth_gateway.dart';

class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({AuthUser? initialUser, this.confirmationRequired = false})
    : _currentUser = initialUser;

  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;
  bool confirmationRequired;
  Object? nextError;

  @override
  bool get available => true;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  Future<AuthSubmission> register({
    required String email,
    required String password,
  }) async {
    _throwNextError();
    if (confirmationRequired) {
      return const AuthSubmission(user: null, emailConfirmationRequired: true);
    }
    return _authenticate(email);
  }

  @override
  Future<AuthSubmission> signIn({
    required String email,
    required String password,
  }) async {
    _throwNextError();
    return _authenticate(email);
  }

  AuthSubmission _authenticate(String email) {
    _currentUser = AuthUser(id: 'ТУРШИЛТ-1', email: email);
    _controller.add(_currentUser);
    return AuthSubmission(user: _currentUser);
  }

  @override
  Future<void> signOut() async {
    _throwNextError();
    _currentUser = null;
    _controller.add(null);
  }

  void _throwNextError() {
    final error = nextError;
    nextError = null;
    if (error != null) throw error;
  }

  Future<void> dispose() => _controller.close();
}
