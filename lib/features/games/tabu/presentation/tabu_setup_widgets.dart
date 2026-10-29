import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../domain/tabu_models.dart';

abstract final class TabuTeamColors {
  static const accents = [Color(0xFF246BCE), Color(0xFFCA3652)];
  static const pastels = [Color(0xFFE7F0FF), Color(0xFFFFE4E6)];

  static ColorScheme schemeFor(BuildContext context, int index) =>
      ColorScheme.fromSeed(
        seedColor: accents[index],
        brightness: Theme.of(context).brightness,
      );

  static Color surfaceFor(BuildContext context, int index) => Color.alphaBlend(
    schemeFor(context, index).primary.withValues(alpha: .08),
    Theme.of(context).colorScheme.surfaceContainerLow,
  );
}

class TabuSetupForm extends StatelessWidget {
  const TabuSetupForm({
    super.key,
    required this.formKey,
    required this.names,
    required this.seconds,
    required this.target,
    required this.onSeconds,
    required this.onTarget,
  });
  final GlobalKey<FormState> formKey;
  final List<TextEditingController> names;
  final int seconds, target;
  final ValueChanged<int> onSeconds, onTarget;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 850;
    final colors = Theme.of(context).colorScheme;
    Widget heading(String text, IconData icon, {bool separated = false}) =>
        Padding(
          padding: EdgeInsets.only(
            top: (compact ? 24.0 : 28.0) + (separated ? 8 : 0),
            bottom: 12,
          ),
          child: Row(
            children: [
              Icon(icon, color: colors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
        );
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Image.asset(
                  'assets/illustrations/taboo.png',
                  width: compact ? 70 : 88,
                  excludeFromSemantics: true,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Tabu',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontSize: compact ? 42 : 50),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Kelimeyi anlat, yasaklı kelimeleri söyleme!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.35,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: compact ? 70 : 88,
                  child: Transform.rotate(
                    angle: .15,
                    child: Icon(
                      Icons.forum_rounded,
                      color: colors.primary.withValues(alpha: .65),
                      size: compact ? 44 : 56,
                    ),
                  ),
                ),
              ],
            ),
          ),
          heading('Takım İsimleri', Icons.groups_rounded),
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _team(context, i),
          ],
          heading('Tur Süresi', Icons.schedule_rounded, separated: true),
          Row(
            children: [
              for (final value in [60, 90, 120]) ...[
                if (value != 60) const SizedBox(width: 8),
                Expanded(
                  child: _option(
                    context,
                    key: ValueKey('duration-$value'),
                    selected: seconds == value,
                    onPressed: () => onSeconds(value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            fontVariations: AppTheme.displayWeight,
                          ),
                        ),
                        const Text('saniye', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          heading('Hedef Puan', Icons.track_changes_rounded, separated: true),
          LayoutBuilder(
            builder: (context, constraints) {
              final largeText = MediaQuery.textScalerOf(context).scale(14) > 21;
              final columns = largeText || constraints.maxWidth < 280 ? 2 : 3;
              final width =
                  (constraints.maxWidth - (columns - 1) * 8) / columns;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final value in tabuTargetScores)
                    SizedBox(
                      width: width,
                      child: _option(
                        context,
                        key: ValueKey('target-$value'),
                        selected: target == value,
                        onPressed: () => onTarget(value),
                        child: Text('$value puan', textAlign: TextAlign.center),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _team(BuildContext context, int index) {
    final colors = Theme.of(context).colorScheme;
    final team = TabuTeamColors.schemeFor(context, index);
    return Container(
      key: ValueKey('tabu-team-panel-$index'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TabuTeamColors.surfaceFor(context, index),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .45)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: team.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.groups_rounded, color: team.onPrimary, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              key: ValueKey('team-$index'),
              controller: names[index],
              maxLength: 24,
              textInputAction:
                  index == 0 ? TextInputAction.next : TextInputAction.done,
              onFieldSubmitted:
                  index == 1 ? (_) => FocusScope.of(context).unfocus() : null,
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
                fontVariations: AppTheme.labelWeight,
              ),
              decoration: InputDecoration(
                labelText: 'Takım ${index + 1}',
                labelStyle: TextStyle(color: team.primary, fontSize: 13),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                counterText: '',
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: team.primary, width: 1.5),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colors.error),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colors.error, width: 1.5),
                ),
                suffixIcon: IconButton(
                  tooltip: 'Takım ${index + 1} adını temizle',
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                  onPressed: names[index].clear,
                ),
                errorMaxLines: 2,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Takım adı boş olamaz.';
                }
                if (turkishKey(names[0].text) == turkishKey(names[1].text)) {
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

  Widget _option(
    BuildContext context, {
    required Key key,
    required bool selected,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      child: OutlinedButton(
        key: key,
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          backgroundColor:
              selected ? colors.primaryContainer : colors.surfaceContainerLow,
          foregroundColor:
              selected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
          side: BorderSide(
            color:
                selected
                    ? colors.primary
                    : colors.outlineVariant.withValues(alpha: .55),
            width: selected ? 1.5 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontVariations: AppTheme.titleWeight,
            fontSize: 14,
          ),
        ),
        child: child,
      ),
    );
  }
}

class TabuStartButton extends StatelessWidget {
  const TabuStartButton({super.key, required this.onPressed});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground =
        onPressed == null
            ? colors.onSurface.withValues(alpha: .38)
            : colors.onPrimary;
    return FilledButton.icon(
      key: const ValueKey('tabu-start'),
      onPressed: onPressed,
      icon: Icon(Icons.play_arrow_rounded, color: foreground),
      label: Text(
        'Oyuna Başla',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: foreground,
          fontVariations: AppTheme.titleWeight,
        ),
      ),
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          fontVariations: AppTheme.titleWeight,
        ),
      ),
    );
  }
}

Future<void> showTabuRules(BuildContext context) {
  FocusScope.of(context).unfocus();
  final colors = Theme.of(context).colorScheme;
  return showModalBottomSheet<void>(
    backgroundColor: colors.surface,

    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
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
                  'Oyunu Nasıl Oynarız?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                for (final rule in [
                  (
                    Icons.forum_rounded,
                    'Kelimeyi anlat',
                    'Karttaki kelimeyi takımına anlat.',
                    colors.primaryContainer,
                    colors.onPrimaryContainer,
                  ),
                  (
                    Icons.block_rounded,
                    'Yasaklı kelimeleri söyleme',
                    'Karttaki beş yasaklı kelimeyi kullanma.',
                    colors.errorContainer,
                    colors.onErrorContainer,
                  ),
                  (
                    Icons.hourglass_bottom_rounded,
                    'Süre dolmadan anlat',
                    'Seçilen süre içinde mümkün olduğunca çok kelime anlat.',
                    colors.tertiaryContainer,
                    colors.onTertiaryContainer,
                  ),
                  (
                    Icons.emoji_events_rounded,
                    'Hedef puana ulaş',
                    'Belirlenen hedefe ilk ulaşan takım kazanır.',
                    colors.secondaryContainer,
                    colors.onSecondaryContainer,
                  ),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: rule.$4,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(rule.$1, color: rule.$5, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rule.$2,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(rule.$3),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
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
