import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Буриад хувцасны хэлбэрээс сэдэвлэсэн чимэглэл.
///
/// Бүгдийг кодоор зурна — гадны зураг ашиглахгүй тул лицензийн асуудалгүй,
/// ямар ч дэлгэцийн нягтралд тод, багц дээр жин нэмэхгүй.

/// Тоорцог малгайн дүрс — толгой хэсэгт.
///
/// Бөмбөгөр орой, дээрээ жинс, доогуураа өргөсөн хүрээ.
class ToortsogCrest extends StatelessWidget {
  const ToortsogCrest({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size * 1.6,
    height: size,
    child: CustomPaint(painter: const _ToortsogPainter()),
  );
}

class _ToortsogPainter extends CustomPainter {
  const _ToortsogPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * .045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = BuriadColors.khadag.withValues(alpha: .75);

    // Бөмбөгөр орой — өндөр, нарийн
    final crown = Path()
      ..moveTo(w * .33, h * .70)
      ..cubicTo(w * .33, h * .17, w * .67, h * .17, w * .67, h * .70);
    canvas.drawPath(crown, line);

    // Өргөсөн хүрээ — хоёр үзүүр нь дээшээ
    final brim = Path()
      ..moveTo(w * .22, h * .64)
      ..quadraticBezierTo(w * .50, h * .90, w * .78, h * .64)
      ..moveTo(w * .26, h * .70)
      ..quadraticBezierTo(w * .50, h * .82, w * .74, h * .70);
    canvas.drawPath(brim, line);

    // Оройн жинс — шар товгор, улаан залаа
    canvas.drawCircle(
      Offset(w * .50, h * .20),
      h * .075,
      Paint()..color = BuriadColors.shar,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * .50, h * .13)
        ..quadraticBezierTo(w * .565, h * .04, w * .60, h * .10),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * .04
        ..strokeCap = StrokeCap.round
        ..color = BuriadColors.uls,
    );
  }

  @override
  bool shouldRepaint(_ToortsogPainter old) => false;
}

/// Энгэрийн шатлаг ирмэг — биеийн хэсгийн зүүн хүрээ.
///
/// Деэлийн энгэр цээжин дээр шатлан бууж, ирмэг дагуу товчтой байдаг.
class EngerEdge extends StatelessWidget {
  const EngerEdge({super.key, required this.child, this.width = 26});

  final Widget child;

  /// Ирмэгийн өргөн.
  final double width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: width,
          child: CustomPaint(painter: const _EngerPainter()),
        ),
        Padding(
          padding: EdgeInsets.only(left: width + 12),
          child: child,
        ),
      ],
    );
  }
}

class _EngerPainter extends CustomPainter {
  const _EngerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..color = BuriadColors.shar.withValues(alpha: .55);

    // Шатлан буух ирмэг
    final path = Path()..moveTo(w * .82, 0);
    const steps = 3;
    for (var i = 0; i < steps; i++) {
      final y0 = h * (i / steps);
      final y1 = h * ((i + .55) / steps);
      final x = w * (.82 - i * .22);
      path
        ..lineTo(x, y1)
        ..lineTo(x - w * .18, y1);
      if (i < steps - 1) path.lineTo(x - w * .18, h * ((i + 1) / steps));
      if (y0 > h) break;
    }
    canvas.drawPath(path, line);

    // Ирмэг дагуух товчнууд
    final btn = Paint()..color = BuriadColors.shar.withValues(alpha: .75);
    for (var i = 0; i < steps; i++) {
      final y = h * ((i + .28) / steps);
      canvas.drawCircle(Offset(w * .82, y), 2.6, btn);
    }
  }

  @override
  bool shouldRepaint(_EngerPainter old) => false;
}

/// Гутлын өргөсөн хоншоорын хээ — хөл хэсэгт.
class GutalBorder extends StatelessWidget {
  const GutalBorder({super.key, this.height = 26});

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: CustomPaint(painter: const _GutalPainter()),
  );
}

class _GutalPainter extends CustomPainter {
  const _GutalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = BuriadColors.khadag.withValues(alpha: .35);

    // Давтагдах өргөсөн хоншоор
    const unit = 46.0;
    final n = max(1, (w / unit).floor());
    final step = w / n;
    final path = Path()..moveTo(0, h * .78);
    for (var i = 0; i < n; i++) {
      final x = i * step;
      path
        ..lineTo(x + step * .52, h * .78)
        ..quadraticBezierTo(x + step * .80, h * .78, x + step * .78, h * .34)
        ..quadraticBezierTo(x + step * .76, h * .62, x + step * .96, h * .62)
        ..lineTo(x + step, h * .78);
    }
    canvas.drawPath(path, line);

    // Доогуур зэрэгцээ шугам
    canvas.drawLine(
      Offset(0, h * .94),
      Offset(w, h * .94),
      Paint()
        ..strokeWidth = 1
        ..color = BuriadColors.line,
    );
  }

  @override
  bool shouldRepaint(_GutalPainter old) => false;
}
