import 'package:oynika/features/games/who_am_i/application/who_motion_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/core/utils/app_orientation.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/features/games/who_am_i/application/who_controller.dart';
import 'package:oynika/features/games/who_am_i/application/who_deck_provider.dart';
import 'package:oynika/features/games/who_am_i/data/who_card_repository.dart';
import 'package:oynika/features/games/who_am_i/domain/who_models.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_screen.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_landscape_board.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_orientation_provider.dart';

void main() {
  final cards = WhoCardRepository.decode(
    File(WhoCardRepository.assetPath).readAsStringSync(),
  );
  late ProviderContainer c;
  var now = Duration.zero;
  Future<void> tap(WidgetTester t, String label) async {
    final f = find.text(label);
    await t.ensureVisible(f);
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> open(WidgetTester t, AppOrientation manager) async {
    now = Duration.zero;
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    t.view.physicalSize = const Size(393, 786);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    c = ProviderContainer(
      overrides: [
        whoOrientationProvider.overrideWithValue(manager),
        whoMotionPreferredProvider.overrideWithValue(false),
        whoClockProvider.overrideWithValue(() => now),
        whoCardsProvider.overrideWith((ref) async => cards),
        whoCardRandomProvider.overrideWithValue(Random(19)),
      ],
    );
    addTearDown(c.dispose);
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(theme: AppTheme.light, home: const WhoScreen()),
      ),
    );
    await t.pumpAndSettle();
    await tap(t, 'Oyunu Başlat');
  }

  Future<void> completeCountdown(WidgetTester t) async {
    now += const Duration(seconds: 3);
    c.read(whoSessionProvider.notifier).tick();
    await t.pumpAndSettle();
  }

  testWidgets(
    'Dikey hazırlık, 3/2/1, API ve ölçüm bekleme; onaydan önce saat başlamaz',
    (t) async {
      final wait = Completer<void>();
      final calls = <List<DeviceOrientation>>[];
      await open(
        t,
        AppOrientation((directions) async {
          calls.add(directions);
          if (directions.contains(DeviceOrientation.landscapeLeft)) {
            await wait.future;
          }
        }),
      );
      expect(calls.last, [DeviceOrientation.portraitUp]);
      await tap(t, 'Başlamaya Hazırım');
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await t.pump();
      expect(c.read(whoSessionProvider)!.phase, WhoPhase.countdown);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(
        find.text('Telefonunu yan çevir ve alnına yerleştir!'),
        findsOneWidget,
      );
      for (final n in [3, 2, 1]) {
        expect(find.text('$n'), findsOneWidget);
        now += const Duration(seconds: 1);
        c.read(whoSessionProvider.notifier).tick();
        await t.pump();
      }
      expect(c.read(whoSessionProvider)!.phase, WhoPhase.orienting);
      now += const Duration(minutes: 2);
      c.read(whoSessionProvider.notifier).tick();
      expect(
        c.read(whoSessionProvider)!.remaining,
        const Duration(seconds: 90),
      );
      expect(find.byKey(const ValueKey('who-active-card')), findsNothing);
      t.view.physicalSize = const Size(786, 393);
      await t.pumpAndSettle();
      expect(
        t
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Hazırım'))
            .onPressed,
        isNull,
      );
      wait.complete();
      await t.pumpAndSettle();
      await tap(t, 'Hazırım');
      expect(c.read(whoSessionProvider)!.phase, WhoPhase.playing);
      expect(find.byType(SingleChildScrollView), findsNothing);
      now += const Duration(seconds: 90);
      c.read(whoSessionProvider.notifier).tick();
      await t.pumpAndSettle();
      expect(calls.last, [DeviceOrientation.portraitUp]);
      t.view.physicalSize = const Size(393, 786);
      await t.pumpAndSettle();
      expect(find.text('Tur Bitti!'), findsOneWidget);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      await tap(t, 'Çık');
      expect(calls.last, [DeviceOrientation.portraitUp]);
      expect(find.byKey(const ValueKey('who-start')), findsOneWidget);
    },
  );
  testWidgets(
    'Bekleyen yön isteği sırasında arka plan ve dispose kelimeyi açamaz',
    (t) async {
      final wait = Completer<void>();
      final calls = <List<DeviceOrientation>>[];
      await open(
        t,
        AppOrientation((directions) async {
          calls.add(directions);
          if (directions.contains(DeviceOrientation.landscapeLeft)) {
            await wait.future;
          }
        }),
      );
      await tap(t, 'Başlamaya Hazırım');
      await completeCountdown(t);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await t.pump();
      expect(c.read(whoSessionProvider)!.phase, WhoPhase.paused);
      await t.pumpWidget(const SizedBox());
      wait.complete();
      await t.pumpAndSettle();
      expect(calls.last, [DeviceOrientation.portraitUp]);
      expect(find.byKey(const ValueKey('who-active-card')), findsNothing);
      expect(t.takeException(), isNull);
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    },
  );
  testWidgets('Hazırda onay olsa da portrait ölçümde kart ve süre başlamaz', (
    t,
  ) async {
    await open(t, AppOrientation((_) async {}));
    await tap(t, 'Başlamaya Hazırım');
    await completeCountdown(t);
    expect(
      t
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Hazırım'))
          .onPressed,
      isNull,
    );
    expect(c.read(whoSessionProvider)!.card, isNull);
  });

  for (final dark in [false, true]) {
    for (final size in [
      const Size(568, 320),
      const Size(667, 375),
      const Size(844, 390),
      const Size(932, 430),
    ]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'Yatay, çentik, büyük yazı, uzun isim: $dark/$size/$scale',
          (t) async {
            t.view.physicalSize = size;
            t.view.devicePixelRatio = 1;
            t.view.padding = FakeViewPadding(
              left: size.width > 800 ? 47 : 0,
              right: size.width > 800 ? 47 : 0,
              bottom: size.width > 800 ? 21 : 0,
            );
            t.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(t.view.resetPhysicalSize);
            addTearDown(t.view.resetDevicePixelRatio);
            addTearDown(t.view.resetPadding);
            addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
            final longest = cards.reduce(
              (a, b) => a.name.length > b.name.length ? a : b,
            );
            final s = WhoGameSession(
              settings: WhoGameSettings(
                names: ['Uzun Oyuncu İsmi Deneme', 'Deniz'],
              ),
              phase: WhoPhase.playing,
              card: longest,
            );
            await t.pumpWidget(
              MaterialApp(
                theme: dark ? AppTheme.dark : AppTheme.light,
                home: Scaffold(
                  body: SafeArea(
                    child: WhoLandscapeBoard(
                      session: s,
                      onCorrect: () {},
                      onPass: () {},
                      onPause: () {},
                      onExit: () {},
                    ),
                  ),
                ),
              ),
            );
            await t.pumpAndSettle();
            expect(find.byType(SingleChildScrollView), findsNothing);
            expect(
              find.widgetWithText(FilledButton, 'Doğru +1').hitTestable(),
              findsOneWidget,
            );
            expect(
              find.widgetWithText(FilledButton, 'Pas').hitTestable(),
              findsOneWidget,
            );
            final paragraph = t.renderObject<RenderParagraph>(
              find.byKey(const ValueKey('who-active-card')),
            );
            expect(paragraph.didExceedMaxLines, isFalse);
            expect(t.takeException(), isNull);
            final text = t.widget<Text>(
              find.byKey(const ValueKey('who-active-card')),
            );
            expect(text.style!.color, Colors.white);
            expect(text.maxLines, 2);
          },
        );
      }
    }
  }
}
