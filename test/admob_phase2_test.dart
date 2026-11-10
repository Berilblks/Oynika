import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/app.dart';
import 'package:oynika/app/router/app_router.dart';
import 'package:oynika/core/ads/ad_units.dart';
import 'package:oynika/core/ads/ads_service.dart';
import 'package:oynika/core/ads/google_ads_backend.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' show AdWidget;
import 'package:oynika/features/games/charades/application/charades_controller.dart';
import 'package:oynika/features/games/charades/domain/charades_models.dart'
    show CharadesCard, CharadesOutcome;
import 'package:oynika/features/games/tabu/application/game_controller.dart';
import 'package:oynika/features/games/tabu/data/card_repository.dart';
import 'package:oynika/features/games/tabu/domain/tabu_models.dart';

class _Interstitial implements InterstitialPlacement {
  final completion = Completer<void>();
  int shown = 0;
  int disposed = 0;
  @override
  Future<void> show() {
    shown++;
    return completion.future;
  }

  @override
  void dispose() => disposed++;
}

class _Backend implements AdsBackend {
  bool allowed = true;
  bool required = false;
  bool failConsent = false;
  bool failInitialize = false;
  bool revokeOnPrivacy = false;
  int updates = 0;
  int initialized = 0;
  int interstitialRequests = 0;
  InterstitialPlacement? interstitial;

  @override
  Future<void> updateConsent() async {
    updates++;
    if (failConsent) throw StateError('Consent failed');
  }

  @override
  Future<void> showConsentIfRequired() async {}
  @override
  Future<bool> privacyOptionsRequired() async => required;
  @override
  Future<void> showPrivacyOptions() async {
    if (revokeOnPrivacy) allowed = false;
  }

  @override
  Future<bool> canRequestAds() async => allowed;
  @override
  Future<void> initialize() async {
    initialized++;
    if (failInitialize) throw StateError('Initialization failed');
  }

  @override
  Future<InterstitialPlacement?> loadInterstitial(String unit) async {
    interstitialRequests++;
    final ad = interstitial;
    interstitial = null;
    return ad;
  }
}

