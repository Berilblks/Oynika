import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/features/games/tabu/application/game_controller.dart';
import 'package:oynika/features/games/tabu/data/card_repository.dart';
import 'package:oynika/features/games/tabu/domain/tabu_models.dart';

void main() {
  final source = File('assets/data/tabu_cards.json').readAsStringSync();
  final rows = (jsonDecode(source) as List).cast<Map<String, dynamic>>();
  final cards = CardRepository.decode(source);
  final original =
      jsonDecode(
            File('test/fixtures/tabu_cards_phase3.json').readAsStringSync(),
          )
          as List;
  final added = cards.skip(250).take(250).toList();
  final expansion = cards.skip(500).toList();
  const expansionCounts = {
    'Günlük yaşam': 90,
    'Yiyecek ve içecek': 60,
    'Meslekler': 40,
    'Hayvanlar ve doğa': 50,
    'Türkiye ve kültür': 50,
    'Teknoloji': 40,
    'Spor ve eğlence': 40,
    'Duygular ve ilişkiler': 50,
    'Seyahat ve mekânlar': 40,
    'Deyimler ve popüler ifadeler': 40,
  };
  final legacyCategories = original
      .map((row) => (row as Map)['category'] as String)
      .toSet();

  test('İlk 250 kartın sırası ve bütün alanları Faz 3 ile aynı kalır', () {
    expect(original, hasLength(250));
    expect(rows.take(250).toList(), original);
    expect(added, hasLength(250));
    expect(cards, hasLength(1000));
  });

  test('1000 kart mevcut şemaya ve sıralı benzersiz ID biçimine uyar', () {
    const keys = {'id', 'word', 'forbidden', 'category', 'difficulty'};
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      expect(row.keys.toSet(), keys, reason: 'Kart $i');
      for (final key in ['id', 'word', 'category', 'difficulty']) {
        expect(row[key], isA<String>(), reason: 'Kart $i: $key');
      }
      expect(row['forbidden'], isA<List>());
      expect(
        (row['forbidden'] as List).every((word) => word is String),
        isTrue,
      );
      expect(cards[i].id, 'tabu-${(i + 1).toString().padLeft(3, '0')}');
    }
    expect(cards.map((card) => card.id).toSet(), hasLength(1000));
  });

  test('Hedefler Türkçe büyük/küçük harf normalleştirmesiyle benzersizdir', () {
    expect(turkishKey(' İSTANBUL '), turkishKey('istanbul'));
    expect(turkishKey('IŞIK'), turkishKey('ışık'));
    expect(cards.map((card) => turkishKey(card.word)).toSet(), hasLength(1000));
  });

  test('Her kartta tam beş dolu farklı yasaklı vardır ve hedef bulunmaz', () {
    for (final card in cards) {
      final forbidden = card.forbidden.map(tabuWordKey).toList();
      expect(forbidden, hasLength(5), reason: card.id);
      expect(
        forbidden.every((word) => word.isNotEmpty),
        isTrue,
        reason: card.id,
      );
      expect(forbidden.toSet(), hasLength(5), reason: card.id);
      expect(
        forbidden,
        isNot(contains(tabuWordKey(card.word))),
        reason: card.id,
      );
    }
  });

  test('İlk 500 kartta eski kategori ve 300/160/40 dağılımı korunur', () {
    expect(
      cards.take(500).map((card) => card.category).toSet(),
      legacyCategories,
    );
    expect(
      cards.map((card) => card.difficulty).toSet(),
      tabuDifficulties.toSet(),
    );
    for (final category in legacyCategories) {
      final group = cards
          .take(500)
          .where((card) => card.category == category)
          .toList();
      expect(group, hasLength(50), reason: category);
      for (final entry in {'Kolay': 30, 'Orta': 16, 'Zor': 4}.entries) {
        expect(
          group.where((card) => card.difficulty == entry.key),
          hasLength(entry.value),
          reason: '$category/${entry.key}',
        );
      }
    }
    for (final entry in {'Kolay': 300, 'Orta': 160, 'Zor': 40}.entries) {
      expect(
        cards.take(500).where((card) => card.difficulty == entry.key),
        hasLength(entry.value),
      );
    }
  });

  test(
    'Faz 3.1 kartlarında kategori başına 25 ve 15/8/2 zorluk dağılımı vardır',
    () {
      for (final category in legacyCategories) {
        final group = added.where((card) => card.category == category).toList();
        expect(group, hasLength(25), reason: category);
        for (final entry in {'Kolay': 15, 'Orta': 8, 'Zor': 2}.entries) {
          expect(
            group.where((card) => card.difficulty == entry.key),
            hasLength(entry.value),
            reason: '$category/${entry.key}',
          );
        }
      }
    },
  );

  test(
    'Eski 500 kart yalnızca doğrulanmış Ön yargı yazım düzeltmesiyle korunur',
    () {
      final legacy =
          (jsonDecode(
                    File(
                      'test/fixtures/tabu_cards_500.json',
                    ).readAsStringSync(),
                  )
                  as List)
              .cast<Map<String, dynamic>>();
      expect(legacy, hasLength(500));
      expect(legacy[274]['word'], 'Önyargı');
      legacy[274]['word'] = 'Ön yargı';
      expect(rows.take(500).toList(), legacy);
      expect(expansion, hasLength(500));
    },
  );

  test(
    'Yeni 500 kartın on kategori kotası ve 200/225/75 dağılımı doğrudur',
    () {
      expect(
        expansion.map((card) => card.category).toSet(),
        expansionCounts.keys.toSet(),
      );
      for (final entry in expansionCounts.entries) {
        expect(
          expansion.where((card) => card.category == entry.key),
          hasLength(entry.value),
          reason: entry.key,
        );
      }
      for (final entry in {'Kolay': 200, 'Orta': 225, 'Zor': 75}.entries) {
        expect(
          expansion.where((card) => card.difficulty == entry.key),
          hasLength(entry.value),
          reason: entry.key,
        );
      }
      expect(
        cards.map((card) => card.category).toSet(),
        tabuCategories.toSet(),
      );
      expect(tabuCategories, hasLength(17));
    },
  );

  test(
    'Türkçe harf, boşluk, noktalama ve düzeltme işareti farkları tekrar oluşturmaz',
    () {
      expect(tabuWordKey('İŞ GÖRÜŞMESİ!'), tabuWordKey('is-gorusmesi'));
      expect(tabuWordKey('Öz güven'), tabuWordKey('Özgüven'));
      expect(tabuWordKey('KÂĞIT'), tabuWordKey('kagit'));
      expect(
        cards.map((card) => tabuWordKey(card.word)).toSet(),
        hasLength(1000),
      );
      final first = Map<String, dynamic>.from(rows.first);
      for (final variant in ['KAHVALTI', 'kahvalti!', 'Kah-val-tı']) {
        final duplicate = {...first, 'id': 'duplicate', 'word': variant};
        expect(
          () => CardRepository.decode(jsonEncode([first, duplicate])),
          throwsFormatException,
        );
      }
    },
  );

  test(
    'Yeni hedefler kendi basit çekimli biçimlerini yasaklı olarak içermez',
    () {
      const suffixes = [
        'ı',
        'i',
        'u',
        'ü',
        'a',
        'e',
        'da',
        'de',
        'ta',
        'te',
        'dan',
        'den',
        'tan',
        'ten',
        'lar',
        'ler',
        'ın',
        'in',
        'un',
        'ün',
        'nın',
        'nin',
        'nun',
        'nün',
        'sı',
        'si',
        'su',
        'sü',
        'yı',
        'yi',
        'yu',
        'yü',
        'ya',
        'ye',
        'ları',
        'leri',
      ];
      for (final card in expansion) {
        final target = turkishKey(card.word);
        final stems = <String>{target};
        const softening = {'p': 'b', 'ç': 'c', 't': 'd', 'k': 'ğ'};
        if (softening.containsKey(target[target.length - 1])) {
          stems.add(
            target.substring(0, target.length - 1) +
                softening[target[target.length - 1]]!,
          );
        }
        final forms = <String>{
          target,
          for (final stem in stems)
            for (final suffix in suffixes) stem + suffix,
        };
        for (final forbidden in card.forbidden) {
          expect(
            forms,
            isNot(contains(turkishKey(forbidden))),
            reason: '${card.id}: ${card.word}/$forbidden',
          );
        }
      }
    },
  );

  test(
    'İncelenen eş anlamlı ve yabancı ad alternatifleri ayrı hedefler değildir',
    () {
      final targets = cards.map((card) => tabuWordKey(card.word)).toSet();
      for (final aliases in [
        ['Volkan', 'Yanardağ'],
        ['Valiz', 'Bavul'],
        ['Nehir', 'Irmak'],
        ['Sahil', 'Kıyı'],
        ['Şifre', 'Parola'],
        ['Ön yargı', 'Peşin hüküm'],
        ['Sportmenlik', 'Fair play'],
        ['Kahve', 'Türk kahvesi'],
        ['İstenmeyen ileti', 'Spam', 'Çöp e-posta'],
        ['Taşınabilir şarj cihazı', 'Powerbank'],
        ['Özçekim', 'Selfie'],
        ['Ayakkabıcı', 'Kunduracı'],
        ['Ateş ölçer', 'Termometre'],
        ['Kablosuz ağ', 'Wi-Fi'],
        ['İnsansız hava aracı', 'Drone'],
        ['Karekod', 'QR kod'],
      ]) {
        expect(
          aliases.map(tabuWordKey).where(targets.contains),
          hasLength(1),
          reason: aliases.join('/'),
        );
      }
    },
  );

  test(
    'Metinlerde gereksiz boşluk, kontrol karakteri, bozuk UTF-8 veya benzer alfabe karakteri yoktur',
    () {
      final invalid = RegExp(
        r'[\u0000-\u001f\u007f\u00a0\u00ad\u200b-\u200f\u202a-\u202e\u2060\uFEFF\uFFFD\u0370-\u052f]',
      );
      for (final card in cards) {
        for (final value in [
          card.id,
          card.word,
          card.category,
          card.difficulty,
          ...card.forbidden,
        ]) {
          expect(value, value.trim(), reason: '${card.id}: <$value>');
          expect(value.contains(RegExp(r'\s{2,}')), isFalse, reason: card.id);
          expect(
            invalid.hasMatch(value),
            isFalse,
            reason: '${card.id}: $value',
          );
          expect(
            value.contains('Ã') || value.contains('Ä') || value.contains('Å'),
            isFalse,
            reason: card.id,
          );
        }
      }
    },
  );

  test(
    '1000 kart gösterilmeden tekrar yok; takım değişiminde deste korunur ve bitince yenilenir',
    () {
      var now = Duration.zero;
      final container = ProviderContainer(
        overrides: [tabuClockProvider.overrideWithValue(() => now)],
      );
      addTearDown(container.dispose);
      container.listen(tabuGameProvider, (_, _) {});
      final controller = container.read(tabuGameProvider.notifier);
      GameState state() => container.read(tabuGameProvider);
      controller.configure(
        GameSession(names: ['Mor', 'Pembe'], seconds: 120),
        cards,
        random: Random(31),
      );
      expect(
        state().deck.map((card) => card.id),
        isNot(orderedEquals(cards.map((card) => card.id))),
      );
      controller.startRound();
      final seen = <String>{};
      for (var i = 0; i < 1000; i++) {
        final current = state().card!.id;
        expect(seen.add(current), isTrue, reason: 'Kart ${i + 1}: $current');
        now += const Duration(milliseconds: 400);
        if ((i + 1) % 100 == 0 && i != 999) {
          now += const Duration(seconds: 120);
          controller.tick();
          controller.nextRound();
          controller.startRound();
          expect(state().deckCycle, 0);
        } else {
          controller.answer(current, CardOutcome.taboo);
        }
        if (i == 999) expect(state().card!.id, isNot(current));
      }
      expect(seen, hasLength(1000));
      expect(state().deckCycle, 1);
      expect(state().phase, GamePhase.playing);
      expect(state().winner, isNull);
    },
  );
}
