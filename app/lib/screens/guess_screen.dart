import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/word.dart';
import '../state/game_state.dart';
import '../theme.dart';
import '../widgets/home_cards.dart';
import '../widgets/word_picture.dart';
import '../widgets/yohor_line.dart';

/// Тааварлах: карт, дөрвөн сонголт, дүгнэлт, дараагийн үг.
class GuessScreen extends StatefulWidget {
  const GuessScreen({super.key, required this.state});

  final GameState state;

  @override
  State<GuessScreen> createState() => _GuessScreenState();
}

class _GuessScreenState extends State<GuessScreen>
    with SingleTickerProviderStateMixin {
  late final _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  AudioPlayer? _player;
  Question? _lastQ;
  bool _shownFlipped = false;
  bool _audioError = false;

  @override
  void initState() {
    super.initState();
    _lastQ = widget.state.q;
    widget.state.addListener(_onState);
  }

  /// Шинэ асуулт ирэхэд картыг нүүр тал руу нь буцааж, аудиог зогсооно;
  /// эргүүлэх төлөв өөрчлөгдвөл анимаци тоглуулна.
  void _onState() {
    final s = widget.state;
    if (!identical(_lastQ, s.q)) {
      _lastQ = s.q;
      _flip.value = 0;
      _shownFlipped = false;
      _player?.stop();
      if (_audioError) setState(() => _audioError = false);
    }
    if (s.flipped != _shownFlipped) {
      _shownFlipped = s.flipped;
      s.flipped ? _flip.forward() : _flip.reverse();
    }
  }

  Future<void> _playAudio(Word w) async {
    if (!w.hasAudio) return;
    try {
      final player = _player ??= AudioPlayer();
      await player.stop();
      await player.play(UrlSource(w.a));
    } catch (_) {
      if (mounted) setState(() => _audioError = true);
    }
  }

  @override
  void dispose() {
    widget.state.removeListener(_onState);
    _player?.dispose();
    _flip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Дэлгэц тусдаа маршрут тул төлөвөө өөрөө сонсоно — нүүрний
    // ListenableBuilder энд хүрэхгүй.
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) => _page(),
    );
  }

  Widget _page() {
    final s = widget.state;
    final q = s.q;
    return SubPage(
      title: 'Тааварлах',
      trailing: _Score(score: s.score),
      child: q == null
          ? const EmptyNote(
              'Тоглохын тулд дор хаяж 4 үг хэрэгтэй.\n'
              '«Үг нэмэх» хэсгээс оруулна уу.',
            )
          : Column(
              children: [
                YohorLine(
                  streak: s.streak,
                  round: GameState.round,
                  pulse: s.ringDone,
                ),
                const SizedBox(height: 16),
                Expanded(child: _body(s, q)),
              ],
            ),
    );
  }

  Widget _body(GameState s, Question q) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Flashcard(
            q: q,
            flip: _flip,
            locked: s.locked,
            correct: s.lastCorrect,
            audioError: _audioError,
            onTap: s.toggleFlip,
            onSound: () => _playAudio(q.right),
          ),
          // Зөв хариулсан бол сонголтууд алга болж, шууд «Дараагийн үг» гарна.
          // Буруу бол үлдээнэ — аль нь зөв байсныг харах хэрэгтэй.
          if (!(s.locked && s.lastCorrect)) ...[
            const SizedBox(height: 16),
            for (var i = 0; i < q.opts.length; i++) ...[
              if (i > 0) const SizedBox(height: 9),
              _Answer(
                index: i,
                text: q.optionText(q.opts[i]),
                state: !s.locked
                    ? _AnswerState.idle
                    : identical(q.opts[i], q.right)
                    ? _AnswerState.right
                    : identical(q.opts[i], s.chosen)
                    ? _AnswerState.wrong
                    : _AnswerState.disabled,
                onTap: s.locked ? null : () => s.answer(q.opts[i]),
              ),
            ],
          ],
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: s.locked ? _Verdict(q: q, correct: s.lastCorrect) : null,
          ),
          if (s.locked) ...[
            const SizedBox(height: 12),
            MainButton(text: 'Дараагийн үг', onTap: s.newQuestion),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- карт

class _Flashcard extends StatelessWidget {
  const _Flashcard({
    required this.q,
    required this.flip,
    required this.locked,
    required this.correct,
    required this.audioError,
    required this.onTap,
    required this.onSound,
  });

  final Question q;
  final Animation<double> flip;
  final bool locked;
  final bool correct;
  final bool audioError;
  final VoidCallback onTap;
  final VoidCallback onSound;

  static const _height = 330.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: locked,
      label: 'Карт эргүүлэх',
      child: GestureDetector(
        onTap: locked ? onTap : null,
        child: AnimatedBuilder(
          animation: flip,
          builder: (context, _) {
            final angle = flip.value * pi;
            final showBack = angle > pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, .001)
                ..rotateY(angle),
              child: showBack
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _face(_back()),
                    )
                  : _face(_front()),
            );
          },
        ),
      ),
    );
  }

  Widget _face(Widget child) {
    return Container(
      height: _height,
      decoration: BoxDecoration(
        // CSS: linear-gradient(145deg, #1d527d 0%, #123554 72%)
        gradient: const LinearGradient(
          begin: Alignment(-.574, -.819),
          end: Alignment(.574, .819),
          colors: [Color(0xFF1D527D), Color(0xFF123554)],
          stops: [0, .72],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BuriadColors.shar.withValues(alpha: .55)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          children: [
            // дотоод нарийн хүрээ
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: BuriadColors.khadag.withValues(alpha: .2),
                  ),
                ),
              ),
            ),
            // алхан хээ — буланд намуухан
            const Positioned(
              right: -14,
              bottom: -14,
              width: 74,
              height: 74,
              child: CustomPaint(painter: _MeanderPainter()),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _front() {
    final foot = !locked
        ? 'Хариултаа сонгоно уу'
        : correct
        ? 'Зөв хариуллаа'
        : 'Энд дарж зөв үгийг харна уу';
    final soundText = audioError
        ? 'Файл нээгдэхгүй байна'
        : q.right.hasAudio
        ? 'Дуудлага сонсох'
        : 'Дуудлага ороогүй';
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0x2E8FC7DE))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'БУРИАД ХЭЛНИЙ КАРТ',
                style: label(
                  size: 10,
                  color: BuriadColors.khadag,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '01',
                style: display(
                  size: 10,
                  color: BuriadColors.khadag,
                  spacing: 1,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 20, 6, 8),
          child: Column(
            children: [
              Text(
                q.promptLabel.toUpperCase(),
                style: label(
                  size: 10,
                  color: BuriadColors.khadag,
                ).copyWith(letterSpacing: 1.4),
              ),
              const SizedBox(height: 6),
              Text(
                q.promptText,
                textAlign: TextAlign.center,
                style: display(size: 30, weight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              _SoundPill(
                text: soundText,
                enabled: q.right.hasAudio && !audioError,
                onTap: onSound,
              ),
            ],
          ),
        ),
        const Spacer(),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 32),
          child: Center(
            child: Text(
              foot,
              textAlign: TextAlign.center,
              style: body(size: 11, color: BuriadColors.sutDim, height: 1.35),
            ),
          ),
        ),
      ],
    );
  }

  Widget _back() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WordPicture(word: q.right, size: 76, emojiSize: 38),
              const SizedBox(height: 14),
              Text(
                q.backLabel.toUpperCase(),
                style: label(
                  size: 10,
                  color: BuriadColors.khadag,
                ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.4),
              ),
              const SizedBox(height: 14),
              Text(
                q.backWord,
                textAlign: TextAlign.center,
                style: display(
                  size: 30,
                  weight: FontWeight.w600,
                  color: BuriadColors.shar,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                q.backSub,
                style: body(size: 14, color: BuriadColors.sutDim),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Text(
            'Буцааж дараад үргэлжлүүлнэ үү',
            textAlign: TextAlign.center,
            style: body(size: 11, color: BuriadColors.sutDim),
          ),
        ),
      ],
    );
  }
}

