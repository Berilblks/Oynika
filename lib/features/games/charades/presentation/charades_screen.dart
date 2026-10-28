import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../application/charades_controller.dart';
import '../data/charades_repository.dart';
import '../domain/charades_models.dart';
import '../../tabu/presentation/tabu_widgets.dart';
import 'charades_card_widget.dart';

class CharadesScreen extends ConsumerStatefulWidget {
  const CharadesScreen({super.key});
  @override
  ConsumerState<CharadesScreen> createState() => _CharadesScreenState();
}

class _CharadesScreenState extends ConsumerState<CharadesScreen>
    with WidgetsBindingObserver {
  final _form = GlobalKey<FormState>();
  final _purple = TextEditingController(text: 'Mor Takım');
  final _pink = TextEditingController(text: 'Pembe Takım');
  int _seconds = 90;
  int _targetScore = 20;
  CharadesController get controller => ref.read(charadesGameProvider.notifier);

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
    if (ref.read(charadesGameProvider).phase == GamePhase.result) {
      context.go('/games');
      return;
    }
    if (ref.read(charadesGameProvider).phase == GamePhase.setup) {
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
      context.go('/games');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charadesGameProvider);
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
            'Sessiz Sinema',
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
    final cards = ref.watch(charadesCardsProvider);
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'assets/illustrations/charades.png',
            height: 105,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
          const Text(
            'Konuşma, ses çıkarma; harf söyleme veya yazı yazma.\nFilm ve dizi adlarını yalnızca hareketlerle anlat!',
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
                      onPressed: () => ref.invalidate(charadesCardsProvider),
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
            CelebrationIcon(pink: state.activeTeam == 1),
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
            'Pas (${state.remainingPasses})',
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
          state.paused ||
                  (outcome == CharadesOutcome.pass &&
                      state.remainingPasses <= 0)
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
          const CelebrationIcon(),
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
            'Oyunlara Dön',
            onPressed: () => context.go('/games'),
            secondary: true,
            icon: Icons.home_rounded,
          ),
        ],
      ),
    ],
  );
}
