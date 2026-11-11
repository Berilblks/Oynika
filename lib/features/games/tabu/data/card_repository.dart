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
  'Yiyecek ve içecek',
  'Hayvanlar ve doğa',
  'Türkiye ve kültür',
  'Spor ve eğlence',
  'Duygular ve ilişkiler',
  'Seyahat ve mekânlar',
  'Deyimler ve popüler ifadeler',
];
const tabuDifficulties = ['Kolay', 'Orta', 'Zor'];

// Compare punctuation, spacing, Turkish letters and common accent variants
// without changing the team-name normalization used by the games.
String tabuWordKey(String value) {
  var key = turkishKey(value);
  for (final entry in const {
    'ç': 'c',
    'ğ': 'g',
    'ı': 'i',
    'ö': 'o',
    'ş': 's',
    'ü': 'u',
    'â': 'a',
    'î': 'i',
    'û': 'u',
    '\u0307': '',
  }.entries) {
    key = key.replaceAll(entry.key, entry.value);
  }
  return key.replaceAll(RegExp(r'[^a-z0-9]'), '');
}

class CardRepository {
  Future<List<TabuCard>> load() async =>
      decode(await rootBundle.loadString('assets/data/tabu_cards.json'));

  static List<TabuCard> decode(String source) {
    final rows = jsonDecode(source) as List<dynamic>;
    final cards = rows
        .map((row) => TabuCard.fromJson(row as Map<String, dynamic>))
        .toList();
    final ids = <String>{}, words = <String>{};
    for (final card in cards) {
      final forbidden = card.forbidden.map(tabuWordKey).toSet();
      if (card.id.isEmpty ||
          !ids.add(card.id) ||
          tabuWordKey(card.word).isEmpty ||
          !words.add(tabuWordKey(card.word)) ||
          card.forbidden.length != 5 ||
          forbidden.length != 5 ||
          forbidden.contains('') ||
          forbidden.contains(tabuWordKey(card.word)) ||
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
