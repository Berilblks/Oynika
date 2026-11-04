import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tabu/domain/tabu_models.dart';
import '../domain/word_pair_data.dart';

enum UndercoverPhase {
  setup,
  wordDistribution,
  readyForDiscussion,
  discussion,
  voting,
  elimination,
  finished,
}

enum UndercoverRole { normal, spy }

typedef WordPair = ({String first, String second});
typedef UndercoverPlayer =
    ({int id, String name, UndercoverRole role, String word});

final undercoverPairs = List<WordPair>.unmodifiable(
  wordPairData.trim().split('\n').map((line) {
    final words = line.split('|');
    return (first: words[0], second: words[1]);
  }),
);

int spyCountFor(int count) => switch (count) {
  >= 3 && <= 5 => 1,
  >= 6 && <= 9 => 2,
  >= 10 && <= 20 => 3,
  _ => throw RangeError.range(count, 3, 20),
};

class UndercoverSession {
  const UndercoverSession({
    required this.players,
    required this.pair,
    required this.spyCount,
    this.index = 0,
    this.currentHasSeenWord = false,
  });

  final List<UndercoverPlayer> players;
  final WordPair pair;
  final int spyCount;
  final int index;
  final bool currentHasSeenWord;

  UndercoverPhase get phase =>
      index == players.length
          ? UndercoverPhase.readyForDiscussion
          : UndercoverPhase.wordDistribution;
  UndercoverPlayer? get current =>
      index < players.length ? players[index] : null;
  Iterable<int> get seenPlayerIds => players
      .take(index + (currentHasSeenWord ? 1 : 0))
      .map((player) => player.id);
}

final undercoverRandomProvider = Provider<Random>((ref) => Random.secure());
final _undercoverDeckProvider = Provider<_WordDeck>(
  (ref) => _WordDeck(ref.watch(undercoverRandomProvider)),
);
final undercoverSessionProvider =
    NotifierProvider.autoDispose<UndercoverController, UndercoverSession?>(
      UndercoverController.new,
    );

class _WordDeck {
  _WordDeck(this.random);
  final Random random;
  final _remaining = <WordPair>[];
  WordPair? _previous;

  WordPair draw() {
    if (_remaining.isEmpty) {
      _remaining.addAll(undercoverPairs);
      _remaining.shuffle(random);
      if (_remaining.last == _previous) {
        _remaining.add(_remaining.removeAt(0));
      }
    }
    return _previous = _remaining.removeLast();
  }
}

class UndercoverController extends Notifier<UndercoverSession?> {
  @override
  UndercoverSession? build() => null;

  void start(List<String> names) {
    final spyCount = spyCountFor(names.length);
    final cleaned = names.map((name) => name.trim()).toList();
    final keys = cleaned.map(turkishKey).toSet();
    if (keys.contains('') || keys.length != names.length) {
      throw ArgumentError('Oyuncu isimleri dolu ve benzersiz olmalı.');
    }
    final random = ref.read(undercoverRandomProvider);
    final ids = List<int>.generate(names.length, (index) => index);
    final spies = (ids.toList()..shuffle(random)).take(spyCount).toSet();
    final pair = ref.read(_undercoverDeckProvider).draw();
    final flip = random.nextBool();
    state = UndercoverSession(
      players: List.unmodifiable([
        for (final id in ids)
          (
            id: id,
            name: cleaned[id],
            role:
                spies.contains(id) ? UndercoverRole.spy : UndercoverRole.normal,
            word: spies.contains(id) == flip ? pair.first : pair.second,
          ),
      ]),
      pair: pair,
      spyCount: spyCount,
    );
  }

  String? reveal(int playerId) {
    final session = state;
    final player = session?.current;
    if (session == null || player == null || player.id != playerId) return null;
    state = UndercoverSession(
      players: session.players,
      pair: session.pair,
      spyCount: session.spyCount,
      index: session.index,
      currentHasSeenWord: true,
    );
    return player.word;
  }

  void next(int playerId) {
    final session = state;
    if (session == null ||
        session.current?.id != playerId ||
        !session.currentHasSeenWord) {
      return;
    }
    state = UndercoverSession(
      players: session.players,
      pair: session.pair,
      spyCount: session.spyCount,
      index: session.index + 1,
    );
  }

  void exit() => state = null;
}
