import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ads/google_ads_backend.dart';

import 'undercover_visuals.dart';
import '../../domain/party_game.dart';
import '../application/undercover_controller.dart';
import 'undercover_distribution_screen.dart';
import 'undercover_round_screen.dart';
import 'undercover_results_screen.dart';
import '../../tabu/domain/tabu_models.dart';

class UndercoverSetupScreen extends ConsumerStatefulWidget {
  const UndercoverSetupScreen({super.key});

  @override
  ConsumerState<UndercoverSetupScreen> createState() =>
      _UndercoverSetupScreenState();
}

class _UndercoverSetupScreenState extends ConsumerState<UndercoverSetupScreen> {
  static const _minPlayers = 3;
  static const _maxPlayers = 20;
  final _form = GlobalKey<FormState>();
  final _names = List.generate(
    _maxPlayers,
    (index) => TextEditingController(text: 'Oyuncu ${index + 1}'),
  );
  int _count = 6;

  static const _privacyChannel = MethodChannel('oynika/undercover_privacy');
  bool _starting = false;
  UndercoverSession? _viewingResults;
  Object _resultsEntry = Object();
  bool _secure = false;
  Future<void> _privacyRelease = Future.value();

  int get _spies => spyCountFor(_count);

  Future<void> _enablePrivacy() async {
    await _privacyRelease;
    if (!kIsWeb && Platform.isAndroid && !_secure) {
      await _privacyChannel.invokeMethod<void>('setSecure', true);
      _secure = true;
    }
  }

  Future<void> _releasePrivacy() {
    if (!_secure) return _privacyRelease;
    _secure = false;
    return _privacyRelease = _clearSecureFrame();
  }

  Future<void> _clearSecureFrame() async {
    await WidgetsBinding.instance.endOfFrame;
    try {
      await _privacyChannel.invokeMethod<void>('setSecure', false);
    } on PlatformException {
      // Keep the native window protected if clearing the flag fails.
    }
  }

  @override
  void dispose() {
    unawaited(_releasePrivacy());
    for (final name in _names) {
      name.dispose();
    }
    super.dispose();
  }

  String? _validateName(int index, String? value) {
    final name = turkishKey(value?.trim() ?? '');
    if (name.isEmpty) return 'Oyuncu adı boş olamaz.';
    for (var other = 0; other < _count; other++) {
      if (other != index && turkishKey(_names[other].text.trim()) == name) {
        return 'Oyuncu isimleri farklı olmalı.';
      }
    }
    return null;
  }

  Future<void> _start() async {
    if (_starting || !_form.currentState!.validate()) return;
    final names = [
      for (var index = 0; index < _count; index++) _names[index].text,
    ];
    await _launchGame(() {
      ref.read(undercoverSessionProvider.notifier).start(names);
      return true;
    });
  }

