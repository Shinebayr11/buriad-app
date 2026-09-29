import 'dart:math';

import 'package:flutter/material.dart';

import '../models/word_entry.dart';
import '../state/memory_state.dart';
import '../theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/heritage_frame.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({
    super.key,
    required this.words,
    required this.onAddWords,
    this.random,
  });

  final List<WordEntry> words;
  final VoidCallback onAddWords;
  final Random? random;

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  late final MemoryState _game;

  @override
  void initState() {
    super.initState();
    _game = MemoryState(widget.words, random: widget.random);
  }

  Future<void> _select(int id) async {
    final result = _game.select(id);
    setState(() {});
    if (result == MemoryTurnResult.mismatch) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(_game.hideMismatch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Хос олох')),
      body: HeritageFrame(
        child: SafeArea(
          top: false,
          child: !_game.hasEnoughWords
              ? EmptyState(
                  icon: Icons.grid_view_outlined,
                  title: 'Тоглоход үг хүрэлцэхгүй байна',
                  message: 'Хос олох тоглоомд хамгийн багадаа 6 үг хэрэгтэй.',
                  action: FilledButton.icon(
                    onPressed: widget.onAddWords,
                    icon: const Icon(Icons.add),
                    label: const Text('Үг нэмэх'),
                  ),
                )
              : Column(
                  children: [
                    if (_game.completed)
                      MaterialBanner(
                        content: const Text('Бүх хосыг оллоо.'),
                        actions: [
                          TextButton(
                            onPressed: () => setState(_game.restart),
                            child: const Text('Дахин тоглох'),
                          ),
                        ],
                      ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.82,
                            ),
                        itemCount: _game.cards.length,
                        itemBuilder: (context, index) {
                          final card = _game.cards[index];
                          return _MemoryCardView(
                            card: card,
                            visible: _game.isVisible(card.id),
                            matched: _game.matchedIds.contains(card.id),
                            onTap: () => _select(card.id),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _MemoryCardView extends StatelessWidget {
  const _MemoryCardView({
    required this.card,
    required this.visible,
    required this.matched,
    required this.onTap,
  });

  final MemoryGameCard card;
  final bool visible;
  final bool matched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: visible ? 'Нээгдсэн карт' : 'Хаалттай карт',
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: matched ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: matched
                ? AppColors.khus
                : visible
                ? AppColors.tengerSoft
                : AppColors.tenger,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: visible ? AppColors.shar : AppColors.line,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: visible
                  ? FittedBox(
                      key: ValueKey('open-${card.id}'),
                      fit: BoxFit.scaleDown,
                      child: card.kind == MemoryCardKind.emoji
                          ? card.word.emoji.isEmpty
                                ? const Icon(Icons.image_not_supported_outlined)
                                : Text(
                                    card.word.emoji,
                                    style: const TextStyle(fontSize: 38),
                                  )
                          : Text(
                              card.word.buriad,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                    )
                  : const Icon(
                      Icons.auto_awesome,
                      key: ValueKey('closed'),
                      color: AppColors.khadag,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
