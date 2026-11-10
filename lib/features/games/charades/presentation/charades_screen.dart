import '../../../../core/ads/google_ads_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../application/charades_controller.dart';
import '../data/charades_repository.dart';
import '../domain/charades_models.dart';
import '../../tabu/presentation/tabu_widgets.dart';
import 'charades_card_widget.dart';
import 'charades_setup_widgets.dart';

class CharadesScreen extends ConsumerStatefulWidget {
  const CharadesScreen({super.key});
  @override
  ConsumerState<CharadesScreen> createState() => _CharadesScreenState();
}

class _CharadesScreenState extends ConsumerState<CharadesScreen>
    with WidgetsBindingObserver {
  final _form = GlobalKey<FormState>();
  final _blue = TextEditingController(text: 'Mavi Takım');
  final _red = TextEditingController(text: 'Kırmızı Takım');
  int _seconds = 90;
  int _targetScore = 20;
  bool _askingExit = false;
  CharadesController get controller => ref.read(charadesGameProvider.notifier);

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
    if (!mounted || _askingExit) return;
    final result = ref.read(charadesGameProvider);
    if (result.phase == GamePhase.result) {
      _leaveResult(result, () => context.go('/games'));
      return;
    }
    if (ref.read(charadesGameProvider).phase == GamePhase.setup) {
      _leave();
      return;
    }
    controller.pause();
    _askingExit = true;
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
    _askingExit = false;
    if (leave == true && mounted) _leave();
  }

  void _leaveResult(CharadesState result, VoidCallback leave) {
    if (!mounted) return;
    ref
        .read(adsServiceProvider)
        .leaveResult(
          result,
          () => mounted && identical(ref.read(charadesGameProvider), result),
          leave,
        );
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/games');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charadesGameProvider);
    if (state.phase == GamePhase.result) {
      ref.read(adsServiceProvider).recordCompletion(state);
    }
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
                    'Sessiz Sinema',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
          actions: [
            if (setup)
              IconButton(
                key: const ValueKey('charades-rules'),
                tooltip: 'Oyun kuralları',
                onPressed: () => showCharadesRules(context),
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

  Widget _setup() => CharadesSetupForm(
    formKey: _form,
    names: [_blue, _red],
    seconds: _seconds,
    target: _targetScore,
    onSeconds: (value) => setState(() => _seconds = value),
    onTarget: (value) => setState(() => _targetScore = value),
  );

  Widget _startAction() => ref
      .watch(charadesCardsProvider)
      .when(
        data:
            (deck) => CharadesStartButton(
              onPressed: () {
                if (_form.currentState!.validate()) {
                  FocusScope.of(context).unfocus();
                  controller.configure(
                    GameSession(
                      names: [_blue.text, _red.text],
                      seconds: _seconds,
                      targetScore: _targetScore,
                    ),
                    deck,
                  );
                }
              },
            ),
        loading: () => const CharadesStartButton(onPressed: null),
        error:
            (error, stack) => TextButton(
              onPressed: () => ref.invalidate(charadesCardsProvider),
              child: const Text('Kartlar yüklenemedi. Yeniden Dene'),
            ),
      );

  Widget _preRound(CharadesState state) => Column(
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
              teamColor: CharadesTeamColors.accents[state.activeTeam],
            ),
            _title(state.teams[state.activeTeam].name),
            const SizedBox(height: 14),
            const Text(
              'Bir oyuncu kartı görsün ve konuşmadan anlatsın.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text('Tur ${state.round + 1} • ${state.session!.seconds} saniye'),
            const SizedBox(height: 18),
            ScoreWidget(
              teams: state.teams,
              teamColors: [
                for (var i = 0; i < 2; i++)
                  CharadesTeamColors.schemeFor(context, i).primary,
              ],
              targetScore: state.session!.targetScore,
            ),
          ],
        ),
      ),
      const SizedBox(height: 38),
      TabuButton(
        'Hazırım',
        icon: Icons.play_arrow_rounded,
        onPressed: controller.startRound,
      ),
    ],
  );

  Widget _gameplay(CharadesState state) => Column(
    children: [
      Text(
        'Sıra: ${state.teams[state.activeTeam].name}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 10),
      ScoreWidget(
        teams: state.teams,
        teamColors: CharadesTeamColors.pastels,
        light: true,
        targetScore: state.session!.targetScore,
      ),
      const SizedBox(height: 14),
      TimerWidget(remaining: state.remaining),
      const SizedBox(height: 20),
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
              const SizedBox(height: 18),
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
          duration: const Duration(milliseconds: 180),
          child: CharadesCardWidget(
            key: ValueKey(state.card!.id),
            card: state.card!,
          ),
        ),
      const SizedBox(height: 18),
      if (state.deckCycle > 0)
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Tüm yapımlar görüldü. Deste yeniden karıştırıldı.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      Row(
        children: [
          _answer(
            state,
            'Pas',
            Icons.swap_horiz_rounded,
            const Color(0xFFFFE5A8),
            CharadesOutcome.pass,
          ),
          const SizedBox(width: 14),
          _answer(
            state,
            'Doğru',
            Icons.check_rounded,
            const Color(0xFFD9F5E8),
            CharadesOutcome.correct,
          ),
        ],
      ),
    ],
  );

  Widget _answer(
    CharadesState state,
    String label,
    IconData icon,
    Color color,
    CharadesOutcome outcome,
  ) => Expanded(
    child: ElevatedButton(
      onPressed:
          state.paused
              ? null
              : () => controller.answer(state.card!.id, outcome),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppTheme.ink,
        disabledBackgroundColor:
            outcome == CharadesOutcome.pass
                ? color.withValues(alpha: .25)
                : Colors.white12,
        disabledForegroundColor:
            outcome == CharadesOutcome.pass
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

  Widget _roundResult(CharadesState state) => Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        children: [
          CelebrationIcon(
            teamColor: CharadesTeamColors.accents[state.activeTeam],
          ),
          _title('Tur Bitti!'),
          const SizedBox(height: 24),
          TabuPanel(
            child: Column(
              children: [
                _title(state.teams[state.activeTeam].name),
                const SizedBox(height: 14),
                const Text(
                  'Bir oyuncu kartı görsün ve konuşmadan anlatsın.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '${state.correct} kelime bildi!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Net puan: ${state.correct}'),
                Text('${state.passed} pas kullanıldı'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          RoundScoreCards(
            teams: state.teams,
            colors: CharadesTeamColors.pastels,
          ),
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

  Widget _gameResult(CharadesState state) => Column(
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
          ScoreWidget(
            teams: state.teams,
            teamColors: [
              for (var i = 0; i < 2; i++)
                CharadesTeamColors.schemeFor(context, i).primary,
            ],
          ),
        ],
      ),
      Column(
        children: [
          const SizedBox(height: 30),
          TabuButton(
            'Tekrar Oyna',
            onPressed: () => _leaveResult(state, controller.replay),
            icon: Icons.replay_rounded,
          ),
          const SizedBox(height: 14),
          TabuButton(
            'Oyunlara Dön',
            onPressed: () => _leaveResult(state, () => context.go('/games')),
            secondary: true,
            icon: Icons.home_rounded,
          ),
        ],
      ),
    ],
  );
}
