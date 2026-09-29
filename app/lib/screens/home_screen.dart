import 'package:flutter/material.dart';

import '../models/genre.dart';
import '../state/game_state.dart';
import '../theme.dart';
import '../widgets/home_cards.dart';
import 'edit_screen.dart';
import 'guess_screen.dart';
import 'pairs_screen.dart';
import 'story_list_screen.dart';

/// Нүүр дэлгэц — аппын гарц. Тоглоом, аман зохиолын ангилал, үгийн сан.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.state});

  final GameState state;

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  /// Ангиллын картуудыг хоёр баганаар. IntrinsicHeight нь хосолсон картыг
  /// ижил өндөртэй болгоно — гүйлгэх жагсаалт дотор stretch дангаараа
  /// хязгааргүй өндөр өгдөг.
  Widget _genreGrid(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < Genre.values.length; i += 2) {
      final pair = Genre.values.skip(i).take(2).toList();
      if (i > 0) rows.add(const SizedBox(height: 9));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < pair.length; j++) ...[
                if (j > 0) const SizedBox(width: 9),
                Expanded(
                  child: _GenreCard(
                    state: state,
                    genre: pair[j],
                    onTap: () => _open(
                      context,
                      StoryListScreen(state: state, genre: pair[j]),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  @override
  Widget build(BuildContext context) {
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
          child: ListenableBuilder(
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
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                children: [
                  const _Mark(),
                  const SizedBox(height: 26),

                  HomeSection(
                    title: 'Тоглоом',
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: HomeCard(
                              title: 'Тааварлах',
                              hint: 'Карт харж утгыг нь олно',
                              meta: '${state.words.length} үг',
                              accent: true,
                              onTap: () =>
                                  _open(context, GuessScreen(state: state)),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: HomeCard(
                              title: 'Хос олох',
                              hint: 'Зураг, үгийг хослуулна',
                              meta: 'санах ой',
                              onTap: () =>
                                  _open(context, PairsScreen(state: state)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  HomeSection(title: 'Аман зохиол', child: _genreGrid(context)),

                  HomeSection(
                    title: 'Үгийн сан',
                    child: HomeCard(
                      title: 'Үг нэмэх, засах',
                      hint: 'Шинэ үг оруулах, JSON солилцох',
                      meta: '${state.words.length} үг',
                      onTap: () => _open(context, EditScreen(state: state)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GenreCard extends StatelessWidget {
  const _GenreCard({
    required this.state,
    required this.genre,
    required this.onTap,
  });

  final GameState state;
  final Genre genre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = state.byGenre(genre).length;
    return HomeCard(
      title: genre.title,
      hint: genre.hint,
      meta: n == 0 ? 'хоосон' : '$n бичлэг',
      dim: n == 0,
      onTap: onTap,
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Буриад үг',
          style: display(size: 26, weight: FontWeight.w800, spacing: -.5),
        ),
        const SizedBox(height: 4),
        Text(
          'ХЭЛ · АМАН ЗОХИОЛ · ӨВ',
          style: label(size: 11).copyWith(letterSpacing: 1.1),
        ),
      ],
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
