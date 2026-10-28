import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/charades_models.dart';

class CharadesRepository {
  Future<List<CharadesCard>> load() async => decode(
    await rootBundle.loadString('assets/data/sessiz_sinema_cards.json'),
  );

  static List<CharadesCard> decode(String source) {
    final data = jsonDecode(source);
    if (data is! List || data.isEmpty) {
      throw const FormatException('Kart havuzu boş veya geçersiz.');
    }
    final ids = <String>{}, titles = <String>{};
    final cards = <CharadesCard>[];
    for (final row in data) {
      if (row is! Map<String, dynamic> ||
          row.length != 4 ||
          ![
            'id',
            'title',
            'category',
            'difficulty',
          ].every((key) => row[key] is String)) {
        throw const FormatException('Geçersiz Sessiz Sinema şeması.');
      }
      final card = CharadesCard.fromJson(row);
      if (card.id.trim().isEmpty ||
          card.title.trim().isEmpty ||
          !ids.add(card.id) ||
          !titles.add(turkishKey(card.title)) ||
          !['Film', 'Dizi'].contains(card.category) ||
          !['Kolay', 'Orta', 'Zor'].contains(card.difficulty)) {
        throw FormatException('Geçersiz Sessiz Sinema kartı: ${card.id}');
      }
      cards.add(card);
    }
    return List.unmodifiable(cards);
  }
}

final charadesCardsProvider = FutureProvider<List<CharadesCard>>(
  (ref) => CharadesRepository().load(),
);
