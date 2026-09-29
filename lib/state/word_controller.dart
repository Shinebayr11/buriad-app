import 'package:flutter/foundation.dart';

import '../data/buriad_text.dart';
import '../data/word_codec.dart';
import '../data/word_store.dart';
import '../models/word_entry.dart';

class WordController extends ChangeNotifier {
  WordController(this._store);

  final WordStore _store;
  final List<WordEntry> _words = [];
  String _query = '';
  bool _loading = true;
  Object? _error;

  bool get loading => _loading;
  Object? get error => _error;
  List<WordEntry> get words => List.unmodifiable(_words);
  List<WordEntry> get visibleWords => searchAndSortWords(_words, _query);

  Future<int> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final snapshot = await _store.load();
      _words
        ..clear()
        ..addAll(snapshot.words);
      return snapshot.skipped;
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _query = query;
    notifyListeners();
  }

  Future<void> add(WordEntry word) async {
    _words.add(word);
    await _persist();
  }

  Future<void> update(WordEntry previous, WordEntry replacement) async {
    final index = _words.indexOf(previous);
    if (index < 0) return;
    _words[index] = replacement;
    await _persist();
  }

  Future<void> delete(WordEntry word) async {
    _words.remove(word);
    await _persist();
  }

  Future<WordDecodeResult> importJson(String source) async {
    final result = decodeWords(source);
    _words
      ..clear()
      ..addAll(result.words);
    await _persist();
    return result;
  }

  String exportJson() => encodeWords(_words);

  Future<void> _persist() async {
    try {
      await _store.save(_words);
      _error = null;
    } catch (error) {
      _error = error;
      rethrow;
    } finally {
      notifyListeners();
    }
  }
}
