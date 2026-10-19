String turkishKey(String value) =>
    value.trim().replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();

class TabuCard {
  const TabuCard({
    required this.id,
    required this.word,
    required this.forbidden,
    required this.category,
    required this.difficulty,
  });
  final String id, word, category, difficulty;
  final List<String> forbidden;

  factory TabuCard.fromJson(Map<String, dynamic> json) => TabuCard(
    id: json['id'] as String,
    word: json['word'] as String,
    forbidden: List<String>.unmodifiable(json['forbidden'] as List),
    category: json['category'] as String,
    difficulty: json['difficulty'] as String,
  );
}

class Team {
  const Team(this.name, [this.score = 0]);
  final String name;
  final int score;
  Team add(int points) => Team(name, score + points);
}

const tabuTargetScores = [10, 15, 20, 25, 30];

class GameSession {
  GameSession({
    required List<String> names,
    required this.seconds,
    this.targetScore = 20,
  }) : names = List.unmodifiable(names.map((name) => name.trim())) {
    if (names.length != 2 ||
        names.any((name) => name.trim().isEmpty) ||
        turkishKey(names[0]) == turkishKey(names[1])) {
      throw ArgumentError('İki farklı ve boş olmayan takım adı gerekli.');
    }
    if (![60, 90, 120].contains(seconds)) {
      throw ArgumentError('Geçersiz tur süresi.');
    }
    if (!tabuTargetScores.contains(targetScore)) {
      throw ArgumentError('Geçersiz hedef puan.');
    }
  }
  final List<String> names;
  final int seconds;
  final int targetScore;
}

enum GamePhase { setup, preRound, playing, roundResult, result }

enum CardOutcome { correct, taboo, pass }

class RoundScore {
  const RoundScore(this.team, this.correct, this.taboo, this.passed);
  final int team, correct, taboo, passed;
  int get points => correct - taboo;
}

class GameState {
  const GameState({
    this.session,
    this.phase = GamePhase.setup,
    this.teams = const [],
    this.deck = const [],
    this.cardIndex = -1,
    this.round = 0,
    this.remaining = Duration.zero,
    this.paused = false,
    this.correct = 0,
    this.taboo = 0,
    this.passed = 0,
    this.rounds = const [],
    this.deckCycle = 0,
  });
  final GameSession? session;
  final GamePhase phase;
  final List<Team> teams;
  final List<TabuCard> deck;
  final int cardIndex, round, correct, taboo, passed;
  final Duration remaining;
  final bool paused;
  final int deckCycle;
  final List<RoundScore> rounds;
  int get activeTeam => round % 2;
  int get remainingPasses => 3 - passed;
  TabuCard? get card =>
      cardIndex >= 0 && cardIndex < deck.length ? deck[cardIndex] : null;
  int? get targetWinner {
    if (session == null) return null;
    final index = teams.indexWhere(
      (team) => team.score >= session!.targetScore,
    );
    return index < 0 ? null : index;
  }

  int? get winner => targetWinner;

  GameState copyWith({
    GamePhase? phase,
    List<Team>? teams,
    int? cardIndex,
    int? round,
    Duration? remaining,
    bool? paused,
    int? correct,
    int? taboo,
    int? passed,
    List<RoundScore>? rounds,
    int? deckCycle,
    List<TabuCard>? deck,
  }) => GameState(
    session: session,
    phase: phase ?? this.phase,
    teams: teams ?? this.teams,
    deck: deck ?? this.deck,
    cardIndex: cardIndex ?? this.cardIndex,
    round: round ?? this.round,
    remaining: remaining ?? this.remaining,
    paused: paused ?? this.paused,
    correct: correct ?? this.correct,
    taboo: taboo ?? this.taboo,
    passed: passed ?? this.passed,
    rounds: rounds ?? this.rounds,
    deckCycle: deckCycle ?? this.deckCycle,
  );
}
