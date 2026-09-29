import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/word_entry.dart';
import '../state/quiz_state.dart';
import '../theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/heritage_frame.dart';
import '../widgets/yoohor_progress.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.words,
    required this.onAddWords,
    this.random,
  });

  final List<WordEntry> words;
  final VoidCallback onAddWords;
  final Random? random;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizState _game;
  final _audioPlayer = AudioPlayer();
  bool _pulse = false;

  @override
  void initState() {
    super.initState();
    _game = QuizState(widget.words, random: widget.random);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _answer(WordEntry choice) {
    setState(() {
      _game.answer(choice);
      if (_game.completed) _pulse = true;
    });
    if (_game.completed) {
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        if (mounted) setState(() => _pulse = false);
      });
    }
  }

  Future<void> _playAudio() async {
    final path = _game.question?.answer.audioPath;
    if (path == null || path.isEmpty) return;
    final assetPath = path.startsWith('assets/') ? path.substring(7) : path;
    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Бичлэгийг тоглуулж чадсангүй.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Тааварлах')),
      body: HeritageFrame(
        child: SafeArea(
          top: false,
          child: !_game.hasEnoughWords
              ? EmptyState(
                  icon: Icons.quiz_outlined,
                  title: 'Тоглоход үг хүрэлцэхгүй байна',
                  message: 'Тааварлах тоглоомд хамгийн багадаа 4 үг хэрэгтэй.',
                  action: FilledButton.icon(
                    onPressed: widget.onAddWords,
                    icon: const Icon(Icons.add),
                    label: const Text('Үг нэмэх'),
                  ),
                )
              : _game.completed
              ? _completed()
              : _question(),
        ),
      ),
    );
  }

  Widget _question() {
    final question = _game.question!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        YoohorProgress(results: _game.progress, pulse: _pulse),
        const SizedBox(height: 24),
        Text(
          question.direction == QuizDirection.mongolianToBuriad
              ? 'Буриад үгийг сонгоно уу'
              : 'Монгол утгыг сонгоно уу',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _game.answered
              ? () => setState(_game.toggleExplanation)
              : null,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: Tween(begin: 0.95, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Card(
              key: ValueKey(_game.showExplanation),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      _game.showExplanation
                          ? (question.answer.note.isEmpty
                                ? 'Тайлбар оруулаагүй байна.'
                                : question.answer.note)
                          : question.prompt,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (_game.answered) ...[
                      const SizedBox(height: 12),
                      Text(
                        _game.showExplanation
                            ? 'Карт дээр дарж асуултыг харна уу.'
                            : 'Карт дээр дарж тайлбарыг харна уу.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.sutDim),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final choice in question.choices)
          if (!(_game.answered &&
              _game.answerIsCorrect &&
              choice != question.answer))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FilledButton(
                onPressed: _game.answered ? null : () => _answer(choice),
                style: FilledButton.styleFrom(
                  backgroundColor: _choiceColor(choice),
                  disabledBackgroundColor: _choiceColor(choice),
                  disabledForegroundColor: AppColors.sut,
                ),
                child: Text(question.choiceLabel(choice)),
              ),
            ),
        if (_game.answered) ...[
          if (question.answer.audioPath.isNotEmpty)
            OutlinedButton.icon(
              onPressed: _playAudio,
              icon: const Icon(Icons.volume_up_outlined),
              label: const Text('Дуудлагын бичлэг сонсох'),
            ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => setState(_game.next),
            child: const Text('Дараах асуулт'),
          ),
        ],
      ],
    );
  }

  Color? _choiceColor(WordEntry choice) {
    if (!_game.answered) return null;
    if (choice == _game.question!.answer) return AppColors.khus;
    if (choice == _game.selected) return AppColors.uls;
    return AppColors.tengerSoft;
  }

  Widget _completed() {
    final correct = _game.progress.where((result) => result == true).length;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          YoohorProgress(results: _game.progress, pulse: _pulse),
          const SizedBox(height: 32),
          const Icon(
            Icons.celebration_outlined,
            size: 52,
            color: AppColors.shar,
          ),
          const SizedBox(height: 16),
          Text(
            'Давталт дууслаа',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text('$correct / ${QuizState.roundLength} зөв хариулт'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => setState(_game.restart),
            child: const Text('Дахин тоглох'),
          ),
        ],
      ),
    );
  }
}
