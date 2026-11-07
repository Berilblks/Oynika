enum WhoCardCategory {
  turkishMusicians,
  turkishActorsAndTv,
  foreignCelebrities,
  athletes,
  historicalAndNotable,
  humanCharacters,
}

enum WhoCardDifficulty { easy, medium, hard }

String whoCardNameKey(String name) => name
    .trim()
    .replaceAll('I', 'ı')
    .replaceAll('İ', 'i')
    .toLowerCase()
    .replaceAll(RegExp(r"[\s'’.,!?-]+"), '');

class WhoCard {
  const WhoCard({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
  });
  final String id;
  final String name;
  final WhoCardCategory category;
  final WhoCardDifficulty difficulty;

  factory WhoCard.fromJson(Map<String, dynamic> json) {
    const keys = ['id', 'name', 'category', 'difficulty'];
    if (json.length != keys.length ||
        !keys.every((key) => json[key] is String)) {
      throw const FormatException('Geçersiz Ben Kimim? kart şeması.');
    }
    final id = json['id'] as String;
    final name = json['name'] as String;
    if (!RegExp(r'^who-\d{3}$').hasMatch(id) ||
        name.trim().isEmpty ||
        name != name.trim() ||
        name.contains(RegExp(r'\s{2,}|[\x00-\x1F\x7F]'))) {
      throw FormatException('Geçersiz Ben Kimim? kartı: $id');
    }
    try {
      return WhoCard(
        id: id,
        name: name,
        category: WhoCardCategory.values.byName(json['category'] as String),
        difficulty: WhoCardDifficulty.values.byName(
          json['difficulty'] as String,
        ),
      );
    } on ArgumentError {
      throw FormatException('Geçersiz kategori veya zorluk: $id');
    }
  }
}