  Future<void> _launchGame(bool Function() launch) async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      await _enablePrivacy();
      if (!mounted) {
        await _releasePrivacy();
        return;
      }
      if (launch()) {
        _viewingResults = null;
        _resultsEntry = Object();
      } else {
        await _releasePrivacy();
      }
    } on PlatformException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gizlilik koruması açılamadı. Tekrar dene.'),
          ),
        );
      }
    } on MissingPluginException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gizlilik koruması kullanılamıyor.')),
        );
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _showRules() async {
    FocusScope.of(context).unfocus();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .9,
      ),
      builder: (context) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Aramızdaki Casus Nasıl Oynanır?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              for (final (index, rule)
                  in PartyGame.undercover.instructions.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _numberBadge(context, index),
                      const SizedBox(width: 12),
                      Expanded(child: Text(rule)),
                    ],
                  ),
                ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 56)),
                child: const Text('Anladım'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberBadge(BuildContext context, int index) {
    final colors = Theme.of(context).colorScheme;
    final palette = [
      (colors.primaryContainer, colors.onPrimaryContainer),
      (colors.secondaryContainer, colors.onSecondaryContainer),
      (colors.tertiaryContainer, colors.onTertiaryContainer),
    ];
    final (background, foreground) = palette[index % palette.length];
    return Container(
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${index + 1}',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: foreground),
      ),
    );
  }

  Widget _playerField(BuildContext context, int index) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ExcludeSemantics(child: _numberBadge(context, index)),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              key: ValueKey('undercover-player-$index'),
              controller: _names[index],
              maxLength: 24,
              textInputAction:
                  index == _count - 1
                      ? TextInputAction.done
                      : TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Oyuncu ${index + 1} adı',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                counterText: '',
                filled: false,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
                errorMaxLines: 3,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colors.primary),
                ),
              ),
              validator: (value) => _validateName(index, value),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final session = ref.watch(undercoverSessionProvider);
    if (session != null) {
      final player = session.current;
      final controller = ref.read(undercoverSessionProvider.notifier);
      final finished = session.phase == UndercoverPhase.finished;
      final ads = ref.read(adsServiceProvider);
      final round = session.round;
      if (finished) ads.recordCompletion(session, round: round);
      if (round != null &&
          (round.phase == UndercoverPhase.elimination ||
              (round.phase == UndercoverPhase.tie &&
                  round.runoffCandidates.isNotEmpty))) {
        ads.recordRound(round);
      }
      bool isCurrent() =>
          mounted && identical(ref.read(undercoverSessionProvider), session);
      if (identical(_viewingResults, session) &&
          session.phase == UndercoverPhase.finished) {
        return UndercoverResultsScreen(
          session: session,
          busy: _starting,
          onBack: () => setState(() {
            _viewingResults = null;
            _resultsEntry = Object();
          }),
          onReplay: () => ads.leaveResult(
            session,
            isCurrent,
            () => _launchGame(() => controller.restartWithSamePlayers(session)),
            round: round,
          ),
          onHome: () => ads.leaveResult(session, isCurrent, () {
            _viewingResults = null;
            controller.exit();
            context.go('/');
          }, round: round),
        );
      }
      if (round != null) {
        return UndercoverRoundScreen(
          key: ValueKey(round),
          round: round,
          names: {for (final player in session.players) player.id: player.name},
          activeCount: session.activeIds.length,
          eliminatedRole:
              round.eliminatedId == null
                  ? null
                  : session.players[round.eliminatedId!].role,
          onBeginVoting: () => controller.beginVoting(round),
          onVote: (candidate) =>
              controller.vote(round, round.voter!, candidate),
          onTie: () {
            if (round.runoffCandidates.isNotEmpty) {
              ads.leaveRound(
                round,
                isCurrent,
                () => controller.continueTie(round),
              );
            } else {
              controller.continueTie(round);
            }
          },
          onElimination: () => ads.leaveRound(
            round,
            isCurrent,
            () => controller.continueElimination(round),
          ),
          onResults: () {
            if (identical(ref.read(undercoverSessionProvider), session) &&
                session.phase == UndercoverPhase.finished &&
                !identical(_viewingResults, session)) {
              ads.leaveRound(
                round,
                isCurrent,
                () => setState(() => _viewingResults = session),
                transition: _resultsEntry,
              );
            }
          },
          enablePrivacy: _enablePrivacy,
          releasePrivacy: _releasePrivacy,
          onExit: finished
              ? () => ads.leaveResult(
                  session,
                  isCurrent,
                  controller.exit,
                  round: round,
                )
              : controller.exit,
        );
      }
      return UndercoverDistributionScreen(
        key: ValueKey(session.index),
        playerName: player!.name,
        playerIndex: session.index,
        playerCount: session.players.length,
        hasSeenWord: session.currentHasSeenWord,
        onReveal: () => controller.reveal(player.id),
        onNext: () {
          controller.next(player.id);
          if (session.index + 1 == session.players.length) {
            unawaited(_releasePrivacy());
          }
        },
        onExit: () {
          controller.exit();
          unawaited(_releasePrivacy());
        },
      );
    }
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return UndercoverScaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Geri',
          onPressed:
              () => context.canPop() ? context.pop() : context.go('/games'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            tooltip: 'Oyun kuralları',
            onPressed: _showRules,
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      bottomNavigationBar: keyboardOpen
          ? null
          : Material(
              color: Colors.transparent,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: UndercoverButton(
                      label: 'Oyunu Başlat',
                      icon: Icons.play_arrow_rounded,
                      onPressed: _starting ? null : _start,
                    ),
                  ),
                ),
              ),
            ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Aramızdaki Casus',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const UndercoverArt(size: 150),
                    const SizedBox(height: 16),
                    UndercoverPanel(
                      child: Text(
                        'İpuçlarını dinle, casusları bul! Ama dikkat et, casuslar da seninle birlikte oynuyor.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('Oyuncu Sayısı', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Card(
                      color: colors.surfaceContainerLow,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: colors.outlineVariant.withValues(alpha: .45),
                        ),
                      ),
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            IconButton.filledTonal(
                              tooltip: 'Oyuncu azalt',
                              onPressed:
                                  _count == _minPlayers
                                      ? null
                                      : () {
                                        FocusScope.of(context).unfocus();
                                        setState(() => _count--);
                                      },
                              icon: const Icon(Icons.remove_rounded),
                            ),
                            Expanded(
                              child: Text(
                                '$_count oyuncu',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                            IconButton.filledTonal(
                              tooltip: 'Oyuncu artır',
                              onPressed:
                                  _count == _maxPlayers
                                      ? null
                                      : () {
                                        FocusScope.of(context).unfocus();
                                        setState(() => _count++);
                                      },
                              icon: const Icon(Icons.add_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$_spies casus aranızda gizleniyor!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 28),
                    Text('Oyuncu İsimleri', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    for (var index = 0; index < _count; index++)
                      _playerField(context, index),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
