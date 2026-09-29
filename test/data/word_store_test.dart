import 'dart:convert';

import 'package:buriad_ug/data/shared_preferences_word_store.dart';
import 'package:buriad_ug/models/word_entry.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_word_store.dart';

void main() {
  test('FakeStore үгийн санг санах ойд хадгална', () async {
    final store = FakeWordStore();
    const words = [WordEntry(buriad: 'ТУРШИЛТ-1', mongolian: 'туршилт 1')];

    await store.save(words);
    final snapshot = await store.load();

    expect(snapshot.words, words);
  });

  test('өмнөх хоосон санд жишээ үгийг нэг удаа нэмнэ', () async {
    SharedPreferences.setMockInitialValues({'word_store_v1': '[]'});
    final store = SharedPreferencesWordStore(
      bundle: _StringBundle(
        jsonEncode([
          {'b': 'ТУРШИЛТ-1', 'm': 'туршилт 1'},
        ]),
      ),
    );

    final migrated = await store.load();
    expect(migrated.words, hasLength(1));

    await store.save(const []);
    final afterAdminDelete = await store.load();
    expect(afterAdminDelete.words, isEmpty);
  });

  test('ижил үг байвал админы хадгалсан хувилбарыг хэвээр үлдээнэ', () async {
    SharedPreferences.setMockInitialValues({
      'word_store_v1': jsonEncode([
        {'b': 'ТУРШИЛТ-1', 'm': 'туршилт 1'},
      ]),
    });
    final store = SharedPreferencesWordStore(
      bundle: _StringBundle(
        jsonEncode([
          {'b': 'ТУРШИЛТ-1', 'm': 'туршилт 2'},
        ]),
      ),
    );

    final snapshot = await store.load();

    expect(snapshot.words, hasLength(1));
    expect(snapshot.words.single.mongolian, 'туршилт 1');
  });

  test('өмнөх жишээ үгийн хувилбарт шинэ багцыг нэмнэ', () async {
    SharedPreferences.setMockInitialValues({
      'word_store_v1': '[]',
      'word_seed_version': 1,
    });
    final store = SharedPreferencesWordStore(
      bundle: _StringBundle(
        jsonEncode([
          {'b': 'ТУРШИЛТ-1', 'm': 'туршилт 1'},
        ]),
      ),
    );

    final snapshot = await store.load();

    expect(snapshot.words, hasLength(1));
  });
}

class _StringBundle extends CachingAssetBundle {
  _StringBundle(this.source);

  final String source;

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(source));
    return ByteData.sublistView(bytes);
  }
}
