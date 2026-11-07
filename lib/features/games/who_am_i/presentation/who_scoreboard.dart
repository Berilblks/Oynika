import 'package:flutter/material.dart';
import '../domain/who_models.dart';

class WhoScoreboard extends StatelessWidget {
  const WhoScoreboard({super.key, required this.session, this.showNext = true});
  final WhoGameSession session;
  final bool showNext;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), c = theme.colorScheme, s = session;
    final next =
        showNext && s.phase != WhoPhase.winner ? s.nextPlayer.id : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Genel Puan Tablosu', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final index in s.ranking)
          Builder(
            builder: (context) {
              final result = s.lastTurn(index), isNext = index == next;
              final rank =
                  1 +
                  s.totals.where((points) => points > s.totals[index]).length;
              return Container(
                key: ValueKey('who-score-$index'),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isNext ? c.primaryContainer : c.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isNext
                            ? c.primary
                            : c.outlineVariant.withValues(alpha: .3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$rank.', style: theme.textTheme.titleMedium),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.settings.players[index].name,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${s.totals[index]}',
                          style: theme.textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (result == null)
                      const Text('Henüz oynamadı')
                    else
                      Text(
                        'Son tur: ${result.correct} doğru • ${result.passed} pas • ${result.points} puan',
                      ),
                    Text('Toplam: ${s.totals[index]} puan'),
                    if (isNext)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Sıradaki oyuncu',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: c.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
