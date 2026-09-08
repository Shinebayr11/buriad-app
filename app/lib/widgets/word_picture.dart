import 'package:flutter/material.dart';

import '../models/word.dart';
import '../theme.dart';

/// Үгийн зураг: эможи эсвэл http хаягтай зураг. Дугуй хүрээтэй хувилбар.
class WordPicture extends StatelessWidget {
  const WordPicture({
    super.key,
    required this.word,
    required this.size,
    required this.emojiSize,
  });

  final Word word;
  final double size;
  final double emojiSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x59081E32), // rgba(8,30,50,.35)
        border: Border.all(color: BuriadColors.shar.withValues(alpha: .55)),
      ),
      child: WordMark(word: word, emojiSize: emojiSize, imageSize: size * .82),
    );
  }
}

/// Хүрээгүй: эможи текст эсвэл дугуй зураг.
class WordMark extends StatelessWidget {
  const WordMark({
    super.key,
    required this.word,
    required this.emojiSize,
    required this.imageSize,
  });

  final Word word;
  final double emojiSize;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    if (word.e == Word.defaultMark) {
      // ◈ (U+25C8) багцалсан хоёр фонтын аль алинд нь байхгүй тул зарим
      // төхөөрөмж дээр дөрвөлжин хайрцаг болдог. Оронд нь зурдаг icon.
      return DefaultMark(size: emojiSize, color: BuriadColors.khadag);
    }
    if (!word.hasImage) {
      return Text(
        word.e,
        style: TextStyle(fontSize: emojiSize, height: 1),
        textAlign: TextAlign.center,
      );
    }
    return ClipOval(
      child: Image.network(
        word.e,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            DefaultMark(size: emojiSize, color: BuriadColors.khadag),
      ),
    );
  }
}

/// Зураг ороогүй үгийн тэмдэг — ромб. Фонтоос хамаарахгүй, зурж гаргана.
class DefaultMark extends StatelessWidget {
  const DefaultMark({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _MarkPainter(color)),
  );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    Path rhombus(double k) => Path()
      ..moveTo(c.dx, c.dy - r * k)
      ..lineTo(c.dx + r * k, c.dy)
      ..lineTo(c.dx, c.dy + r * k)
      ..lineTo(c.dx - r * k, c.dy)
      ..close();

    canvas.drawPath(
      rhombus(.92),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .07
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(rhombus(.4), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.color != color;
}

/// Шар өргөлттэй үндсэн товч (CSS .next / .btn-main).
class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.text,
    required this.onTap,
    this.display = true,
  });

  final String text;
  final VoidCallback? onTap;

  /// true — Unbounded (.next), false — Golos Text (.btn-main).
  final bool display;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: BuriadColors.shar,
          foregroundColor: BuriadColors.tengerDeep,
          padding: EdgeInsets.all(display ? 15 : 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(display ? 13 : 11),
          ),
          textStyle: display
              ? TextStyle(
                  fontFamily: Fonts.display,
                  fontFamilyFallback: Fonts.fallback,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                )
              : const TextStyle(
                  fontFamily: Fonts.body,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
        ),
        child: Text(text),
      ),
    );
  }
}

/// Хүрээтэй, дэвсгэргүй товч (CSS .btn-ghost).
class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: BuriadColors.sut,
        side: const BorderSide(color: BuriadColors.line),
        padding: const EdgeInsets.all(13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        textStyle: const TextStyle(
          fontFamily: Fonts.body,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}

/// Хоосон төлөвийн бичиг (CSS .empty).
class EmptyNote extends StatelessWidget {
  const EmptyNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 10),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: body(size: 14, color: BuriadColors.sutDim, height: 1.6),
    ),
  );
}
