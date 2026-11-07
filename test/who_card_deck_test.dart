import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oynika/features/games/who_am_i/data/who_card_repository.dart';
import 'package:oynika/features/games/who_am_i/domain/who_card.dart';
import 'package:oynika/features/games/who_am_i/domain/who_card_deck.dart';
import 'package:oynika/features/games/who_am_i/domain/who_models.dart';
import 'package:oynika/features/games/who_am_i/application/who_controller.dart';
import 'package:oynika/features/games/who_am_i/application/who_deck_provider.dart';

class _RefreshController extends WhoController {
  void refreshWithSameSettings() {
    state = WhoGameSession(settings: state!.settings);
  }
}

class _BoundaryRandom implements Random {
  int calls = 0;
  bool boundarySwap = false;
  @override
  int nextInt(int max) {
    if (max == 1) {
      boundarySwap = true;
      return 0;
    }
    return calls++ == 0 ? max - 1 : 0;
  }

  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
}

void main() {
  final cards = WhoCardRepository.decode(
    File(WhoCardRepository.assetPath).readAsStringSync(),
  );
  List<String> draw(WhoCardDeck deck, int n) =>
      List.generate(n, (_) => deck.draw().id);
  test(
    'İlk karıştırma ve beş döngüde 300 benzersiz kart, sınırda tekrar yok',
    () {
      final deck = WhoCardDeck(cards: cards, random: Random(42));
      String? previous;
      for (var cycle = 0; cycle < 5; cycle++) {
        final order = draw(deck, 300);
        expect(order.toSet(), cards.map((c) => c.id).toSet());
        expect(order, isNot(orderedEquals(cards.map((c) => c.id))));
        expect(order.first, isNot(previous));
        expect(deck.remainingCount, 0);
        previous = order.last;
      }
    },
  );
  test('Sabit seed tekrarlanabilir, farklı seed farklı karıştırır', () {
    final a = draw(WhoCardDeck(cards: cards, random: Random(17)), 900);
    expect(draw(WhoCardDeck(cards: cards, random: Random(17)), 900), a);
    expect(
      draw(WhoCardDeck(cards: cards, random: Random(18)), 300),
      isNot(orderedEquals(a.take(300))),
    );
  });
  test('Döngü sınırındaki çakışma özellikle düzeltilir', () {
    final random = _BoundaryRandom();
    final deck = WhoCardDeck(cards: cards.take(2).toList(), random: random);
    final first = draw(deck, 2);
    final second = draw(deck, 2);
    expect(first.last, isNot(second.first));
    expect(random.boundarySwap, isTrue);
  });
  test('Boş ve mükerrer IDli deste reddedilir', () {
    expect(() => WhoCardDeck(cards: []), throwsArgumentError);
    expect(
      () => WhoCardDeck(cards: [cards.first, cards.first]),
      throwsArgumentError,
    );
  });
  test('Tek kartlık test havuzu tükenince güvenli yeniden kullanılır', () {
    final deck = WhoCardDeck(cards: [cards.first], random: Random(1));
    expect(draw(deck, 3), List.filled(3, cards.first.id));
  });
  test('Girdi listesinin sonradan değiştirilmesi desteyi etkilemez', () {
    final source = cards.toList();
    final deck = WhoCardDeck(cards: source, random: Random(3));
    source.clear();
    expect(draw(deck, 300).toSet(), hasLength(300));
  });
  test(
    'Oturum güncellemesi desteyi korur, reset ve yeni oyun yeni deste oluşturur',
    () async {
      final container = ProviderContainer(
        overrides: [
          whoCardsProvider.overrideWith((ref) async => cards),
          whoCardRandomProvider.overrideWithValue(Random(9)),
          whoSessionProvider.overrideWith(_RefreshController.new),
        ],
      );
      addTearDown(container.dispose);
      final sub = container.listen(whoDeckProvider, (_, _) {});
      addTearDown(sub.close);
      expect(await container.read(whoDeckProvider.future), isNull);
      final controller =
          container.read(whoSessionProvider.notifier) as _RefreshController;
      controller.start(
        names: ['Ece', 'Deniz'],
        duration: WhoRoundDuration.standard,
      );
      final deck = (await container.read(whoDeckProvider.future))!;
      final firstPlayer = draw(deck, 150);
      controller.refreshWithSameSettings();
      await container.pump();
      final nextPlayerDeck = (await container.read(whoDeckProvider.future))!;
      expect(nextPlayerDeck, same(deck));
      expect(nextPlayerDeck.remainingCount, 150);
      final secondPlayer = draw(nextPlayerDeck, 150);
      expect({...firstPlayer, ...secondPlayer}, hasLength(300));
      controller.reset();
      expect(await container.read(whoDeckProvider.future), isNull);
      controller.start(
        names: ['Ece', 'Deniz'],
        duration: WhoRoundDuration.standard,
      );
      final fresh = (await container.read(whoDeckProvider.future))!;
      expect(fresh, isNot(same(deck)));
      expect(fresh.remainingCount, 300);
      expect(draw(fresh, 150), isNot(orderedEquals(firstPlayer)));
    },
  );
  test('Gerçek yerel repository ile oturuma ait deste sağlanır', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final sub = c.listen(whoDeckProvider, (_, _) {});
    addTearDown(sub.close);
    c
        .read(whoSessionProvider.notifier)
        .start(names: ['Ece', 'Deniz'], duration: WhoRoundDuration.standard);
    final deck = (await c.read(whoDeckProvider.future))!;
    expect(deck.remainingCount, 300);
    expect(deck.draw(), isA<WhoCard>());
  });
}
