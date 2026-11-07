import 'package:oynika/features/games/who_am_i/application/who_motion_provider.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:oynika/core/utils/app_orientation.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_orientation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/features/games/who_am_i/application/who_controller.dart';
import 'package:oynika/features/games/who_am_i/application/who_deck_provider.dart';
import 'package:oynika/features/games/who_am_i/data/who_card_repository.dart';
import 'package:oynika/features/games/who_am_i/domain/who_models.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_screen.dart';

class Clock {
  Duration now = Duration.zero;
}

void main() {
  final cards = WhoCardRepository.decode(
    File(WhoCardRepository.assetPath).readAsStringSync(),
  );
  late Clock clock;
  late ProviderContainer c;
  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 160));
  }

  Future<void> open(
    WidgetTester tester, {
    bool dark = false,
    Size size = const Size(393, 786),
    double scale = 1,
  }) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    clock = Clock();
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    c = ProviderContainer(
      overrides: [
        whoOrientationProvider.overrideWithValue(AppOrientation((_) async {})),
        whoMotionPreferredProvider.overrideWithValue(false),
        whoClockProvider.overrideWithValue(() => clock.now),
        whoCardsProvider.overrideWith((ref) async => cards),
        whoCardRandomProvider.overrideWithValue(Random(19)),
      ],
    );
    addTearDown(c.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: const WhoScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tap(tester, find.byKey(const ValueKey('who-start')));
    await tester.pump();
  }

  Future<void> advance(WidgetTester tester, Duration time) async {
    clock.now += time;
    c.read(whoSessionProvider.notifier).tick();
    await tester.pump(const Duration(milliseconds: 160));
  }

  Future<void> turnAndConfirm(WidgetTester tester) async {
    final size = tester.view.physicalSize;
    if (size.width < size.height) {
      tester.view.physicalSize = Size(size.height, size.width);
    }
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Hazırım'))
          .onPressed,
      isNotNull,
      reason: 'orientation readiness',
    );
    await tap(tester, find.text('Hazırım'));
    expect(
      c.read(whoSessionProvider)!.phase,
      WhoPhase.playing,
      reason: 'after orientation confirmation',
    );
  }

  Future<void> play(WidgetTester tester) async {
    await tap(tester, find.text('Başlamaya Hazırım'));
    await advance(tester, const Duration(seconds: 3));
    await turnAndConfirm(tester);
  }

  WhoGameSession session() => c.read(whoSessionProvider)!;

  testWidgets('Ayarlardan hazırlık, 3/2/1, gerçek kart ve tam süre', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Sıra Sende, Oyuncu 1!'), findsOneWidget);
    expect(find.byKey(const ValueKey('who-active-card')), findsNothing);
    await tap(tester, find.text('Başlamaya Hazırım'));
    for (final number in [3, 2, 1]) {
      expect(find.text('$number'), findsOneWidget);
      expect(find.byKey(const ValueKey('who-active-card')), findsNothing);
      await advance(tester, const Duration(seconds: 1));
    }
    expect(session().phase, WhoPhase.orienting);
    await turnAndConfirm(tester);
    expect(find.byKey(const ValueKey('who-active-card')), findsOneWidget);
    expect(find.text('01:30'), findsOneWidget);
    expect(cards.map((card) => card.id), contains(session().card!.id));
    c.read(whoSessionProvider.notifier).pause();
    await tester.pump();
  });
  testWidgets('Doğru/Pas, kilit, sonuç, sıradaki oyuncu ve yeniden başlat', (
    tester,
  ) async {
    await open(tester);
    await play(tester);
    final correct = find.widgetWithText(FilledButton, 'Doğru +1');
    final stale = tester.widget<FilledButton>(correct).onPressed!;
    stale();
    stale();
    await tester.pump();
    expect(session().correct, 1);
    expect(tester.widget<FilledButton>(correct).onPressed, isNull);
    await advance(tester, const Duration(milliseconds: 301));
    await tap(tester, find.widgetWithText(FilledButton, 'Pas'));
    expect(session().passed, 1);
    expect(session().totals, [1, 0, 0, 0]);
    await advance(tester, const Duration(seconds: 91));
    expect(find.text('Tur Bitti!'), findsOneWidget);
    expect(find.text('Kazanılan puan: 1'), findsOneWidget);
    expect(find.text('Toplam puan: 1'), findsOneWidget);
    await tap(tester, find.text('Sıradaki Oyuncu'));
    expect(find.text('Sıra Sende, Oyuncu 2!'), findsOneWidget);
    expect(session().deckRemaining, 297);
    await tap(tester, find.byTooltip('Oyunu yeniden başlat'));
    await tap(tester, find.text('Yeniden Başlat'));
    expect(session().phase, WhoPhase.ready);
    expect(session().totals, [0, 0, 0, 0]);
    expect(session().currentPlayerIndex, 0);
    await c.read(whoDeckProvider.future);
    await tester.pump();
    expect((await c.read(whoDeckProvider.future))!.remainingCount, 300);
  });
  testWidgets('Arka plan anında gizler; dönüşte manuel devam ve çıkış onayı', (
    tester,
  ) async {
    await open(tester);
    await play(tester);
    final card = session().card!;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(session().phase, WhoPhase.paused);
    expect(find.byKey(const ValueKey('who-active-card')), findsNothing);
    await advance(tester, const Duration(minutes: 2));
    expect(session().remaining, const Duration(seconds: 90));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(session().phase, WhoPhase.paused);
    await tap(tester, find.text('Devam Et'));
    await turnAndConfirm(tester);
    expect(session().card!.id, card.id);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Oyundan çıkmak istiyor musun?'), findsOneWidget);
    expect(find.byKey(const ValueKey('who-active-card')), findsNothing);
    await tap(tester, find.text('Vazgeç'));
    expect(session().phase, WhoPhase.paused);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tap(tester, find.text('Çık'));
    expect(c.read(whoSessionProvider), isNull);
    expect(find.byKey(const ValueKey('who-start')), findsOneWidget);
  });
  testWidgets('Widget dispose sonrası aktif Timer temizlenir', (tester) async {
    await open(tester);
    await play(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await tester.pump();
    await tester.pump();

    clock.now += const Duration(minutes: 10);
    await tester.pump(const Duration(minutes: 10));
    final retained = c.read(whoSessionProvider);
    expect(
      retained == null ||
          (retained.phase == WhoPhase.playing &&
              retained.remaining == const Duration(seconds: 90)),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
  for (final dark in [false, true]) {
    for (final size in [const Size(320, 568), const Size(393, 786)]) {
      testWidgets('Tüm evreler küçük ekran/büyük yazı: $dark/$size', (
        tester,
      ) async {
        await open(tester, dark: dark, size: size, scale: 1.6);
        expect(find.text('Başlamaya Hazırım').hitTestable(), findsOneWidget);
        await play(tester);
        expect(
          find.widgetWithText(FilledButton, 'Doğru +1').hitTestable(),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(FilledButton, 'Pas').hitTestable(),
          findsOneWidget,
        );
        await tester.ensureVisible(
          find.byKey(const ValueKey('who-active-card')),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        c.read(whoSessionProvider.notifier).pause();
        await tester.pump();
        expect(find.text('Devam Et').hitTestable(), findsOneWidget);
        c.read(whoSessionProvider.notifier).resume();
        await advance(tester, const Duration(seconds: 91));
        expect(find.text('Sıradaki Oyuncu').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
