import 'package:flutter/material.dart';

import '../widgets/heritage_frame.dart';

enum AuthMode { signIn, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.mode, required this.onContinue});

  final AuthMode mode;
  final VoidCallback onContinue;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    // TODO: Supabase холбоход серверийн дуудлагыг зөвхөн энд хийнэ.
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final registering = widget.mode == AuthMode.register;
    return Scaffold(
      appBar: AppBar(title: Text(registering ? 'Бүртгүүлэх' : 'Нэвтрэх')),
      body: HeritageFrame(
        child: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        registering ? 'Шинэ бүртгэл' : 'Тавтай морилно уу',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'И-мэйл',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          final emailPattern = RegExp(
                            r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                          );
                          if (!emailPattern.hasMatch(text)) {
                            return 'И-мэйл хаягаа зөв оруулна уу.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscurePassword,
                        autofillHints: registering
                            ? const [AutofillHints.newPassword]
                            : const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Нууц үг',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            tooltip: _obscurePassword
                                ? 'Нууц үгийг харуулах'
                                : 'Нууц үгийг нуух',
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').length < 8) {
                            return 'Нууц үг 8-аас цөөнгүй тэмдэгттэй байна.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _submit,
                        child: Text(registering ? 'Бүртгүүлэх' : 'Нэвтрэх'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: widget.onContinue,
                        child: const Text('Бүртгэлгүйгээр үзэх'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
