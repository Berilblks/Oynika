import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/app.dart';
import 'package:oynika/app/router/app_router.dart';
import 'package:oynika/app/theme/theme_mode_provider.dart';
import 'package:oynika/features/games/charades/application/charades_controller.dart';
import 'package:oynika/features/games/charades/data/charades_repository.dart';
import 'package:oynika/features/games/charades/domain/charades_models.dart';
import 'package:oynika/features/games/charades/presentation/charades_card_widget.dart';

void main() {
  final cards = CharadesRepository.decode(
    File('assets/data/sessiz_sinema_cards.json').readAsStringSync(),
  );
  late Duration now;
  Future<ProviderContainer> open(
    WidgetTester tester, {
    Size size = const Size(393, 786),
    double scale = 1,
    bool dark = false,
  }) async {
    now = Duration.zero;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final c = ProviderContainer(
      overrides: [
        charadesCardsProvider.overrideWith((ref) async => cards),
        charadesClockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(c.dispose);
    c
        .read(themeModeProvider.notifier)
        .select(dark ? ThemeMode.dark : ThemeMode.light);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: const OynikaApp()),
    );
    c.read(appRouterProvider).go('/games/charades');
    await tester.pumpAndSettle();
    return c;
  }

  Future<void> tap(WidgetTester tester, String label) async {
    final finder = find.text(label);
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('Ayarlar doğrulanır ve düzenlenmiş takım/süre/hedef korunur', (
    tester,
  ) async {
    final c = await open(tester);
    await tester.enterText(find.byKey(const ValueKey('team-0')), ' ');
    await tap(tester, 'Oyuna Başla');
    expect(find.text('Takım adı boş olamaz.'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('team-0')), 'Yıldızlar');
    await tap(tester, '120');
    await tap(tester, '30 puan');
    await tap(tester, 'Oyuna Başla');
    expect(c.read(charadesGameProvider).session!.seconds, 120);
    expect(c.read(charadesGameProvider).session!.targetScore, 30);
    expect(c.read(charadesGameProvider).teams.first.name, 'Yıldızlar');
    expect(find.byType(CharadesCardWidget), findsNothing);
    expect(c.read(charadesGameProvider).card, isNull);
  });
  for (final size in [
    const Size(320, 568),
    const Size(393, 786),
    const Size(768, 1024),
  ]) {
    testWidgets('Beş evre, kart gizliliği, pas ve geri akışı: ${size.width}', (
      tester,
    ) async {
      final c = await open(tester, size: size, scale: 1.4, dark: true);
      final control = c.read(charadesGameProvider.notifier);
      await tap(tester, '60');
      await tap(tester, '10 puan');
      await tap(tester, 'Oyuna Başla');
      expect(find.byType(CharadesCardWidget), findsNothing);
      expect(find.text('Sıra Kimde?'), findsOneWidget);
      for (var round = 0; round < 8; round++) {
        expect(c.read(charadesGameProvider).activeTeam, round % 2);
        await tap(tester, 'Hazırım');
        expect(find.text('01:00'), findsOneWidget);
        expect(find.byType(CharadesCardWidget), findsOneWidget);
        expect(find.text('Bilemedi'), findsNothing);
        expect(find.text('Yanlış'), findsNothing);
        expect(find.text('Tabu'), findsNothing);
        if (round == 0) {
          final id = c.read(charadesGameProvider).card!.id;
          await tester.tap(find.byTooltip('Duraklat'));
          await tester.pumpAndSettle();
          expect(find.byType(CharadesCardWidget), findsNothing);
          expect(find.text('Oyun Duraklatıldı'), findsOneWidget);
          now += const Duration(seconds: 200);
          control.tick();
          expect(c.read(charadesGameProvider).remaining.inSeconds, 60);
          await tap(tester, 'Devam Et');
          expect(c.read(charadesGameProvider).card!.id, id);
          for (var n = 3; n > 0; n--) {
            now += const Duration(milliseconds: 400);
            await tap(tester, 'Pas ($n)');
          }
          expect(
            tester
                .widget<ElevatedButton>(
                  find.widgetWithText(ElevatedButton, 'Pas (0)'),
                )
                .onPressed,
            isNull,
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
          await tester.pumpAndSettle();
          expect(find.byType(CharadesCardWidget), findsNothing);
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tap(tester, 'Devam Et');
          now += const Duration(milliseconds: 400);
          await tap(tester, 'Doğru');
        }
        expect(tester.takeException(), isNull);
        now += const Duration(seconds: 60);
        control.tick();
        await tester.pumpAndSettle();
        expect(find.text('Tur Bitti!'), findsOneWidget);
        expect(find.text('Skoru Gör'), findsNothing);
        await tap(tester, 'Sonraki Takım');
        expect(c.read(charadesGameProvider).remainingPasses, 3);
      }
      await tap(tester, 'Hazırım');
      for (var i = 0; i < 9; i++) {
        control.answer(
          c.read(charadesGameProvider).card!.id,
          CharadesOutcome.correct,
        );
        now += const Duration(milliseconds: 400);
      }
      await tester.pumpAndSettle();
      expect(find.text('Kazanan:'), findsOneWidget);
      await tap(tester, 'Tekrar Oyna');
      expect(c.read(charadesGameProvider).teams.first.score, 0);
      expect(c.read(charadesGameProvider).session!.targetScore, 10);
      await tap(tester, 'Hazırım');
      for (var i = 0; i < 10; i++) {
        control.answer(
          c.read(charadesGameProvider).card!.id,
          CharadesOutcome.correct,
        );
        now += const Duration(milliseconds: 400);
      }
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Geri'));
      await tester.pumpAndSettle();
      expect(c.read(appRouterProvider).state.uri.path, '/games');
      c.read(appRouterProvider).go('/games/charades');
      await tester.pumpAndSettle();
      expect(c.read(charadesGameProvider).phase, GamePhase.setup);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'Aktif oyundan çıkış onayı ve iptalden sonra güvenli duraklatma',
    (tester) async {
      final c = await open(tester);
      await tap(tester, 'Oyuna Başla');
      await tap(tester, 'Hazırım');
      await tester.tap(find.byTooltip('Geri'));
      await tester.pumpAndSettle();
      expect(find.text('Oyundan çıkılsın mı?'), findsOneWidget);
      await tap(tester, 'Oyunda Kal');
      expect(c.read(charadesGameProvider).paused, isTrue);
      await tester.tap(find.byTooltip('Geri'));
      await tester.pumpAndSettle();
      await tap(tester, 'Çık');
      expect(c.read(appRouterProvider).state.uri.path, '/games');
    },
  );
  testWidgets('Uzun film adı kartta kesilmez', (tester) async {
    final c = await open(tester, size: const Size(320, 568), scale: 1.6);
    final longest = [...cards]
      ..sort((a, b) => b.title.length.compareTo(a.title.length));
    c.read(charadesGameProvider.notifier).configure(
      GameSession(names: ['Mor', 'Pembe'], seconds: 90),
      [longest.first],
    );
    await tester.pumpAndSettle();
    await tap(tester, 'Hazırım');
    expect(find.text(longest.first.title), findsOneWidget);
    await tester.ensureVisible(find.text('Doğru'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    c.read(appRouterProvider).go('/games');
    await tester.pumpAndSettle();
  });
}
