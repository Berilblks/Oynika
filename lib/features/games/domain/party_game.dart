import 'package:flutter/material.dart';

enum PartyGame {
  taboo(
    title: 'Tabu',
    description: 'Yasaklı kelimelere dikkat!',
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
    description: 'Konuşmadan anlat, takımın bilsin!',
    asset: 'charades',
    background: Color(0xFFE8DDFB),
    accent: Color(0xFF5631B4),
    instructions: [
      'Bir kişi anlatıcı olsun, diğerleri tahmin etsin.',
      'Anlatıcı, kendisine verilen ifadeyi yalnızca hareketlerle anlatsın.',
      'Konuşmadan ve ses çıkarmadan doğru tahmine ulaşmaya çalışın.',
    ],
  ),
  undercover(
    title: 'Aramızdaki Casus',
    description: 'İpuçlarını takip et, casusu bul!',
    asset: 'undercover',
    background: Color(0xFFD9F5E8),
    accent: Color(0xFF137E64),
    instructions: [
      'Oyuncular arasından rastgele casuslar seçilir.',
      'Normal oyuncular aynı gizli kelimeyi görür.',
      'Casuslar kendi rollerini bilir, kelimeyi görmez.',
      'Herkes sırayla tek kelimelik ipucu verir.',
      'Casuslar ipuçlarından kelimeyi anlamaya ve kendilerini gizlemeye çalışır.',
      'Oyuncular gizli oylamayla bir kişiyi elemeye çalışır.',
      'Elenen kişinin rolü hemen açıklanır.',
      'Bütün casuslar elenirse normal oyuncular kazanır.',
      'Kalan casuslar normal oyuncular kadar veya daha fazlaysa casuslar kazanır.',
    ],
  ),
  whoAmI(
    isPlayable: true,
    title: 'Ben Kimim?',
    description: 'Sorular sor, kim olduğunu keşfet!',
    asset: 'who_am_i',
    background: Color(0xFFFFEECA),
    accent: Color(0xFF8D571E),
    instructions: [
      'Telefon alnına yatay tutulur. Hazırım ile kelime ve süre hemen başlar.',
      'Diğer oyuncular ekrandaki kişinin kim olduğunu anlatır.',
      'Doğru cevap +1, Pas 0 puandır. Öne eğ: Doğru; arkaya eğ: Pas. Yeni hareket için telefonu düz konuma getir. Dokunmatik butonlar da kullanılabilir.',
      'Herkes eşit sayıda normal tur oynar. Hedefe erken ulaşan olsa bile mevcut tur sırası tamamlanır.',
      'Tam tur sırası sonunda hedef puana ulaşan en yüksek puanlı oyuncu kazanır.',
      'En yüksek puan eşitse yalnızca eşit oyuncular ek tur oynar; eşitlik çözülene kadar sürer.',
    ],
  );

  const PartyGame({
    this.isPlayable = true,
    required this.title,
    required this.description,
    required this.asset,
    required this.background,
    required this.accent,
    required this.instructions,
  });

  final bool isPlayable;
  final String title;
  final String description;
  final String asset;
  final Color background;
  final Color accent;
  final List<String> instructions;

  static String get slogan => '${values.length} Oyun, Tek Uygulama!';
  static const supportingText = "Arkadaşlarınla eğlence Oynika'da!";
  static String get availabilityMessage {
    final ready = values
        .where((game) => game.isPlayable)
        .map((game) => game.title)
        .join(', ');
    final planned = values
        .where((game) => !game.isPlayable)
        .map((game) => game.title)
        .join(', ');
    return '$ready oynanabilir.${planned.isEmpty ? '' : ' $planned geliştirme aşamasında.'}';
  }

  String get assetPath => 'assets/illustrations/$asset.png';
  String get path => '/games/$asset';

  static PartyGame? fromSlug(String? slug) {
    for (final game in values) {
      if (game.asset == slug) return game;
    }
    return null;
  }
}
