import 'package:buriad_ug/data/word_codec.dart';
import 'package:buriad_ug/models/word_entry.dart';
import 'package:buriad_ug/state/quiz_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('аппын жишээ үгийн сан 30 баталгаатай бичлэгтэй', () async {
    final source = await rootBundle.loadString('assets/data/words.json');
    final result = decodeWords(source);
    final normalizedWords = result.words
        .map((word) => word.buriad.toLowerCase())
        .toSet();

    expect(result.skipped, 0);
    expect(result.words, hasLength(30));
    expect(normalizedWords, hasLength(30));
    expect(
      result.words,
      everyElement(
        isA<WordEntry>()
            .having((word) => word.source, 'эх сурвалж', startsWith('https://'))
            .having(
              (word) => word.verifiedBy,
              'баталгаажуулсан эх сурвалж',
              isNotEmpty,
            ),
      ),
    );

    final quiz = QuizState(result.words);
    expect(quiz.hasEnoughWords, isTrue);
    expect(quiz.question?.choices, hasLength(4));
  });
}
