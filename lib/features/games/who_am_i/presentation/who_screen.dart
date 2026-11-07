import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/game_art.dart';
import '../../domain/party_game.dart';
import '../application/who_controller.dart';
import '../domain/who_models.dart';
import 'who_page.dart';
import 'who_game_screen.dart';

class WhoScreen extends ConsumerStatefulWidget {
  const WhoScreen({super.key});
  @override
  ConsumerState<WhoScreen> createState() => _WhoScreenState();
}

class _WhoScreenState extends ConsumerState<WhoScreen> {
  final _form = GlobalKey<FormState>();
  final _names = List.generate(
    20,
    (i) => TextEditingController(text: 'Oyuncu ${i + 1}'),
  );
  int _count = 4;
  WhoRoundDuration _duration = WhoRoundDuration.standard;
  int _targetScore = 20;

  @override
  void dispose() {
    for (final name in _names) {
      name.dispose();
    }
    super.dispose();
  }

  String? _validate(int index, String? value) {
    final key = whoNameKey(value ?? '');
    if (key.isEmpty) return 'Oyuncu adı boş olamaz.';
    for (var i = 0; i < _count; i++) {
      if (i != index && whoNameKey(_names[i].text) == key) {
        return 'Oyuncu isimleri farklı olmalı.';
      }
    }
    return null;
  }

  void _start() {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    for (var i = 0; i < _count; i++) {
      _names[i].text = _names[i].text.trim();
    }
    ref
        .read(whoSessionProvider.notifier)
        .start(
          names: [for (var i = 0; i < _count; i++) _names[i].text],
          duration: _duration,
          targetScore: _targetScore,
        );
  }

  Future<void> _rules() async {
    FocusScope.of(context).unfocus();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .9,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                    'Nasıl Oynanır?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  for (final (i, rule) in PartyGame.whoAmI.instructions.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _badge(context, i),
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
                    child: const Text(
                      'Tamam, Başlayalım!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _badge(BuildContext context, int index) {
    final colors = Theme.of(context).colorScheme;
    final palette = [
      (colors.primaryContainer, colors.onPrimaryContainer),
      (colors.secondaryContainer, colors.onSecondaryContainer),
      (colors.tertiaryContainer, colors.onTertiaryContainer),
    ];
    final (bg, fg) = palette[index % palette.length];
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${index + 1}',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg),
      ),
    );
  }

  Widget _field(BuildContext context, int index) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
      ),
      child: Row(
        children: [
          ExcludeSemantics(child: _badge(context, index)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              key: ValueKey('who-name-$index'),
              controller: _names[index],
              textInputAction:
                  index == _count - 1
                      ? TextInputAction.done
                      : TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Oyuncu ${index + 1} adı',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 4,
                ),
                errorMaxLines: 3,
              ),
              validator: (value) => _validate(index, value),
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
    final session = ref.watch(whoSessionProvider);
    if (session != null) {
      return const WhoGameScreen();
    }
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    return WhoPage(
      onBack: () => context.canPop() ? context.pop() : context.go('/games'),
      onRules: _rules,
      bottom:
          keyboard
              ? null
              : SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const ValueKey('who-start'),
                  onPressed: _start,
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Oyunu Başlat',
                    textAlign: TextAlign.center,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF46309B),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 56),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: theme.textTheme.titleMedium,
                  ),
                ),
              ),
      body: SingleChildScrollView(
        key: const PageStorageKey('who-setup-scroll'),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ben Kimim?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  const GameArt(game: PartyGame.whoAmI, height: 115),
                  const SizedBox(height: 12),
                  Text(
                    'Telefonunu alnına koy, ipuçlarını dinle ve kim olduğunu keşfet!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  Text('Oyuncu Sayısı', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          key: const ValueKey('who-minus'),
                          tooltip: 'Oyuncu azalt',
                          onPressed:
                              _count == 2
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
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        IconButton.filledTonal(
                          key: const ValueKey('who-plus'),
                          tooltip: 'Oyuncu artır',
                          onPressed:
                              _count == 20
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
                  const SizedBox(height: 28),
                  Text('Oyuncu İsimleri', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  for (var i = 0; i < _count; i++) _field(context, i),
                  const SizedBox(height: 20),
                  Text('Tur Süresi', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final option in WhoRoundDuration.values)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: option == WhoRoundDuration.long ? 0 : 8,
                            ),
                            child: Semantics(
                              selected: _duration == option,
                              child: OutlinedButton(
                                key: ValueKey('who-duration-${option.seconds}'),
                                onPressed:
                                    () => setState(() => _duration = option),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      _duration == option
                                          ? colors.primaryContainer
                                          : colors.surfaceContainerLow,
                                  foregroundColor:
                                      _duration == option
                                          ? colors.onPrimaryContainer
                                          : colors.onSurfaceVariant,
                                  side: BorderSide(
                                    color:
                                        _duration == option
                                            ? colors.primary
                                            : colors.outlineVariant,
                                    width: _duration == option ? 1.5 : 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 12,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${option.seconds}',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const Text(
                                      'saniye',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text('Hedef Puan', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final target in WhoGameSettings.targetScores)
                        ChoiceChip(
                          key: ValueKey('who-target-$target'),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Text('$target puan'),
                          ),
                          selected: _targetScore == target,
                          onSelected:
                              (_) => setState(() => _targetScore = target),
                          selectedColor: colors.primaryContainer,
                          side: BorderSide(
                            color:
                                _targetScore == target
                                    ? colors.primary
                                    : colors.outlineVariant,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
