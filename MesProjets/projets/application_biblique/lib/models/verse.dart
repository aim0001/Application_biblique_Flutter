class Verse {
  final String book;
  final int chapter;
  final int verse;
  final String text;
  final String languageCode;
  Verse({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.languageCode
  });

  // Méthode Factory pour créer un objet Verse à partir de données JSON
  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      book: json['book'],
      chapter: int.parse(json['chapter']),
      verse: int.parse(json['verse']),
      text: json['text'],
      languageCode: json['languageCode'] ?? 'en',
    );
  }
}
