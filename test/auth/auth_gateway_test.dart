import 'package:buriad_ug/auth/auth_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Supabase алдааг монголоор тайлбарлана', () {
    expect(
      authFailureMessage(const AuthFailure('invalid_credentials')),
      'И-мэйл эсвэл нууц үг буруу байна.',
    );
    expect(
      authFailureMessage(const AuthFailure('email_not_confirmed')),
      'И-мэйл хаягаа эхлээд баталгаажуулна уу.',
    );
    expect(
      authFailureMessage(const AuthFailure('user_already_exists')),
      'Энэ и-мэйлээр бүртгэл үүссэн байна.',
    );
    expect(
      authFailureMessage(const AuthFailure('email_provider_disabled')),
      'Supabase дээр и-мэйлээр бүртгүүлэх тохиргоо идэвхгүй байна.',
    );
    expect(
      authFailureMessage(const AuthFailure('email_address_not_authorized')),
      'Энэ и-мэйл рүү баталгаажуулах захиа илгээх эрхгүй байна. SMTP тохиргоог шалгана уу.',
    );
  });

  test('үл мэдэгдэх алдаанд дотоод мэдээлэл харуулахгүй', () {
    expect(
      authFailureMessage(Exception('ТУРШИЛТ-1')),
      'Нэвтрэх үйлдэл амжилтгүй боллоо. Дахин оролдоно уу.',
    );
  });
}
