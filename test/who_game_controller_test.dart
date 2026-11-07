import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/features/games/who_am_i/application/who_controller.dart';
import 'package:oynika/features/games/who_am_i/domain/who_models.dart';
import 'package:oynika/features/games/who_am_i/domain/who_card_deck.dart';
import 'package:oynika/features/games/who_am_i/data/who_card_repository.dart';

class Harness {
  Harness({WhoRoundDuration duration = WhoRoundDuration.short}) {
    container = ProviderContainer(
      overrides: [whoClockProvider.overrideWithValue(() => now)],
    );
    sub = container.listen(whoSessionProvider, (_, _) {});
    controller = container.read(whoSessionProvider.notifier);
    controller.start(names: ['Ece', 'Deniz'], duration: duration);
  }
  Duration now = Duration.zero;
  late ProviderContainer container;
  late ProviderSubscription<WhoGameSession?> sub;
  late WhoController controller;
  final deck = WhoCardDeck(
    cards: WhoCardRepository.decode(
      File(WhoCardRepository.assetPath).readAsStringSync(),
    ),
    random: Random(15),
  );
  WhoGameSession get s => container.read(whoSessionProvider)!;
  void advance(Duration time) {
    now += time;
    controller.tick();
  }

  void play() {
    controller.beginCountdown(deck);
    advance(const Duration(seconds: 3));
    controller.confirmOrientation();
  }

  void dispose() {
    sub.close();
    container.dispose();
  }
}