AdsService _service(_Backend backend) {
  final service = AdsService(
    backend,
    interstitialAdUnitFor(TargetPlatform.android, release: false),
  );
  addTearDown(service.dispose);
  return service;
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  testWidgets(
    'Tabu and Charades share the counter and early exits do not count',
    (tester) async {
      const cards = [
        TabuCard(
          id: 'a',
          word: 'Bir',
          forbidden: ['a'],
          category: 'Test',
          difficulty: 'easy',
        ),
        TabuCard(
          id: 'b',
          word: 'İki',
          forbidden: ['b'],
          category: 'Test',
          difficulty: 'easy',
        ),
      ];
      final ad = _Interstitial();
      final ads = _service(_Backend()..interstitial = ad);
      var now = Duration.zero;
      final container = ProviderContainer(
        overrides: [
          adsServiceProvider.overrideWithValue(ads),
          tabuCardsProvider.overrideWith((_) async => cards),
          tabuClockProvider.overrideWithValue(() => now),
          charadesClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const OynikaApp(),
        ),
      );
      await tester.pumpAndSettle();
      final router = container.read(appRouterProvider);
      router.go('/games/taboo');
      await tester.pumpAndSettle();
      final game = container.read(tabuGameProvider.notifier);
      final session = GameSession(
        names: ['Mavi', 'Kırmızı'],
        seconds: 60,
        targetScore: 10,
      );
      game.configure(session, cards);
      game.startRound();
      await tester.pump();
      router.go('/');
      await tester.pumpAndSettle();
      expect(ads.completedGames, 0);
      expect(ad.shown, 0);

      router.go('/games/taboo');
      await tester.pumpAndSettle();
      final freshGame = container.read(tabuGameProvider.notifier);
      freshGame.configure(session, cards);
      freshGame.startRound();
      for (var answer = 0; answer < 10; answer++) {
        final state = container.read(tabuGameProvider);
        freshGame.answer(state.card!.id, CardOutcome.correct);
        now += const Duration(milliseconds: 400);
      }
      await tester.pumpAndSettle();
      expect(ads.completedGames, 1);
      expect(ad.shown, 0);
      await tester.tap(find.text('Tekrar Oyna'));
      await tester.pumpAndSettle();
      expect(container.read(tabuGameProvider).phase, GamePhase.preRound);
      expect(ads.completedGames, 1);
      expect(ad.shown, 0);

      router.go('/games/charades');
      await tester.pumpAndSettle();
      final charades = container.read(charadesGameProvider.notifier);
      charades.configure(session, const [
        CharadesCard(
          id: 'a',
          title: 'Bir',
          category: 'Film',
          difficulty: 'easy',
        ),
        CharadesCard(
          id: 'b',
          title: 'İki',
          category: 'Dizi',
          difficulty: 'easy',
        ),
      ]);
      charades.startRound();
      for (var answer = 0; answer < 10; answer++) {
        final state = container.read(charadesGameProvider);
        charades.answer(state.card!.id, CharadesOutcome.correct);
        now += const Duration(milliseconds: 400);
      }
      await tester.pumpAndSettle();
      expect(ads.completedGames, 2);
      expect(ad.shown, 0);
      await tester.tap(find.text('Tekrar Oyna'));
      await tester.pumpAndSettle();
      expect(ad.shown, 1);
      expect(container.read(charadesGameProvider).phase, GamePhase.result);
      ad.completion.complete();
      await tester.pumpAndSettle();
      expect(container.read(charadesGameProvider).phase, GamePhase.preRound);
      expect(ad.disposed, 1);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test('Debug/profile and release QA select official platform test units', () {
    for (final (platform, fullscreen) in [
      (TargetPlatform.android, '1033173712'),
      (TargetPlatform.iOS, '4411468910'),
    ]) {
      final testUnits = 'ca-app-pub-3940256099942544/$fullscreen';
      expect(interstitialAdUnitFor(platform, release: false), testUnits);
      expect(
        interstitialAdUnitFor(platform, release: true, testMode: true),
        testUnits,
      );
    }
  });

  test('Production units are selected only for the corresponding release', () {
    expect(
      interstitialAdUnitFor(TargetPlatform.android, release: true),
      'ca-app-pub-8170413007027196/4528638952',
    );
    expect(
      interstitialAdUnitFor(TargetPlatform.iOS, release: true),
      'ca-app-pub-8170413007027196/3293392996',
    );
    expect(
      interstitialAdUnitFor(TargetPlatform.windows, release: true),
      isNull,
    );
    expect(
      interstitialAdUnitFor(TargetPlatform.iOS, release: true, web: true),
      isNull,
    );
  });

  for (final mode in ['denied', 'consent error', 'SDK error']) {
    test('$mode blocks all ad requests and keeps exits synchronous', () async {
      final backend = _Backend()
        ..allowed = mode == 'SDK error'
        ..failConsent = mode == 'consent error'
        ..failInitialize = mode == 'SDK error';
      final ads = _service(backend);
      await Future.wait([ads.start(), ads.start()]);
      expect(backend.updates, 1);
      expect(backend.initialized, mode == 'SDK error' ? 1 : 0);
      expect(ads.status.value.ready, isFalse);
      expect(backend.interstitialRequests, 0);
      var exited = 0;
      ads.leaveResult(Object(), () => true, () => exited++);
      expect(exited, 1);
    });
  }

  test(
    'Startup UMP failure honors previous eligibility from the SDK',
    () async {
      final backend = _Backend()
        ..failConsent = true
        ..required = true
        ..interstitial = _Interstitial();
      final ads = _service(backend);

      await Future.wait([ads.start(), ads.start()]);
      await _flush();

      expect(backend.updates, 1);
      expect(backend.initialized, 1);
      expect(ads.status.value.ready, isTrue);
      expect(ads.status.value.privacyOptions, isTrue);
      expect(backend.interstitialRequests, 1);
    },
  );

  test(
    'Privacy change discards the cached interstitial if UMP revokes eligibility',
    () async {
      final fullscreen = _Interstitial();
      final backend = _Backend()
        ..required = true
        ..revokeOnPrivacy = true
        ..interstitial = fullscreen;
      final ads = _service(backend);
      await ads.start();
      await _flush();
      expect(ads.status.value.privacyOptions, isTrue);
      expect(await ads.openPrivacyOptions(), isTrue);
      expect(fullscreen.disposed, 1);
      expect(ads.status.value.ready, isFalse);
      expect(backend.initialized, 1);
      expect(backend.interstitialRequests, 1);
    },
  );

  test('Interstitial preloading rechecks UMP eligibility', () async {
    final backend = _Backend();
    final ads = _service(backend);
    await ads.start();
    await _flush();
    expect(backend.interstitialRequests, 1);
    backend.allowed = false;
    ads.recordCompletion(Object());
    await _flush();
    expect(backend.interstitialRequests, 1);
  });

  test(
    'Count terminal identity once and show only on each second departure',
    () async {
      final second = _Interstitial();
      final fourth = _Interstitial();
      final backend = _Backend()..interstitial = second;
      final ads = _service(backend);
      await ads.start();
      await _flush();
      var exits = 0;
      void exit() => exits++;

      // A cancelled or stale attempt never adds an unfinished result.
      ads.leaveResult(Object(), () => false, exit);
      expect(ads.completedGames, 0);
      final first = Object();
      ads.recordCompletion(first);
      ads.recordCompletion(first);
      ads.leaveResult(first, () => true, exit);
      ads.leaveResult(first, () => true, exit);
      expect(exits, 1);
      expect(second.shown, 0);

      final result = Object();
      ads.recordCompletion(result);
      expect(second.shown, 0);
      ads.leaveResult(result, () => true, exit);
      ads.leaveResult(result, () => true, exit);
      expect(second.shown, 1);
      expect(exits, 1);
      backend.interstitial = fourth;
      second.completion.complete();
      await _flush();
      expect(exits, 2);
      expect(second.disposed, 1);

      // Replays are new completions only when their own terminal state arrives.
      ads.leaveResult(Object(), () => true, exit);
      ads.leaveResult(Object(), () => true, exit);
      expect(fourth.shown, 1);
      expect(exits, 3);
      fourth.completion.completeError(StateError('show failed'));
      await _flush();
      expect(exits, 4);
      expect(fourth.disposed, 1);
      expect(ads.completedGames, 4);
    },
  );

  test(
    'No loaded interstitial means immediate navigation even on game two',
    () async {
      final ads = _service(_Backend());
      await ads.start();
      await _flush();
      ads.recordCompletion(Object());
      final second = Object();
      var exited = false;
      ads.leaveResult(second, () => true, () => exited = true);
      expect(exited, isTrue);
      expect(ads.completedGames, 2);
    },
  );

  test(
    'Old pending fullscreen exit cannot navigate a replaced route',
    () async {
      final fullscreen = _Interstitial();
      final ads = _service(_Backend()..interstitial = fullscreen);
      await ads.start();
      await _flush();
      ads.recordCompletion(Object());
      var current = true;
      var navigations = 0;
      ads.leaveResult(Object(), () => current, () => navigations++);
      expect(fullscreen.shown, 1);
      current = false;
      fullscreen.completion.complete();
      await _flush();
      expect(navigations, 0);
      expect(fullscreen.disposed, 1);
    },
  );

  testWidgets('Home has no ad widget and its body touches the navigation bar', (
    tester,
  ) async {
    final ads = _service(_Backend()..interstitial = _Interstitial());
    final container = ProviderContainer(
      overrides: [adsServiceProvider.overrideWithValue(ads)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const OynikaApp()),
    );
    await tester.pumpAndSettle();

    expect(ads.status.value.ready, isTrue);
    expect(find.byType(AdWidget), findsNothing);
    final shell = tester.widget<Scaffold>(
      find.byWidgetPredicate(
        (widget) => widget is Scaffold && widget.bottomNavigationBar != null,
      ),
    );
    expect(
      tester.getBottomLeft(find.byWidget(shell.body!)).dy,
      tester.getTopLeft(find.byType(NavigationBar)).dy,
    );
  });
}
