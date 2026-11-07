import 'who_card.dart';

enum WhoRoundDuration {
  short(60),
  standard(90),
  long(120);

  const WhoRoundDuration(this.seconds);
  final int seconds;
}

class WhoPlayer {
  const WhoPlayer({required this.id, required this.name});
  final int id;
  final String name;
}

String whoNameKey(String name) =>
    name.trim().replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();

class WhoGameSettings {
  static const targetScores = [10, 15, 20, 25, 30];
  WhoGameSettings({
    required List<String> names,
    this.duration = WhoRoundDuration.standard,
    this.targetScore = 20,
  }) : players = List.unmodifiable([
         for (final (index, name) in names.indexed)
           WhoPlayer(id: index, name: name.trim()),
       ]) {
    if (players.length < 2 || players.length > 20) {
      throw ArgumentError('Oyuncu sayısı 2–20 arasında olmalı.');
    }
    if (!targetScores.contains(targetScore)) {
      throw ArgumentError('Geçersiz hedef puan.');
    }
    if (players.any((player) => player.name.isEmpty)) {
      throw ArgumentError('Oyuncu adı boş olamaz.');
    }
    if (players.map((player) => whoNameKey(player.name)).toSet().length !=
        players.length) {
      throw ArgumentError('Oyuncu isimleri farklı olmalı.');
    }
  }
  final List<WhoPlayer> players;
  final WhoRoundDuration duration;
  final int targetScore;
}

enum WhoPhase {
  ready,
  countdown,
  orienting,
  playing,
  paused,
  roundResult,
  winner,
}

enum WhoOutcome { correct, pass }

class WhoCardAnswer {
  const WhoCardAnswer(this.card, this.outcome);
  final WhoCard card;
  final WhoOutcome outcome;
}

class WhoTurnResult {
  const WhoTurnResult({
    required this.playerIndex,
    required this.cycle,
    required this.correct,
    required this.passed,
    required this.total,
  });
  final int playerIndex, cycle, correct, passed, total;
  int get points => correct;
}

class WhoGameSession {
  WhoGameSession({
    required this.settings,
    this.currentPlayerIndex = 0,
    this.phase = WhoPhase.ready,
    Duration? remaining,
    this.countdownRemaining = const Duration(seconds: 3),
    this.card,
    this.correct = 0,
    this.passed = 0,
    this.round = 1,
    this.deckRemaining = 300,
    this.feedback,
    this.turnPosition = 0,
    this.cycle = 1,
    this.tieBreak = false,
    this.winnerIndex,
    List<int>? turnOrder,
    List<WhoTurnResult> history = const [],
    List<int>? totals,
    List<WhoCardAnswer> answers = const [],
  }) : turnOrder = List.unmodifiable(
         turnOrder ?? List.generate(settings.players.length, (i) => i),
       ),
       history = List.unmodifiable(history),
       remaining = remaining ?? Duration(seconds: settings.duration.seconds),
       totals = List.unmodifiable(
         totals ?? List.filled(settings.players.length, 0),
       ),
       answers = List.unmodifiable(answers);
  final WhoGameSettings settings;
  final int currentPlayerIndex;
  final WhoPhase phase;
  final Duration remaining, countdownRemaining;
  final WhoCard? card;
  final int correct, passed, round, deckRemaining;
  final WhoOutcome? feedback;
  final List<int> totals;
  final List<WhoCardAnswer> answers;
  final List<int> turnOrder;
  final List<WhoTurnResult> history;
  final int turnPosition, cycle;
  final bool tieBreak;
  final int? winnerIndex;
  bool get sequenceComplete => turnPosition == turnOrder.length - 1;
  int get highestScore =>
      turnOrder.map((i) => totals[i]).reduce((a, b) => a > b ? a : b);
  List<int> get leaders =>
      turnOrder.where((i) => totals[i] == highestScore).toList();
  List<int> get upcomingOrder =>
      sequenceComplete && highestScore >= settings.targetScore
          ? leaders
          : turnOrder;
  List<int> get ranking =>
      List<int>.generate(settings.players.length, (i) => i)..sort((a, b) {
        final byScore = totals[b].compareTo(totals[a]);
        return byScore == 0 ? a.compareTo(b) : byScore;
      });
  WhoTurnResult? lastTurn(int playerIndex) {
    for (final result in history.reversed) {
      if (result.playerIndex == playerIndex) return result;
    }
    return null;
  }

  WhoPlayer get currentPlayer => settings.players[currentPlayerIndex];
  WhoPlayer get nextPlayer =>
      settings.players[sequenceComplete
          ? upcomingOrder.first
          : turnOrder[turnPosition + 1]];
  int get roundPoints => correct;
  int get countdown => (countdownRemaining.inMilliseconds + 999) ~/ 1000;

  WhoGameSession copyWith({
    int? currentPlayerIndex,
    WhoPhase? phase,
    Duration? remaining,
    Duration? countdownRemaining,
    WhoCard? card,
    bool clearCard = false,
    int? correct,
    int? passed,
    int? round,
    int? deckRemaining,
    WhoOutcome? feedback,
    bool clearFeedback = false,
    List<int>? totals,
    List<WhoCardAnswer>? answers,
    int? turnPosition,
    int? cycle,
    bool? tieBreak,
    int? winnerIndex,
    List<int>? turnOrder,
    List<WhoTurnResult>? history,
  }) => WhoGameSession(
    settings: settings,
    currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
    phase: phase ?? this.phase,
    remaining: remaining ?? this.remaining,
    countdownRemaining: countdownRemaining ?? this.countdownRemaining,
    card: clearCard ? null : card ?? this.card,
    correct: correct ?? this.correct,
    passed: passed ?? this.passed,
    round: round ?? this.round,
    deckRemaining: deckRemaining ?? this.deckRemaining,
    feedback: clearFeedback ? null : feedback ?? this.feedback,
    totals: totals ?? this.totals,
    answers: answers ?? this.answers,
    turnPosition: turnPosition ?? this.turnPosition,
    cycle: cycle ?? this.cycle,
    tieBreak: tieBreak ?? this.tieBreak,
    winnerIndex: winnerIndex ?? this.winnerIndex,
    turnOrder: turnOrder ?? this.turnOrder,
    history: history ?? this.history,
  );
}
