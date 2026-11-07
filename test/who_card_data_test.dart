import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oynika/features/games/who_am_i/data/who_card_repository.dart';
import 'package:oynika/features/games/who_am_i/domain/who_card.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_card_labels.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final source = File(WhoCardRepository.assetPath).readAsStringSync();
  final cards = WhoCardRepository.decode(source);
  test(
    'Tam 300 kart, sabit ID–isim eşleşmeleri ve kısa temiz Türkçe adlar',
    () {
      expect(cards, hasLength(300));
      expect(cards.map((c) => c.id).toSet(), hasLength(300));
      expect(cards.map((c) => whoCardNameKey(c.name)).toSet(), hasLength(300));
      final identities =
          jsonDecode(
                File(
                  'test/fixtures/who_phase64_card_identities.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect({for (final card in cards) card.id: card.name}, identities);
      for (final card in cards) {
        expect(card.name, isNotEmpty);
        expect(card.name, card.name.trim());
        expect(card.name.length, lessThanOrEqualTo(30));
        expect(
          card.name.contains(
            RegExp(r'[\x00-\x1F\x7F\u200B-\u200F\u202A-\u202E\uFEFF\uFFFD]'),
          ),
          isFalse,
        );
        expect(card.category.label, isNotEmpty);
        expect(card.difficulty.label, isNotEmpty);
      }
      expect(() => cards.clear(), throwsUnsupportedError);
    },
  );
  test('Kategori sayıları 75/65/65/40/25/30', () {
    expect(
      {
        for (final category in WhoCardCategory.values)
          category: cards.where((c) => c.category == category).length,
      },
      {
        WhoCardCategory.turkishMusicians: 75,
        WhoCardCategory.turkishActorsAndTv: 65,
        WhoCardCategory.foreignCelebrities: 65,
        WhoCardCategory.athletes: 40,
        WhoCardCategory.historicalAndNotable: 25,
        WhoCardCategory.humanCharacters: 30,
      },
    );
  });
  test('Zorluk dağılımı ve Türkçe sunum etiketleri', () {
    expect(
      cards.where((c) => c.difficulty == WhoCardDifficulty.easy),
      hasLength(240),
    );
    expect(
      cards.where((c) => c.difficulty == WhoCardDifficulty.medium),
      hasLength(60),
    );
    expect(
      cards.where((c) => c.difficulty == WhoCardDifficulty.hard),
      hasLength(0),
    );
    expect(WhoCardDifficulty.values.map((d) => d.label), [
      'Kolay',
      'Orta',
      'Zor',
    ]);
  });
  test('Yerel asset Riverpod deposundan internetsiz yüklenir', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final local = await container.read(whoCardsProvider.future);
    expect(local.map((c) => c.id), cards.map((c) => c.id));
    expect(local.map((c) => c.name), cards.map((c) => c.name));
  });
  final valid = {
    'id': 'who-001',
    'name': 'Örnek',
    'category': 'turkishMusicians',
    'difficulty': 'easy',
  };
  final badSources = <Object?>[
    null,
    {},
    [],
    [3],
    [
      {...valid, 'extra': 'x'},
    ],
    [
      {...valid}..remove('difficulty'),
    ],
    [
      {...valid, 'id': 4},
    ],
    [
      {...valid, 'id': 'unknown'},
    ],
    [
      {...valid, 'name': ''},
    ],
    [
      {...valid, 'name': ' Örnek'},
    ],
    [
      {...valid, 'name': 'İki  Boşluk'},
    ],
    [
      {...valid, 'name': 'Satır\nSonu'},
    ],
    [
      {...valid, 'category': 'other'},
    ],
    [
      {...valid, 'difficulty': 'Kolay'},
    ],
    [
      valid,
      {...valid, 'name': 'Farklı'},
    ],
    [
      valid,
      {...valid, 'id': 'who-002', 'name': ' örnek '},
    ],
    [
      {...valid, 'name': 'Kutup Ayısı'},
      {...valid, 'id': 'who-002', 'name': 'KUTUP AYISI'},
    ],
    [
      {...valid, 'name': 'Mickey Mouse'},
      {...valid, 'id': 'who-002', 'name': 'Mickey-Mouse'},
    ],
  ];
  for (final (i, bad) in badSources.indexed) {
    test(
      'Geçersiz şema, enum veya tekrar reddedilir: $i',
      () => expect(
        () => WhoCardRepository.decode(jsonEncode(bad)),
        throwsFormatException,
      ),
    );
  }
  test(
    'Bozuk JSON reddedilir',
    () => expect(() => WhoCardRepository.decode('{'), throwsFormatException),
  );
  test('Yaygın alternatif adlar ayrı kart olarak çoğaltılmaz', () {
    const groups = [
      ['Mustafa Kemal Atatürk', 'Atatürk'],
      ['Âşık Veysel', 'Veysel Şatıroğlu'],
      ['Muhammed Ali', 'Muhammad Ali', 'Cassius Clay'],
      ['Charlie Chaplin', 'Charles Chaplin'],
      ['Mabel Matiz', 'Fatih Karaca'],
      ['Gökhan Özoğuz', 'Athena Gökhan'],
      ['İnek Şaban', 'Şaban'],
    ];
    for (final aliases in groups) {
      final keys = aliases.map(whoCardNameKey).toSet();
      expect(
        cards.where((card) => keys.contains(whoCardNameKey(card.name))),
        hasLength(1),
        reason: aliases.join(' / '),
      );
    }
  });
  test('Eski insan dışı kategoriler ve eski hayvan/nesne/meslek adları yok', () {
    final rows = jsonDecode(source) as List;
    const excludedCategories = {
      'celebrities',
      'fictionalCharacters',
      'animals',
      'professions',
      'objects',
      'funConcepts',
    };
    for (final row in rows) {
      expect(excludedCategories, isNot(contains(row['category'])));
    }
    const excludedNames = {
      'Kedi',
      'Köpek',
      'İnek',
      'Fil',
      'Aslan',
      'Penguen',
      'Öğretmen',
      'Doktor',
      'Astronot',
      'Bilgisayar',
      'Telefon',
      'Kalem',
      'Şemsiye',
      'Shrek',
      'Mickey Mouse',
      'Pinokyo',
      'Şimşek McQueen',
      'Çizmeli Kedi',
      'SüngerBob',
    };
    expect(cards.where((c) => excludedNames.contains(c.name)), isEmpty);
    // Secondary normalisation also catches accents/punctuation/transliteration.
    String identity(String s) => whoCardNameKey(s)
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('é', 'e')
        .replaceAll('â', 'a');
    expect(cards.map((c) => identity(c.name)).toSet(), hasLength(300));
  });
}
