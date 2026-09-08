import 'package:flutter/material.dart';

import '../state/game_state.dart';
import '../theme.dart';
import '../widgets/yohor_ring.dart';
import 'edit_screen.dart';
import 'guess_screen.dart';
import 'pairs_screen.dart';

/// Нүүр дэлгэц: толгой (нэр + оноо), ёохор бөгж, гурван таб.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.state});

  final GameState state;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _tabs = ['Тааварлах', 'Хос олох', 'Үг нэмэх'];

  int _tab = 0;

  /// «Хос олох» руу орох бүрд картуудыг дахин холино (вэб: buildPairs()).
  int _pairsGen = 0;

  void _select(int i) {
    setState(() {
      _tab = i;
      if (i == 1) _pairsGen++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Scaffold(
      body: Container(
        // CSS .shell: radial-gradient(120% 60% at 50% -10%, tenger-soft → transparent)
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.2),
            radius: .9,
            colors: [BuriadColors.tengerSoft, BuriadColors.tengerDeep],
            stops: [0, .6],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ListenableBuilder(
                listenable: state,
                builder: (context, _) {
                  switch (state.load) {
                    case LoadState.loading:
                      return const _Status('Ачааллаж байна...');
                    case LoadState.failed:
                      return const _Status('Үгийн санг уншиж чадсангүй.');
                    case LoadState.ready:
                      break;
                  }
                  // Намхан дэлгэц дээр (жижиг утас, том системийн үсэг) бөгж
                  // халин гарахын оронд багасна. Flexible ашиглавал доорх
                  // Expanded-тэй зайгаа тэн хувааж, тоглоомыг шахдаг.
                  final h = constraints.maxHeight;
                  final ringSize = h >= 560
                      ? 120.0
                      : (h * .22).clamp(56.0, 120.0);

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Column(
                      children: [
                        _Header(score: state.score),
                        const SizedBox(height: 2),
                        YohorRing(
                          streak: state.streak,
                          round: GameState.round,
                          pulse: state.ringDone,
                          size: ringSize,
                        ),
                        const SizedBox(height: 16),
                        _Tabs(labels: _tabs, index: _tab, onSelect: _select),
                        const SizedBox(height: 18),
                        Expanded(
                          child: IndexedStack(
                            index: _tab,
                            children: [
                              GuessScreen(state: state),
                              PairsScreen(
                                key: ValueKey(_pairsGen),
                                state: state,
                              ),
                              EditScreen(state: state),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      text,
      style: body(size: 14, color: BuriadColors.sutDim),
      textAlign: TextAlign.center,
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Үлдсэн зайг эзэлж онооыг баруун зах руу түлхэнэ; нарийн дэлгэцэд
        // (320 өргөн) гарчиг халин гарахгүйгээр шахагдана.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Буриад үг',
                style: display(
                  size: 15,
                  weight: FontWeight.w800,
                  spacing: -.3,
                  height: 1.1,
                ),
              ),
              Text(
                'КАРТ ТОГЛООМ · ТУРШИЛТ',
                style: label(size: 11).copyWith(letterSpacing: .66),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          label: 'Оноо $score',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
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
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.labels,
    required this.index,
    required this.onSelect,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: BuriadColors.khadag.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Semantics(
                button: true,
                selected: i == index,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: i == index
                          ? BuriadColors.tengerSoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: body(
                        size: 13,
                        weight: FontWeight.w600,
                        color: i == index
                            ? BuriadColors.sut
                            : BuriadColors.sutDim,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
