import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/features/games/tabu/application/game_controller.dart';
import 'package:oynika/features/games/tabu/data/card_repository.dart';
import 'package:oynika/features/games/tabu/domain/tabu_models.dart';

void main() {
  final cards = CardRepository.decode(
    File('assets/data/tabu_cards.json').readAsStringSync(),
  );
  late ProviderContainer container;
  late GameController controller;
  late Duration now;
  GameState state() => container.read(tabuGameProvider);
  void advance(int seconds) {
    now += Duration(seconds: seconds);
    controller.tick();
  }

  void setup({int seconds = 60, int targetScore = 20, List<TabuCard>? deck}) =>
      controller.configure(
        GameSession(
          names: ['Mor Takım', 'Pembe Takım'],
          seconds: seconds,
          targetScore: targetScore,
        ),
        deck ?? cards,
        random: Random(7),
      );
  void answer(CardOutcome outcome) {
    controller.answer(state().card!.id, outcome);
    now += const Duration(milliseconds: 400);
  }

  setUp(() {
    now = Duration.zero;
    container = ProviderContainer(
      overrides: [tabuClockProvider.overrideWithValue(() => now)],
    );
    container.listen(tabuGameProvider, (_, _) {});
    controller = container.read(tabuGameProvider.notifier);
  });
  tearDown(() => container.dispose());

  test(
    'Her tur 3 pasla başlar, ilk üç pas kartı atlar ve skoru değiştirmez',
    () {
      setup();
      controller.startRound();
      expect(state().remainingPasses, 3);
      for (var remaining = 2; remaining >= 0; remaining--) {
        final card = state().card!.id;
        answer(CardOutcome.pass);
        expect(state().remainingPasses, remaining);
        expect(state().passed, 3 - remaining);
        expect(state().card!.id, isNot(card));
        expect(state().teams.map((team) => team.score), [0, 0]);
      }
    },
  );
  test(
    'Dördüncü pas kartı, skoru ve kalan hakkı değiştirmez; diğer yanıtlar çalışır',
    () {
      setup();
      controller.startRound();
      for (var i = 0; i < 3; i++) {
        answer(CardOutcome.pass);
      }
      final card = state().card!.id;
      controller.answer(card, CardOutcome.pass);
      expect(state().card!.id, card);
      expect(state().remainingPasses, 0);
      expect(state().passed, 3);
      expect(state().teams[0].score, 0);
      answer(CardOutcome.correct);
      expect(state().teams[0].score, 1);
      expect(state().remainingPasses, 0);
      answer(CardOutcome.taboo);
      expect(state().teams[0].score, 0);
      expect(state().remainingPasses, 0);
    },
  );
  test('Doğru ve Tabu kalan pas hakkını etkilemez', () {
    setup();
    controller.startRound();
    answer(CardOutcome.pass);
    answer(CardOutcome.correct);
    answer(CardOutcome.taboo);
    expect(state().remainingPasses, 2);
    expect(state().passed, 1);
  });
  test('Duraklatma ve devam pas hakkını korur; duraklatmada pas işlenmez', () {
    setup();
    controller.startRound();
    answer(CardOutcome.pass);
    final card = state().card!.id;
    controller.pause();
    advance(100);
    controller.answer(card, CardOutcome.pass);
    expect(state().remainingPasses, 2);
    expect(state().card!.id, card);
    controller.resume();
    expect(state().remainingPasses, 2);
    answer(CardOutcome.pass);
    expect(state().remainingPasses, 1);
  });
  test('Her takım değişiminde pas 3 olur; biten turun istatistiği korunur', () {
    setup();
    for (var round = 0; round < 8; round++) {
      controller.startRound();
      expect(state().remainingPasses, 3);
      for (var i = 0; i < 3; i++) {
        answer(CardOutcome.pass);
      }
      advance(60);
      expect(state().rounds.last.passed, 3);
      controller.nextRound();
      expect(state().remainingPasses, 3);
      expect(state().phase, GamePhase.preRound);
    }
  });
  test('Deste yenilenmesi pas hakkını yenilemez', () {
    setup(deck: cards.take(1).toList());
    controller.startRound();
    for (var i = 0; i < 3; i++) {
      answer(CardOutcome.pass);
    }
    expect(state().deckCycle, 3);
    expect(state().remainingPasses, 0);
    answer(CardOutcome.taboo);
    expect(state().remainingPasses, 0);
    expect(state().deckCycle, 4);
  });
  test(
    'Pas tükenince de hedefte anında kazanılır ve tekrar oyunda pas sıfırlanır',
    () {
      setup(targetScore: 10);
      controller.startRound();
      for (var i = 0; i < 3; i++) {
        answer(CardOutcome.pass);
      }
      for (var i = 0; i < 10; i++) {
        answer(CardOutcome.correct);
      }
      expect(state().phase, GamePhase.result);
      expect(state().winner, 0);
      expect(state().remainingPasses, 0);
      expect(state().rounds.single.passed, 3);
      controller.replay();
      expect(state().remainingPasses, 3);
      expect(state().teams[0].score, 0);
      expect(state().session!.targetScore, 10);
    },
  );

  test('Varsayılan hedef 20, başlangıç skorları sıfır', () {
    final session = GameSession(names: ['A', 'B'], seconds: 90);
    expect(session.targetScore, 20);
    controller.configure(session, cards);
    expect(state().teams.every((team) => team.score == 0), isTrue);
  });
  for (final target in [10, 15, 20, 25, 30]) {
    test(
      '$target hedefinde anında biter, sayaç/kart/skor kilitlenir ve tekrar oyun ayarları korunur',
      () {
        setup(seconds: 120, targetScore: target);
        controller.startRound();
        for (var i = 0; i < target - 1; i++) {
          answer(CardOutcome.correct);
        }
        expect(state().phase, GamePhase.playing);
        final finalCard = state().card!.id;
        answer(CardOutcome.correct);
        expect(state().phase, GamePhase.result);
        expect(state().winner, 0);
        expect(state().teams[0].score, target);
        expect(state().card!.id, finalCard);
        expect(state().remaining, Duration.zero);
        expect(state().rounds, hasLength(1));
        for (final outcome in CardOutcome.values) {
          controller.answer(finalCard, outcome);
        }
        advance(300);
        controller.nextRound();
        controller.resume();
        controller.startRound();
        expect(state().teams[0].score, target);
        expect(state().rounds, hasLength(1));
        expect(state().card!.id, finalCard);
        expect(state().phase, GamePhase.result);
        controller.replay();
        expect(state().teams.map((team) => team.name), [
          'Mor Takım',
          'Pembe Takım',
        ]);
        expect(state().teams.every((team) => team.score == 0), isTrue);
        expect(state().session!.seconds, 120);
        expect(state().session!.targetScore, target);
        expect(state().round, 0);
        expect(state().rounds, isEmpty);
      },
    );
  }
  test('Hedefe ikinci takım ulaşırsa doğru kazanan seçilir', () {
    setup(targetScore: 10);
    controller.startRound();
    advance(60);
    controller.nextRound();
    controller.startRound();
    for (var i = 0; i < 10; i++) {
      answer(CardOutcome.correct);
    }
    expect(state().winner, 1);
    expect(state().phase, GamePhase.result);
    expect(state().teams.map((team) => team.score), [0, 10]);
  });
  test('Hedefin üzerindeki puan da kazanma kontrolünü tetikler', () {
    final seed = GameState(
      session: GameSession(names: ['A', 'B'], seconds: 60, targetScore: 10),
      phase: GamePhase.preRound,
      teams: const [Team('A', 11), Team('B')],
      deck: cards,
      remaining: const Duration(seconds: 60),
    );
    final seededContainer = ProviderContainer(
      overrides: [
        tabuClockProvider.overrideWithValue(() => now),
        tabuGameProvider.overrideWith(() => _SeededGameController(seed)),
      ],
    );
    addTearDown(seededContainer.dispose);
    seededContainer.listen(tabuGameProvider, (_, _) {});
    final seeded = seededContainer.read(tabuGameProvider.notifier);
    seeded.startRound();
    final cardId = seededContainer.read(tabuGameProvider).card!.id;
    seeded.answer(cardId, CardOutcome.pass);
    expect(seededContainer.read(tabuGameProvider).phase, GamePhase.result);
    expect(seededContainer.read(tabuGameProvider).winner, 0);
    expect(seededContainer.read(tabuGameProvider).card!.id, cardId);
  });
  test('Hedefin altında süre dolarsa sonuç yerine sıradaki tur hazırlanır', () {
    setup(targetScore: 10);
    controller.startRound();
    answer(CardOutcome.correct);
    advance(60);
    expect(state().phase, GamePhase.roundResult);
    controller.nextRound();
    expect(state().phase, GamePhase.preRound);
    expect(state().activeTeam, 1);
    expect(state().teams[0].score, 1);
    expect(state().session!.targetScore, 10);
  });
  test('İzin verilmeyen hedef puan reddedilir', () {
    expect(
      () => GameSession(names: ['A', 'B'], seconds: 60, targetScore: 12),
      throwsArgumentError,
    );
  });

  test('250 özgün kart, 10 kategori ve doğru zorluk dağılımı', () {
    expect(cards.length, 250);
    for (final category in tabuCategories) {
      expect(cards.where((c) => c.category == category).length, 25);
    }
    expect(cards.where((c) => c.difficulty == 'Kolay').length, 150);
    expect(cards.where((c) => c.difficulty == 'Orta').length, 80);
    expect(cards.where((c) => c.difficulty == 'Zor').length, 20);
    expect(cards.every((c) => c.forbidden.length == 5), isTrue);
  });
  test('Bozuk JSON kartları reddedilir', () {
    expect(() => CardRepository.decode('[]'), throwsFormatException);
    expect(
      () => CardRepository.decode(
        '[{"id":"1","word":"Test","forbidden":["a","a","b","c","d"],"category":"Doğa","difficulty":"Kolay"}]',
      ),
      throwsFormatException,
    );
  });
  test('Yalnızca iki farklı dolu takım adı; Türkçe ve boşluk doğrulaması', () {
    for (final names in [
      <String>[],
      ['Tek'],
      ['A', 'B', 'C'],
      [' ', 'B'],
      ['A', 'a'],
      [' İZMİR ', 'izmir'],
    ]) {
      expect(() => GameSession(names: names, seconds: 90), throwsArgumentError);
    }
    final session = GameSession(
      names: [' Yıldızlar ', ' Bulutlar '],
      seconds: 90,
    );
    controller.configure(session, cards);
    expect(state().teams.map((t) => t.name), ['Yıldızlar', 'Bulutlar']);
  });
  for (final seconds in [60, 90, 120]) {
    test('$seconds saniye ve oyun öncesinde sayaç başlamaz', () {
      setup(seconds: seconds);
      advance(500);
      expect(state().remaining.inSeconds, seconds);
      controller.startRound();
      expect(state().remaining.inSeconds, seconds);
      advance(1);
      expect(state().remaining.inSeconds, seconds - 1);
    });
  }
  test(
    'Geçersiz tur süresi reddedilir',
    () => expect(
      () => GameSession(names: ['A', 'B'], seconds: 30),
      throwsArgumentError,
    ),
  );
  for (final entry
      in {
        CardOutcome.correct: 1,
        CardOutcome.taboo: -1,
        CardOutcome.pass: 0,
      }.entries) {
    test('${entry.key} puanı ${entry.value}', () {
      setup();
      controller.startRound();
      answer(entry.key);
      expect(state().teams[0].score, entry.value);
    });
  }
  test(
    'Aynı kart iki kez işlenmez, hızlı çift basış yeni kartı da atlamaz',
    () {
      setup();
      controller.startRound();
      final id = state().card!.id;
      controller.answer(id, CardOutcome.correct);
      controller.answer(id, CardOutcome.correct);
      controller.answer(state().card!.id, CardOutcome.correct);
      expect(state().teams[0].score, 1);
      expect(state().cardIndex, 1);
    },
  );
  test('Süre bitince açık kart puanlanmaz ve geç basış reddedilir', () {
    setup();
    controller.startRound();
    now += const Duration(seconds: 60);
    controller.answer(state().card!.id, CardOutcome.correct);
    expect(state().phase, GamePhase.roundResult);
    expect(state().teams[0].score, 0);
    expect(state().rounds.single.correct, 0);
  });
  test('Duraklatma süreyi korur ve buton işlemlerini reddeder', () {
    setup();
    controller.startRound();
    advance(10);
    controller.pause();
    advance(200);
    answer(CardOutcome.correct);
    expect(state().remaining.inSeconds, 50);
    expect(state().teams[0].score, 0);
    controller.resume();
    advance(49);
    expect(state().phase, GamePhase.playing);
    advance(1);
    expect(state().phase, GamePhase.roundResult);
  });
  test('Kartlar ve tur başında bırakılan kartlar tekrarlanmaz', () {
    setup();
    controller.startRound();
    final seen = <String>{};
    for (var i = 0; i < 100; i++) {
      expect(seen.add(state().card!.id), isTrue);
      answer(CardOutcome.taboo);
    }
    final abandoned = state().card!.id;
    advance(60);
    controller.nextRound();
    controller.startRound();
    expect(state().card!.id, isNot(abandoned));
    expect(seen.contains(state().card!.id), isFalse);
  });
  test('Deste bitince yeniden karışır; hedefe ulaşılmadan oyun bitmez', () {
    setup(deck: cards.take(3).toList());
    controller.startRound();
    for (var cycle = 0; cycle < 3; cycle++) {
      final seen = <String>{};
      for (var i = 0; i < 3; i++) {
        expect(seen.add(state().card!.id), isTrue);
        final previous = state().card!.id;
        answer(CardOutcome.taboo);
        expect(state().card!.id, isNot(previous));
      }
      expect(state().phase, GamePhase.playing);
      expect(state().deckCycle, cycle + 1);
      expect(state().teams[0].score, -3 * (cycle + 1));
    }
  });
  test(
    'Tek kartlık havuzda da oyun güvenle sürer; tur başında tükenme sonlandırmaz',
    () {
      setup(deck: cards.take(1).toList());
      controller.startRound();
      final id = state().card!.id;
      answer(CardOutcome.taboo);
      expect(state().teams[0].score, -1);
      expect(state().phase, GamePhase.playing);
      expect(state().card!.id, id);
      advance(60);
      controller.nextRound();
      controller.startRound();
      expect(state().phase, GamePhase.playing);
      expect(state().activeTeam, 1);
    },
  );
  test('Altıncı turdan sonra da takımlar sınırsız dönüşümlü oynar', () {
    setup();
    for (var round = 0; round < 20; round++) {
      expect(state().activeTeam, round % 2);
      controller.startRound();
      if (round.isEven) answer(CardOutcome.correct);
      advance(60);
      expect(state().rounds.length, round + 1);
      controller.nextRound();
      expect(state().phase, GamePhase.preRound);
      expect(state().round, round + 1);
      expect(state().winner, isNull);
    }
    expect(state().teams.map((t) => t.score), [10, 0]);
    controller.startRound();
    for (var i = 0; i < 10; i++) {
      answer(CardOutcome.correct);
    }
    expect(state().phase, GamePhase.result);
    expect(state().winner, 0);
  });
  test('Eşit skorlar ve negatif puanlar tur sınırıyla sonuç üretmez', () {
    setup();
    for (var i = 0; i < 12; i++) {
      controller.startRound();
      answer(CardOutcome.taboo);
      advance(60);
      controller.nextRound();
    }
    expect(state().winner, isNull);
    expect(state().phase, GamePhase.preRound);
    expect(state().teams.map((t) => t.score), [-6, -6]);
  });
}

class _SeededGameController extends GameController {
  _SeededGameController(this.seed);
  final GameState seed;
  @override
  GameState build() {
    super.build();
    return seed;
  }
}
