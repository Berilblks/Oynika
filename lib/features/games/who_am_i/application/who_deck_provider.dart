import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/who_card_repository.dart';
import '../domain/who_card_deck.dart';
import 'who_controller.dart';

final whoCardRandomProvider = Provider<Random>((ref) => Random());

/// Future gameplay keeps watching this provider for the lifetime of its route.
/// Settings identify a game; changes of active player must retain that instance.
final whoDeckProvider = FutureProvider.autoDispose<WhoCardDeck?>((ref) async {
  final settings = ref.watch(
    whoSessionProvider.select((session) => session?.settings),
  );
  if (settings == null) return null;
  final cards = await ref.watch(whoCardsProvider.future);
  return WhoCardDeck(cards: cards, random: ref.read(whoCardRandomProvider));
});
