import 'package:flutter/material.dart';

enum PartyGame {
  taboo(
    title: 'Tabu',
    description: 'Kelimeleri anlat,\ntabuları söyleme!',
    asset: 'taboo',
    background: Color(0xFFFFE3DE),
    accent: Color(0xFFB93F51),
    instructions: [
      'Arkadaşlarınla takımlara ayrıl.',
      'Karttaki ana kelimeyi, yasaklı kelimeleri kullanmadan takımına anlat.',
      'Takımın doğru kelimeyi tahmin etmeye çalışsın.',
    ],
  ),
  charades(
    title: 'Sessiz Sinema',
    description: 'Konuşmadan anlat,\ntahmin etmeye çalış!',
    asset: 'charades',
    background: Color(0xFFE8DDFB),
    accent: Color(0xFF5631B4),
    instructions: [
      'Bir kişi anlatıcı olsun, diğerleri tahmin etsin.',
      'Anlatıcı, kendisine verilen ifadeyi yalnızca hareketlerle anlatsın.',
      'Konuşmadan ve ses çıkarmadan doğru tahmine ulaşmaya çalışın.',
    ],
  ),
  whoAmI(
    title: 'Ben Kimim?',
    description: 'Sorular sor,\nkim olduğunu bul!',
    asset: 'who_am_i',
    background: Color(0xFFFFEECA),
    accent: Color(0xFF8D571E),
    instructions: [
      'Her oyuncuya, kendisinin görmediği bir kimlik verilir.',
      'Sırayla evet ya da hayır ile yanıtlanabilen sorular sorun.',
      'Aldığın ipuçlarını birleştirerek kim olduğunu bulmaya çalış.',
    ],
  ),
  fiveSeconds(
    title: '5 Saniyede Söyle!',
    description: 'Süre bitmeden\naklına geleni söyle!',
    asset: 'five_seconds',
    background: Color(0xFFD9F5E8),
    accent: Color(0xFF137E64),
    instructions: [
      'Sıradaki oyuncu kendisine verilen konuyu dinlesin.',
      'Oyuncu, konuya uygun üç yanıtı beş saniye içinde söylesin.',
      'Süre bitince sıra bir sonraki oyuncuya geçsin.',
    ],
  ),
  neverHaveIEver(
    title: 'Ben Hiç...',
    description: 'Eğlenceli sorularla\narkadaşlarını daha iyi tanı!',
    asset: 'never_have_i_ever',
    background: Color(0xFFDCE9FF),
    accent: Color(0xFF2553A5),
    instructions: [
      'Arkadaşlarınla bir çember oluştur.',
      'Sırayla “Ben hiç...” ile başlayan bir ifadeyi okuyun.',
      'Bu deneyimi yaşayanlar el kaldırsın; dilerseniz hikâyelerinizi paylaşın.',
      'Katılmak istemediğin bir soruyu her zaman pas geçebilirsin.',
    ],
  );

  const PartyGame({
    required this.title,
    required this.description,
    required this.asset,
    required this.background,
    required this.accent,
    required this.instructions,
  });

  final String title;
  final String description;
  final String asset;
  final Color background;
  final Color accent;
  final List<String> instructions;

  String get assetPath => 'assets/illustrations/$asset.png';
  String get path => '/games/$asset';

  static PartyGame? fromSlug(String? slug) {
    for (final game in values) {
      if (game.asset == slug) return game;
    }
    return null;
  }
}
