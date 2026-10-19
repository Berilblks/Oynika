import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../application/game_controller.dart';
import '../data/card_repository.dart';
import '../domain/tabu_models.dart';
import 'tabu_widgets.dart';

class TabuScreen extends ConsumerStatefulWidget {
  const TabuScreen({super.key});
  @override
  ConsumerState<TabuScreen> createState() => _TabuScreenState();
}

class _TabuScreenState extends ConsumerState<TabuScreen>
    with WidgetsBindingObserver {
  final _form = GlobalKey<FormState>();
  final _purple = TextEditingController(text: 'Mor Takım');
  final _pink = TextEditingController(text: 'Pembe Takım');
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
    _purple.dispose();
    _pink.dispose();
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
          title: const Text(
            'Tabu',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          actions: [
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
        body: CustomPaint(
          painter: TabuBackgroundPainter(
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
                      playing ? 4 : 12,
                      20,
                      playing ? 12 : 24,
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

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
  Widget _title(String text) => Text(
    text,
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.headlineMedium,
  );

  Widget _setup() {
    final cards = ref.watch(tabuCardsProvider);
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'assets/illustrations/taboo.png',
            height: 105,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
          const Text(
            'Kelimeleri anlat, tabuları söyleme!',
            textAlign: TextAlign.center,
          ),
          _heading('Takım İsimleri'),
          _teamField(0, _purple),
          const SizedBox(height: 12),
          _teamField(1, _pink),
          _heading('Tur Süresi'),
          Row(
            children: [
              for (final seconds in [60, 90, 120])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Semantics(
                      selected: _seconds == seconds,
                      child: OutlinedButton(
                        key: ValueKey('duration-$seconds'),
                        onPressed: () => setState(() => _seconds = seconds),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor:
                              _seconds == seconds
                                  ? Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer
                                  : null,
                          side: BorderSide(
                            color:
                                _seconds == seconds
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$seconds',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text('saniye'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          _heading('Hedef Puan'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final target in tabuTargetScores)
                Semantics(
                  selected: _targetScore == target,
                  child: OutlinedButton(
                    key: ValueKey('target-$target'),
                    onPressed: () => setState(() => _targetScore = target),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(88, 52),
                      backgroundColor:
                          _targetScore == target
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLow,
                      side: BorderSide(
                        color:
                            _targetScore == target
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    child: Text(
                      '$target puan',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text(
              '2 takım • Sınırsız tur\nHedefe ilk ulaşan kazanır.',
              textAlign: TextAlign.center,
            ),
          ),
          cards.when(
            data:
                (deck) => TabuButton(
                  'Oyuna Başla',
                  onPressed: () {
                    if (_form.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      controller.configure(
                        GameSession(
                          names: [_purple.text, _pink.text],
                          seconds: _seconds,
                          targetScore: _targetScore,
                        ),
                        deck,
                      );
                    }
                  },
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Column(
                  children: [
                    const Text('Kartlar yüklenemedi. Lütfen tekrar dene.'),
                    TextButton(
                      onPressed: () => ref.invalidate(tabuCardsProvider),
                      child: const Text('Yeniden Dene'),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _teamField(int index, TextEditingController editing) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return TabuPanel(
      color: dark ? null : tabuPastels[index],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 12),
            child: Icon(
              Icons.workspace_premium_rounded,
              color:
                  index == 0
                      ? const Color(0xFF8751ED)
                      : const Color(0xFFE85B78),
              size: 30,
            ),
          ),
          Expanded(
            child: TextFormField(
              key: ValueKey('team-$index'),
              controller: editing,
              maxLength: 24,
              decoration: InputDecoration(
                labelText: 'Takım ${index + 1}',
                counterText: '',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Takım adı boş olamaz.';
                }
                if (turkishKey(_purple.text) == turkishKey(_pink.text)) {
                  return 'Takım adları farklı olmalı.';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

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
            CelebrationIcon(pink: state.activeTeam == 1),
            _title(state.teams[state.activeTeam].name),
            const SizedBox(height: 20),
            Text('Tur ${state.round + 1} • ${state.session!.seconds} saniye'),
            const SizedBox(height: 18),
            ScoreWidget(
              teams: state.teams,
              targetScore: state.session!.targetScore,
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
          const CelebrationIcon(),
          _title('Tur Bitti!'),
          const SizedBox(height: 24),
          TabuPanel(
            child: Column(
              children: [
                _title(state.teams[state.activeTeam].name),
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
          const SizedBox(height: 24),
          RoundScoreCards(teams: state.teams),
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
          TabuPanel(child: _title(state.teams[state.winner!].name)),
          const SizedBox(height: 28),
          const Text('Toplam Skor'),
          Text('Hedef Puan: ${state.session!.targetScore}'),
          const SizedBox(height: 12),
          ScoreWidget(teams: state.teams),
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
