import 'package:flutter/material.dart';
import '../domain/who_models.dart';
import 'who_page.dart';
import 'who_scoreboard.dart';

class WhoWinnerScreen extends StatelessWidget {
  const WhoWinnerScreen({
    super.key,
    required this.session,
    required this.onReplay,
    required this.onGames,
  });
  final WhoGameSession session;
  final VoidCallback onReplay, onGames;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), s = session;
    final winner = s.winnerIndex!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onGames();
      },
      child: WhoPage(
        onBack: onGames,
        bottom: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              key: const ValueKey('who-replay'),
              onPressed: onReplay,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Tekrar Oyna'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF46309B),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 56),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onGames,
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('Oyunlara Dön'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    size: 96,
                    color: Color(0xFFE3A626),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kazanan: ${s.settings.players[winner].name}',
                    key: const ValueKey('who-winner'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${s.totals[winner]} puan',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hedef puan: ${s.settings.targetScore}',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Toplam oynanan tur: ${s.history.length}',
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Tamamlanan tur sırası: ${s.cycle}${s.tieBreak ? ' (ek tur dahil)' : ''}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  WhoScoreboard(session: s, showNext: false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
