import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/tabu_models.dart';

const tabuCategories = [
  'Günlük yaşam',
  'Yemek ve içecek',
  'Spor',
  'Meslekler',
  'Teknoloji',
  'Doğa',
  'Eğlence',
  'Kültür',
  'Seyahat',
  'Nesneler',
];
const tabuDifficulties = ['Kolay', 'Orta', 'Zor'];

class CardRepository {
  Future<List<TabuCard>> load() async =>
      decode(await rootBundle.loadString('assets/data/tabu_cards.json'));

  static List<TabuCard> decode(String source) {
    final rows = jsonDecode(source) as List<dynamic>;
    final cards =
        rows
            .map((row) => TabuCard.fromJson(row as Map<String, dynamic>))
            .toList();
    final ids = <String>{}, words = <String>{};
    for (final card in cards) {
      final forbidden = card.forbidden.map(turkishKey).toSet();
      if (card.id.isEmpty ||
          !ids.add(card.id) ||
          card.word.trim().isEmpty ||
          !words.add(turkishKey(card.word)) ||
          card.forbidden.length != 5 ||
          forbidden.length != 5 ||
          forbidden.contains('') ||
          forbidden.contains(turkishKey(card.word)) ||
          !tabuCategories.contains(card.category) ||
          !tabuDifficulties.contains(card.difficulty)) {
        throw FormatException('Geçersiz Tabu kartı: ${card.id}');
      }
    }
    if (cards.isEmpty) throw const FormatException('Kart havuzu boş.');
    return List.unmodifiable(cards);
  }
}

final tabuCardsProvider = FutureProvider<List<TabuCard>>(
  (ref) => CardRepository().load(),
);
