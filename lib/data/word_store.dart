import '../models/word_entry.dart';

abstract interface class WordStore {
  Future<WordStoreSnapshot> load();

  Future<void> save(List<WordEntry> words);
}

class WordStoreSnapshot {
  const WordStoreSnapshot({required this.words, this.skipped = 0});

  final List<WordEntry> words;
  final int skipped;
}
