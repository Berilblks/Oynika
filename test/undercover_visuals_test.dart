import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oynika/features/games/undercover/presentation/undercover_setup_screen.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/features/games/undercover/application/undercover_controller.dart';
import 'package:oynika/features/games/undercover/presentation/undercover_round_screen.dart';
import 'package:oynika/features/games/undercover/presentation/undercover_visuals.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('Şeffaf Casus ayarları, tek başlık ve klavye: $dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: const UndercoverSetupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Aramızdaki Casus'), findsOneWidget);
      expect(tester.widget<AppBar>(find.byType(AppBar)).title, isNull);
      expect(
        tester.getTopLeft(find.text('Aramızdaki Casus')).dy,
        lessThan(tester.getTopLeft(find.byType(UndercoverArt)).dy),
      );
      verifyBackdrop(tester);
      expect(find.text('Oyunu Başlat').hitTestable(), findsOneWidget);
      final field = find.byKey(const ValueKey('undercover-player-0'));
      await tester.ensureVisible(field);
      await tester.enterText(field, 'Deniz');
      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      await tester.pumpAndSettle();
      expect(find.text('Oyunu Başlat'), findsNothing);
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(find.text('Oyunu Başlat').hitTestable(), findsOneWidget);
    });
    for (final phase in [
      UndercoverPhase.clue,
      UndercoverPhase.voting,
      UndercoverPhase.tie,
      UndercoverPhase.elimination,
    ]) {
      testWidgets('Casus görseli, sabit buton ve küçük ekran: $dark / $phase', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final round = UndercoverRound(
          number: 1,
          order: List.generate(20, (i) => i),
          phase: phase,
          leaders: const [0, 1],
          eliminatedId: phase == UndercoverPhase.elimination ? 0 : null,
          winner:
              phase == UndercoverPhase.elimination
                  ? UndercoverRole.normal
                  : null,
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: UndercoverRoundScreen(
              round: round,
              names: {
                for (var i = 0; i < 20; i++) i: 'Uzun Oyuncu İsmi ${i + 1}',
              },
              activeCount: 19,
              eliminatedRole: UndercoverRole.spy,
              onBeginVoting: () {},
              onVote: (_) {},
              onTie: () {},
              onElimination: () {},
              onResults: () {},
              enablePrivacy: () async {},
              releasePrivacy: () async {},
              onExit: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        verifyBackdrop(tester);
        expect(find.byType(UndercoverArt), findsOneWidget);
        expect(find.byIcon(Icons.person_search_rounded), findsNothing);
        expect(find.byType(UndercoverButton).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (phase == UndercoverPhase.elimination) {
          expect(find.text('CASUSTU!'), findsOneWidget);
          expect(find.text('NORMAL OYUNCULAR KAZANDI!'), findsOneWidget);
          expect(find.text('GİZLİ KELİME'), findsNothing);
        }
      });
    }
  }
}

void verifyBackdrop(WidgetTester tester) {
  final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
  expect(scaffold.backgroundColor, Colors.transparent);
  expect(
    find.ancestor(
      of: find.byType(Scaffold),
      matching: find.byType(UndercoverBackdrop),
    ),
    findsOneWidget,
  );
  final barTheme = Theme.of(tester.element(find.byType(AppBar))).appBarTheme;
  expect(barTheme.backgroundColor, Colors.transparent);
  expect(barTheme.surfaceTintColor, Colors.transparent);
  expect(barTheme.scrolledUnderElevation, 0);
  expect(
    barTheme.systemOverlayStyle!.systemNavigationBarColor,
    Colors.transparent,
  );
}
