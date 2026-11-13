import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/app.dart';
import 'package:oynika/app/router/app_router.dart';
import 'package:oynika/core/ads/ad_units.dart';
import 'package:oynika/core/ads/ads_service.dart';
import 'package:oynika/core/ads/ads_diagnostics.dart';
import 'package:oynika/core/ads/google_ads_backend.dart';
import 'package:oynika/core/utils/app_orientation.dart';
import 'package:oynika/features/games/tabu/application/game_controller.dart';
import 'package:oynika/features/games/tabu/data/card_repository.dart';
import 'package:oynika/features/games/tabu/domain/tabu_models.dart';
import 'package:oynika/features/games/charades/application/charades_controller.dart';
import 'package:oynika/features/games/charades/domain/charades_models.dart';
import 'package:oynika/features/games/undercover/application/undercover_controller.dart';
import 'package:oynika/features/games/who_am_i/application/who_controller.dart';
import 'package:oynika/features/games/who_am_i/application/who_motion_provider.dart';
import 'package:oynika/features/games/who_am_i/domain/who_models.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_orientation_provider.dart';

class _Ad implements InterstitialPlacement {
  final closed = Completer<void>();
  int shown = 0;
  bool disposed = false;
  @override
  Future<void> show() {
    shown++;
    return closed.future;
  }

  @override
  void dispose() {
    disposed = true;
  }
}

class _Backend implements AdsBackend {
  bool allowed = true;
  int loads = 0;
  InterstitialPlacement? next;
  Future<InterstitialPlacement?>? pending;
  @override
  Future<void> updateConsent() async {}
  @override
  Future<void> showConsentIfRequired() async {}
  @override
  Future<bool> privacyOptionsRequired() async => false;
  @override
  Future<void> showPrivacyOptions() async {}
  @override
  Future<bool> canRequestAds() async => allowed;
  @override
  Future<void> initialize() async {}
  @override
  Future<InterstitialPlacement?> loadInterstitial(String unit) async {
    loads++;
    if (pending != null) return pending;
    final ad = next;
    next = null;
    return ad;
  }
}

class _Rig {
  _Rig({bool qa = false}) {
    ads = AdsService(
      backend,
      interstitialAdUnitFor(TargetPlatform.iOS, release: false),
      clock: () => now,
      qaEnabled: qa,
    );
    addTearDown(ads.dispose);
  }
  Duration now = Duration.zero;
  final backend = _Backend();
  late final AdsService ads;
  Future<void> start() async {
    await ads.start();
    await flush();
  }
}

Future<void> flush() => Future<void>.delayed(Duration.zero);

class _WhoResult extends WhoController {
  _WhoResult(this.initial);
  final WhoGameSession initial;
  @override
  WhoGameSession? build() {
    super.build();
    return initial;
  }
}

class _UndercoverResult extends UndercoverController {
  _UndercoverResult(this.initial);
  final UndercoverSession initial;
  @override
  UndercoverSession? build() => initial;
}

const _cards = [
  TabuCard(
    id: 'a',
    word: 'Bir',
    forbidden: ['a'],
    category: 'Test',
    difficulty: 'Kolay',
  ),
  TabuCard(
    id: 'b',
    word: 'İki',
    forbidden: ['b'],
    category: 'Test',
    difficulty: 'Kolay',
  ),
];

Future<void> mount(
  WidgetTester tester,
  ProviderContainer c,
  String path,
) async {
  addTearDown(c.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: c, child: const OynikaApp()),
  );
  await tester.pumpAndSettle();
  c.read(appRouterProvider).go(path);
  await tester.pumpAndSettle();
}

