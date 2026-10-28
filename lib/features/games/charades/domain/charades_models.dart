// Reuse the existing, unchanged two-team settings and score value types.
import '../../tabu/domain/tabu_models.dart'
    show GameSession, Team, GamePhase, RoundScore;
export '../../tabu/domain/tabu_models.dart'
    show GameSession, Team, GamePhase, RoundScore, turkishKey, tabuTargetScores;

class CharadesCard {
  const CharadesCard({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
  });
  final String id, title, category, difficulty;
  factory CharadesCard.fromJson(Map<String, dynamic> json) => CharadesCard(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    difficulty: json['difficulty'] as String,
  );
}

enum CharadesOutcome { correct, pass }

class CharadesState {
  const CharadesState({
    this.session,
    this.phase = GamePhase.setup,
    this.teams = const [],
    this.deck = const [],
    this.cardIndex = -1,
    this.round = 0,
    this.remaining = Duration.zero,
    this.paused = false,
    this.correct = 0,
    this.passed = 0,
    this.rounds = const [],
    this.deckCycle = 0,
  });
  final GameSession? session;
  final GamePhase phase;
  final List<Team> teams;
  final List<CharadesCard> deck;
  final int cardIndex, round, correct, passed;
  final Duration remaining;
  final bool paused;
  final int deckCycle;
  final List<RoundScore> rounds;
  int get activeTeam => round % 2;
  int get remainingPasses => 3 - passed;
  CharadesCard? get card =>
      cardIndex >= 0 && cardIndex < deck.length ? deck[cardIndex] : null;
  int? get targetWinner {
    if (session == null) return null;
    final index = teams.indexWhere(
      (team) => team.score >= session!.targetScore,
    );
    return index < 0 ? null : index;
  }

  int? get winner => targetWinner;

  CharadesState copyWith({
    GamePhase? phase,
    List<Team>? teams,
    int? cardIndex,
    int? round,
    Duration? remaining,
    bool? paused,
    int? correct,
    int? passed,
    List<RoundScore>? rounds,
    int? deckCycle,
    List<CharadesCard>? deck,
  }) => CharadesState(
    session: session,
    phase: phase ?? this.phase,
    teams: teams ?? this.teams,
    deck: deck ?? this.deck,
    cardIndex: cardIndex ?? this.cardIndex,
    round: round ?? this.round,
    remaining: remaining ?? this.remaining,
    paused: paused ?? this.paused,
    correct: correct ?? this.correct,
    passed: passed ?? this.passed,
    rounds: rounds ?? this.rounds,
    deckCycle: deckCycle ?? this.deckCycle,
  );
}
