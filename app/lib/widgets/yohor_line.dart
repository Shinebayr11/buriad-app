import 'package:flutter/material.dart';

import '../theme.dart';

/// Давталтын явц — 10 асуултын шугаман заалт.
///
/// Хэрчим бүр нэг асуулт: шар = зөв, улаан = буруу, бүдэг = хариулаагүй.
class YohorLine extends StatefulWidget {
  const YohorLine({
    super.key,
    required this.streak,
    required this.round,
    this.pulse = false,
  });

  final List<bool> streak;
  final int round;

  /// true болох мөчид нэг удаа лугшина (давталт дүүрсэн тэмдэг).
  final bool pulse;

  @override
  State<YohorLine> createState() => _YohorLineState();
}

class _YohorLineState extends State<YohorLine>
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
  void didUpdateWidget(YohorLine old) {
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
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  for (var i = 0; i < widget.round; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    Expanded(
                      child: _Segment(
                        state: i < widget.streak.length
                            ? widget.streak[i]
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${widget.streak.length} / ${widget.round}',
              style: display(size: 13, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.state});

  /// true = зөв, false = буруу, null = хариулаагүй.
  final bool? state;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      height: 6,
      decoration: BoxDecoration(
        color: switch (state) {
          true => BuriadColors.shar,
          false => BuriadColors.uls,
          null => BuriadColors.line,
        },
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
