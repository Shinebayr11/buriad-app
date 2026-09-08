import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// Ёохор бөгж — 10 асуултын давталтын явц.
/// Геометр нь index.html-ийн drawRing()-тэй ижил: 120×120 талбайд R=48.
class YohorRing extends StatefulWidget {
  const YohorRing({
    super.key,
    required this.streak,
    required this.round,
    this.pulse = false,
    this.size = 120,
  });

  final List<bool> streak;
  final int round;

  /// true болох мөчид бөгж нэг удаа лугшина (CSS: .yohor.done → ringpulse).
  final bool pulse;

  /// Бөгжийн талын хэмжээ. Намхан дэлгэц дээр багасгана.
  final double size;

  @override
  State<YohorRing> createState() => _YohorRingState();
}

class _YohorRingState extends State<YohorRing>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 1.06), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.06, end: 1), weight: 1),
  ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void didUpdateWidget(YohorRing old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !old.pulse) _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Давталтын явц: ${widget.streak.length} / ${widget.round}',
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(widget.streak, widget.round),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.streak.length}',
                    style: display(
                      size: widget.size * (26 / 120),
                      weight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  SizedBox(height: widget.size * (4 / 120)),
                  Text(
                    '/ ${widget.round}',
                    style: label(
                      size: widget.size * (9 / 120),
                      color: BuriadColors.sutDim,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.streak, this.round);

  final List<bool> streak;
  final int round;

  @override
  void paint(Canvas canvas, Size size) {
    // Анхны 120×120 зураглалын харьцааг хадгална.
    final k = size.width / 120;
    final r = 48.0 * k, dotR = 3.4 * k;
    const gap = .07;
    final c = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: c, radius: r);
    final seg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * k
      ..strokeCap = StrokeCap.round;
    final dot = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < round; i++) {
      final a0 = i / round * 2 * pi - pi / 2 + gap;
      final a1 = (i + 1) / round * 2 * pi - pi / 2 - gap;
      final st = i < streak.length ? streak[i] : null;
      seg.color = switch (st) {
        true => BuriadColors.shar,
        false => BuriadColors.uls,
        null => BuriadColors.line,
      };
      canvas.drawArc(rect, a0, a1 - a0, false, seg);

      final am = (a0 + a1) / 2;
      dot.color = st == null ? BuriadColors.tengerSoft : BuriadColors.khadag;
      canvas.drawCircle(c + Offset(r * cos(am), r * sin(am)), dotR, dot);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.round != round || !listEquals(old.streak, streak);
}
