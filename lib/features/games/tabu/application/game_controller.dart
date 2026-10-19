import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/tabu_models.dart';

final tabuClockProvider = Provider<Duration Function()>((ref) {
  final watch = Stopwatch()..start();
  ref.onDispose(watch.stop);
  return () => watch.elapsed;
});

final tabuGameProvider =
    NotifierProvider.autoDispose<GameController, GameState>(GameController.new);

class GameController extends Notifier<GameState> {
  Timer? _timer;
  Duration? _deadline, _lastAnswer;
  Random _random = Random();
  Duration get _now => ref.read(tabuClockProvider)();

  @override
  GameState build() {
    ref.onDispose(() => _timer?.cancel());
    return const GameState();
  }

  void configure(GameSession session, List<TabuCard> cards, {Random? random}) {
    if (cards.isEmpty) throw ArgumentError('Kart havuzu boş.');
    _timer?.cancel();
    _lastAnswer = null;
    _deadline = null;
    _random = random ?? Random();
    final deck = List<TabuCard>.of(cards)..shuffle(_random);
    state = GameState(
      session: session,
      phase: GamePhase.preRound,
      teams: List.unmodifiable(session.names.map(Team.new)),
      deck: List.unmodifiable(deck),
      remaining: Duration(seconds: session.seconds),
    );
  }

  void startRound() {
    if (state.phase != GamePhase.preRound) return;
    _advanceCard();
    state = state.copyWith(phase: GamePhase.playing, paused: false);
    _lastAnswer = null;
    _deadline = _now + state.remaining;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => tick());
  }

  void tick() {
    if (state.phase != GamePhase.playing || state.paused) return;
    final remaining = _deadline! - _now;
    if (remaining <= Duration.zero) {
      _finishRound();
    } else {
      state = state.copyWith(remaining: remaining);
    }
  }

  void pause() {
    if (state.phase != GamePhase.playing || state.paused) return;
    tick();
    if (state.phase != GamePhase.playing) return;
    state = state.copyWith(paused: true);
  }

  void resume() {
    if (state.phase != GamePhase.playing || !state.paused) return;
    _deadline = _now + state.remaining;
    state = state.copyWith(paused: false);
  }

  void answer(String cardId, CardOutcome outcome) {
    if (state.phase != GamePhase.playing || state.paused) return;
    tick();
    if (state.phase != GamePhase.playing || state.card?.id != cardId) return;
    if (outcome == CardOutcome.pass && state.remainingPasses <= 0) return;
    if (_lastAnswer != null &&
        _now - _lastAnswer! < const Duration(milliseconds: 350)) {
      return;
    }
    _lastAnswer = _now;
    final points = switch (outcome) {
      CardOutcome.correct => 1,
      CardOutcome.taboo => -1,
      CardOutcome.pass => 0,
    };
    final teams = List<Team>.of(state.teams);
    teams[state.activeTeam] = teams[state.activeTeam].add(points);
    state = state.copyWith(
      teams: List.unmodifiable(teams),
      correct: state.correct + (outcome == CardOutcome.correct ? 1 : 0),
      taboo: state.taboo + (outcome == CardOutcome.taboo ? 1 : 0),
      passed: state.passed + (outcome == CardOutcome.pass ? 1 : 0),
    );
    if (state.targetWinner != null) {
      _finishRound(targetReached: true);
      return;
    }
    _advanceCard();
  }

  void _advanceCard() {
    final next = state.cardIndex + 1;
    if (next >= state.deck.length) {
      final previousId = state.card?.id;
      final deck = List<TabuCard>.of(state.deck)..shuffle(_random);
      if (deck.length > 1 && deck.first.id == previousId) {
        final first = deck[0];
        deck[0] = deck[1];
        deck[1] = first;
      }
      state = state.copyWith(
        deck: List.unmodifiable(deck),
        cardIndex: 0,
        deckCycle: state.deckCycle + 1,
      );
    } else {
      state = state.copyWith(cardIndex: next);
    }
  }

  void _finishRound({bool targetReached = false}) {
    _timer?.cancel();
    state = state.copyWith(
      phase: targetReached ? GamePhase.result : GamePhase.roundResult,
      remaining: Duration.zero,
      paused: false,
      rounds: List.unmodifiable([
        ...state.rounds,
        RoundScore(state.activeTeam, state.correct, state.taboo, state.passed),
      ]),
    );
  }

  void nextRound() {
    if (state.phase != GamePhase.roundResult) return;
    state = state.copyWith(
      phase: GamePhase.preRound,
      round: state.round + 1,
      remaining: Duration(seconds: state.session!.seconds),
      correct: 0,
      taboo: 0,
      passed: 0,
    );
  }

  void replay() {
    if (state.phase == GamePhase.result) configure(state.session!, state.deck);
  }
}
