import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/heritage_frame.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  void _openAuth(BuildContext context, AuthMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AuthScreen(mode: mode, onContinue: onContinue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeritageFrame(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _HatMark(),
                    const SizedBox(height: 28),
                    Text(
                      'Буриад үг',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Буриад хэл, аман зохиол, биет бус өвийг суралцаж, хадгалан түгээх орон зай.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.sutDim, height: 1.45),
                    ),
                    const SizedBox(height: 40),
                    FilledButton(
                      onPressed: () => _openAuth(context, AuthMode.signIn),
                      child: const Text('Нэвтрэх'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _openAuth(context, AuthMode.register),
                      child: const Text('Бүртгүүлэх'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: onContinue,
                      child: const Text('Бүртгэлгүйгээр үзэх'),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Амин Тоонто ТББ-тай хамтран ажиллав.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.khadag),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HatMark extends StatelessWidget {
  const _HatMark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Тоорцог малгайн дүрс',
      child: SizedBox(
        width: 118,
        height: 88,
        child: CustomPaint(painter: _HatPainter()),
      ),
    );
  }
}

class _HatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = AppColors.tengerSoft;
    final accent = Paint()
      ..color = AppColors.shar
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final dome = Rect.fromLTWH(12, 22, size.width - 24, size.height - 30);
    canvas.drawArc(dome, 3.14, 3.14, true, fill);
    canvas.drawArc(dome, 3.14, 3.14, false, accent);
    canvas.drawLine(
      Offset(10, size.height - 8),
      Offset(size.width - 10, size.height - 8),
      accent,
    );
    canvas.drawCircle(
      Offset(size.width / 2, 15),
      7,
      Paint()..color = AppColors.shar,
    );
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, 10),
      accent,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
