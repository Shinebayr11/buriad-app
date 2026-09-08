import 'package:flutter/material.dart';

import '../models/genre.dart';
import '../models/story.dart';
import '../state/game_state.dart';
import '../theme.dart';
import '../widgets/home_cards.dart';
import '../widgets/word_picture.dart';

/// Нэг төрлийн бичлэгүүдийн жагсаалт.
class StoryListScreen extends StatelessWidget {
  const StoryListScreen({super.key, required this.state, required this.genre});

  final GameState state;
  final Genre genre;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final items = state.byGenre(genre);
        return SubPage(
          title: genre.title,
          child: items.isEmpty
              ? const _Empty()
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 9),
                  itemBuilder: (context, i) => _StoryRow(story: items[i]),
                ),
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DefaultMark(size: 42, color: BuriadColors.tengerSoft),
            const SizedBox(height: 18),
            Text(
              'Бичлэг хараахан ороогүй байна.',
              textAlign: TextAlign.center,
              style: body(size: 15, height: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Эх ярианы хүний бичлэг, бичвэр, зөвшөөрөл гурав бүрдсэн үед '
              'энд нэмэгдэнэ.',
              textAlign: TextAlign.center,
              style: body(size: 13, color: BuriadColors.sutDim, height: 1.55),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryRow extends StatelessWidget {
  const _StoryRow({required this.story});

  final Story story;

  String get _duration {
    final total = story.audio.duration.round();
    final m = total ~/ 60, s = total % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final credited = story.creditedName;
    final dialect = story.narrator.dialect?.label ?? '';
    final meta = [
      if (dialect.isNotEmpty) dialect,
      if (credited.isNotEmpty) credited,
      _duration,
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
      decoration: BoxDecoration(
        color: BuriadColors.khadag.withValues(alpha: .06),
        border: Border.all(color: BuriadColors.line),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(story.titleB, style: display(size: 16, weight: FontWeight.w600)),
          if (story.titleM.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              story.titleM,
              style: body(size: 13, color: BuriadColors.sutDim),
            ),
          ],
          const SizedBox(height: 9),
          Text(meta.toUpperCase(), style: label(size: 10)),
        ],
      ),
    );
  }
}
