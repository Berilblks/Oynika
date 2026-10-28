import '../../features/games/charades/presentation/charades_screen.dart';
import '../../features/games/tabu/presentation/tabu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/games/domain/party_game.dart';
import '../../features/games/presentation/game_intro_screen.dart';
import '../../features/games/presentation/games_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/app_navigation_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      StatefulShellRoute.indexedStack(
        builder:
            (context, state, shell) =>
                AppNavigationShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/games',
                name: 'games',
                builder: (context, state) => const GamesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/games/:game',
        name: 'game-intro',
        redirect:
            (context, state) =>
                PartyGame.fromSlug(state.pathParameters['game']) == null
                    ? '/games'
                    : null,
        builder: (context, state) {
          final game = PartyGame.fromSlug(state.pathParameters['game'])!;
          return switch (game) {
            PartyGame.taboo => const TabuScreen(),
            PartyGame.charades => const CharadesScreen(),
            _ => GameIntroScreen(game: game),
          };
        },
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Oynika')),
          body: Center(
            child: TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Ana sayfaya dön'),
            ),
          ),
        ),
  );
  ref.onDispose(router.dispose);
  return router;
});
