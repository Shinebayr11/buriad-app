import 'dart:math';

import '../models/word_entry.dart';

enum MemoryCardKind { emoji, buriad }

class MemoryGameCard {
  const MemoryGameCard({
    required this.id,
    required this.pairId,
    required this.kind,
    required this.word,
  });

  final int id;
  final int pairId;
  final MemoryCardKind kind;
  final WordEntry word;
}

enum MemoryTurnResult { ignored, firstCard, matched, mismatch }

class MemoryState {
  MemoryState(List<WordEntry> words, {Random? random})
    : _random = random ?? Random(),
      _words = List.of(words) {
    if (hasEnoughWords) _deal();
  }

  static const minimumWords = 6;

  final Random _random;
  final List<WordEntry> _words;
  final List<MemoryGameCard> _cards = [];
  final Set<int> _matchedIds = {};
  final List<int> _openIds = [];
  bool _waiting = false;

  bool get hasEnoughWords => _words.length >= minimumWords;
  List<MemoryGameCard> get cards => List.unmodifiable(_cards);
  Set<int> get matchedIds => Set.unmodifiable(_matchedIds);
  List<int> get openIds => List.unmodifiable(_openIds);
  bool get completed =>
      _cards.isNotEmpty && _matchedIds.length == _cards.length;

  bool isVisible(int id) => _openIds.contains(id) || _matchedIds.contains(id);

  MemoryTurnResult select(int id) {
    if (_waiting || _matchedIds.contains(id) || _openIds.contains(id)) {
      return MemoryTurnResult.ignored;
    }
    final card = _cards.where((item) => item.id == id).firstOrNull;
    if (card == null) return MemoryTurnResult.ignored;
    _openIds.add(id);
    if (_openIds.length == 1) return MemoryTurnResult.firstCard;

    final first = _cards.firstWhere((item) => item.id == _openIds.first);
    if (first.pairId == card.pairId) {
      _matchedIds.addAll(_openIds);
      _openIds.clear();
      return MemoryTurnResult.matched;
    }
    _waiting = true;
    return MemoryTurnResult.mismatch;
  }

  void hideMismatch() {
    if (!_waiting) return;
    _openIds.clear();
    _waiting = false;
  }

  void restart() {
    _matchedIds.clear();
    _openIds.clear();
    _waiting = false;
    if (hasEnoughWords) _deal();
  }

  void _deal() {
    final selected = List<WordEntry>.of(_words)..shuffle(_random);
    _cards.clear();
    var id = 0;
    for (var pair = 0; pair < minimumWords; pair++) {
      final word = selected[pair];
      _cards
        ..add(
          MemoryGameCard(
            id: id++,
            pairId: pair,
            kind: MemoryCardKind.emoji,
            word: word,
          ),
        )
        ..add(
          MemoryGameCard(
            id: id++,
            pairId: pair,
            kind: MemoryCardKind.buriad,
            word: word,
          ),
        );
    }
    _cards.shuffle(_random);
  }
}
