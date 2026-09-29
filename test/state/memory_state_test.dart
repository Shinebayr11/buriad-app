import 'dart:math';

import 'package:buriad_ug/models/word_entry.dart';
import 'package:buriad_ug/state/memory_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final words = List.generate(
    7,
    (index) => WordEntry(
      buriad: 'ТУРШИЛТ-${index + 1}',
      mongolian: 'туршилт ${index + 1}',
      emoji: '${index + 1}',
    ),
  );

  test('6-аас цөөн үгтэй үед карт үүсгэхгүй', () {
    final game = MemoryState(words.take(5).toList(), random: Random(1));

    expect(game.hasEnoughWords, isFalse);
    expect(game.cards, isEmpty);
  });

  test('6 үгээс 12 карт үүсгэнэ', () {
    final game = MemoryState(words, random: Random(2));

    expect(game.cards, hasLength(12));
    expect(game.cards.map((card) => card.pairId).toSet(), hasLength(6));
  });

  test('ижил хосыг нээлттэй үлдээнэ', () {
    final game = MemoryState(words, random: Random(3));
    final first = game.cards.first;
    final pair = game.cards.firstWhere(
      (card) => card.pairId == first.pairId && card.id != first.id,
    );

    expect(game.select(first.id), MemoryTurnResult.firstCard);
    expect(game.select(pair.id), MemoryTurnResult.matched);
    expect(game.matchedIds, containsAll([first.id, pair.id]));
  });

  test('өөр хосыг хугацааны дараа хаахад бэлэн болгоно', () {
    final game = MemoryState(words, random: Random(4));
    final first = game.cards.first;
    final other = game.cards.firstWhere((card) => card.pairId != first.pairId);

    game.select(first.id);
    expect(game.select(other.id), MemoryTurnResult.mismatch);
    expect(game.openIds, hasLength(2));
    game.hideMismatch();
    expect(game.openIds, isEmpty);
  });
}