Future<void> tap(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Late QA dismissal after disposal does not leave a cooldown timer',
    (tester) async {
      final ad = _Ad();
      final backend = _Backend()..next = ad;
      final diagnostics = AdsDiagnostics();
      final ads = AdsService(
        backend,
        interstitialAdUnitFor(TargetPlatform.iOS, release: false),
        qaEnabled: true,
        diagnostics: diagnostics,
      );
      var disposed = false;
      addTearDown(() {
        if (!disposed) {
          ads.dispose();
          diagnostics.dispose();
        }
      });
      await ads.start();
      await tester.pump();
      final showing = ads.showQaTestAd(() => true);
      await tester.pump();
      expect(ad.shown, 1);
      ads.dispose();
      diagnostics.dispose();
      disposed = true;
      ad.closed.complete();
      await showing;
      await tester.pump();
      expect(ad.disposed, isTrue);
      // The widget test binding also rejects any outstanding 90-second timer.
    },
  );
  test(
    'A saved round counts once, never completes a game, and shows only on departure',
    () async {
      final h = _Rig();
      final ad = _Ad();
      h.backend.next = ad;
      await h.start();
      final round = Object();
      h.ads.recordRound(round);
      h.ads.recordRound(round);
      expect(h.ads.completedRounds, 1);
      expect(h.ads.completedGames, 0);
      expect(ad.shown, 0);
      var next = 0;
      h.ads.leaveRound(round, () => true, () => next++);
      h.ads.leaveRound(round, () => true, () => next++);
      await flush();
      expect(ad.shown, 1);
      expect(next, 0);
      ad.closed.complete();
      await flush();
      expect(next, 1);
      expect(h.backend.loads, 2);
    },
  );

  test(
    '90 seconds are measured from dismissal; skipped rounds never delay navigation',
    () async {
      final h = _Rig();
      final ad = _Ad();
      final nextAd = _Ad();
      h.backend.next = ad;
      await h.start();
      h.ads.leaveRound(Object(), () => true, () {});
      await flush();
      h.now = const Duration(seconds: 30);
      h.backend.next = nextAd;
      ad.closed.complete();
      await flush();
      expect(h.ads.lastFullscreenAt, h.now);
      h.now = const Duration(milliseconds: 119999);
      var exits = 0;
      h.ads.leaveRound(Object(), () => true, () => exits++);
      expect(exits, 1);
      expect(nextAd.shown, 0);
      h.now = const Duration(seconds: 120);
      h.ads.leaveRound(Object(), () => true, () => exits++);
      await flush();
      expect(nextAd.shown, 1);
      expect(exits, 1);
      nextAd.closed.complete();
      await flush();
      expect(exits, 2);
    },
  );

  test(
    'A late load does not show for a round which already continued',
    () async {
      final h = _Rig();
      final loading = Completer<InterstitialPlacement?>();
      h.backend.pending = loading.future;
      await h.start();
      final skipped = Object();
      var exits = 0;
      h.ads.leaveRound(skipped, () => true, () => exits++);
      expect(exits, 1);
      final ad = _Ad();
      h.backend.pending = null;
      loading.complete(ad);
      await flush();
      expect(ad.shown, 0);
      h.ads.leaveRound(skipped, () => true, () => exits++);
      expect(exits, 1);
      h.ads.leaveRound(Object(), () => true, () => exits++);
      await flush();
      expect(ad.shown, 1);
      ad.closed.complete();
      await flush();
      expect(exits, 2);
    },
  );

  test(
    'Round-to-results and results-to-home share the final round but can both navigate',
    () async {
      final h = _Rig();
      final ad = _Ad();
      final next = _Ad();
      h.backend.next = ad;
      await h.start();
      final round = Object(), game = Object();
      var exits = 0;
      h.ads.leaveRound(round, () => true, () => exits++);
      await flush();
      h.backend.next = next;
      ad.closed.complete();
      await flush();
      h.now += const Duration(seconds: 100);
      h.ads.leaveResult(game, () => true, () => exits++, round: round);
      await flush();
      expect(exits, 2);
      expect(next.shown, 0);
      expect(h.ads.completedRounds, 1);
      expect(h.ads.completedGames, 1);
      h.ads.leaveResult(game, () => true, () => exits++, round: round);
      expect(exits, 2);
    },
  );

  test(
    'QA uses the same interval and never changes completion counters',
    () async {
      final h = _Rig(qa: true);
      final ad = _Ad();
      final next = _Ad();
      h.backend.next = ad;
      await h.start();
      final qa = h.ads.showQaTestAd(() => true);
      await flush();
      h.backend.next = next;
      ad.closed.complete();
      await qa;
      await flush();
      expect(h.ads.completedGames, 0);
      expect(h.ads.completedRounds, 0);
      expect(h.ads.qaCanShow, isFalse);
      var exits = 0;
      h.ads.leaveRound(Object(), () => true, () => exits++);
      expect(exits, 1);
      expect(next.shown, 0);
      h.now += const Duration(seconds: 90);
      h.ads.leaveRound(Object(), () => true, () => exits++);
      await flush();
      expect(next.shown, 1);
      next.closed.complete();
      await flush();
      expect(exits, 2);
    },
  );

  test('UMP denies round ad requests and stale exits do not count', () async {
    final h = _Rig();
    h.backend.allowed = false;
    await h.start();
    h.ads.leaveRound(Object(), () => false, () => fail('stale navigation'));
    expect(h.ads.completedRounds, 0);
    var exits = 0;
    h.ads.leaveRound(Object(), () => true, () => exits++);
    await flush();
    expect(exits, 1);
    expect(h.backend.loads, 0);
    expect(h.ads.completedGames, 0);
  });

  for (final charades in [false, true]) {
    for (final seconds in [60, 90, 120]) {
      testWidgets(
        '${charades ? 'Charades' : 'Tabu'} $seconds-second round preserves scores after ${seconds == 120 ? 'show failure' : 'dismissal'}',
        (tester) async {
          final h = _Rig();
          final ad = _Ad();
          h.backend.next = ad;
          final c = ProviderContainer(
            overrides: [
              adsServiceProvider.overrideWithValue(h.ads),
              tabuCardsProvider.overrideWith((ref) async => _cards),
              tabuClockProvider.overrideWithValue(() => h.now),
              charadesClockProvider.overrideWithValue(() => h.now),
            ],
          );
          await mount(tester, c, charades ? '/games/charades' : '/games/taboo');
          final settings = GameSession(
            names: ['Mavi', 'Kırmızı'],
            seconds: seconds,
            targetScore: 10,
          );
          if (charades) {
            final game = c.read(charadesGameProvider.notifier);
            game.configure(settings, const [
              CharadesCard(
                id: 'a',
                title: 'Bir',
                category: 'Film',
                difficulty: 'Kolay',
              ),
            ]);
            game.startRound();
            game.answer(
              c.read(charadesGameProvider).card!.id,
              CharadesOutcome.correct,
            );
            h.now += Duration(seconds: seconds);
            game.tick();
          } else {
            final game = c.read(tabuGameProvider.notifier);
            game.configure(settings, _cards);
            game.startRound();
            game.answer(c.read(tabuGameProvider).card!.id, CardOutcome.correct);
            h.now += Duration(seconds: seconds);
            game.tick();
          }
          await tester.pumpAndSettle();
          expect(ad.shown, 0);
          expect(h.ads.completedRounds, 1);
          expect(h.ads.completedGames, 0);
          await tap(tester, 'Sonraki Takım');
          expect(ad.shown, 1);
          expect(
            charades
                ? c.read(charadesGameProvider).phase
                : c.read(tabuGameProvider).phase,
            GamePhase.roundResult,
          );
          if (seconds == 120) {
            ad.closed.completeError(
              StateError('Native ad presentation failed'),
            );
          } else {
            ad.closed.complete();
          }
          await tester.pumpAndSettle();
          expect(
            charades
                ? c.read(charadesGameProvider).phase
                : c.read(tabuGameProvider).phase,
            GamePhase.preRound,
          );
          expect(
            charades
                ? c.read(charadesGameProvider).teams.first.score
                : c.read(tabuGameProvider).teams.first.score,
            1,
          );
          expect(
            charades
                ? c.read(charadesGameProvider).activeTeam
                : c.read(tabuGameProvider).activeTeam,
            1,
          );
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }

  testWidgets(
    'Who Am I saved player turn continues with scores intact after dismissal',
    (tester) async {
      final h = _Rig();
      final ad = _Ad();
      h.backend.next = ad;
      final result = WhoGameSession(
        settings: WhoGameSettings(
          names: ['Ada', 'Ece'],
          duration: WhoRoundDuration.short,
        ),
        phase: WhoPhase.roundResult,
        correct: 3,
        passed: 1,
        totals: [3, 0],
        remaining: Duration.zero,
        history: [
          const WhoTurnResult(
            playerIndex: 0,
            cycle: 1,
            correct: 3,
            passed: 1,
            total: 3,
          ),
        ],
      );
      final c = ProviderContainer(
        overrides: [
          adsServiceProvider.overrideWithValue(h.ads),
          whoSessionProvider.overrideWith(() => _WhoResult(result)),
          whoMotionPreferredProvider.overrideWithValue(false),
          whoOrientationProvider.overrideWithValue(
            AppOrientation((_) async {}),
          ),
        ],
      );
      await mount(tester, c, '/games/who_am_i');
      expect(h.ads.completedRounds, 1);
      expect(ad.shown, 0);
      await tap(tester, 'Sıradaki Oyuncu');
      expect(ad.shown, 1);
      expect(c.read(whoSessionProvider)!.phase, WhoPhase.roundResult);
      ad.closed.complete();
      await tester.pumpAndSettle();
      expect(c.read(whoSessionProvider)!.currentPlayer.name, 'Ece');
      expect(c.read(whoSessionProvider)!.totals, [3, 0]);
      expect(c.read(whoSessionProvider)!.phase, WhoPhase.ready);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final finished in [false, true]) {
    testWidgets(
      'Undercover elimination boundary, final=$finished, does not double-ad results',
      (tester) async {
        final h = _Rig();
        final ad = _Ad();
        h.backend.next = ad;
        final session = UndercoverSession(
          players: List.generate(
            4,
            (id) => (
              id: id,
              name: 'Oyuncu ${id + 1}',
              role: id == 0 ? UndercoverRole.spy : UndercoverRole.normal,
            ),
          ),
          secretWord: 'Dondurma',
          spyCount: 1,
          eliminationOrder: [finished ? 0 : 1],
          round: UndercoverRound(
            number: 1,
            order: [0, 1, 2, 3],
            phase: UndercoverPhase.elimination,
            eliminatedId: finished ? 0 : 1,
            winner: finished ? UndercoverRole.normal : null,
          ),
        );
        final c = ProviderContainer(
          overrides: [
            adsServiceProvider.overrideWithValue(h.ads),
            undercoverSessionProvider.overrideWith(
              () => _UndercoverResult(session),
            ),
          ],
        );
        await mount(tester, c, '/games/undercover');
        expect(ad.shown, 0);
        expect(h.ads.completedRounds, 1);
        await tap(tester, finished ? 'Oyun Sonuçları' : 'Yeni Tura Geç');
        expect(ad.shown, 1);
        expect(identical(c.read(undercoverSessionProvider), session), isTrue);
        final next = _Ad();
        h.backend.next = next;
        ad.closed.complete();
        await tester.pumpAndSettle();
        if (finished) {
          h.now += const Duration(seconds: 100);
          // Results can be revisited, but they share the same completed round.
          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();
          await tap(tester, 'Oyun Sonuçları');
          await tap(tester, 'Ana Menü');
          expect(c.read(appRouterProvider).state.uri.path, '/');
          expect(next.shown, 0);
          expect(h.ads.completedGames, 1);
        } else {
          expect(c.read(undercoverSessionProvider)!.round!.number, 2);
          expect(c.read(undercoverSessionProvider)!.eliminationOrder, [1]);
          expect(
            c.read(undercoverSessionProvider)!.phase,
            UndercoverPhase.clue,
          );
        }
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  for (final runoff in [false, true]) {
    testWidgets(
      'Undercover tie has an ad only when a new clue round starts: $runoff',
      (tester) async {
        final h = _Rig();
        final ad = _Ad();
        h.backend.next = ad;
        final session = UndercoverSession(
          players: List.generate(
            4,
            (id) => (
              id: id,
              name: 'Oyuncu ${id + 1}',
              role: id == 0 ? UndercoverRole.spy : UndercoverRole.normal,
            ),
          ),
          secretWord: 'Dondurma',
          spyCount: 1,
          round: UndercoverRound(
            number: 1,
            order: [0, 1, 2, 3],
            phase: UndercoverPhase.tie,
            leaders: [0, 1],
            runoffCandidates: runoff ? [0, 1] : [],
          ),
        );
        final c = ProviderContainer(
          overrides: [
            adsServiceProvider.overrideWithValue(h.ads),
            undercoverSessionProvider.overrideWith(
              () => _UndercoverResult(session),
            ),
          ],
        );
        await mount(tester, c, '/games/undercover');
        await tap(tester, runoff ? 'Yeni Tura Geç' : 'Yeniden Oyla');
        expect(ad.shown, runoff ? 1 : 0);
        if (runoff) {
          ad.closed.complete();
          await tester.pumpAndSettle();
        }
        expect(
          c.read(undercoverSessionProvider)!.phase,
          runoff ? UndercoverPhase.clue : UndercoverPhase.voting,
        );
        expect(h.ads.completedRounds, runoff ? 1 : 0);
        expect(h.ads.completedGames, 0);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  for (final charades in [false, true]) {
    testWidgets(
      'Abandoning an active ${charades ? 'Charades' : 'Tabu'} round never shows an ad',
      (tester) async {
        final h = _Rig();
        final ad = _Ad();
        h.backend.next = ad;
        final c = ProviderContainer(
          overrides: [
            adsServiceProvider.overrideWithValue(h.ads),
            tabuCardsProvider.overrideWith((ref) async => _cards),
            tabuClockProvider.overrideWithValue(() => h.now),
            charadesClockProvider.overrideWithValue(() => h.now),
          ],
        );
        await mount(tester, c, charades ? '/games/charades' : '/games/taboo');
        final settings = GameSession(
          names: ['Mavi', 'Kırmızı'],
          seconds: 60,
          targetScore: 10,
        );
        if (charades) {
          c.read(charadesGameProvider.notifier)
            ..configure(settings, const [
              CharadesCard(
                id: 'a',
                title: 'Bir',
                category: 'Film',
                difficulty: 'Kolay',
              ),
            ])
            ..startRound();
        } else {
          c.read(tabuGameProvider.notifier)
            ..configure(settings, _cards)
            ..startRound();
        }
        await tester.pump();
        await tester.tap(find.byTooltip('Geri'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Çık'));
        await tester.pumpAndSettle();
        expect(h.ads.completedGames, 0);
        expect(h.ads.completedRounds, 0);
        expect(ad.shown, 0);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
