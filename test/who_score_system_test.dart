import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/features/games/who_am_i/application/who_controller.dart';
import 'package:oynika/features/games/who_am_i/data/who_card_repository.dart';
import 'package:oynika/features/games/who_am_i/domain/who_card_deck.dart';
import 'package:oynika/features/games/who_am_i/domain/who_models.dart';

class ScoreHarness {
  ScoreHarness({
    int target = 20,
    List<String> names = const ['Ece', 'Deniz', 'Can'],
  }) {
    c = ProviderContainer(
      overrides: [whoClockProvider.overrideWithValue(() => now)],
    );
    sub = c.listen(whoSessionProvider, (_, _) {});
    controller = c.read(whoSessionProvider.notifier);
    controller.start(
      names: names,
      duration: WhoRoundDuration.short,
      targetScore: target,
    );
  }
  late final ProviderContainer c;
  late final ProviderSubscription<WhoGameSession?> sub;
  late final WhoController controller;
  final deck = WhoCardDeck(
    cards: WhoCardRepository.decode(
      File(WhoCardRepository.assetPath).readAsStringSync(),
    ),
    random: Random(64),
  );
  Duration now = Duration.zero;
  WhoGameSession get s => c.read(whoSessionProvider)!;
  void advance(Duration d) {
    now += d;
    controller.tick();
  }

  void begin() {
    controller.beginCountdown(deck);
    advance(const Duration(seconds: 3));
    controller.confirmOrientation();
  }

  void points(int n) {
    for (var i = 0; i < n; i++) {
      controller.answer(s.card!.id, WhoOutcome.correct);
      advance(const Duration(milliseconds: 301));
    }
  }

  void turn(int n, {int passes = 0}) {
    begin();
    points(n);
    for (var i = 0; i < passes; i++) {
      controller.answer(s.card!.id, WhoOutcome.pass);
      advance(const Duration(milliseconds: 301));
    }
    advance(const Duration(seconds: 61));
  }

  void close() {
    controller.stopTimer();
    sub.close();
    c.dispose();
  }
}

