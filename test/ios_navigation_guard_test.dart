import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/features/games/tabu/application/game_controller.dart';
import 'package:oynika/features/games/tabu/data/card_repository.dart';
import 'package:oynika/features/games/tabu/domain/tabu_models.dart';
import 'package:oynika/features/games/tabu/presentation/tabu_screen.dart';
import 'package:oynika/features/games/charades/application/charades_controller.dart';
import 'package:oynika/features/games/charades/data/charades_repository.dart';
import 'package:oynika/features/games/charades/presentation/charades_screen.dart';

void main() {
  for (final sinema in [false, true]) {
    testWidgets('iOS hızlı geri tek çıkış onayı: sinema=$sinema', (t) async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await t.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            theme: AppTheme.light.copyWith(platform: TargetPlatform.iOS),
            home: sinema ? const CharadesScreen() : const TabuScreen(),
          ),
        ),
      );
      await t.pumpAndSettle();
      final settings = GameSession(
        names: ['Mavi Takım', 'Kırmızı Takım'],
        seconds: 90,
      );
      if (sinema) {
        c
            .read(charadesGameProvider.notifier)
            .configure(
              settings,
              CharadesRepository.decode(
                File('assets/data/sessiz_sinema_cards.json').readAsStringSync(),
              ),
            );
      } else {
        c
            .read(tabuGameProvider.notifier)
            .configure(
              settings,
              CardRepository.decode(
                File('assets/data/tabu_cards.json').readAsStringSync(),
              ),
            );
      }
      await t.pumpAndSettle();
      final back =
          t
              .widget<IconButton>(
                find.byWidgetPredicate(
                  (w) => w is IconButton && w.tooltip == 'Geri',
                ),
              )
              .onPressed!;
      back();
      back();
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog, skipOffstage: false), findsOneWidget);
      await t.tap(find.text('Oyunda Kal'));
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog, skipOffstage: false), findsNothing);
      back();
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await t.tap(find.text('Oyunda Kal'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox.shrink());
    });
  }
}
