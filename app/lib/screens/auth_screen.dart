import 'package:flutter/material.dart';

import '../state/game_state.dart';
import '../theme.dart';
import '../widgets/buriad_ornaments.dart';
import '../widgets/home_cards.dart';
import '../widgets/word_picture.dart';
import 'home_screen.dart';

/// Нэвтрэх / бүртгүүлэх дэлгэц.
///
/// Одоогоор зөвхөн харагдах хэсэг: аппад сервер холбогдоогүй тул бодит
/// бүртгэл үүсэхгүй. Supabase холбогдсоны дараа [_submit] дотор л дуудлага
/// нэмнэ — маягт, шалгалт, алдааны мэдэгдэл бэлэн байна.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.state, required this.signUp});

  final GameState state;

  /// true — бүртгүүлэх, false — нэвтрэх.
  final bool signUp;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _name = TextEditingController();
  final _mail = TextEditingController();
  final _pass = TextEditingController();

  String? _error;

  bool get _signUp => widget.signUp;

  @override
  void dispose() {
    for (final c in [_name, _mail, _pass]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final mail = _mail.text.trim();
    final pass = _pass.text;

    String? problem;
    if (_signUp && _name.text.trim().isEmpty) {
      problem = 'Нэрээ оруулна уу.';
    } else if (!mail.contains('@') || !mail.contains('.')) {
      problem = 'И-мэйл хаяг буруу байна.';
    } else if (pass.length < 8) {
      problem = 'Нууц үг дор хаяж 8 тэмдэгт байна.';
    } else {
      problem =
          'Сервер хараахан холбогдоогүй байна. '
          'Одоохондоо бүртгэлгүйгээр үзнэ үү.';
    }
    setState(() => _error = problem);
  }

  @override
  Widget build(BuildContext context) {
    final title = _signUp ? 'Бүртгүүлэх' : 'Нэвтрэх';
    return SubPage(
      title: title,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: ToortsogCrest(size: 56)),
            const SizedBox(height: 22),
            EngerEdge(
              child: Text(
                _signUp
                    ? 'Бүртгэлтэй бол нэмсэн үг, бичлэг чинь төхөөрөмж '
                          'солиход ч хадгалагдана.'
                    : 'Өмнө бүртгүүлсэн бол и-мэйлээрээ нэвтэрнэ үү.',
                style: body(size: 14, color: BuriadColors.sutDim, height: 1.55),
              ),
            ),
            const SizedBox(height: 22),

            if (_signUp) ...[
              _Label('Нэр'),
              _Field(controller: _name, hint: 'жишээ нь: Батаа'),
            ],
            _Label('И-мэйл'),
            _Field(
              controller: _mail,
              hint: 'name@example.com',
              keyboard: TextInputType.emailAddress,
            ),
            _Label('Нууц үг'),
            _Field(controller: _pass, hint: 'дор хаяж 8 тэмдэгт', secret: true),

            if (_error != null) ...[
              const SizedBox(height: 14),
              _Notice(_error!),
            ],

            const SizedBox(height: 18),
            MainButton(text: title, onTap: _submit, display: false),
            const SizedBox(height: 14),
            Center(
              child: Semantics(
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => HomeScreen(state: widget.state),
                    ),
                    (_) => false,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Бүртгэлгүйгээр үзэх',
                      style: body(
                        size: 14,
                        weight: FontWeight.w600,
                        color: BuriadColors.khadag,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const GutalBorder(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: BuriadColors.shar.withValues(alpha: .1),
        border: Border.all(color: BuriadColors.shar.withValues(alpha: .35)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(text, style: body(size: 13, height: 1.5)),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 13, bottom: 5),
    child: Text(text.toUpperCase(), style: label()),
  );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.keyboard,
    this.secret = false,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;
  final bool secret;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BuriadColors.line),
    );
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: secret,
      style: body(size: 16),
      cursorColor: BuriadColors.shar,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: body(
          size: 16,
          color: BuriadColors.sutDim.withValues(alpha: .6),
        ),
        filled: true,
        fillColor: BuriadColors.khadag.withValues(alpha: .07),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 12,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: BuriadColors.shar),
        ),
      ),
    );
  }
}
