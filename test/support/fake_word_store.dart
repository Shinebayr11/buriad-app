import 'package:buriad_ug/data/word_store.dart';
import 'package:buriad_ug/models/word_entry.dart';

class FakeWordStore implements WordStore {
  FakeWordStore([List<WordEntry> words = const []]) : _words = [...words];

  List<WordEntry> _words;

  @override
  Future<WordStoreSnapshot> load() async =>
      WordStoreSnapshot(words: [..._words]);

  @override
  Future<void> save(List<WordEntry> words) async {
    _words = [...words];
  }
}
