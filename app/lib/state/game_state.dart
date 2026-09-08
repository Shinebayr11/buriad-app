import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/word_store.dart';
import '../models/word.dart';

/// Тааварлах тоглоомын нэг асуулт.
class Question {
  Question({required this.right, required this.toBuriad, required this.opts});

  final Word right;

  /// true — монгол үг харуулж буриадаар нь асууна; false — эсрэгээр.
  final bool toBuriad;
  final List<Word> opts;

  String get promptLabel => toBuriad ? 'Монголоор' : 'Буриадаар';
  String get promptText => toBuriad ? right.m : right.b;
  String get backLabel => toBuriad ? 'Буриад утга' : 'Монгол утга';
  String get backWord => toBuriad ? right.b : right.m;
  String get backSub => toBuriad ? right.m : right.b;
  String optionText(Word w) => toBuriad ? w.b : w.m;
}

enum LoadState { loading, ready, failed }

/// Аппын нэгдсэн төлөв: үгийн сан, оноо, ёохор бөгжийн давталт, одоогийн асуулт.
class GameState extends ChangeNotifier {
  /// [random]-ыг зөвхөн тест дамжуулна — үрийг тогтоовол асуулт давтагдана.
  GameState(this._store, {Random? random}) : _rng = random ?? Random();

  final WordStore _store;
  final Random _rng;

  /// Нэг ёохор бөгж = 10 асуулт.
  static const round = 10;
  static const minForGuess = 4;
  static const minForPairs = 3;

  LoadState load = LoadState.loading;
  List<Word> words = const [];

  int score = 0;
  List<bool> streak = const [];
  Question? q;

  /// Хариулсны дараа сонголт түгжигдэж, карт эргүүлэх боломжтой болно.
  bool locked = false;
  bool flipped = false;
  Word? chosen;

  /// Бөгж дүүрч шинэ давталт эхэлсэн мөчид true — анимаци тоглуулахад.
  bool ringDone = false;

  Future<void> init() async {
    try {
      words = await _store.loadSaved() ?? await _store.loadBundled();
      load = LoadState.ready;
      _nextQuestion();
    } catch (_) {
      load = LoadState.failed;
    }
    notifyListeners();
  }

  List<T> _shuffled<T>(Iterable<T> l) => List<T>.of(l)..shuffle(_rng);

  bool get canGuess => words.length >= minForGuess;
  bool get canPair => words.length >= minForPairs;
  bool get lastCorrect => chosen != null && identical(chosen, q?.right);

  void newQuestion() {
    _nextQuestion();
    notifyListeners();
  }

  void _nextQuestion() {
    if (!canGuess) {
      q = null;
      return;
    }
    if (streak.length >= round) {
      streak = const [];
      score = 0;
      ringDone = true;
    } else {
      ringDone = false;
    }
    locked = false;
    flipped = false;
    chosen = null;

    final pool = _shuffled(words);
    final right = pool[0];
    final toBuriad = _rng.nextDouble() < .45; // чиглэлээ солино
    q = Question(
      right: right,
      toBuriad: toBuriad,
      opts: _shuffled([right, ...pool.sublist(1, 4)]),
    );
  }

  void answer(Word w) {
    if (locked || q == null) return;
    locked = true;
    chosen = w;
    final ok = identical(w, q!.right);
    if (ok) score += 10;
    streak = [...streak, ok];
    notifyListeners();
  }

  void toggleFlip() {
    if (!locked) return;
    flipped = !flipped;
    notifyListeners();
  }

  /// Хос олох тоглоомд зориулж санамсаргүй 6 үг сонгоно.
  List<Word> pickForPairs() => _shuffled(words).take(6).toList();

  // ---------- үгийн сан ----------

  Future<void> addWord(Word w) => _update([...words, w]);

  Future<void> removeAt(int i) => _update([...words]..removeAt(i));

  /// JSON-оос оруулсан бүхэл саныг солино.
  Future<void> replaceAll(List<Word> list) async {
    await _update(list);
    newQuestion();
  }

  Future<void> resetToBundled() async {
    await _store.clearSaved();
    words = await _store.loadBundled();
    newQuestion();
  }

  Future<void> _update(List<Word> next) async {
    words = next;
    if (q == null && canGuess) _nextQuestion();
    notifyListeners();
    await _store.save(words);
  }
}