void main() {
  for (final target in WhoGameSettings.targetScores) {
    test('$target hedefi tam sıra sonunda kazanılır', () {
      final h = ScoreHarness(target: target);
      addTearDown(h.close);
      h.turn(target);
      expect(h.s.phase, WhoPhase.roundResult);
      expect(h.s.winnerIndex, isNull);
      h.controller.nextPlayer();
      h.turn(1);
      expect(h.s.phase, WhoPhase.roundResult);
      h.controller.nextPlayer();
      h.turn(2);
      expect(h.s.phase, WhoPhase.winner);
      expect(h.s.winnerIndex, 0);
      expect(h.s.history.map((r) => r.playerIndex), [0, 1, 2]);
    });
  }
  test('Varsayılan 20 ve geçersiz hedef reddi', () {
    expect(WhoGameSettings(names: ['A', 'B']).targetScore, 20);
    for (final n in [0, 9, 12, 31]) {
      expect(
        () => WhoGameSettings(names: ['A', 'B'], targetScore: n),
        throwsArgumentError,
      );
    }
  });
  test('Hedef yoksa normal sıralar eşit oyuncu turuyla devam eder', () {
    final h = ScoreHarness();
    addTearDown(h.close);
    for (var i = 0; i < 6; i++) {
      h.turn(1);
      expect(h.s.phase, WhoPhase.roundResult);
      h.controller.nextPlayer();
    }
    expect(h.s.totals, [2, 2, 2]);
    expect(h.s.cycle, 3);
    expect(h.s.history.where((r) => r.playerIndex == 0).length, 2);
    expect(h.s.history.where((r) => r.playerIndex == 2).length, 2);
  });
  test('İlk hedefe ulaşan değil sıra sonunda en yüksek oyuncu kazanır', () {
    final h = ScoreHarness(target: 10);
    addTearDown(h.close);
    h.turn(10);
    h.controller.nextPlayer();
    h.turn(13);
    h.controller.nextPlayer();
    h.turn(12);
    expect(h.s.winnerIndex, 1);
    expect(h.s.totals, [10, 13, 12]);
  });
  test('Üçlü eşitlik daralır; sadece eşit liderler ek tur oynar', () {
    final h = ScoreHarness(target: 10, names: ['A', 'B', 'C', 'D']);
    addTearDown(h.close);
    for (final score in [10, 10, 0, 10]) {
      h.turn(score);
      if (!h.s.sequenceComplete) h.controller.nextPlayer();
    }
    expect(h.s.phase, WhoPhase.roundResult);
    h.controller.nextPlayer();
    expect(h.s.turnOrder, [0, 1, 3]);
    expect(h.s.tieBreak, isTrue);
    h.turn(1);
    h.controller.nextPlayer();
    h.turn(1);
    h.controller.nextPlayer();
    h.turn(0);
    expect(h.s.phase, WhoPhase.roundResult);
    h.controller.nextPlayer();
    expect(h.s.turnOrder, [0, 1]);
    h.turn(0);
    h.controller.nextPlayer();
    h.turn(1);
    expect(h.s.phase, WhoPhase.winner);
    expect(h.s.winnerIndex, 1);
    expect(h.s.history.map((r) => r.playerIndex), [0, 1, 2, 3, 0, 1, 3, 0, 1]);
  });
  test('Sıfır puanlı ek tur eşitliği çözmez, sıra devam eder', () {
    final h = ScoreHarness(target: 10, names: ['A', 'B']);
    addTearDown(h.close);
    h.turn(10);
    h.controller.nextPlayer();
    h.turn(10);
    h.controller.nextPlayer();
    for (var i = 0; i < 4; i++) {
      h.turn(0);
      expect(h.s.phase, WhoPhase.roundResult);
      h.controller.nextPlayer();
    }
    expect(h.s.turnOrder, [0, 1]);
    expect(h.s.cycle, 4);
  });
  test('Her turun doğru/pas/puan/toplam kaydı ve sıralaması korunur', () {
    final h = ScoreHarness();
    addTearDown(h.close);
    h.turn(3, passes: 2);
    h.controller.nextPlayer();
    h.turn(5, passes: 1);
    expect(h.s.ranking, [1, 0, 2]);
    expect(h.s.lastTurn(0)!.correct, 3);
    expect(h.s.lastTurn(0)!.passed, 2);
    expect(h.s.lastTurn(0)!.points, 3);
    expect(h.s.lastTurn(1)!.total, 5);
    expect(h.s.nextPlayer.id, 2);
  });
  test(
    'Oyun bitince sensör/dokunma dahil cevap ve nextPlayer değişiklik yapamaz',
    () {
      final h = ScoreHarness(target: 10, names: ['A', 'B']);
      addTearDown(h.close);
      h.turn(10);
      h.controller.nextPlayer();
      h.begin();
      final old = h.s.card!.id;
      h.advance(const Duration(seconds: 61));
      final done = h.s;
      h.controller.answer(old, WhoOutcome.correct);
      h.controller.answer(old, WhoOutcome.pass);
      h.controller.nextPlayer();
      h.advance(const Duration(minutes: 2));
      expect(h.s, same(done));
    },
  );
  test(
    'Tekrar Oyna isim/süre/hedefi korur, skor/history/deck/yeni sıra temizlenir',
    () {
      final h = ScoreHarness(target: 15, names: ['Ece', 'Deniz']);
      addTearDown(h.close);
      h.turn(15);
      h.controller.nextPlayer();
      h.turn(1);
      final settings = h.s.settings;
      h.controller.restart();
      expect(h.s.phase, WhoPhase.ready);
      expect(h.s.settings.players.map((p) => p.name), ['Ece', 'Deniz']);
      expect(h.s.settings.duration, settings.duration);
      expect(h.s.settings.targetScore, 15);
      expect(h.s.settings, isNot(same(settings)));
      expect(h.s.totals, [0, 0]);
      expect(h.s.history, isEmpty);
      expect(h.s.turnOrder, [0, 1]);
      expect(h.s.turnPosition, 0);
      expect(h.s.cycle, 1);
      expect(h.s.tieBreak, isFalse);
      expect(h.s.winnerIndex, isNull);
      expect(h.s.deckRemaining, 300);
    },
  );
}
