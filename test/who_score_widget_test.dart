import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/core/utils/app_orientation.dart';
import 'package:oynika/features/games/who_am_i/application/who_controller.dart';
import 'package:oynika/features/games/who_am_i/application/who_deck_provider.dart';
import 'package:oynika/features/games/who_am_i/data/who_card_repository.dart';
import 'package:oynika/features/games/who_am_i/domain/who_card_deck.dart';
import 'package:oynika/features/games/who_am_i/domain/who_models.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_orientation_provider.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_screen.dart';

void main() {
  final cards = WhoCardRepository.decode(
    File(WhoCardRepository.assetPath).readAsStringSync(),
  );
  late ProviderContainer c;
  late WhoController controller;
  late GoRouter router;
  var now = Duration.zero;
  final calls = <List<DeviceOrientation>>[];
  Future<void> open(
    WidgetTester t, {
    bool dark = false,
    double scale = 1,
  }) async {
    now = Duration.zero;
    calls.clear();
    t.view.physicalSize = const Size(320, 568);
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    c = ProviderContainer(
      overrides: [
        whoClockProvider.overrideWithValue(() => now),
        whoCardsProvider.overrideWith((ref) async => cards),
        whoOrientationProvider.overrideWithValue(
          AppOrientation((directions) async {
            calls.add(directions);
          }),
        ),
        whoCardRandomProvider.overrideWithValue(Random(64)),
      ],
    );
    addTearDown(c.dispose);
    controller = c.read(whoSessionProvider.notifier);
    router = GoRouter(
      initialLocation: '/who',
      routes: [
        GoRoute(path: '/who', builder: (_, _) => const WhoScreen()),
        GoRoute(
          path: '/games',
          builder: (_, _) => const Scaffold(body: Text('Oyunlar menüsü')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp.router(
          theme: dark ? AppTheme.dark : AppTheme.light,
          routerConfig: router,
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, Finder f) async {
    await t.ensureVisible(f);
    await t.tap(f);
    await t.pumpAndSettle();
  }

  WhoGameSession s() => c.read(whoSessionProvider)!;
  void turn(int score, {int passes = 0}) {
    controller.beginCountdown(WhoCardDeck(cards: cards, random: Random(64)));
    now += const Duration(seconds: 3);
    controller.tick();
    controller.confirmOrientation();
    for (var i = 0; i < score + passes; i++) {
      controller.answer(
        s().card!.id,
        i < score ? WhoOutcome.correct : WhoOutcome.pass,
      );
      now += const Duration(milliseconds: 301);
      controller.tick();
    }
    now += const Duration(seconds: 61);
    controller.tick();
  }

  testWidgets('Varsayılan 20; beş hedef seçimi ve başlatma ayarları', (
    t,
  ) async {
    await open(t);
    expect(
      t
          .widget<ChoiceChip>(find.byKey(const ValueKey('who-target-20')))
          .selected,
      isTrue,
    );
    for (final target in WhoGameSettings.targetScores) {
      final f = find.byKey(ValueKey('who-target-$target'));
      await tap(t, f);
      expect(t.widget<ChoiceChip>(f).selected, isTrue);
    }
    await tap(t, find.byKey(const ValueKey('who-start')));
    expect(s().settings.targetScore, 30);
    expect(find.textContaining('Hedef puan: 30'), findsOneWidget);
  });
  testWidgets('Tur sonucu tüm oyuncuları sıralar ve sıradaki oyuncuyu açar', (
    t,
  ) async {
    await open(t);
    controller.start(
      names: ['Ece', 'Deniz', 'Can'],
      duration: WhoRoundDuration.short,
      targetScore: 10,
    );
    turn(10, passes: 2);
    await t.pumpAndSettle();
    expect(s().phase, WhoPhase.roundResult);
    expect(find.text('Genel Puan Tablosu'), findsOneWidget);
    final ece = find.byKey(const ValueKey('who-score-0'));
    expect(
      find.descendant(
        of: ece,
        matching: find.text('Son tur: 10 doğru • 2 pas • 10 puan'),
      ),
      findsOneWidget,
    );
    final deniz = find.byKey(const ValueKey('who-score-1'));
    expect(
      find.descendant(of: deniz, matching: find.text('Sıradaki oyuncu')),
      findsOneWidget,
    );
    await tap(t, find.text('Sıradaki Oyuncu'));
    expect(s().currentPlayer.name, 'Deniz');
    expect(find.text('Sıra Sende, Deniz!'), findsOneWidget);
  });
  for (final dark in [false, true]) {
    testWidgets(
      'Kazanan, tekrar oyna, yeni deste, oyunlara dön ve büyük yazı: $dark',
      (t) async {
        await open(t, dark: dark, scale: 1.8);
        controller.start(
          names: ['Ece Uzun Oyuncu Adı', 'Deniz'],
          duration: WhoRoundDuration.short,
          targetScore: 10,
        );
        turn(10);
        controller.nextPlayer();
        turn(1);
        await t.pumpAndSettle();
        expect(s().phase, WhoPhase.winner);
        expect(find.text('Kazanan: Ece Uzun Oyuncu Adı'), findsOneWidget);
        expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
        expect(find.text('Toplam oynanan tur: 2'), findsOneWidget);
        expect(calls.last, [DeviceOrientation.portraitUp]);
        final oldSettings = s().settings,
            oldDeck = await c.read(whoDeckProvider.future);
        await tap(t, find.text('Tekrar Oyna'));
        expect(s().totals, [0, 0]);
        expect(s().history, isEmpty);
        expect(s().settings.targetScore, 10);
        expect(s().settings.duration, WhoRoundDuration.short);
        expect(s().settings.players.first.name, 'Ece Uzun Oyuncu Adı');
        expect(s().settings, isNot(same(oldSettings)));
        final deck = await c.read(whoDeckProvider.future);
        expect(deck, isNot(same(oldDeck)));
        expect(deck!.remainingCount, 300);
        turn(10);
        controller.nextPlayer();
        turn(0);
        await t.pumpAndSettle();
        await tap(t, find.text('Oyunlara Dön'));
        expect(find.text('Oyunlar menüsü'), findsOneWidget);
        expect(c.read(whoSessionProvider), isNull);
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'Eski kazanan callback leri yeni oturumu ve çıkılmış rotayı etkileyemez',
    (t) async {
      await open(t);
      controller.start(
        names: ['Ece', 'Deniz'],
        duration: WhoRoundDuration.short,
        targetScore: 10,
      );
      turn(10);
      controller.nextPlayer();
      turn(0);
      await t.pumpAndSettle();
      final replay =
          t
              .widget<ButtonStyleButton>(
                find.byKey(const ValueKey('who-replay')),
              )
              .onPressed!;
      final games =
          t
              .widget<ButtonStyleButton>(
                find
                    .ancestor(
                      of: find.text('Oyunlara Dön'),
                      matching: find.byWidgetPredicate(
                        (w) => w is ButtonStyleButton,
                      ),
                    )
                    .first,
              )
              .onPressed!;
      replay();
      await t.pumpAndSettle();
      final settings = s().settings;
      replay();
      games();
      await t.pumpAndSettle();
      expect(s().settings, same(settings));
      expect(s().phase, WhoPhase.ready);
      turn(10);
      controller.nextPlayer();
      turn(0);
      await t.pumpAndSettle();
      final currentGames =
          t
              .widget<ButtonStyleButton>(
                find
                    .ancestor(
                      of: find.text('Oyunlara Dön'),
                      matching: find.byWidgetPredicate(
                        (w) => w is ButtonStyleButton,
                      ),
                    )
                    .first,
              )
              .onPressed!;
      currentGames();
      await t.pumpAndSettle();
      currentGames();
      replay();
      await t.pump();
      expect(find.text('Oyunlar menüsü'), findsOneWidget);
      expect(c.read(whoSessionProvider), isNull);
      expect(t.takeException(), isNull);
    },
  );
}
