import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../charades/presentation/charades_setup_widgets.dart';
import '../../tabu/presentation/tabu_widgets.dart';
import '../../domain/party_game.dart';
import '../application/undercover_controller.dart';
import 'undercover_distribution_screen.dart';
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
  bool _secure = false;

  int get _spies => spyCountFor(_count);

  Future<void> _releasePrivacy() async {
    if (!_secure) return;
    _secure = false;
    await WidgetsBinding.instance.endOfFrame;
    try {
      await _privacyChannel.invokeMethod<void>('setSecure', false);
    } on PlatformException {
      // Leaving the window protected is safer than revealing a stale frame.
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
    setState(() => _starting = true);
    try {
      if (!kIsWeb && Platform.isAndroid) {
        await _privacyChannel.invokeMethod<void>('setSecure', true);
        _secure = true;
      }
      if (!mounted) {
        await _releasePrivacy();
        return;
      }
      ref.read(undercoverSessionProvider.notifier).start(names);
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
      builder:
          (context) => SafeArea(
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
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
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
      return UndercoverDistributionScreen(
        key: ValueKey(session.index),
        playerName: player?.name,
        hasSeenWord: session.currentHasSeenWord,
        onReveal: () => player == null ? null : controller.reveal(player.id),
        onNext: () {
          if (player == null) return;
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
    return Scaffold(
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
      bottomNavigationBar:
          keyboardOpen
              ? null
              : Material(
                color: colors.surface,
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Center(
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: CharadesStartButton(
                        onPressed: _starting ? null : _start,
                      ),
                    ),
                  ),
                ),
              ),
      body: CustomPaint(
        painter:
            theme.brightness == Brightness.light
                ? TabuBackgroundPainter(dark: false, playing: false)
                : null,
        child: SafeArea(
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
                      Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.tertiaryContainer,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.person_search_rounded,
                              color: colors.onTertiaryContainer,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aramızdaki Casus',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Kelimen farklı mı? Kimseye belli etme!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          height: 1.35,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Geliştirme aşamasında',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
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
                      Text(
                        'Oyuncu İsimleri',
                        style: theme.textTheme.titleMedium,
                      ),
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
      ),
    );
  }
}
