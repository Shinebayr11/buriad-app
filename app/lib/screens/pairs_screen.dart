import 'package:flutter/material.dart';

import '../models/word.dart';
import '../state/game_state.dart';
import '../theme.dart';
import '../widgets/home_cards.dart';
import '../widgets/word_picture.dart';

/// Хос олох (санах ой): 6 үг → 12 карт; зураг ба буриад үгийг нь хослуулна.
class PairsScreen extends StatefulWidget {
  const PairsScreen({super.key, required this.state});

  final GameState state;

  @override
  State<PairsScreen> createState() => _PairsScreenState();
}

enum _Kind { picture, buriad }

class _Card {
  const _Card(this.id, this.kind, this.word);

  final int id;
  final _Kind kind;
  final Word word;
}

class _PairsScreenState extends State<PairsScreen> {
  List<_Card> _cards = const [];
  final _up = <int>[];
  final _matched = <int>{};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    final picked = widget.state.pickForPairs();
    final cards = <_Card>[];
    for (var i = 0; i < picked.length; i++) {
      cards.add(_Card(i, _Kind.picture, picked[i]));
      cards.add(_Card(i, _Kind.buriad, picked[i]));
    }
    cards.shuffle();
    setState(() {
      _cards = cards;
      _up.clear();
      _matched.clear();
      _busy = false;
    });
  }

  void _flip(int i) {
    if (_busy || _up.contains(i) || _matched.contains(i)) return;
    setState(() => _up.add(i));
    if (_up.length < 2) return;

    _busy = true;
    final a = _cards[_up[0]], b = _cards[_up[1]];
    final match = a.id == b.id && a.kind != b.kind;
    Future.delayed(Duration(milliseconds: match ? 340 : 900), () {
      if (!mounted) return;
      setState(() {
        if (match) _matched.addAll(_up);
        _up.clear();
        _busy = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Хос олох',
      child: !widget.state.canPair
          ? const EmptyNote('Дор хаяж 3 үг нэмнэ үү.')
          : _grid(),
    );
  }

  Widget _grid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3 / 4,
            ),
            itemCount: _cards.length,
            itemBuilder: (context, i) => _Tile(
              card: _cards[i],
              up: _up.contains(i),
              matched: _matched.contains(i),
              onTap: () => _flip(i),
            ),
          ),
          const SizedBox(height: 16),
          MainButton(text: 'Дахин холих', onTap: _build),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.card,
    required this.up,
    required this.matched,
    required this.onTap,
  });

  final _Card card;
  final bool up;
  final bool matched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shown = up || matched;
    final (bg, border) = matched
        ? (BuriadColors.khus, BuriadColors.khus)
        : up
        ? (BuriadColors.tengerSoft, BuriadColors.khadag)
        : (BuriadColors.khadag.withValues(alpha: .06), BuriadColors.line);
    final fg = matched ? BuriadColors.tengerDeep : BuriadColors.sut;

    final Widget face;
    if (!shown) {
      face = const DefaultMark(size: 24, color: BuriadColors.tengerSoft);
    } else if (card.kind == _Kind.picture) {
      face = WordMark(word: card.word, emojiSize: 30, imageSize: 56);
    } else {
      face = Text(
        card.word.b,
        textAlign: TextAlign.center,
        style: body(size: 14, weight: FontWeight.w600, color: fg, height: 1.2),
      );
    }

    return Semantics(
      button: true,
      label: shown
          ? (card.kind == _Kind.picture ? 'Зураг' : card.word.b)
          : 'Хаалттай карт',
      child: GestureDetector(
        onTap: matched ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: face,
        ),
      ),
    );
  }
}
