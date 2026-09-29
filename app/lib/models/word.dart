/// Нэг үгийн бичлэг. Талбарын нэрс words.json-той ижил (b, m, e, n, a) —
/// хожим Supabase руу шилжихэд ч энэ бүтэц хэвээр үлдэнэ.
class Word {
  const Word({
    required this.b,
    required this.m,
    this.e = defaultMark,
    this.n = '',
    this.a = '',
  });

  /// Зураг өгөөгүй үед харуулах тэмдэг.
  static const defaultMark = '◈';

  final String b; // буриад үг
  final String m; // монгол утга
  final String e; // эможи эсвэл зургийн хаяг (http...)
  final String n; // тайлбар — заавал биш
  final String a; // дуудлагын файлын хаяг — заавал биш

  /// Гаднаас ирсэн бичлэгийг апп доторх нэгдсэн хэлбэрт оруулна.
  factory Word.fromJson(Map<String, dynamic> j) {
    final e = _str(j['e']);
    return Word(
      b: _str(j['b']),
      m: _str(j['m']),
      e: e.isEmpty ? defaultMark : e,
      n: _str(j['n']),
      a: _str(j['a']),
    );
  }

  static String _str(Object? v) => (v ?? '').toString().trim();

  Map<String, dynamic> toJson() => {'b': b, 'm': m, 'e': e, 'n': n, 'a': a};

  bool get hasImage => e.startsWith('http');
  bool get hasAudio => a.isNotEmpty;

  /// JSON жагсаалтыг шалгаж уншина. Бичлэг бүрд b ба m хоёулаа байх ёстой —
  /// нэг нь ч дутуу бол бүхэл файлыг хүлээж авахгүй (null).
  static List<Word>? parseList(Object? raw) {
    if (raw is! List) return null;
    final out = <Word>[];
    for (final item in raw) {
      if (item is! Map) return null;
      final w = Word.fromJson(Map<String, dynamic>.from(item));
      if (w.b.isEmpty || w.m.isEmpty) return null;
      out.add(w);
    }
    return out;
  }
}
