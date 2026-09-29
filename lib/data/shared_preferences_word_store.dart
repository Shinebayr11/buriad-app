import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/word_entry.dart';
import 'word_codec.dart';
import 'word_store.dart';

class SharedPreferencesWordStore implements WordStore {
  SharedPreferencesWordStore({AssetBundle? bundle})
    : bundle = bundle ?? rootBundle;

  static const _storageKey = 'word_store_v1';
  static const _seedVersionKey = 'word_seed_version';
  static const _currentSeedVersion = 1;
  final AssetBundle bundle;

  @override
  Future<WordStoreSnapshot> load() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_storageKey);
    final bundled = decodeWords(
      await bundle.loadString('assets/data/words.json'),
    );

    if (saved == null) {
      await preferences.setInt(_seedVersionKey, _currentSeedVersion);
      return WordStoreSnapshot(words: bundled.words, skipped: bundled.skipped);
    }

    final stored = decodeWords(saved);
    final seedVersion = preferences.getInt(_seedVersionKey) ?? 0;
    if (seedVersion >= _currentSeedVersion) {
      return WordStoreSnapshot(words: stored.words, skipped: stored.skipped);
    }

    final words = _mergeSeedWords(bundled.words, stored.words);
    final didSave = await preferences.setString(
      _storageKey,
      encodeWords(words),
    );
    final didSaveVersion = await preferences.setInt(
      _seedVersionKey,
      _currentSeedVersion,
    );
    if (!didSave || !didSaveVersion) {
      throw StateError('Жишээ үгсийг төхөөрөмжид хадгалж чадсангүй.');
    }
    return WordStoreSnapshot(
      words: words,
      skipped: bundled.skipped + stored.skipped,
    );
  }

  @override
  Future<void> save(List<WordEntry> words) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_storageKey, encodeWords(words));
    if (!saved) {
      throw StateError('Үгийн санг төхөөрөмжид хадгалж чадсангүй.');
    }
  }

  List<WordEntry> _mergeSeedWords(
    List<WordEntry> bundled,
    List<WordEntry> stored,
  ) {
    final storedWords = {
      for (final word in stored) word.buriad.trim().toLowerCase(),
    };
    return [
      ...stored,
      for (final word in bundled)
        if (!storedWords.contains(word.buriad.trim().toLowerCase())) word,
    ];
  }
}
