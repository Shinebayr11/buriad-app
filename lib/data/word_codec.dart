import 'dart:convert';

import '../models/word_entry.dart';

class WordDecodeResult {
  const WordDecodeResult({required this.words, required this.skipped});

  final List<WordEntry> words;
  final int skipped;
}

WordDecodeResult decodeWords(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! List) {
    throw const FormatException('Үгийн JSON нь жагсаалт байх ёстой.');
  }

  final words = <WordEntry>[];
  var skipped = 0;
  for (final item in decoded) {
    try {
      if (item is! Map) throw const FormatException();
      words.add(WordEntry.fromJson(Map<String, dynamic>.from(item)));
    } on FormatException {
      skipped++;
    } on TypeError {
      skipped++;
    }
  }
  return WordDecodeResult(words: words, skipped: skipped);
}

String encodeWords(List<WordEntry> words) =>
    const JsonEncoder.withIndent('  ')
        .convert(words.map((word) => word.toJson()).toList(growable: false));
