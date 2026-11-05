import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tabu/domain/tabu_models.dart';
import '../domain/word_data.dart';

enum UndercoverPhase {
  setup,
  wordDistribution,
  clue,
  voting,
  tie,
  elimination,
  finished,
}

enum UndercoverRole { normal, spy }

typedef UndercoverPlayer = ({int id, String name, UndercoverRole role});
typedef UndercoverSecret = ({UndercoverRole role, String? word});

final undercoverWords = List<String>.unmodifiable(
  undercoverWordData.trim().split('\n'),
);

int spyCountFor(int count) => switch (count) {
  >= 3 && <= 5 => 1,
  >= 6 && <= 9 => 2,
  >= 10 && <= 20 => 3,
  _ => throw RangeError.range(count, 3, 20),
};

class UndercoverRound {
  const UndercoverRound({
    required this.number,
    required this.order,
    this.phase = UndercoverPhase.clue,
    this.votes = const {},
    this.runoffCandidates = const [],
    this.leaders = const [],
    this.eliminatedId,
    this.winner,
  });

  final int number;
  final List<int> order;
  final UndercoverPhase phase;
  final Map<int, int> votes;
  final List<int> runoffCandidates;
  final List<int> leaders;
  final int? eliminatedId;
  final UndercoverRole? winner;

  int? get voter =>
      phase == UndercoverPhase.voting ? order[votes.length] : null;
  List<int> get candidates =>
      (runoffCandidates.isEmpty ? order : runoffCandidates)
          .where((id) => id != voter)
          .toList(growable: false);

  UndercoverRound copyWith({
    UndercoverPhase? phase,
    Map<int, int>? votes,
    List<int>? runoffCandidates,
    List<int>? leaders,
    int? eliminatedId,
    UndercoverRole? winner,
  }) => UndercoverRound(
    number: number,
    order: order,
    phase: phase ?? this.phase,
    votes: votes ?? this.votes,
    runoffCandidates: runoffCandidates ?? this.runoffCandidates,
    leaders: leaders ?? this.leaders,
    eliminatedId: eliminatedId ?? this.eliminatedId,
    winner: winner ?? this.winner,
  );
}

class UndercoverSession {
  const UndercoverSession({
    required this.players,
    required this.secretWord,
    required this.spyCount,
    this.index = 0,
    this.currentHasSeenWord = false,
    this.round,
    this.eliminationOrder = const [],
  });

  final List<UndercoverPlayer> players;
  final String secretWord;
  final int spyCount;
  final int index;
  final bool currentHasSeenWord;
  final UndercoverRound? round;
  final List<int> eliminationOrder;

  Set<int> get eliminatedIds => eliminationOrder.toSet();

  List<int> get activeIds => [
    for (final player in players)
      if (!eliminationOrder.contains(player.id)) player.id,
  ];

  UndercoverPhase get phase {
    if (round?.winner != null) return UndercoverPhase.finished;
    return round?.phase ?? UndercoverPhase.wordDistribution;
  }

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
  final _remaining = <String>[];
  String? _previous;

  String draw() {
    if (_remaining.isEmpty) {
      _remaining.addAll(undercoverWords);
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
    final secretWord = ref.read(_undercoverDeckProvider).draw();
    state = UndercoverSession(
      players: List.unmodifiable([
        for (final id in ids)
          (
            id: id,
            name: cleaned[id],
            role:
                spies.contains(id) ? UndercoverRole.spy : UndercoverRole.normal,
          ),
      ]),
      secretWord: secretWord,
      spyCount: spyCount,
    );
  }

  UndercoverSecret? reveal(int playerId) {
    final session = state;
    final player = session?.current;
    if (session == null || player == null || player.id != playerId) return null;
    state = UndercoverSession(
      players: session.players,
      secretWord: session.secretWord,
      spyCount: session.spyCount,
      index: session.index,
      currentHasSeenWord: true,
    );
    return (
      role: player.role,
      word: player.role == UndercoverRole.normal ? session.secretWord : null,
    );
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
      secretWord: session.secretWord,
      spyCount: session.spyCount,
      index: session.index + 1,
      round:
          session.index + 1 == session.players.length
              ? UndercoverRound(
                number: 1,
                order: List.unmodifiable(session.activeIds),
              )
              : null,
    );
  }

