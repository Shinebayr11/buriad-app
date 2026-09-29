import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

class HeritageFrame extends StatelessWidget {
  const HeritageFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: CustomPaint(painter: _GarmentPainter())),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _GarmentPainter extends CustomPainter {
  const _GarmentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final accent = Paint()
      ..color = AppColors.shar.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, 24);
    canvas.drawArc(
      Rect.fromCenter(center: center, width: 88, height: 48),
      math.pi,
      math.pi,
      false,
      accent,
    );
    canvas.drawCircle(Offset(center.dx, 5), 4, accent);
    canvas.drawLine(Offset(center.dx, 9), Offset(center.dx, 24), accent);

    final edge = Path()
      ..moveTo(size.width - 28, 80)
      ..lineTo(size.width - 48, 100)
      ..lineTo(size.width - 28, 120)
      ..lineTo(size.width - 48, 140);
    canvas.drawPath(edge, line);
    for (var y = 96.0; y <= 144; y += 24) {
      canvas.drawCircle(Offset(size.width - 22, y), 3, accent);
    }

    final soleY = size.height - 18;
    final sole = Path()..moveTo(0, soleY);
    for (var x = 0.0; x < size.width + 28; x += 28) {
      sole
        ..quadraticBezierTo(x + 14, soleY - 12, x + 24, soleY)
        ..lineTo(x + 28, soleY);
    }
    canvas.drawPath(sole, accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