class _SoundPill extends StatelessWidget {
  const _SoundPill({
    required this.text,
    required this.enabled,
    required this.onTap,
  });

  final String text;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .55,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: BuriadColors.khadag.withValues(alpha: .07),
            border: Border.all(color: BuriadColors.line),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                size: 15,
                color: BuriadColors.khadag,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: body(
                    size: 12.5,
                    weight: FontWeight.w600,
                    color: BuriadColors.khadag,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Алхан хээ: CSS .card::after — хоёр давхар булан.
class _MeanderPainter extends CustomPainter {
  const _MeanderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = BuriadColors.khadag.withValues(alpha: .13);
    const t = 5.0;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, t), p);
    canvas.drawRect(Rect.fromLTWH(0, 0, t, size.height), p);
    canvas.drawRect(Rect.fromLTWH(18, 18, size.width - 18, t), p);
    canvas.drawRect(Rect.fromLTWH(18, 18, t, size.height - 18), p);
  }

  @override
  bool shouldRepaint(_MeanderPainter old) => false;
}

// ---------------------------------------------------------------- хариулт

enum _AnswerState { idle, right, wrong, disabled }

class _Answer extends StatelessWidget {
  const _Answer({
    required this.index,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final int index;
  final String text;
  final _AnswerState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg, idxColor) = switch (state) {
      _AnswerState.right => (
        BuriadColors.khus,
        BuriadColors.khus,
        BuriadColors.tengerDeep,
        BuriadColors.tengerDeep,
      ),
      _AnswerState.wrong => (
        BuriadColors.uls,
        BuriadColors.uls,
        BuriadColors.sut,
        BuriadColors.sutDim,
      ),
      _ => (
        BuriadColors.khadag.withValues(alpha: .06),
        BuriadColors.line,
        BuriadColors.sut,
        BuriadColors.sutDim,
      ),
    };
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: 'Хариулт ${index + 1}: $text',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 14),
                child: Text(
                  '${index + 1}',
                  style: display(size: 11, color: idxColor),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  text,
                  style: body(size: 16, weight: FontWeight.w600, color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Verdict extends StatelessWidget {
  const _Verdict({required this.q, required this.correct});

  final Question q;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final w = q.right;
    final note = w.n.isNotEmpty ? ' · ${w.n}' : '';
    return Column(
      children: [
        Text(
          correct ? 'Зөв' : 'Буруу',
          style: display(
            size: 15,
            color: correct ? BuriadColors.khus : BuriadColors.uls,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          correct ? '${w.b} — ${w.m}$note' : '${w.b} гэдэг нь ${w.m}$note',
          textAlign: TextAlign.center,
          style: body(size: 13, color: BuriadColors.sutDim),
        ),
      ],
    );
  }
}

/// Толгой дахь оноо.
class _Score extends StatelessWidget {
  const _Score({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Оноо $score',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$score',
            style: display(
              size: 20,
              weight: FontWeight.w600,
              color: BuriadColors.shar,
            ),
          ),
          Text('ОНОО', style: label(size: 10).copyWith(letterSpacing: .8)),
        ],
      ),
    );
  }
}
