import 'package:flutter/material.dart';
import '../../features/games/domain/party_game.dart';

class GameArt extends StatelessWidget {
  const GameArt({super.key, required this.game, this.height = 100});

  final PartyGame game;
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child:
        game == PartyGame.undercover
            ? SizedBox(
              height: height,
              child: Icon(
                Icons.person_search_rounded,
                size: height * .8,
                color: game.accent,
              ),
            )
            : Image.asset(
              game.assetPath,
              height: height,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
  );
}
