import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/app.dart';
import 'package:oynika/app/launch_splash.dart';
import 'package:oynika/app/router/app_router.dart';
import 'package:oynika/core/ads/ad_units.dart';
import 'package:oynika/core/ads/ads_diagnostics.dart';
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
  Completer<void>? pendingUpdate;
  Future<InterstitialPlacement?>? pendingInterstitial;
  int updates = 0;
  int initialized = 0;
  int interstitialRequests = 0;
  InterstitialPlacement? interstitial;

  @override
  Future<void> updateConsent() async {
    updates++;
    await pendingUpdate?.future;
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
    if (pendingInterstitial != null) return pendingInterstitial;
    final ad = interstitial;
    interstitial = null;
    return ad;
  }
}

AdsService _service(
  _Backend backend, {
  bool qa = false,
  AdsDiagnostics? diagnostics,
  Duration retryCooldown = const Duration(seconds: 15),
}) {
  final service = AdsService(
    backend,
    interstitialAdUnitFor(TargetPlatform.android, release: false),
    qaEnabled: qa,
    diagnostics: diagnostics,
    retryCooldown: retryCooldown,
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
      final nextAd = _Interstitial();
      final backend = _Backend()..interstitial = ad;
      final ads = _service(backend);
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
      expect(container.read(tabuGameProvider).phase, GamePhase.result);
      expect(ads.completedGames, 1);
      expect(ad.shown, 1);
      backend.interstitial = nextAd;
      ad.completion.complete();
      await tester.pumpAndSettle();
      expect(container.read(tabuGameProvider).phase, GamePhase.preRound);

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
      expect(nextAd.shown, 0);
      await tester.tap(find.text('Tekrar Oyna'));
      await tester.pumpAndSettle();
      expect(nextAd.shown, 1);
      expect(container.read(charadesGameProvider).phase, GamePhase.result);
      nextAd.completion.complete();
      await tester.pumpAndSettle();
      expect(container.read(charadesGameProvider).phase, GamePhase.preRound);
      expect(ad.disposed, 1);
      expect(nextAd.disposed, 1);
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
    'Every completed game has one exit opportunity, including the first',
    () async {
      var ad = _Interstitial();
      final backend = _Backend()..interstitial = ad;
      final ads = _service(backend);
      await ads.start();
      await _flush();
      var exits = 0;
      ads.leaveResult(Object(), () => false, () => exits++);
      expect(ads.completedGames, 0);
      for (var i = 0; i < 4; i++) {
        final result = Object();
        ads.recordCompletion(result);
        ads.recordCompletion(result);
        expect(ads.completedGames, i + 1);
        expect(ad.shown, 0); // Merely opening results never shows an ad.
        ads.leaveResult(result, () => true, () => exits++);
        ads.leaveResult(result, () => true, () => exits++);
        await _flush();
        expect(ad.shown, 1);
        expect(exits, i);
        final next = _Interstitial();
        backend.interstitial = next;
        if (i == 3) {
          ad.completion.completeError(StateError('show failed'));
        } else {
          ad.completion.complete();
        }
        await _flush();
        expect(exits, i + 1);
        expect(ad.disposed, 1);
        ads.leaveResult(result, () => true, () => exits++);
        expect(exits, i + 1);
        ad = next;
      }
      expect(ads.completedGames, 4);
    },
  );

  test(
    'No loaded ad means immediate navigation on first and later games',
    () async {
      final ads = _service(_Backend());
      await ads.start();
      await _flush();
      for (var i = 1; i <= 3; i++) {
        var exited = false;
        ads.leaveResult(Object(), () => true, () => exited = true);
        expect(exited, isTrue);
        expect(ads.completedGames, i);
        await _flush();
      }
    },
  );

  test('A retry of the same result cannot consume a second ad', () async {
    final ad = _Interstitial();
    final next = _Interstitial();
    final backend = _Backend()..interstitial = ad;
    final ads = _service(backend);
    await ads.start();
    await _flush();
    final result = Object();
    var exits = 0;
    Future<void> leave() async {
      exits++;
    }

    ads.leaveResult(result, () => true, leave);
    await _flush();
    backend.interstitial = next;
    ad.completion.complete();
    await _flush();
    ads.leaveResult(result, () => true, leave);
    await _flush();
    expect(exits, 2);
    expect(ads.completedGames, 1);
    expect(ad.shown, 1);
    expect(next.shown, 0);
  });

  test(
    'Normal result exit rechecks UMP before presenting a loaded ad',
    () async {
      final ad = _Interstitial();
      final backend = _Backend()..interstitial = ad;
      final ads = _service(backend);
      await ads.start();
      await _flush();
      backend.allowed = false;
      var exited = false;
      ads.leaveResult(Object(), () => true, () => exited = true);
      await _flush();
      expect(ad.shown, 0);
      expect(ad.disposed, 1);
      expect(exited, isTrue);
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
      await _flush();
      expect(fullscreen.shown, 1);
      current = false;
      fullscreen.completion.complete();
      await _flush();
      expect(navigations, 0);
      expect(fullscreen.disposed, 1);
    },
  );

  testWidgets(
    'Splash completes without waiting for UMP and never returns on resume',
    (tester) async {
      final backend = _Backend()..pendingUpdate = Completer<void>();
      final ads = _service(backend);
      final container = ProviderContainer(
        overrides: [adsServiceProvider.overrideWithValue(ads)],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const OynikaApp(),
        ),
      );
      expect(find.byKey(const ValueKey('launch-splash')), findsOneWidget);
      expect(backend.updates, 0);
      await tester.pump(LaunchSplash.duration);
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byKey(const ValueKey('launch-splash')), findsNothing);
      expect(backend.updates, 1);
      expect(ads.status.value.busy, isTrue);
      await tester.tap(find.byKey(const ValueKey('explore-games')));
      await tester.pumpAndSettle();
      expect(container.read(appRouterProvider).state.uri.path, '/games');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.byKey(const ValueKey('launch-splash')), findsNothing);
      expect(backend.updates, 1);
      backend.pendingUpdate!.complete();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
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
  test('QA forces official test units even in a release build', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      final unit = interstitialAdUnitFor(platform, release: true, qa: true);
      expect(isGoogleTestInterstitialUnit(unit), isTrue);
      expect(
        isGoogleTestInterstitialUnit(
          interstitialAdUnitFor(platform, release: true),
        ),
        isFalse,
      );
    }
  });

  test(
    'Initialization failure can recover without restarting the app',
    () async {
      final backend = _Backend()..failInitialize = true;
      final ads = _service(backend, retryCooldown: Duration.zero);
      await ads.start();
      expect(ads.status.value.ready, isFalse);
      backend.failInitialize = false;
      expect(await ads.retryConsent(), isTrue);
      await _flush();
      expect(ads.status.value.ready, isTrue);
      expect(backend.initialized, 2);
      expect(backend.interstitialRequests, 1);
    },
  );

  test(
    'Offline startup retries are serialized and resume retries are capped',
    () async {
      final backend = _Backend()
        ..failConsent = true
        ..allowed = false;
      final ads = _service(backend, retryCooldown: Duration.zero);
      await ads.start();
      for (var i = 0; i < 5; i++) {
        await ads.retryConsent(automatic: true);
      }
      expect(backend.updates, 4);
      expect(backend.interstitialRequests, 0);
      backend.failConsent = false;
      backend.allowed = true;
      await ads.retryConsent();
      await _flush();
      expect(backend.updates, 5);
      expect(ads.status.value.ready, isTrue);
      expect(backend.interstitialRequests, 1);
      await ads.retryConsent(automatic: true);
      expect(backend.updates, 5);
    },
  );

  test('Pending UMP work and cooldown prevent repeated requests', () async {
    final backend = _Backend()..pendingUpdate = Completer<void>();
    final ads = _service(backend);
    final startup = ads.start();
    expect(await ads.retryConsent(), isFalse);
    backend.pendingUpdate!.complete();
    await startup;
    expect(await ads.retryConsent(), isFalse);
    expect(backend.updates, 1);
  });

  test('QA controls require QA mode and an official test unit', () async {
    final backend = _Backend();
    final ads = _service(backend);
    await ads.loadQaTestAd();
    await ads.showQaTestAd(() => true);
    expect(backend.interstitialRequests, 0);
    final production = AdsService(
      backend,
      interstitialAdUnitFor(TargetPlatform.iOS, release: true),
      qaEnabled: true,
    );
    addTearDown(production.dispose);
    await production.loadQaTestAd();
    expect(production.qaEnabled, isFalse);
    expect(backend.interstitialRequests, 0);
  });

  test(
    'QA load and show preserve the completion counter and reject duplicate shows',
    () async {
      final ad = _Interstitial();
      final backend = _Backend()..interstitial = ad;
      final diagnostics = AdsDiagnostics();
      addTearDown(diagnostics.dispose);
      final ads = _service(backend, qa: true, diagnostics: diagnostics);
      await ads.start();
      await _flush();
      expect(ads.qaCanShow, isTrue);
      expect(diagnostics.value(AdQaField.unitType), 'test');
      final show = ads.showQaTestAd(() => true);
      final duplicate = ads.showQaTestAd(() => true);
      await _flush();
      expect(ad.shown, 1);
      expect(ads.completedGames, 0);
      expect(ads.qaCanShow, isFalse);
      ad.completion.complete();
      await Future.wait([show, duplicate]);
      expect(ads.completedGames, 0);
      expect(ad.disposed, 1);
      expect(diagnostics.value(AdQaField.show), 'Gösterim tamamlandı');
    },
  );

  test(
    'QA cannot load without consent or show after consent is revoked',
    () async {
      final backend = _Backend()..allowed = false;
      final ads = _service(backend, qa: true);
      await ads.start();
      await ads.loadQaTestAd();
      expect(backend.interstitialRequests, 0);
      expect(ads.qaCanShow, isFalse);

      final ad = _Interstitial();
      backend.allowed = true;
      backend.interstitial = ad;
      final ready = _service(backend, qa: true);
      await ready.start();
      await _flush();
      backend.allowed = false;
      await ready.showQaTestAd(() => true);
      expect(ad.shown, 0);
      expect(ad.disposed, 1);
    },
  );

  test('A disposed QA screen cannot present a late ad', () async {
    final ad = _Interstitial();
    final backend = _Backend()..pendingInterstitial = Future.value(ad);
    final ads = _service(backend, qa: true);
    await ads.start();
    await _flush();
    await ads.showQaTestAd(() => false);
    expect(ad.shown, 0);
  });

  test(
    'QA messages contain no raw identifiers and the event list is bounded',
    () {
      final safe = safeAdError(
        'secret-domain-device-id',
        7,
        'Network error for person@example.com ca-app-pub-secret 192.168.1.1',
      );
      expect(safe, 'other / 7 / Ağ bağlantısı hatası');
      final diagnostics = AdsDiagnostics();
      for (var i = 0; i < 50; i++) {
        diagnostics.event('event $i');
      }
      expect(diagnostics.events.length, 40);
      diagnostics.dispose();
      expect(() => diagnostics.event('late callback'), returnsNormally);
    },
  );

  for (final qa in [false, true]) {
    testWidgets('QA route and settings visibility are gated: $qa', (
      tester,
    ) async {
      final diagnostics = qa ? AdsDiagnostics() : null;
      if (diagnostics != null) addTearDown(diagnostics.dispose);
      final ads = _service(_Backend(), qa: qa, diagnostics: diagnostics);
      final container = ProviderContainer(
        overrides: [
          adsQaEnabledProvider.overrideWithValue(qa),
          adsServiceProvider.overrideWithValue(ads),
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
      router.go('/settings');
      await tester.pumpAndSettle();
      final label = find.text('Reklam tanılama (QA)');
      expect(label, qa ? findsOneWidget : findsNothing);
      router.go('/qa/ads');
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        qa ? '/qa/ads' : '/settings',
      );
      if (qa) {
        await tester.scrollUntilVisible(find.text('Test reklamını yükle'), 200);
      }
      expect(
        find.text('Test reklamını yükle'),
        qa ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('Test reklamını göster'),
        qa ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
