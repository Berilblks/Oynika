import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/features/games/domain/party_game.dart';
import 'package:oynika/shared/widgets/game_art.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'Casus illüstrasyonu ${dark ? "koyu" : "açık"} temada oranını korur',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: const Scaffold(
              body: Center(
                child: GameArt(game: PartyGame.undercover, height: 64),
              ),
            ),
          ),
        );
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/illustrations/undercover.png'),
            tester.element(find.byType(GameArt)),
          ),
        );
        await tester.pumpAndSettle();
        final image = tester.widget<Image>(find.byType(Image));
        expect(
          (image.image as AssetImage).assetName,
          'assets/illustrations/undercover.png',
        );
        expect(image.fit, BoxFit.contain);
        expect(image.color, isNull);
        expect(tester.getSize(find.byType(Image)), const Size(64, 64));
        expect(find.byType(ClipRRect), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
