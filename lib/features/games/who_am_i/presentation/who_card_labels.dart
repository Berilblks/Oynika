import '../domain/who_card.dart';

extension WhoCardCategoryLabel on WhoCardCategory {
  String get label => switch (this) {
    WhoCardCategory.turkishMusicians => 'Türk şarkıcı ve müzisyenler',
    WhoCardCategory.turkishActorsAndTv => 'Türk oyuncu ve televizyon ünlüleri',
    WhoCardCategory.foreignCelebrities => 'Yabancı ünlüler',
    WhoCardCategory.athletes => 'Sporcular',
    WhoCardCategory.historicalAndNotable => 'Tarihî veya tanınmış kişiler',
    WhoCardCategory.humanCharacters => 'Tanınmış insan karakterleri',
  };
}

extension WhoCardDifficultyLabel on WhoCardDifficulty {
  String get label => switch (this) {
    WhoCardDifficulty.easy => 'Kolay',
    WhoCardDifficulty.medium => 'Orta',
    WhoCardDifficulty.hard => 'Zor',
  };
}
