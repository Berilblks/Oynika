import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../core/constants/app_dimensions.dart';
import '../../features/games/domain/party_game.dart';
import 'game_art.dart';

class GameCard extends StatefulWidget {
  const GameCard({super.key, required this.game, this.horizontal = false});

  final PartyGame game;
  final bool horizontal;

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final background =
        dark
            ? Color.alphaBlend(
              game.background.withValues(alpha: 0.16),
              theme.colorScheme.surface,
            )
            : game.background;
    final foreground = dark ? theme.colorScheme.onSurface : AppTheme.ink;
    final accent = dark ? game.background : game.accent;
    final description = Text(
      game.description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: dark ? theme.colorScheme.onSurfaceVariant : AppTheme.muted,
        fontSize: 11,
        height: 1.23,
      ),
    );
    final title = Text(
      game.title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: foreground,
        fontSize: 16,
        height: 1.12,
        letterSpacing: -0.5,
      ),
    );
    final arrow = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: dark ? 0.13 : 0.10),
      ),
      child: Icon(Icons.chevron_right_rounded, color: accent, size: 27),
    );
    return Semantics(
      button: true,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.cornerRadius),
            boxShadow: [
              BoxShadow(
                color: game.accent.withValues(alpha: dark ? 0.03 : 0.045),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Material(
            color: background,
            borderRadius: BorderRadius.circular(AppDimensions.cornerRadius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: ValueKey('game-card-${game.asset}'),
              onTap: () => context.push(game.path),
              onHighlightChanged: (value) => setState(() => _pressed = value),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child:
                    widget.horizontal
                        ? LayoutBuilder(
                          builder: (context, constraints) {
                            final artWidth =
                                constraints.maxWidth < 310 ? 74.0 : 120.0;
                            return Row(
                              children: [
                                SizedBox(
                                  width: artWidth,
                                  child: GameArt(
                                    game: game,
                                    height: artWidth * 0.82,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      title,
                                      const SizedBox(height: 6),
                                      description,
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                arrow,
                              ],
                            );
                          },
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: GameArt(game: game, height: 64)),
                            const SizedBox(height: 6),
                            title,
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(child: description),
                                const SizedBox(width: 4),
                                arrow,
                              ],
                            ),
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
