import '../../../../core/ads/google_ads_backend.dart';
import 'package:go_router/go_router.dart';
import 'who_scoreboard.dart';
import 'who_winner_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_orientation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/game_art.dart';
import '../../domain/party_game.dart';
import '../application/who_controller.dart';
import '../application/who_motion_provider.dart';
import '../application/who_motion_service.dart';
import '../domain/who_tilt_detector.dart';
import '../application/who_deck_provider.dart';
import '../data/who_card_repository.dart';
import '../domain/who_models.dart';
import 'who_page.dart';
import 'who_landscape_board.dart';
import 'who_orientation_provider.dart';
import 'who_motion_debug_panel.dart';

class WhoGameScreen extends ConsumerStatefulWidget {
  const WhoGameScreen({super.key});
  @override
  ConsumerState<WhoGameScreen> createState() => _WhoGameScreenState();
}

class _WhoGameScreenState extends ConsumerState<WhoGameScreen>
    with WidgetsBindingObserver {
  bool _asking = false;
  bool _resuming = false, _orientationReady = false;
  bool? _desiredLandscape;
  bool _orientationError = false;
  int _orientationEpoch = 0;
  late final OrientationLease _orientation;
  late final WhoController _controller;
  late final WhoMotionService _motion;
  late bool _useMotion;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(whoSessionProvider.notifier);
    _useMotion = ref.read(whoMotionPreferredProvider);
    _motion = ref.read(whoMotionFactoryProvider)();
    _motion.onChanged = () {
      if (mounted && whoMotionDebugEnabled) setState(() {});
    };
    WidgetsBinding.instance.addObserver(this);
    _orientation = ref.read(whoOrientationProvider).acquire();
    _syncOrientation(false);
  }

  @override
  void dispose() {
    _motion.dispose();
    _orientationEpoch++;
    unawaited(_orientation.close().then<void>((_) {}, onError: (Object _) {}));
    _controller.stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _wantsLandscape(WhoPhase? phase) =>
      _resuming ||
      [
        WhoPhase.countdown,
        WhoPhase.orienting,
        WhoPhase.playing,
      ].contains(phase);

  void _syncOrientation(bool landscape) {
    if (_desiredLandscape == landscape && !_orientationError) return;
    _desiredLandscape = landscape;
    _orientationReady = false;
    _orientationError = false;
    final epoch = ++_orientationEpoch;
    unawaited(() async {
      try {
        final applied = await _orientation.setLandscape(landscape);
        if (!mounted || epoch != _orientationEpoch) return;
        setState(() => _orientationReady = applied);
      } catch (_) {
        if (!mounted || epoch != _orientationEpoch) return;
        setState(() => _orientationError = true);
      }
    }());
  }

  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final size = View.of(context).physicalSize;
    if (size.width <= size.height &&
        ref.read(whoSessionProvider)?.phase == WhoPhase.playing) {
      _resuming = false;
      _controller.pause();
      _syncOrientation(false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _stopMotion();
    // Rotation can temporarily remove window focus. During this gate no secret
    // is visible and the round clock has not started; do not undo the rotation.
    final phase = ref.read(whoSessionProvider)?.phase;
    if (state == AppLifecycleState.inactive &&
        (_resuming ||
            phase == WhoPhase.countdown ||
            phase == WhoPhase.orienting)) {
      return;
    }
    if (state != AppLifecycleState.resumed) {
      _resuming = false;
      _controller.pause();
      _syncOrientation(false);
    } else {
      _syncOrientation(_wantsLandscape(ref.read(whoSessionProvider)?.phase));
    }
  }

  void _resumeWithOrientation() {
    if (!mounted) return;
    setState(() => _resuming = true);
    _syncOrientation(true);
  }

  bool get _canStart {
    final size = MediaQuery.sizeOf(context);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (!_orientationReady ||
        _desiredLandscape != true ||
        size.width <= size.height ||
        (lifecycle != null && lifecycle != AppLifecycleState.resumed)) {
      return false;
    }
    return true;
  }

  void _stopMotion() {
    _motion.stop();
  }

  void _confirmReady({bool touchOnly = false}) {
    if (!mounted || _asking || !_canStart) return;
    final phase = ref.read(whoSessionProvider)?.phase;
    if (phase != WhoPhase.orienting &&
        !(phase == WhoPhase.paused && _resuming)) {
      return;
    }
    if (touchOnly) {
      _stopMotion();
      _useMotion = false;
    }
    _resuming = false;
    if (ref.read(whoSessionProvider)?.phase == WhoPhase.paused) {
      _controller.resume();
    }
    if (ref.read(whoSessionProvider)?.phase == WhoPhase.orienting) {
      _controller.confirmOrientation();
    }
    _syncOrientation(_wantsLandscape(ref.read(whoSessionProvider)?.phase));
    if (_useMotion) _startMotion();
  }

  void _startMotion() {
    if (!mounted) return;
    final round = ref.read(whoSessionProvider);
    if (round == null || round.phase != WhoPhase.playing || !_canStart) return;
    _motion.startAutomatic();
    _motion.onTilt = (direction) {
      final current = ref.read(whoSessionProvider);
      if (!mounted ||
          current == null ||
          current.phase != WhoPhase.playing ||
          !identical(current.settings, round.settings) ||
          current.round != round.round ||
          !_canStart ||
          _motion.state != WhoMotionState.active) {
        return;
      }
      _answer(
        current.card!.id,
        direction == WhoTiltDirection.forward
            ? WhoOutcome.correct
            : WhoOutcome.pass,
      );
    };
  }

  void _answer(String cardId, WhoOutcome outcome) {
    if (!mounted) return;
    final before = ref.read(whoSessionProvider)?.answers.length;
    _controller.answer(cardId, outcome);
    if (ref.read(whoSessionProvider)?.answers.length != before) {
      _motion.afterAnswer(outcome == WhoOutcome.correct ? 'Doğru +1' : 'Pas');
    }
  }

  Future<void> _confirm({bool restart = false}) async {
    if (!mounted || _asking) return;
    _stopMotion();
    final controller = ref.read(whoSessionProvider.notifier);
    _resuming = false;
    controller.pause();
    _syncOrientation(false);
    setState(() => _asking = true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          restart ? 'Oyunu yeniden başlat?' : 'Oyundan çıkmak istiyor musun?',
        ),
        content: Text(
          restart
              ? 'Puanlar sıfırlanacak. Oyuncular ve tur süresi korunacak.'
              : 'Bu oyundaki ilerlemen kaybolacak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(restart ? 'Yeniden Başlat' : 'Çık'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _asking = false);
    if (confirmed == true) {
      if (restart) {
        controller.restart();
      } else {
        controller.reset();
      }
    }
  }

  String _time(Duration time) {
    final seconds = (time.inMilliseconds + 999) ~/ 1000;
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  Widget _button(
    String label,
    VoidCallback? action, {
    Color? color,
    IconData? icon,
  }) => FilledButton(
    onPressed: _asking ? null : action,
    style: FilledButton.styleFrom(
      backgroundColor: color ?? const Color(0xFF46309B),
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 56),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 6),
        ],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    ),
  );

  Widget _turningPage(WhoGameSession s, bool landscape) {
    final countdown = s.phase == WhoPhase.countdown && !_resuming;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirm();
      },
      child: WhoPage(
        showAppBar: false,
        onBack: () => _confirm(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Geri',
                    onPressed: () => _confirm(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      s.currentPlayer.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Duraklat',
                    onPressed: _controller.pause,
                    icon: const Icon(Icons.pause_rounded),
                  ),
                ],
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) => Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: box.maxWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.screen_rotation_rounded, size: 36),
                            if (countdown)
                              Text(
                                '${s.countdown}',
                                key: const ValueKey('who-countdown'),
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      fontSize: 76,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              'Telefonunu yan çevir ve alnına yerleştir!',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (!countdown) ...[
                              const SizedBox(height: 12),
                              Text(
                                _orientationError
                                    ? 'Yatay görünüm hazırlanamadı. Tekrar deneyebilirsin.'
                                    : !landscape
                                    ? 'Yatay görünüm bekleniyor. Telefonunu yan çevir ve uygulamayı tam ekranda aç.'
                                    : 'Hazırım ile kelime ve süre hemen başlar. Sensör oyun sırasında otomatik hazırlanır.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Öne eğ: Doğru (+1) • Arkaya eğ: Pas\nYeni kart için telefonu düz konuma getir.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (countdown)
                _button(
                  'Duraklat',
                  _controller.pause,
                  icon: Icons.pause_rounded,
                )
              else if (_orientationError)
                _button('Yeniden Dene', () => _syncOrientation(true))
              else
                _button(
                  'Hazırım',

                  _orientationReady && landscape && _desiredLandscape == true
                      ? _confirmReady
                      : null,
                  icon: Icons.play_arrow_rounded,
                ),
              if (!countdown)
                TextButton(
                  onPressed:
                      _orientationReady && landscape
                          ? () => _confirmReady(touchOnly: true)
                          : null,
                  child: const Text('Dokunmatik Devam Et'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(whoSessionProvider, (previous, next) {
      if (previous?.phase != next?.phase) {
        if (next?.phase != WhoPhase.playing) _stopMotion();
        _syncOrientation(_wantsLandscape(next?.phase));
      }
    });
    final s = ref.watch(whoSessionProvider)!;
    final controller = ref.read(whoSessionProvider.notifier);
    final deck = ref.watch(whoDeckProvider);
    final readyDeck =
        !deck.isLoading && !deck.hasError ? deck.asData?.value : null;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final landscape = size.width > size.height;
    if (s.phase == WhoPhase.countdown ||
        s.phase == WhoPhase.orienting ||
        _resuming ||
        (s.phase == WhoPhase.playing && (!_orientationReady || !landscape))) {
      return _turningPage(s, landscape);
    }
    if (s.phase == WhoPhase.playing) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirm();
        },
        child: WhoPage(
          landscapeGame: true,
          showAppBar: false,
          onBack: () => _confirm(),
          body: WhoLandscapeBoard(
            session: s,
            motionDiagnostics:
                whoMotionDebugEnabled ? _motion.diagnostics : null,
            onResetMotion: _startMotion,
            onExit: () => _confirm(),
            onPause: _controller.pause,
            onCorrect:
                _asking || s.feedback != null
                    ? null
                    : () => _answer(s.card!.id, WhoOutcome.correct),
            onPass:
                _asking || s.feedback != null
                    ? null
                    : () => _answer(s.card!.id, WhoOutcome.pass),
          ),
        ),
      );
    }
    final roundIdentity = s.history.isEmpty ? s : s.history.last;
    if (s.phase == WhoPhase.roundResult) {
      ref.read(adsServiceProvider).recordRound(roundIdentity);
    }
    if (s.phase == WhoPhase.winner) {
      final ads = ref.read(adsServiceProvider)
        ..recordCompletion(s, round: roundIdentity);
      bool isCurrent() => mounted && identical(ref.read(whoSessionProvider), s);
      return WhoWinnerScreen(
        session: s,
        onReplay: () => ads.leaveResult(
          s,
          isCurrent,
          controller.restart,
          round: roundIdentity,
        ),
        onGames: () => ads.leaveResult(s, isCurrent, () {
          _stopMotion();
          controller.reset();
          context.go('/games');
        }, round: roundIdentity),
      );
    }
    late Widget content, bottom;
    switch (s.phase) {
      case WhoPhase.ready:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GameArt(game: PartyGame.whoAmI, height: 100),
            const SizedBox(height: 24),
            Text(
              'Sıra Sende, ${s.currentPlayer.name}!',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Telefonu alnına yerleştir.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Arkadaşlarının verdiği ipuçlarıyla kelimeyi tahmin et.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '${s.settings.duration.seconds} saniyelik tur • Toplam puan: ${s.totals[s.currentPlayerIndex]}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Hedef puan: ${s.settings.targetScore} • ${s.tieBreak ? 'Ek tur' : 'Tur sırası'} ${s.cycle}',
              textAlign: TextAlign.center,
            ),
            if (deck.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Kartlar hazırlanıyor…'),
              ),
            if (deck.hasError)
              TextButton(
                onPressed: () => ref.invalidate(whoCardsProvider),
                child: const Text('Kartlar yüklenemedi. Tekrar Dene'),
              ),
          ],
        );
        bottom = _button(
          'Başlamaya Hazırım',
          readyDeck == null
              ? null
              : () => controller.beginCountdown(
                readyDeck,
                expectedSettings: s.settings,
              ),
          icon: Icons.play_arrow_rounded,
        );
      case WhoPhase.winner:
      case WhoPhase.countdown:
      case WhoPhase.orienting:
      case WhoPhase.playing:
        throw StateError('Landscape phase must use the dedicated layout.');
      case WhoPhase.paused:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pause_circle_outline_rounded,
              size: 68,
              color: colors.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Tur Duraklatıldı',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(s.currentPlayer.name, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Kalan süre: ${_time(s.remaining)}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Hazır olduğunda devam edebilirsin.',
              textAlign: TextAlign.center,
            ),
          ],
        );
        bottom = _button('Devam Et', () {
          final lifecycle = WidgetsBinding.instance.lifecycleState;
          if (lifecycle == null || lifecycle == AppLifecycleState.resumed) {
            _resumeWithOrientation();
          }
        }, icon: Icons.play_arrow_rounded);
      case WhoPhase.roundResult:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GameArt(game: PartyGame.whoAmI, height: 84),
            const SizedBox(height: 20),
            Text(
              'Tur Bitti!',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            Text(
              s.currentPlayer.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    'Doğru: ${s.correct} • Pas: ${s.passed}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kazanılan puan: ${s.roundPoints}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Toplam puan: ${s.totals[s.currentPlayerIndex]}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sıradaki oyuncu: ${s.nextPlayer.name}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Hedef puan: ${s.settings.targetScore}',
              textAlign: TextAlign.center,
            ),
            if (s.sequenceComplete &&
                s.highestScore >= s.settings.targetScore &&
                s.leaders.length > 1)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Eşitlik! Yalnızca liderler ek tur oynayacak.',
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            WhoScoreboard(session: s),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _confirm(restart: true),
              icon: const Icon(Icons.replay_rounded),
              label: const Text(
                'Oyunu Yeniden Başlat',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
        bottom = _button(
          'Sıradaki Oyuncu',
          () => ref
              .read(adsServiceProvider)
              .leaveRound(
                roundIdentity,
                () => mounted && identical(ref.read(whoSessionProvider), s),
                controller.nextPlayer,
              ),
          icon: Icons.arrow_forward_rounded,
        );
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirm();
      },
      child: WhoPage(
        onBack: () => _confirm(),
        actions: [
          if (s.phase == WhoPhase.playing || s.phase == WhoPhase.countdown)
            IconButton(
              tooltip: 'Duraklat',
              onPressed: controller.pause,
              icon: const Icon(Icons.pause_rounded),
            ),
          IconButton(
            tooltip: 'Oyunu yeniden başlat',
            onPressed: () => _confirm(restart: true),
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
        bottom: bottom,
        body: LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewport.maxHeight),
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
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
}
