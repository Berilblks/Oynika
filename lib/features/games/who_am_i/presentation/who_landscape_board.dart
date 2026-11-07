import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../domain/who_models.dart';
import 'who_motion_debug_panel.dart';

class WhoLandscapeBoard extends StatelessWidget {
  const WhoLandscapeBoard({
    super.key,
    required this.session,
    required this.onCorrect,
    required this.onPass,
    required this.onPause,
    required this.onExit,
    this.motionDiagnostics,
    this.onResetMotion,
  });
  final WhoGameSession session;
  final VoidCallback? onCorrect, onPass, onResetMotion;
  final VoidCallback onPause, onExit;
  final String? motionDiagnostics;
  Widget _fit(String text, TextStyle? style) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(text, style: style, maxLines: 1),
  );
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final theme = Theme.of(context), s = session;
      final dark = theme.brightness == Brightness.dark;
      final seconds = (s.remaining.inMilliseconds + 999) ~/ 1000;
      final time =
          '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
      final horizontal = (box.maxWidth * .025).clamp(12.0, 24.0);
      final vertical = (box.maxHeight * .03).clamp(8.0, 14.0);
      final gap = (box.maxHeight * .03).clamp(8.0, 14.0);
      final headerHeight = (box.maxHeight * .14).clamp(44.0, 48.0);
      final buttonHeight = (box.maxHeight * .17).clamp(48.0, 64.0);
      final surface = theme.colorScheme.primary.withValues(
        alpha: dark ? .12 : .07,
      );
      const green = Color(0xFF16774F), orange = Color(0xFFAD591A);
      Widget utility(String tooltip, IconData icon, VoidCallback? action) =>
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              tooltip: tooltip,
              onPressed: action,
              icon: Icon(icon, size: 22),
              padding: const EdgeInsets.all(8),
              style: IconButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
                backgroundColor: surface,
              ),
            ),
          );
      Widget action(
        String label,
        IconData icon,
        VoidCallback? callback,
        Color color,
      ) => SizedBox(
        height: buttonHeight,
        child: FilledButton(
          onPressed: callback,
          style: FilledButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: color.withValues(alpha: .35),
            disabledForegroundColor: Colors.white.withValues(alpha: .85),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            minimumSize: Size.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 26, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 21,
                    fontVariations: AppTheme.titleWeight,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      final cardColors =
          s.feedback == WhoOutcome.correct
              ? const [Color(0xFF218A5E), Color(0xFF146343)]
              : s.feedback == WhoOutcome.pass
              ? const [Color(0xFFBE6A24), Color(0xFF995016)]
              : dark
              ? const [Color(0xFF6548BB), Color(0xFF49328F)]
              : const [Color(0xFF6950C5), Color(0xFF4D359F)];
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: Column(
          children: [
            SizedBox(
              height: headerHeight,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        utility('Geri', Icons.arrow_back_rounded, onExit),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Tooltip(
                              message: s.currentPlayer.name,
                              child: _fit(
                                s.currentPlayer.name,
                                theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      width: (box.maxWidth * .18).clamp(96.0, 148.0),
                      height: headerHeight - 4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Semantics(
                        label: 'Kalan süre $time',
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 18,
                                color:
                                    seconds <= 10
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                time,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 24,
                                  color:
                                      seconds <= 10
                                          ? theme.colorScheme.error
                                          : theme.colorScheme.primary,
                                  fontVariations: AppTheme.titleWeight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            label: 'Tur puanı ${s.correct}',
                            child: Tooltip(
                              message: 'Tur puanı',
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: _fit(
                                  '${s.correct} puan',
                                  theme.textTheme.titleMedium?.copyWith(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (onResetMotion != null) ...[
                          utility(
                            'Sensörü yeniden ayarla',
                            Icons.screen_rotation_alt_rounded,
                            onResetMotion,
                          ),
                          const SizedBox(width: 6),
                        ],
                        utility('Duraklat', Icons.pause_rounded, onPause),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (motionDiagnostics != null)
              WhoMotionDebugPanel(diagnostics: motionDiagnostics!),
            SizedBox(height: gap),
            Expanded(
              child: AnimatedContainer(
                key: const ValueKey('who-word-surface'),
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontal,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: cardColors,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF26164F,
                      ).withValues(alpha: dark ? .18 : .12),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child:
                    s.feedback == null
                        ? WhoAdaptiveWord(
                          word: s.card!.name.replaceAll('i', 'İ').toUpperCase(),
                        )
                        : Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  s.feedback == WhoOutcome.correct
                                      ? Icons.check_circle_rounded
                                      : Icons.skip_next_rounded,
                                  size: 60,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s.feedback == WhoOutcome.correct
                                      ? '+1 Doğru'
                                      : 'Pas',
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
              ),
            ),
            Semantics(
              liveRegion: true,
              label:
                  s.feedback == WhoOutcome.correct
                      ? 'Doğru, 1 puan'
                      : s.feedback == WhoOutcome.pass
                      ? 'Pas, 0 puan'
                      : '',
              child: SizedBox(height: gap),
            ),
            Row(
              children: [
                Expanded(
                  child: action(
                    'Doğru +1',
                    Icons.check_rounded,
                    onCorrect,
                    green,
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  child: action('Pas', Icons.skip_next_rounded, onPass, orange),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

/// Measures with the real font, width, height and accessibility scale.
class WhoAdaptiveWord extends StatelessWidget {
  const WhoAdaptiveWord({super.key, required this.word});
  final String word;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final base = Theme.of(context).textTheme.headlineLarge!.copyWith(
        color: Colors.white,
        height: 1.05,
        fontVariations: AppTheme.displayWeight,
      );
      final scaler = MediaQuery.textScalerOf(context);
      var low = 1.0;
      var high = math.min(160.0, box.maxHeight);
      for (var i = 0; i < 14; i++) {
        final size = (low + high) / 2;
        final painter = TextPainter(
          text: TextSpan(text: word, style: base.copyWith(fontSize: size)),
          textDirection: Directionality.of(context),
          textScaler: scaler,
          maxLines: 2,
        );
        painter.layout(maxWidth: box.maxWidth);
        final fits =
            !painter.didExceedMaxLines &&
            painter.height <= box.maxHeight &&
            painter.width <= box.maxWidth;
        painter.dispose();
        if (fits) {
          low = size;
        } else {
          high = size;
        }
      }
      return Center(
        child: Text(
          word,
          key: const ValueKey('who-active-card'),
          textAlign: TextAlign.center,
          maxLines: 2,
          softWrap: true,
          style: base.copyWith(fontSize: low),
        ),
      );
    },
  );
}
