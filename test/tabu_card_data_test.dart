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
  final added = cards.skip(250).toList();

  test('İlk 250 kartın sırası ve bütün alanları Faz 3 ile aynı kalır', () {
    expect(original, hasLength(250));
    expect(rows.take(250).toList(), original);
    expect(added, hasLength(250));
    expect(cards, hasLength(500));
  });

  test('500 kart mevcut şemaya ve sıralı benzersiz ID biçimine uyar', () {
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
    expect(cards.map((card) => card.id).toSet(), hasLength(500));
  });

  test('Hedefler Türkçe büyük/küçük harf normalleştirmesiyle benzersizdir', () {
    expect(turkishKey(' İSTANBUL '), turkishKey('istanbul'));
    expect(turkishKey('IŞIK'), turkishKey('ışık'));
    expect(cards.map((card) => turkishKey(card.word)).toSet(), hasLength(500));
  });

  test('Her kartta tam beş dolu farklı yasaklı vardır ve hedef bulunmaz', () {
    for (final card in cards) {
      final forbidden = card.forbidden.map(turkishKey).toList();
      expect(forbidden, hasLength(5), reason: card.id);
      expect(
        forbidden.every((word) => word.isNotEmpty),
        isTrue,
        reason: card.id,
      );
      expect(forbidden.toSet(), hasLength(5), reason: card.id);
      expect(
        forbidden,
        isNot(contains(turkishKey(card.word))),
        reason: card.id,
      );
    }
  });

  test('Toplamda kategori başına 50; kolay/orta/zor 300/160/40', () {
    expect(cards.map((card) => card.category).toSet(), tabuCategories.toSet());
    expect(
      cards.map((card) => card.difficulty).toSet(),
      tabuDifficulties.toSet(),
    );
    for (final category in tabuCategories) {
      final group = cards.where((card) => card.category == category).toList();
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
        cards.where((card) => card.difficulty == entry.key),
        hasLength(entry.value),
      );
    }
  });

  test(
    'Yeni 250 kartta kategori başına 25 ve 15/8/2 zorluk dağılımı vardır',
    () {
      for (final category in tabuCategories) {
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
    '500 kart gösterilmeden tekrar yok; takım değişiminde deste korunur ve bitince yenilenir',
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
      for (var i = 0; i < 500; i++) {
        final current = state().card!.id;
        expect(seen.add(current), isTrue, reason: 'Kart ${i + 1}: $current');
        now += const Duration(milliseconds: 400);
        if ((i + 1) % 100 == 0 && i != 499) {
          now += const Duration(seconds: 120);
          controller.tick();
          controller.nextRound();
          controller.startRound();
          expect(state().deckCycle, 0);
        } else {
          controller.answer(current, CardOutcome.taboo);
        }
        if (i == 499) expect(state().card!.id, isNot(current));
      }
      expect(seen, hasLength(500));
      expect(state().deckCycle, 1);
      expect(state().phase, GamePhase.playing);
      expect(state().winner, isNull);
    },
  );
}
