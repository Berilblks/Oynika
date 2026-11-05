import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/features/games/undercover/application/undercover_controller.dart';
import 'package:oynika/features/games/undercover/presentation/undercover_results_screen.dart';

void main() {
  for (final count in [3, 20]) {
    for (final dark in [false, true]) {
      testWidgets('Sonuç listesi, roller, sıra ve büyük yazı: $count / $dark', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final spies = spyCountFor(count);
        final session = UndercoverSession(
          players: List.generate(
            count,
            (id) => (
              id: id,
              name: 'Oyuncu ${id + 1}',
              role: id < spies ? UndercoverRole.spy : UndercoverRole.normal,
            ),
          ),
          secretWord: 'Dondurma',
          spyCount: spies,
          eliminationOrder: List.generate(spies, (i) => spies - i - 1),
          round: UndercoverRound(
            number: spies,
            order: List.generate(count, (i) => i),
            phase: UndercoverPhase.elimination,
            winner: UndercoverRole.normal,
          ),
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: UndercoverResultsScreen(
              session: session,
              busy: false,
              onBack: () {},
              onHome: () {},
              onReplay: () {},
            ),
          ),
        );
        expect(find.text('NORMAL OYUNCULAR KAZANDI!'), findsOneWidget);
        expect(find.text('DONDURMA'), findsOneWidget);
        for (var id = 0; id < spies; id++) {
          expect(
            find.byKey(ValueKey('undercover-result-spy-$id')),
            findsOneWidget,
          );
        }
        double previous = -double.infinity;
        for (var id = 0; id < count; id++) {
          final row = find.byKey(ValueKey('undercover-result-player-$id'));
          expect(tester.getTopLeft(row).dy, greaterThan(previous));
          previous = tester.getTopLeft(row).dy;
          if (id < spies) {
            expect(
              find.descendant(
                of: row,
                matching: find.text('Casus · Elendi · ${spies - id}. elenen'),
              ),
              findsOneWidget,
            );
          } else {
            expect(
              find.descendant(
                of: row,
                matching: find.text('Normal Oyuncu · Oyunda Kaldı'),
              ),
              findsOneWidget,
            );
          }
        }
        final footer = tester.getRect(find.text('Tekrar Oyna'));
        await tester.ensureVisible(
          find.byKey(ValueKey('undercover-result-player-${count - 1}')),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(find.text('Tekrar Oyna')), footer);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
