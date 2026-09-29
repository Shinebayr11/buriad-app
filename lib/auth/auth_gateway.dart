class AuthUser {
  const AuthUser({required this.id, required this.email, this.isAdmin = false});

  final String id;
  final String email;
  final bool isAdmin;

  @override
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.id == id &&
      other.email == email &&
      other.isAdmin == isAdmin;

  @override
  int get hashCode => Object.hash(id, email, isAdmin);
}

class AuthSubmission {
  const AuthSubmission({
    required this.user,
    this.emailConfirmationRequired = false,
  });

  final AuthUser? user;
  final bool emailConfirmationRequired;
}

class AuthFailure implements Exception {
  const AuthFailure(this.code);

  final String code;
}

abstract interface class AuthGateway {
  bool get available;
  AuthUser? get currentUser;
  Stream<AuthUser?> get authStateChanges;

  Future<AuthSubmission> signIn({
    required String email,
    required String password,
  });

  Future<AuthSubmission> register({
    required String email,
    required String password,
  });

  Future<void> resendSignupConfirmation({required String email});

  Future<void> signOut();
}

String authFailureMessage(Object error) {
  if (error is! AuthFailure) {
    return 'Нэвтрэх үйлдэл амжилтгүй боллоо. Дахин оролдоно уу.';
  }
  return switch (error.code) {
    'not_configured' => 'Supabase тохиргоо хийгдээгүй байна.',
    'invalid_credentials' => 'И-мэйл эсвэл нууц үг буруу байна.',
    'email_not_confirmed' => 'И-мэйл хаягаа эхлээд баталгаажуулна уу.',
    'user_already_exists' => 'Энэ и-мэйлээр бүртгэл үүссэн байна.',
    'email_provider_disabled' =>
      'Supabase дээр и-мэйлээр бүртгүүлэх тохиргоо идэвхгүй байна.',
    'email_address_not_authorized' => 'Энэ и-мэйл рүү баталгаажуулах захиа илгээх эрхгүй байна. SMTP тохиргоог шалгана уу.',
    'email_address_invalid' => 'И-мэйл хаягаа шалгаад дахин оролдоно уу.',
    'weak_password' => 'Нууц үг хангалттай найдвартай биш байна.',
    'rate_limit' =>
      'Хэт олон оролдлого хийлээ. Түр хүлээгээд дахин оролдоно уу.',
    'network' => 'Сүлжээний холболтоо шалгаад дахин оролдоно уу.',
    _ => 'Нэвтрэх үйлдэл амжилтгүй боллоо. Дахин оролдоно уу.',
  };
}
