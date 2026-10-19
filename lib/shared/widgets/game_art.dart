import 'package:flutter/material.dart';
import '../../features/games/domain/party_game.dart';

class GameArt extends StatelessWidget {
  const GameArt({super.key, required this.game, this.height = 100});

  final PartyGame game;
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Image.asset(
      game.assetPath,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    ),
  );
}
