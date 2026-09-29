import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/word_entry.dart';
import 'word_codec.dart';
import 'word_store.dart';

class SharedPreferencesWordStore implements WordStore {
  SharedPreferencesWordStore({AssetBundle? bundle})
    : bundle = bundle ?? rootBundle;

  static const _storageKey = 'word_store_v1';
  final AssetBundle bundle;

  @override
  Future<WordStoreSnapshot> load() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_storageKey);
    final source = saved ?? await bundle.loadString('assets/data/words.json');
    final result = decodeWords(source);
    return WordStoreSnapshot(words: result.words, skipped: result.skipped);
  }

  @override
  Future<void> save(List<WordEntry> words) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_storageKey, encodeWords(words));
    if (!saved) {
      throw StateError('Үгийн санг төхөөрөмжид хадгалж чадсангүй.');
    }
  }
}
