import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/features/games/charades/application/charades_controller.dart';
import 'package:oynika/features/games/charades/data/charades_repository.dart';
import 'package:oynika/features/games/charades/domain/charades_models.dart';

void main() {
  final cards = CharadesRepository.decode(
    File('assets/data/sessiz_sinema_cards.json').readAsStringSync(),
  );
  late ProviderContainer container;
  late CharadesController controller;
  late Duration now;
  CharadesState state() => container.read(charadesGameProvider);
  void setup({int seconds = 90, int target = 20, List<CharadesCard>? deck}) =>
      controller.configure(
        GameSession(
          names: ['Mor Takım', 'Pembe Takım'],
          seconds: seconds,
          targetScore: target,
        ),
        deck ?? cards,
        random: Random(4),
      );
  void answer(CharadesOutcome outcome) {
    controller.answer(state().card!.id, outcome);
    now += const Duration(milliseconds: 400);
  }

  void finish() {
    now += const Duration(seconds: 120);
    controller.tick();
  }

  setUp(() {
    now = Duration.zero;
    container = ProviderContainer(
      overrides: [charadesClockProvider.overrideWithValue(() => now)],
    );
    container.listen(charadesGameProvider, (_, _) {});
    controller = container.read(charadesGameProvider.notifier);
  });
  tearDown(() => container.dispose());

  test('Tam iki düzenlenebilir ve farklı dolu takım adı', () {
    for (final names in [
      <String>[],
      ['A'],
      ['A', 'B', 'C'],
      [' ', 'B'],
      [' İZMİR ', 'izmir'],
    ]) {
      expect(
        () =>
            controller.configure(GameSession(names: names, seconds: 90), cards),
        throwsArgumentError,
      );
    }
    controller.configure(
      GameSession(names: [' Yıldızlar ', ' Aylar '], seconds: 90),
      cards,
    );
    expect(state().teams.map((t) => t.name), ['Yıldızlar', 'Aylar']);
  });
  for (final seconds in [60, 90, 120]) {
    test('$seconds saniye yalnızca Hazırım ile başlar', () {
      setup(seconds: seconds);
      now += const Duration(seconds: 300);
      controller.tick();
      expect(state().remaining.inSeconds, seconds);
      expect(state().card, isNull);
      controller.startRound();
      now += const Duration(seconds: 1);
      controller.tick();
      expect(state().remaining.inSeconds, seconds - 1);
    });
  }
  for (final target in [10, 15, 20, 25, 30]) {
    test(
      '$target hedefinde hemen biter; tekrar oyun ayarları ve temiz geçmiş',
      () {
        setup(seconds: 120, target: target);
        controller.startRound();
        for (var i = 0; i < target - 1; i++) {
          answer(CharadesOutcome.correct);
        }
        final card = state().card!.id;
        answer(CharadesOutcome.correct);
        expect(state().phase, GamePhase.result);
        expect(state().winner, 0);
        expect(state().card!.id, card);
        expect(state().remaining, Duration.zero);
        for (final outcome in CharadesOutcome.values) {
          controller.answer(card, outcome);
        }
        finish();
        controller.nextRound();
        controller.resume();
        controller.startRound();
        expect(state().teams[0].score, target);
        expect(state().rounds, hasLength(1));
        controller.replay();
        expect(state().teams.every((t) => t.score == 0), isTrue);
        expect(state().session!.targetScore, target);
        expect(state().session!.seconds, 120);
        expect(state().teams[0].name, 'Mor Takım');
        expect(state().cardIndex, -1);
        expect(state().round, 0);
        expect(state().remainingPasses, 3);
        expect(state().rounds, isEmpty);
      },
    );
  }
  test('Doğru +1, pas sıfır; üçten fazla pas kabul edilmez', () {
    setup();
    controller.startRound();
    answer(CharadesOutcome.correct);
    for (var i = 0; i < 3; i++) {
      answer(CharadesOutcome.pass);
      expect(state().remainingPasses, 2 - i);
    }
    final id = state().card!.id;
    answer(CharadesOutcome.pass);
    expect(state().card!.id, id);
    expect(state().teams[0].score, 1);
    answer(CharadesOutcome.correct);
    expect(state().teams[0].score, 2);
    expect(state().remainingPasses, 0);
  });
  test('Aynı kart ve hızlı çift tıklama iki puan üretmez', () {
    setup();
    controller.startRound();
    final id = state().card!.id;
    controller.answer(id, CharadesOutcome.correct);
    controller.answer(id, CharadesOutcome.correct);
    controller.answer(state().card!.id, CharadesOutcome.correct);
    expect(state().teams[0].score, 1);
    expect(state().cardIndex, 1);
  });
  test(
    'Süre sonunda mevcut karta puan verilmez, sonraki takımda pas üç olur',
    () {
      setup();
      controller.startRound();
      answer(CharadesOutcome.pass);
      final id = state().card!.id;
      now += const Duration(seconds: 90);
      controller.answer(id, CharadesOutcome.correct);
      expect(state().phase, GamePhase.roundResult);
      expect(state().teams[0].score, 0);
      expect(state().rounds.single.passed, 1);
      controller.nextRound();
      expect(state().activeTeam, 1);
      expect(state().remainingPasses, 3);
      controller.startRound();
      expect(state().card!.id, isNot(id));
    },
  );
  test('Duraklatmada saat, kart ve pas sabit kalır', () {
    setup();
    controller.startRound();
    answer(CharadesOutcome.pass);
    now += const Duration(seconds: 10);
    controller.pause();
    final before = state();
    now += const Duration(seconds: 500);
    controller.tick();
    controller.answer(before.card!.id, CharadesOutcome.correct);
    expect(state().remaining, before.remaining);
    expect(state().card!.id, before.card!.id);
    expect(state().remainingPasses, 2);
    expect(state().teams[0].score, 0);
    controller.resume();
    now += const Duration(seconds: 1);
    controller.tick();
    expect(state().remaining, before.remaining - const Duration(seconds: 1));
  });
  test('Tur sınırı yoktur; ikinci takım da hedefe ulaşarak kazanır', () {
    setup(target: 10);
    for (var i = 0; i < 11; i++) {
      controller.startRound();
      finish();
      controller.nextRound();
      expect(state().phase, GamePhase.preRound);
    }
    expect(state().activeTeam, 1);
    controller.startRound();
    for (var i = 0; i < 10; i++) {
      answer(CharadesOutcome.correct);
    }
    expect(state().winner, 1);
    expect(state().teams.map((t) => t.score), [0, 10]);
  });
  test('500 kart görülmeden tekrar yok; takım geçişi desteyi sıfırlamaz', () {
    setup(seconds: 120, target: 30);
    controller.startRound();
    final seen = <String>{};
    for (var i = 0; i < 500; i++) {
      final id = state().card!.id;
      expect(seen.add(id), isTrue);
      // End rounds rather than scoring: target and three-pass rules stay real.
      finish();
      controller.nextRound();
      controller.startRound();
      if (i < 499) {
        expect(state().deckCycle, 0);
      } else {
        expect(state().card!.id, isNot(id));
      }
    }
    expect(seen, hasLength(500));
    expect(state().deckCycle, 1);
    expect(state().teams.every((t) => t.score >= 0), isTrue);
    expect(state().phase, GamePhase.playing);
  });
  test('Tek kartlık havuz da çökmeksizin devam eder', () {
    setup(deck: cards.take(1).toList());
    controller.startRound();
    answer(CharadesOutcome.pass);
    expect(state().deckCycle, 1);
    expect(state().remainingPasses, 2);
  });
}
