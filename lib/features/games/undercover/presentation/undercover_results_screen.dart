import 'package:flutter/material.dart';

import '../application/undercover_controller.dart';
import 'undercover_visuals.dart';

class UndercoverResultsScreen extends StatelessWidget {
  const UndercoverResultsScreen({
    super.key,
    required this.session,
    required this.busy,
    required this.onBack,
    required this.onReplay,
    required this.onHome,
  });

  final UndercoverSession session;
  final bool busy;
  final VoidCallback onBack;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final winner = session.round!.winner!;
    final spies = session.players.where(
      (player) => player.role == UndercoverRole.spy,
    );
    final eliminationPositions = {
      for (final (index, id) in session.eliminationOrder.indexed) id: index + 1,
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !busy) onBack();
      },
      child: UndercoverScaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: busy ? null : onBack),
          title: const Text('Oyun Sonuçları'),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UndercoverButton(
                    onPressed: busy ? null : onReplay,
                    icon: Icons.replay_rounded,
                    label: 'Tekrar Oyna',
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: busy ? null : onHome,
                    child: const Text('Ana Menü'),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const UndercoverArt(size: 88),
                    const SizedBox(height: 12),
                    UndercoverWinner(
                      label:
                          winner == UndercoverRole.spy
                              ? 'CASUSLAR KAZANDI!'
                              : 'NORMAL OYUNCULAR KAZANDI!',
                    ),
                    const SizedBox(height: 16),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'GİZLİ KELİME',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              session.secretWord
                                  .replaceAll('i', 'İ')
                                  .toUpperCase(),
                              key: const ValueKey('undercover-result-word'),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Casuslar Kimdi?', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final player in spies)
                          Chip(
                            key: ValueKey('undercover-result-spy-${player.id}'),
                            avatar: const UndercoverArt(size: 24),
                            label: Text(player.name),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Oyuncular', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    for (final (index, player) in session.players.indexed)
                      _PlayerResult(
                        key: ValueKey('undercover-result-player-${player.id}'),
                        player: player,
                        position: index + 1,
                        eliminatedAt: eliminationPositions[player.id],
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

class _PlayerResult extends StatelessWidget {
  const _PlayerResult({
    super.key,
    required this.player,
    required this.position,
    required this.eliminatedAt,
  });

  final UndercoverPlayer player;
  final int position;
  final int? eliminatedAt;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spy = player.role == UndercoverRole.spy;
    final status =
        eliminatedAt == null
            ? 'Oyunda Kaldı'
            : 'Elendi · $eliminatedAt. elenen';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: colors.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              spy ? colors.tertiaryContainer : colors.secondaryContainer,
          foregroundColor:
              spy ? colors.onTertiaryContainer : colors.onSecondaryContainer,
          child: Text('$position'),
        ),
        title: Text(player.name),
        subtitle: Text('${spy ? 'Casus' : 'Normal Oyuncu'} · $status'),
      ),
    );
  }
}
