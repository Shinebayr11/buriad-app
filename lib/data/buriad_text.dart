import '../models/word_entry.dart';

const _alphabet = [
  'а',
  'б',
  'в',
  'г',
  'д',
  'е',
  'ё',
  'ж',
  'з',
  'и',
  'й',
  'к',
  'л',
  'м',
  'н',
  'о',
  'ө',
  'п',
  'р',
  'с',
  'т',
  'у',
  'ү',
  'ф',
  'х',
  'һ',
  'ц',
  'ч',
  'ш',
  'щ',
  'ъ',
  'ы',
  'ь',
  'э',
  'ю',
  'я',
];

final _alphabetOrder = {
  for (var index = 0; index < _alphabet.length; index++)
    _alphabet[index]: index,
};

int compareBuriadText(String left, String right) {
  final leftRunes = left.toLowerCase().runes.toList(growable: false);
  final rightRunes = right.toLowerCase().runes.toList(growable: false);
  final commonLength = leftRunes.length < rightRunes.length
      ? leftRunes.length
      : rightRunes.length;
  for (var index = 0; index < commonLength; index++) {
    final leftCharacter = String.fromCharCode(leftRunes[index]);
    final rightCharacter = String.fromCharCode(rightRunes[index]);
    final leftOrder = _alphabetOrder[leftCharacter] ?? 1000 + leftRunes[index];
    final rightOrder =
        _alphabetOrder[rightCharacter] ?? 1000 + rightRunes[index];
    if (leftOrder != rightOrder) return leftOrder.compareTo(rightOrder);
  }
  return leftRunes.length.compareTo(rightRunes.length);
}

List<WordEntry> searchAndSortWords(List<WordEntry> words, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  final result = words.where((word) {
    if (normalizedQuery.isEmpty) return true;
    return word.buriad.toLowerCase().contains(normalizedQuery) ||
        word.mongolian.toLowerCase().contains(normalizedQuery);
  }).toList();
  result.sort((left, right) => compareBuriadText(left.buriad, right.buriad));
  return result;
}
