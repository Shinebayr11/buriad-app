import 'package:buriad_ug/models/word_entry.dart';
import 'package:buriad_ug/state/word_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_word_store.dart';

void main() {
  test('үг нэмэх, засах, устгах төлвийг хадгална', () async {
    final store = FakeWordStore();
    final controller = WordController(store);
    await controller.load();
    const first = WordEntry(buriad: 'ТУРШИЛТ-1', mongolian: 'туршилт 1');
    const updated = WordEntry(buriad: 'ТУРШИЛТ-2', mongolian: 'туршилт 2');

    await controller.add(first);
    await controller.update(first, updated);
    expect(controller.words, [updated]);
    await controller.delete(updated);

    expect(controller.words, isEmpty);
    expect((await store.load()).words, isEmpty);
  });

  test('JSON оруулахдаа буруу бичлэгийн тоог буцаана', () async {
    final controller = WordController(FakeWordStore());
    await controller.load();

    final result = await controller.importJson(
      '[{"b":"ТУРШИЛТ-1","m":"туршилт 1"},{"b":"","m":""}]',
    );

    expect(result.words, hasLength(1));
    expect(result.skipped, 1);
    expect(controller.exportJson(), contains('ТУРШИЛТ-1'));
  });
}