  void _saveRound(
    UndercoverSession session,
    UndercoverRound round, {
    List<int>? eliminated,
  }) {
    state = UndercoverSession(
      players: session.players,
      secretWord: session.secretWord,
      spyCount: session.spyCount,
      index: session.index,
      round: round,
      eliminationOrder: eliminated ?? session.eliminationOrder,
    );
  }

  // A callback belongs to the snapshot that rendered it. Repeated taps on a
  // stale screen cannot advance the next speaker, voter or phase.
  UndercoverSession? _at(UndercoverRound expected, UndercoverPhase phase) {
    final session = state;
    return identical(session?.round, expected) && expected.phase == phase
        ? session
        : null;
  }

  void beginVoting(UndercoverRound expected) {
    final session = _at(expected, UndercoverPhase.clue);
    if (session == null) return;
    _saveRound(session, expected.copyWith(phase: UndercoverPhase.voting));
  }

  void vote(UndercoverRound expected, int voterId, int candidateId) {
    final session = _at(expected, UndercoverPhase.voting);
    if (session == null ||
        expected.voter != voterId ||
        !expected.candidates.contains(candidateId)) {
      return;
    }
    final votes = {...expected.votes, voterId: candidateId};
    if (votes.length < expected.order.length) {
      _saveRound(session, expected.copyWith(votes: Map.unmodifiable(votes)));
      return;
    }
    final totals = {
      for (final id
          in expected.runoffCandidates.isEmpty
              ? expected.order
              : expected.runoffCandidates)
        id: 0,
    };
    for (final id in votes.values) {
      totals[id] = totals[id]! + 1;
    }
    final maxVotes = totals.values.reduce(max);
    final leaders = totals.keys.where((id) => totals[id] == maxVotes).toList();
    final counted = expected.copyWith(votes: const {});
    if (leaders.length == 1) {
      _eliminate(session, counted, leaders.single);
    } else {
      _saveRound(
        session,
        counted.copyWith(
          phase: UndercoverPhase.tie,
          leaders: List.unmodifiable(leaders),
        ),
      );
    }
  }

  void continueTie(UndercoverRound expected) {
    final session = _at(expected, UndercoverPhase.tie);
    if (session == null) return;
    if (expected.runoffCandidates.isNotEmpty) {
      _nextRound(session, expected);
      return;
    }
    _saveRound(
      session,
      expected.copyWith(
        phase: UndercoverPhase.voting,
        runoffCandidates: expected.leaders,
        leaders: const [],
      ),
    );
  }

  void _eliminate(
    UndercoverSession session,
    UndercoverRound expected,
    int eliminatedId,
  ) {
    final eliminated = [...session.eliminationOrder, eliminatedId];
    final remaining = session.players.where((p) => !eliminated.contains(p.id));
    final spies = remaining.where((p) => p.role == UndercoverRole.spy).length;
    final normals = remaining.length - spies;
    final winner =
        spies == 0
            ? UndercoverRole.normal
            : spies >= normals
            ? UndercoverRole.spy
            : null;
    _saveRound(
      session,
      expected.copyWith(
        phase: UndercoverPhase.elimination,
        eliminatedId: eliminatedId,
        winner: winner,
      ),
      eliminated: List.unmodifiable(eliminated),
    );
  }

  void continueElimination(UndercoverRound expected) {
    final session = _at(expected, UndercoverPhase.elimination);
    if (session == null || expected.winner != null) return;
    _nextRound(session, expected);
  }

  void _nextRound(UndercoverSession session, UndercoverRound previous) {
    _saveRound(
      session,
      UndercoverRound(
        number: previous.number + 1,
        order: List.unmodifiable(session.activeIds),
      ),
    );
  }

  bool restartWithSamePlayers(UndercoverSession completed) {
    if (!identical(state, completed) ||
        completed.phase != UndercoverPhase.finished) {
      return false;
    }
    start([for (final player in completed.players) player.name]);
    return true;
  }

  void exit() => state = null;
}
