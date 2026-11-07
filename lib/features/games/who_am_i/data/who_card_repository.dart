import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/who_card.dart';

class WhoCardRepository {
  const WhoCardRepository();
  static const assetPath = 'assets/data/who_am_i_cards.json';

  Future<List<WhoCard>> load() async =>
      decode(await rootBundle.loadString(assetPath));

  static List<WhoCard> decode(String source) {
    final rows = jsonDecode(source);
    if (rows is! List || rows.isEmpty) {
      throw const FormatException('Ben Kimim? kart havuzu boş veya geçersiz.');
    }
    final ids = <String>{}, names = <String>{};
    final cards = <WhoCard>[];
    for (final row in rows) {
      if (row is! Map<String, dynamic>) {
        throw const FormatException('Geçersiz kart kaydı.');
      }
      final card = WhoCard.fromJson(row);
      if (!ids.add(card.id) || !names.add(whoCardNameKey(card.name))) {
        throw FormatException('Tekrarlanan kart kimliği veya adı: ${card.id}');
      }
      cards.add(card);
    }
    return List.unmodifiable(cards);
  }
}

final whoCardsProvider = FutureProvider<List<WhoCard>>(
  (ref) => const WhoCardRepository().load(),
);
