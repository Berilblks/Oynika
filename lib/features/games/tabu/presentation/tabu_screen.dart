import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../application/game_controller.dart';
import '../data/card_repository.dart';
import '../domain/tabu_models.dart';
import 'tabu_widgets.dart';
import 'tabu_setup_widgets.dart';

class TabuScreen extends ConsumerStatefulWidget {
  const TabuScreen({super.key});
  @override
  ConsumerState<TabuScreen> createState() => _TabuScreenState();
}

class _TabuScreenState extends ConsumerState<TabuScreen>
    with WidgetsBindingObserver {
  final _form = GlobalKey<FormState>();
  final _blue = TextEditingController(text: 'Mavi Takım');
  final _red = TextEditingController(text: 'Kırmızı Takım');
  int _seconds = 90;
  int _targetScore = 20;
  GameController get controller => ref.read(tabuGameProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _blue.dispose();
    _red.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) controller.pause();
  }

  Future<void> _exit() async {
    if (ref.read(tabuGameProvider).phase == GamePhase.setup) {
      _leave();
      return;
    }
    controller.pause();
    final leave = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Oyundan çıkılsın mı?'),
            content: const Text('Bu oyunun skorları silinecek.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Oyunda Kal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Çık'),
              ),
            ],
          ),
    );
    if (leave == true && mounted) _leave();
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tabuGameProvider);
    final playing = state.phase == GamePhase.playing;
    final setup = state.phase == GamePhase.setup;
    final content = switch (state.phase) {
      GamePhase.setup => _setup(),
      GamePhase.preRound => _preRound(state),
      GamePhase.playing => _gameplay(state),
      GamePhase.roundResult => _roundResult(state),
      GamePhase.result => _gameResult(state),
    };
    return PopScope(
      canPop: state.phase == GamePhase.setup,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _exit();
      },
      child: Scaffold(
        backgroundColor: playing ? const Color(0xFF382078) : null,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: playing ? const Color(0xFF382078) : null,
          foregroundColor: playing ? Colors.white : null,
          leading: IconButton(
            tooltip: 'Geri',
            onPressed: _exit,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title:
              setup
                  ? null
                  : const Text(
                    'Tabu',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
          actions: [
            if (setup)
              IconButton(
                key: const ValueKey('tabu-rules'),
                tooltip: 'Oyun kuralları',
                onPressed: () => showTabuRules(context),
                icon: const Icon(Icons.info_outline_rounded),
              ),
            if (playing)
              IconButton(
                tooltip: state.paused ? 'Devam et' : 'Duraklat',
                onPressed: state.paused ? controller.resume : controller.pause,
                icon: Icon(
                  state.paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                ),
              ),
          ],
        ),
        bottomNavigationBar:
            setup && MediaQuery.viewInsetsOf(context).bottom == 0
                ? Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: SafeArea(
                    top: false,
                    minimum: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Center(
                      heightFactor: 1,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: _startAction(),
                      ),
                    ),
                  ),
                )
                : null,
        body: CustomPaint(
          painter:
              setup && Theme.of(context).brightness == Brightness.dark
                  ? null
                  : TabuBackgroundPainter(
                    dark: Theme.of(context).brightness == Brightness.dark,
                    playing: playing,
                  ),
          child: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder:
                  (context, constraints) => SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      setup
                          ? 0
                          : playing
                          ? 4
                          : 12,
                      20,
                      setup
                          ? 8
                          : playing
                          ? 12
                          : 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 480,
                          minHeight: (constraints.maxHeight -
                                  (playing ? 16 : 36))
                              .clamp(0, double.infinity),
                        ),
                        child: content,
                      ),
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(String text) => Text(
    text,
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.headlineMedium,
  );

  Widget _setup() => TabuSetupForm(
    formKey: _form,
    names: [_blue, _red],
    seconds: _seconds,
    target: _targetScore,
    onSeconds: (value) => setState(() => _seconds = value),
    onTarget: (value) => setState(() => _targetScore = value),
  );

  Widget _startAction() => ref
      .watch(tabuCardsProvider)
      .when(
        data:
            (deck) => TabuStartButton(
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                FocusScope.of(context).unfocus();
                controller.configure(
                  GameSession(
                    names: [_blue.text, _red.text],
                    seconds: _seconds,
                    targetScore: _targetScore,
                  ),
                  deck,
                );
              },
            ),
        loading: () => const TabuStartButton(onPressed: null),
        error:
            (error, stack) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Kartlar yüklenemedi. Lütfen tekrar dene.'),
                TextButton(
                  onPressed: () => ref.invalidate(tabuCardsProvider),
                  child: const Text('Yeniden Dene'),
                ),
              ],
            ),
      );

  List<Color> get _scoreColors =>
      Theme.of(context).brightness == Brightness.dark
          ? const [Color(0xFF9CC7FF), Color(0xFFFFA2B5)]
          : TabuTeamColors.accents;

  Widget _teamName(String name) => Text(
    name,
    textAlign: TextAlign.center,
    style: Theme.of(
      context,
    ).textTheme.headlineMedium?.copyWith(color: AppTheme.ink),
  );

  Widget _preRound(GameState state) => Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const SizedBox(height: 30),
      TabuPanel(
        child: Column(
          children: [
            const Text(
              'Sıra Kimde?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            CelebrationIcon(
              teamColor: TabuTeamColors.accents[state.activeTeam],
            ),
            _title(state.teams[state.activeTeam].name),
            const SizedBox(height: 20),
            Text('Tur ${state.round + 1} • ${state.session!.seconds} saniye'),
            const SizedBox(height: 18),
            ScoreWidget(
              teams: state.teams,
              targetScore: state.session!.targetScore,
              teamColors: _scoreColors,
            ),
          ],
        ),
      ),
      const SizedBox(height: 38),
      TabuButton(
        'Tura Başla',
        icon: Icons.play_arrow_rounded,
        onPressed: controller.startRound,
      ),
    ],
  );

  Widget _gameplay(GameState state) => Column(
    children: [
      ScoreWidget(
        teams: [state.teams[state.activeTeam]],
        light: true,
        targetScore: state.session!.targetScore,
        teamColors: [
          const [Color(0xFF9CC7FF), Color(0xFFFFA2B5)][state.activeTeam],
        ],
      ),
      SizedBox(height: MediaQuery.sizeOf(context).height < 700 ? 12 : 16),
      TimerWidget(remaining: state.remaining),
      SizedBox(height: MediaQuery.sizeOf(context).height < 700 ? 18 : 22),
      if (state.paused)
        TabuPanel(
          child: Column(
            children: [
              _title('Oyun Duraklatıldı'),
              const SizedBox(height: 12),
              const Text(
                'Hazır olduğunda kaldığın yerden devam et.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TabuButton(
                'Devam Et',
                onPressed: controller.resume,
                icon: Icons.play_arrow_rounded,
              ),
            ],
          ),
        )
      else
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: TabuCardWidget(
            key: ValueKey(state.card!.id),
            card: state.card!,
            color: tabuPastels[state.cardIndex % 5],
          ),
        ),
      SizedBox(height: MediaQuery.sizeOf(context).height < 700 ? 16 : 18),
      if (state.deckCycle > 0)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Tüm kartlar görüldü. Deste yeniden karıştırıldı.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _answer(
            state,
            'Tabu',
            Icons.block_rounded,
            const Color(0xFFFF657E),
            CardOutcome.taboo,
          ),
          const SizedBox(width: 10),
          _answer(
            state,
            'Pas (${state.remainingPasses})',
            Icons.swap_horiz_rounded,
            const Color(0xFFFFD35A),
            CardOutcome.pass,
          ),
          const SizedBox(width: 10),
          _answer(
            state,
            'Doğru',
            Icons.check_rounded,
            const Color(0xFF42D5AA),
            CardOutcome.correct,
          ),
        ],
      ),
    ],
  );

  Widget _answer(
    GameState state,
    String label,
    IconData icon,
    Color color,
    CardOutcome outcome,
  ) => Expanded(
    child: ElevatedButton(
      onPressed:
          state.paused ||
                  (outcome == CardOutcome.pass && state.remainingPasses <= 0)
              ? null
              : () => controller.answer(state.card!.id, outcome),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppTheme.ink,
        disabledBackgroundColor:
            outcome == CardOutcome.pass
                ? color.withValues(alpha: .25)
                : Colors.white12,
        disabledForegroundColor:
            outcome == CardOutcome.pass
                ? AppTheme.ink.withValues(alpha: .45)
                : Colors.white38,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _roundResult(GameState state) => Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        children: [
          CelebrationIcon(teamColor: TabuTeamColors.accents[state.activeTeam]),
          _title('Tur Bitti!'),
          const SizedBox(height: 24),
          TabuPanel(
            color: TabuTeamColors.pastels[state.activeTeam],
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: AppTheme.ink),
              child: Column(
                children: [
                  _teamName(state.teams[state.activeTeam].name),
                  const SizedBox(height: 10),
                  Text(
                    '${state.correct} kelime bildi!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Net puan: ${state.correct - state.taboo}'),
                  Text('${state.taboo} tabu • ${state.passed} pas'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          RoundScoreCards(teams: state.teams, colors: TabuTeamColors.pastels),
        ],
      ),
      Column(
        children: [
          const SizedBox(height: 30),
          TabuButton('Sonraki Takım', onPressed: controller.nextRound),
        ],
      ),
    ],
  );

  Widget _gameResult(GameState state) => Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        children: [
          const SizedBox(height: 22),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: .85, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutBack,
            builder:
                (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
            child: const CelebrationIcon(trophy: true),
          ),
          _title('Kazanan:'),
          const SizedBox(height: 20),
          TabuPanel(
            color: TabuTeamColors.pastels[state.winner!],
            child: _teamName(state.teams[state.winner!].name),
          ),
          const SizedBox(height: 28),
          const Text('Toplam Skor'),
          Text('Hedef Puan: ${state.session!.targetScore}'),
          const SizedBox(height: 12),
          ScoreWidget(teams: state.teams, teamColors: _scoreColors),
        ],
      ),
      Column(
        children: [
          const SizedBox(height: 30),
          TabuButton(
            'Tekrar Oyna',
            onPressed: controller.replay,
            icon: Icons.replay_rounded,
          ),
          const SizedBox(height: 14),
          TabuButton(
            'Ana Sayfaya Dön',
            onPressed: () => context.go('/'),
            secondary: true,
            icon: Icons.home_rounded,
          ),
        ],
      ),
    ],
  );
}
