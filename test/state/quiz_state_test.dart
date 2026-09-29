import 'dart:math';

import 'package:buriad_ug/models/word_entry.dart';
import 'package:buriad_ug/state/quiz_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final words = List.generate(
    6,
    (index) => WordEntry(
      buriad: 'ТУРШИЛТ-${index + 1}',
      mongolian: 'туршилт ${index + 1}',
      note: 'ТУРШИЛТ-${index + 11}',
    ),
  );

  test('4-өөс цөөн үгтэй үед асуулт үүсгэхгүй', () {
    final game = QuizState(words.take(3).toList(), random: Random(1));

    expect(game.hasEnoughWords, isFalse);
    expect(game.question, isNull);
    expect(game.progress, hasLength(10));
  });

  test('асуулт 4 сонголттой бөгөөд хариулсны дараа түгжинэ', () {
    final game = QuizState(words, random: Random(2));
    final question = game.question!;

    expect(question.choices, hasLength(4));
    expect(game.answer(question.answer), isTrue);
    expect(game.answered, isTrue);
    expect(game.answer(question.choices.first), isFalse);
    expect(game.progress.whereType<bool>(), hasLength(1));
  });

  test('10 асуултын дараа давталт дуусна', () {
    final game = QuizState(words, random: Random(3));

    for (var index = 0; index < QuizState.roundLength; index++) {
      game.answer(game.question!.answer);
      if (index < QuizState.roundLength - 1) game.next();
    }

    expect(game.completed, isTrue);
    expect(game.progress, everyElement(isTrue));
  });
}
