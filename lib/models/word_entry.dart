class WordEntry {
  const WordEntry({
    required this.buriad,
    required this.mongolian,
    this.emoji = '',
    this.note = '',
    this.audioPath = '',
    this.dialect = '',
    this.source = '',
    this.verifiedBy = '',
  });

  final String buriad;
  final String mongolian;
  final String emoji;
  final String note;
  final String audioPath;
  final String dialect;
  final String source;
  final String verifiedBy;

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    String text(String key) {
      final value = json[key];
      if (value == null) return '';
      if (value is! String) {
        throw FormatException('$key талбар тэмдэгт мөр байх ёстой.');
      }
      return value.trim();
    }

    final buriad = text('b');
    final mongolian = text('m');
    if (buriad.isEmpty || mongolian.isEmpty) {
      throw const FormatException('b болон m талбар хоосон байж болохгүй.');
    }

    final dialect = text('dialect');
    const dialects = {'', 'хори', 'ага', 'сартуул'};
    if (!dialects.contains(dialect)) {
      throw const FormatException('dialect талбарын утга буруу байна.');
    }

    return WordEntry(
      buriad: buriad,
      mongolian: mongolian,
      emoji: text('e'),
      note: text('n'),
      audioPath: text('a'),
      dialect: dialect,
      source: text('source'),
      verifiedBy: text('verifiedBy'),
    );
  }

  Map<String, dynamic> toJson() => {
    'b': buriad,
    'm': mongolian,
    'e': emoji,
    'n': note,
    'a': audioPath,
    'dialect': dialect,
    'source': source,
    'verifiedBy': verifiedBy,
  };

  WordEntry copyWith({
    String? buriad,
    String? mongolian,
    String? emoji,
    String? note,
    String? audioPath,
    String? dialect,
    String? source,
    String? verifiedBy,
  }) {
    return WordEntry(
      buriad: buriad ?? this.buriad,
      mongolian: mongolian ?? this.mongolian,
      emoji: emoji ?? this.emoji,
      note: note ?? this.note,
      audioPath: audioPath ?? this.audioPath,
      dialect: dialect ?? this.dialect,
      source: source ?? this.source,
      verifiedBy: verifiedBy ?? this.verifiedBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WordEntry &&
      other.buriad == buriad &&
      other.mongolian == mongolian &&
      other.emoji == emoji &&
      other.note == note &&
      other.audioPath == audioPath &&
      other.dialect == dialect &&
      other.source == source &&
      other.verifiedBy == verifiedBy;

  @override
  int get hashCode => Object.hash(
    buriad,
    mongolian,
    emoji,
    note,
    audioPath,
    dialect,
    source,
    verifiedBy,
  );
}
