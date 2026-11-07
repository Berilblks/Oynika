import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/who_models.dart';
import '../domain/who_card.dart';
import '../domain/who_card_deck.dart';

final whoClockProvider = Provider<Duration Function()>((ref) {
  final watch = Stopwatch()..start();
  ref.onDispose(watch.stop);
  return () => watch.elapsed;
});
final whoSessionProvider =
    NotifierProvider.autoDispose<WhoController, WhoGameSession?>(
      WhoController.new,
    );

class WhoController extends Notifier<WhoGameSession?> {
  Timer? _timer;
  WhoCardDeck? _deck;
  Duration? _deadline, _unlock;
  WhoPhase? _pausedPhase;
  WhoCard? _pausedCard;
  Duration get _now => ref.read(whoClockProvider)();
  @override
  WhoGameSession? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  void start({
    required List<String> names,
    required WhoRoundDuration duration,
    int targetScore = 20,
  }) {
    if (state != null) return;
    state = WhoGameSession(
      settings: WhoGameSettings(
        names: names,
        duration: duration,
        targetScore: targetScore,
      ),
    );
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => tick());
  }

  /// The view can leave before Riverpod finishes disposing its dependency graph.
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void beginCountdown(WhoCardDeck deck, {WhoGameSettings? expectedSettings}) {
    final s = state;
    if (s == null ||
        s.phase != WhoPhase.ready ||
        (expectedSettings != null &&
            !identical(s.settings, expectedSettings))) {
      return;
    }
    _deck ??= deck;
    _deadline = _now + const Duration(seconds: 3);
    state = s.copyWith(
      phase: WhoPhase.countdown,
      countdownRemaining: const Duration(seconds: 3),
      deckRemaining: _deck!.remainingCount,
    );
    _schedule();
  }

  void tick() {
    final s = state;
    if (s == null || _deadline == null) return;
    if (s.phase == WhoPhase.countdown) {
      final left = _deadline! - _now;
      if (left <= Duration.zero) {
        _timer?.cancel();
        _deadline = null;
        state = s.copyWith(
          phase: WhoPhase.orienting,
          countdownRemaining: Duration.zero,
        );
      } else {
        state = s.copyWith(countdownRemaining: left);
      }
    } else if (s.phase == WhoPhase.playing) {
      final left = _deadline! - _now;
      if (left <= Duration.zero) {
        _timer?.cancel();
        _deadline = null;
        _unlock = null;
        final winner =
            s.sequenceComplete &&
                    s.highestScore >= s.settings.targetScore &&
                    s.leaders.length == 1
                ? s.leaders.single
                : null;
        state = s.copyWith(
          phase: winner == null ? WhoPhase.roundResult : WhoPhase.winner,
          winnerIndex: winner,
          history: [
            ...s.history,
            WhoTurnResult(
              playerIndex: s.currentPlayerIndex,
              cycle: s.cycle,
              correct: s.correct,
              passed: s.passed,
              total: s.totals[s.currentPlayerIndex],
            ),
          ],
          remaining: Duration.zero,
          clearCard: true,
          clearFeedback: true,
        );
      } else {
        state = s.copyWith(
          remaining: left,
          clearFeedback: _unlock == null || _now >= _unlock!,
        );
      }
    }
  }

  /// Acknowledged by the view only after native orientation and layout are ready.
  void confirmOrientation() {
    final s = state;
    if (s == null || s.phase != WhoPhase.orienting) return;
    final card = _deck!.draw();
    _deadline = _now + s.remaining;
    state = s.copyWith(
      phase: WhoPhase.playing,
      card: card,
      deckRemaining: _deck!.remainingCount,
    );
    _schedule();
  }

  void answer(String cardId, WhoOutcome outcome) {
    tick();
    final s = state;
    if (s == null ||
        s.phase != WhoPhase.playing ||
        s.card?.id != cardId ||
        (_unlock != null && _now < _unlock!)) {
      return;
    }
    final totals = s.totals.toList();
    final correct = outcome == WhoOutcome.correct;
    if (correct) totals[s.currentPlayerIndex]++;
    final next = _deck!.draw();
    _unlock = _now + const Duration(milliseconds: 300);
    state = s.copyWith(
      card: next,
      deckRemaining: _deck!.remainingCount,
      correct: s.correct + (correct ? 1 : 0),
      passed: s.passed + (correct ? 0 : 1),
      totals: totals,
      feedback: outcome,
      answers: [...s.answers, WhoCardAnswer(s.card!, outcome)],
    );
  }

  void pause() {
    tick();
    final s = state;
    if (s == null ||
        ![
          WhoPhase.playing,
          WhoPhase.countdown,
          WhoPhase.orienting,
        ].contains(s.phase)) {
      return;
    }
    _pausedPhase = s.phase;
    _pausedCard = s.card;
    _timer?.cancel();
    _deadline = null;
    _unlock = null;
    state = s.copyWith(
      phase: WhoPhase.paused,
      clearCard: true,
      clearFeedback: true,
    );
  }

  void resume() {
    final s = state;
    if (s == null || s.phase != WhoPhase.paused || _pausedPhase == null) return;
    final phase = _pausedPhase!;
    _deadline =
        phase == WhoPhase.orienting
            ? null
            : _now +
                (phase == WhoPhase.countdown
                    ? s.countdownRemaining
                    : s.remaining);
    state = s.copyWith(phase: phase, card: _pausedCard);
    _pausedCard = null;
    _pausedPhase = null;
    if (phase != WhoPhase.orienting) _schedule();
  }

  void nextPlayer() {
    final s = state;
    if (s == null || s.phase != WhoPhase.roundResult) return;
    _unlock = null;
    final order = s.sequenceComplete ? s.upcomingOrder : s.turnOrder;
    final position = s.sequenceComplete ? 0 : s.turnPosition + 1;
    state = s.copyWith(
      phase: WhoPhase.ready,
      currentPlayerIndex: order[position],
      turnOrder: order,
      turnPosition: position,
      cycle: s.cycle + (s.sequenceComplete ? 1 : 0),
      tieBreak:
          s.tieBreak ||
          (s.sequenceComplete && s.highestScore >= s.settings.targetScore),
      round: s.round + 1,
      remaining: Duration(seconds: s.settings.duration.seconds),
      countdownRemaining: const Duration(seconds: 3),
      correct: 0,
      passed: 0,
      answers: [],
      clearCard: true,
      clearFeedback: true,
    );
  }

  void restart() {
    final s = state;
    if (s == null) return;
    final settings = WhoGameSettings(
      names: s.settings.players.map((p) => p.name).toList(),
      duration: s.settings.duration,
      targetScore: s.settings.targetScore,
    );
    _clear();
    state = WhoGameSession(settings: settings);
  }

  void _clear() {
    _timer?.cancel();
    _timer = null;
    _deck = null;
    _deadline = null;
    _unlock = null;
    _pausedCard = null;
    _pausedPhase = null;
  }

  void reset() {
    _clear();
    state = null;
  }
}
