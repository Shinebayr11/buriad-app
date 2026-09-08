/// Аман зохиолын төрөл.
///
/// stories.json дахь `genre` талбарын утга. Нүүр дэлгэц дээр ангилал болж
/// харагдана.
enum Genre {
  ulger('үлгэр', 'Үлгэр', 'Зохиомол ярианы уламжлал'),
  domog('домог', 'Домог', 'Газар нутаг, өвөг дээдсийн тухай'),
  tuukh('түүх', 'Түүх', 'Болсон явдлын дурсамж'),
  oguulleg('өгүүллэг', 'Өгүүллэг', 'Богино хэмжээний ярианы зохиол');

  const Genre(this.key, this.title, this.hint);

  /// JSON дотор бичигдэх утга.
  final String key;

  /// Дэлгэцэд харагдах нэр.
  final String title;

  /// Ангиллын товч тайлбар.
  final String hint;

  static Genre? parse(String? s) {
    final v = (s ?? '').trim().toLowerCase();
    for (final g in Genre.values) {
      if (g.key == v) return g;
    }
    return null;
  }
}
