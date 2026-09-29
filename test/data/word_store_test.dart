import 'package:buriad_ug/models/word_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_word_store.dart';

void main() {
  test('FakeStore үгийн санг санах ойд хадгална', () async {
    final store = FakeWordStore();
    const words = [WordEntry(buriad: 'ТУРШИЛТ-1', mongolian: 'туршилт 1')];

    await store.save(words);
    final snapshot = await store.load();

    expect(snapshot.words, words);
  });
}
