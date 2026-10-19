import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../shared/widgets/game_art.dart';
import '../domain/party_game.dart';

class GameIntroScreen extends StatelessWidget {
  const GameIntroScreen({super.key, required this.game});

  final PartyGame game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Geri',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed:
              () => context.canPop() ? context.pop() : context.go('/games'),
        ),
        title: const Text('Oyunu keşfet'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.contentMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color:
                          theme.brightness == Brightness.dark
                              ? Color.alphaBlend(
                                game.background.withValues(alpha: 0.15),
                                colors.surface,
                              )
                              : game.background,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      children: [
                        GameArt(game: game, height: 155),
                        const SizedBox(height: 12),
                        Text(
                          game.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          game.description.replaceAll('\n', ' '),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Nasıl oynanır?', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  for (var i = 0; i < game.instructions.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: colors.primary.withValues(
                              alpha: 0.10,
                            ),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              game.instructions[i],
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.construction_rounded, color: colors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Geliştirme aşamasında',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Bu oyun henüz oynanabilir değil. Eğlenceyi hazırlıyoruz!',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
