import 'package:buriad_app/data/word_store.dart';
import 'package:buriad_app/models/word.dart';
import 'package:buriad_app/state/game_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_store.dart';

/// Тестэд зориулсан сан — багцын asset болон төхөөрөмжийн хадгалалтад хүрэхгүй.
class _FakeStore implements WordStore {
  _FakeStore(this.bundled);

  final List<Word> bundled;
  List<Word>? saved;
  int saveCount = 0;

  @override
  Future<List<Word>> loadBundled() async => bundled;

  @override
  Future<List<Word>?> loadSaved() async => saved;

  @override
  Future<void> save(List<Word> words) async {
    saved = words;
    saveCount++;
  }

  @override
  Future<void> clearSaved() async => saved = null;
}

List<Word> _words(int n) =>
    [for (var i = 0; i < n; i++) Word(b: 'б$i', m: 'м$i', e: '$i')];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('хадгалсан сан байвал багцынхыг дарж ирнэ', () async {
    final store = _FakeStore(_words(5))..saved = _words(7);
    final s = GameState(store, stories: FakeStoryStore());
    await s.init();
    expect(s.load, LoadState.ready);
    expect(s.words, hasLength(7));
  });

  test('хадгалсан сан байхгүй бол багцынхыг уншина', () async {
    final s = GameState(_FakeStore(_words(5)), stories: FakeStoryStore());
    await s.init();
    expect(s.words, hasLength(5));
    expect(s.q, isNotNull);
  });

  test('4-өөс цөөн үгтэй бол асуулт үүсэхгүй', () async {
    final s = GameState(_FakeStore(_words(3)), stories: FakeStoryStore());
    await s.init();
    expect(s.canGuess, isFalse);
    expect(s.q, isNull);
    expect(s.canPair, isTrue); // хос олоход 3 хангалттай
  });

  test('асуулт үргэлж 4 сонголттой бөгөөд зөв хариулт нь дотор нь байна', () async {
    final s = GameState(_FakeStore(_words(10)), stories: FakeStoryStore());
    await s.init();
    for (var i = 0; i < 30; i++) {
      final q = s.q!;
      expect(q.opts, hasLength(4));
      expect(q.opts.where((o) => identical(o, q.right)), hasLength(1));
      expect(q.opts.toSet(), hasLength(4), reason: 'сонголт давхардах ёсгүй');
      s.newQuestion();
    }
  });

  test('зөв хариулт 10 оноо нэмнэ, буруу нэмэхгүй', () async {
    final s = GameState(_FakeStore(_words(6)), stories: FakeStoryStore());
    await s.init();

    s.answer(s.q!.right);
    expect(s.score, 10);
    expect(s.lastCorrect, isTrue);
    expect(s.streak, [true]);

    s.newQuestion();
    final wrong = s.q!.opts.firstWhere((o) => !identical(o, s.q!.right));
    s.answer(wrong);
    expect(s.score, 10);
    expect(s.lastCorrect, isFalse);
    expect(s.streak, [true, false]);
  });

  test('хариулсны дараа хоёр дахь хариулт тоологдохгүй', () async {
    final s = GameState(_FakeStore(_words(6)), stories: FakeStoryStore());
    await s.init();
    s.answer(s.q!.right);
    s.answer(s.q!.opts.firstWhere((o) => !identical(o, s.q!.right)));
    expect(s.score, 10);
    expect(s.streak, hasLength(1));
  });

  test('10 асуултын дараа бөгж болон оноо тэглэгдэнэ', () async {
    final s = GameState(_FakeStore(_words(6)), stories: FakeStoryStore());
    await s.init();
    for (var i = 0; i < GameState.round; i++) {
      s.answer(s.q!.right);
      s.newQuestion();
    }
    expect(s.streak, isEmpty);
    expect(s.score, 0);
    expect(s.ringDone, isTrue);

    s.answer(s.q!.right);
    s.newQuestion();
    expect(s.ringDone, isFalse);
    expect(s.streak, hasLength(1));
  });

  test('карт зөвхөн хариулсны дараа эргэнэ', () async {
    final s = GameState(_FakeStore(_words(6)), stories: FakeStoryStore());
    await s.init();
    s.toggleFlip();
    expect(s.flipped, isFalse);
    s.answer(s.q!.right);
    s.toggleFlip();
    expect(s.flipped, isTrue);
  });

  test('үг нэмэх, устгах бүрд төхөөрөмж дээр хадгална', () async {
    final store = _FakeStore(_words(5));
    final s = GameState(store, stories: FakeStoryStore());
    await s.init();

    await s.addWord(const Word(b: 'шинэ', m: 'new'));
    expect(s.words, hasLength(6));
    expect(store.saved, hasLength(6));

    await s.removeAt(0);
    expect(s.words, hasLength(5));
    expect(store.saveCount, 2);
  });

  test('3 үгээс 4 болоход асуулт өөрөө үүснэ', () async {
    final s = GameState(_FakeStore(_words(3)), stories: FakeStoryStore());
    await s.init();
    expect(s.q, isNull);
    await s.addWord(const Word(b: 'дөрөв', m: '4'));
    expect(s.q, isNotNull);
  });

  test('анхны санг сэргээхэд хадгалсан нь устана', () async {
    final store = _FakeStore(_words(5))..saved = _words(9);
    final s = GameState(store, stories: FakeStoryStore());
    await s.init();
    expect(s.words, hasLength(9));

    await s.resetToBundled();
    expect(s.words, hasLength(5));
    expect(store.saved, isNull);
  });

  test('хос олоход хамгийн ихдээ 6 үг сонгоно', () async {
    final s = GameState(_FakeStore(_words(20)), stories: FakeStoryStore());
    await s.init();
    expect(s.pickForPairs(), hasLength(6));

    final few = GameState(_FakeStore(_words(4)), stories: FakeStoryStore());
    await few.init();
    expect(few.pickForPairs(), hasLength(4));
  });

  test('асуултын чиглэл хоёр тал руу эргэнэ', () async {
    final s = GameState(_FakeStore(_words(10)), stories: FakeStoryStore());
    await s.init();
    final dirs = <bool>{};
    for (var i = 0; i < 60; i++) {
      dirs.add(s.q!.toBuriad);
      s.newQuestion();
    }
    expect(dirs, hasLength(2), reason: 'монгол→буриад ба буриад→монгол хоёулаа гарна');
  });

  test('чиглэлээс хамааран асуулт, хариулт солигдоно', () {
    const right = Word(b: 'уһан', m: 'ус');
    final toB = Question(right: right, toBuriad: true, opts: const [right]);
    expect(toB.promptLabel, 'Монголоор');
    expect(toB.promptText, 'ус');
    expect(toB.optionText(right), 'уһан');
    expect(toB.backWord, 'уһан');

    final toM = Question(right: right, toBuriad: false, opts: const [right]);
    expect(toM.promptLabel, 'Буриадаар');
    expect(toM.promptText, 'уһан');
    expect(toM.optionText(right), 'ус');
    expect(toM.backWord, 'ус');
  });
}
