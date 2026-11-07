import 'dart:math';
import 'who_card.dart';

/// A game owns one deck. Player changes never create or reset a deck.
class WhoCardDeck {
  WhoCardDeck({required List<WhoCard> cards, Random? random})
    : _cards = List.unmodifiable(cards),
      _random = random ?? Random() {
    if (_cards.isEmpty ||
        _cards.map((card) => card.id).toSet().length != _cards.length) {
      throw ArgumentError(
        'Deste boş olamaz ve kart kimlikleri benzersiz olmalı.',
      );
    }
    _shuffle();
  }
  final List<WhoCard> _cards;
  final Random _random;
  late List<WhoCard> _cycle;
  int _index = 0;
  String? _previousId;

  int get remainingCount => _cycle.length - _index;

  void _shuffle() {
    _cycle = _cards.toList()..shuffle(_random);
    if (_cycle.length > 1 && _cycle.first.id == _previousId) {
      final swap = 1 + _random.nextInt(_cycle.length - 1);
      final first = _cycle.first;
      _cycle[0] = _cycle[swap];
      _cycle[swap] = first;
    }
    _index = 0;
  }

  WhoCard draw() {
    if (_index == _cycle.length) _shuffle();
    final card = _cycle[_index++];
    _previousId = card.id;
    return card;
  }
}
