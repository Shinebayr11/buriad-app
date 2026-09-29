import 'dart:math';

import '../models/word_entry.dart';

enum QuizDirection { mongolianToBuriad, buriadToMongolian }

class QuizQuestion {
  const QuizQuestion({
    required this.direction,
    required this.answer,
    required this.choices,
  });

  final QuizDirection direction;
  final WordEntry answer;
  final List<WordEntry> choices;

  String get prompt => direction == QuizDirection.mongolianToBuriad
      ? answer.mongolian
      : answer.buriad;

  String choiceLabel(WordEntry word) =>
      direction == QuizDirection.mongolianToBuriad
      ? word.buriad
      : word.mongolian;
}

class QuizState {
  QuizState(List<WordEntry> words, {Random? random})
    : _words = List.of(words),
      _random = random ?? Random() {
    if (_words.length >= minimumWords) _createQuestion();
  }

  static const minimumWords = 4;
  static const roundLength = 10;

  final List<WordEntry> _words;
  final Random _random;
  final List<bool> _results = [];
  QuizQuestion? _question;
  WordEntry? _selected;
  bool _showExplanation = false;

  bool get hasEnoughWords => _words.length >= minimumWords;
  QuizQuestion? get question => _question;
  WordEntry? get selected => _selected;
  bool get answered => _selected != null;
  bool get answerIsCorrect => _selected == _question?.answer;
  bool get showExplanation => _showExplanation;
  bool get completed => _results.length == roundLength;
  List<bool?> get progress => [
    ..._results,
    ...List<bool?>.filled(roundLength - _results.length, null),
  ];

  bool answer(WordEntry choice) {
    if (!hasEnoughWords || answered || completed) return false;
    _selected = choice;
    final correct = choice == _question!.answer;
    _results.add(correct);
    return correct;
  }

  void toggleExplanation() {
    if (answered) _showExplanation = !_showExplanation;
  }

  void next() {
    if (!answered || completed) return;
    _selected = null;
    _showExplanation = false;
    _createQuestion();
  }

  void restart() {
    _results.clear();
    _selected = null;
    _showExplanation = false;
    if (hasEnoughWords) _createQuestion();
  }

  void _createQuestion() {
    final shuffled = List<WordEntry>.of(_words)..shuffle(_random);
    final choices = shuffled.take(4).toList(growable: false);
    final answer = choices[_random.nextInt(choices.length)];
    _question = QuizQuestion(
      direction: _random.nextBool()
          ? QuizDirection.mongolianToBuriad
          : QuizDirection.buriadToMongolian,
      answer: answer,
      choices: choices,
    );
  }
}
