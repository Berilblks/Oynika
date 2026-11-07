import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../features/games/domain/party_game.dart';
import 'game_card.dart';

class GameCollection extends StatelessWidget {
  const GameCollection({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var row = 0; row < (PartyGame.values.length + 1) ~/ 2; row++) ...[
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: GameCard(game: PartyGame.values[row * 2])),
              const SizedBox(width: AppDimensions.itemSpacing),
              Expanded(
                child:
                    row * 2 + 1 < PartyGame.values.length
                        ? GameCard(game: PartyGame.values[row * 2 + 1])
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        if (row * 2 + 2 < PartyGame.values.length)
          const SizedBox(height: AppDimensions.itemSpacing),
      ],
    ],
  );
}