void main() {
  late Harness h;
  setUp(() => h = Harness());
  tearDown(() => h.dispose());
  test(
    'Hazırlık, 3/2/1 sayacı ve ilk kart: hazırlık tur süresinden düşmez',
    () {
      expect(h.s.phase, WhoPhase.ready);
      expect(h.s.card, isNull);
      h.controller.beginCountdown(h.deck);
      expect(h.s.countdown, 3);
      h.advance(const Duration(seconds: 1));
      expect(h.s.countdown, 2);
      h.controller.beginCountdown(h.deck);
      expect(h.s.countdown, 2);
      h.advance(const Duration(seconds: 1));
      expect(h.s.countdown, 1);
      expect(h.s.card, isNull);
      expect(h.s.remaining, const Duration(seconds: 60));
      h.advance(const Duration(seconds: 1));
      expect(h.s.phase, WhoPhase.orienting);
      h.controller.confirmOrientation();
      expect(h.s.phase, WhoPhase.playing);
      expect(h.s.card, isNotNull);
      expect(h.s.remaining, const Duration(seconds: 60));
      expect(h.s.deckRemaining, 299);
    },
  );
  for (final duration in WhoRoundDuration.values) {
    test('Seçilen süre gerçek turda ${duration.seconds} saniye', () {
      h.dispose();
      h = Harness(duration: duration);
      h.play();
      h.advance(Duration(seconds: duration.seconds - 1));
      expect(h.s.phase, WhoPhase.playing);
      h.advance(const Duration(seconds: 1));
      expect(h.s.phase, WhoPhase.roundResult);
      expect(h.s.remaining, Duration.zero);
    });
  }
  test('Yatay görünüm onaylanana kadar kart ve süre başlamaz', () {
    h.controller.beginCountdown(h.deck);
    h.advance(const Duration(seconds: 3));
    expect(h.s.phase, WhoPhase.orienting);
    expect(h.s.card, isNull);
    h.advance(const Duration(minutes: 5));
    expect(h.s.remaining, const Duration(seconds: 60));
    expect(h.deck.remainingCount, 300);
    h.controller.confirmOrientation();
    h.controller.confirmOrientation();
    expect(h.s.phase, WhoPhase.playing);
    expect(h.deck.remainingCount, 299);
    expect(h.s.remaining, const Duration(seconds: 60));
  });
  test(
    'Saat kayması yok: gerçek geçen milisaniye, sabit saatte tick süre düşürmez',
    () {
      h.play();
      h.advance(const Duration(milliseconds: 10123));
      expect(h.s.remaining, const Duration(milliseconds: 49877));
      for (var i = 0; i < 50; i++) {
        h.controller.tick();
      }
      expect(h.s.remaining, const Duration(milliseconds: 49877));
    },
  );
  test('Doğru +1, Pas 0, kart sonucu kaydı ve yeni kart', () {
    h.play();
    final first = h.s.card!;
    h.controller.answer(first.id, WhoOutcome.correct);
    expect(h.s.correct, 1);
    expect(h.s.roundPoints, 1);
    expect(h.s.totals, [1, 0]);
    expect(h.s.answers.single.card, same(first));
    expect(h.s.answers.single.outcome, WhoOutcome.correct);
    expect(h.s.card!.id, isNot(first.id));
    expect(h.s.feedback, WhoOutcome.correct);
    h.advance(const Duration(milliseconds: 301));
    final next = h.s.card!;
    h.controller.answer(next.id, WhoOutcome.pass);
    expect(h.s.passed, 1);
    expect(h.s.totals, [1, 0]);
    expect(h.s.answers.last.outcome, WhoOutcome.pass);
  });
  test(
    'Aynı kartın çift yanıtı ve geçişte yeni karta hızlı dokunma engellenir',
    () {
      h.play();
      final first = h.s.card!.id;
      h.controller.answer(first, WhoOutcome.correct);
      h.controller.answer(first, WhoOutcome.correct);
      h.controller.answer(h.s.card!.id, WhoOutcome.correct);
      expect(h.s.correct, 1);
      h.advance(const Duration(milliseconds: 301));
      expect(h.s.feedback, isNull);
      h.controller.answer(h.s.card!.id, WhoOutcome.correct);
      expect(h.s.correct, 2);
    },
  );
  test('301 sınırsız pas, gerçek destenin döngüsü ve sınır koruması', () {
    h.dispose();
    h = Harness(duration: WhoRoundDuration.long);
    h.play();
    final ids = <String>[];
    for (var i = 0; i < 301; i++) {
      ids.add(h.s.card!.id);
      h.controller.answer(h.s.card!.id, WhoOutcome.pass);
      h.advance(const Duration(milliseconds: 301));
    }
    expect(h.s.passed, 301);
    expect(h.s.totals, [0, 0]);
    expect(ids.take(300).toSet(), hasLength(300));
    expect(ids[299], isNot(ids[300]));
    expect(h.s.phase, WhoPhase.playing);
  });
  test('Süre bittikten sonra cevap verilmez, yanıtsız son kart puanlanmaz', () {
    h.play();
    h.controller.answer(h.s.card!.id, WhoOutcome.correct);
    h.advance(const Duration(milliseconds: 301));
    final last = h.s.card!.id;
    h.now += const Duration(seconds: 60);
    h.controller.answer(last, WhoOutcome.correct);
    expect(h.s.phase, WhoPhase.roundResult);
    expect(h.s.correct, 1);
    expect(h.s.answers, hasLength(1));
    expect(h.s.card, isNull);
    h.controller.answer(last, WhoOutcome.pass);
    expect(h.s.passed, 0);
  });
  test(
    'Duraklatma kelimeyi state ten kaldırır ve süreyi korur; manuel devam',
    () {
      h.play();
      h.advance(const Duration(seconds: 7));
      final card = h.s.card;
      h.controller.pause();
      expect(h.s.phase, WhoPhase.paused);
      expect(h.s.card, isNull);
      h.advance(const Duration(minutes: 2));
      expect(h.s.remaining, const Duration(seconds: 53));
      h.controller.answer(card!.id, WhoOutcome.correct);
      expect(h.s.correct, 0);
      h.controller.resume();
      expect(h.s.card, same(card));
      expect(h.s.phase, WhoPhase.playing);
      h.advance(const Duration(seconds: 1));
      expect(h.s.remaining, const Duration(seconds: 52));
    },
  );
  test('Hazırlık sayacı da duraklatılır ve kaldığı yerden devam eder', () {
    h.controller.beginCountdown(h.deck);
    h.advance(const Duration(seconds: 1));
    h.controller.pause();
    h.advance(const Duration(minutes: 1));
    h.controller.resume();
    h.advance(const Duration(seconds: 1));
    expect(h.s.phase, WhoPhase.countdown);
    expect(h.s.countdown, 1);
    h.advance(const Duration(seconds: 1));
    h.controller.confirmOrientation();
    expect(h.s.phase, WhoPhase.playing);
    expect(h.s.remaining, const Duration(seconds: 60));
  });
  test(
    'Sınırsız tur, oyuncu sırası, ilk oyuncuya dönüş ve toplamlar korunur',
    () {
      for (var round = 0; round < 8; round++) {
        expect(h.s.currentPlayerIndex, round % 2);
        h.play();
        h.controller.answer(h.s.card!.id, WhoOutcome.correct);
        h.advance(const Duration(seconds: 60));
        h.controller.nextPlayer();
        h.controller.nextPlayer();
      }
      expect(h.s.currentPlayerIndex, 0);
      expect(h.s.totals, [4, 4]);
      expect(h.s.round, 9);
      expect(h.s.deckRemaining, 284);
      expect(h.s.correct, 0);
      expect(h.s.answers, isEmpty);
    },
  );
  test(
    'Yeniden başlatma ayarları korur; eski oturumun başlatma callback i engellenir',
    () {
      final old = h.s.settings;
      h.play();
      h.controller.answer(h.s.card!.id, WhoOutcome.correct);
      h.controller.restart();
      expect(h.s.phase, WhoPhase.ready);
      expect(h.s.totals, [0, 0]);
      expect(h.s.answers, isEmpty);
      expect(h.s.currentPlayerIndex, 0);
      expect(h.s.settings.players.map((p) => p.name), ['Ece', 'Deniz']);
      expect(h.s.settings.duration, WhoRoundDuration.short);
      expect(h.s.settings, isNot(same(old)));
      h.controller.beginCountdown(h.deck, expectedSettings: old);
      expect(h.s.phase, WhoPhase.ready);
      h.controller.reset();
      expect(h.container.read(whoSessionProvider), isNull);
      h.advance(const Duration(minutes: 5));
      expect(h.container.read(whoSessionProvider), isNull);
    },
  );
}
