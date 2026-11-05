import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/features/games/tabu/domain/tabu_models.dart';
import 'package:oynika/features/games/undercover/application/undercover_controller.dart';
import 'package:oynika/features/games/undercover/presentation/undercover_setup_screen.dart';

ProviderContainer testContainer(int seed) => ProviderContainer(
  overrides: [undercoverRandomProvider.overrideWithValue(Random(seed))],
);

List<String> names(int count) => List.generate(count, (i) => 'Oyuncu ${i + 1}');

void main() {
  test('Çevrimdışı havuz en az 250 benzersiz Türkçe kelime içerir', () {
    expect(undercoverWords.length, greaterThanOrEqualTo(250));
    final allowed = RegExp(r'^[a-zA-ZçğıöşüÇĞİÖŞÜâîûÂÎÛ]+$');
    for (final word in undercoverWords) {
      expect(word, matches(allowed));
    }
    expect(
      undercoverWords.map(turkishKey).toSet(),
      hasLength(undercoverWords.length),
    );
  });

  test('Oyuncu sırası korunur ve her eşikte doğru roller atanır', () {
    final container = testContainer(42);
    addTearDown(container.dispose);
    final controller = container.read(undercoverSessionProvider.notifier);
    for (final (count, expected) in [
      (3, 1),
      (5, 1),
      (6, 2),
      (9, 2),
      (10, 3),
      (20, 3),
    ]) {
      controller.start(names(count));
      final session = container.read(undercoverSessionProvider)!;
      expect(session.players.map((p) => p.name), names(count));
      expect(session.players.map((p) => p.id).toSet(), hasLength(count));
      final spies = session.players.where((p) => p.role == UndercoverRole.spy);
      expect(spies, hasLength(expected));
      for (final player in session.players) {
        expect(controller.reveal((player.id + 1) % count), isNull);
        final secret = controller.reveal(player.id);
        expect(secret?.role, player.role);
        expect(
          secret?.word,
          player.role == UndercoverRole.normal ? session.secretWord : null,
        );
        controller.next(player.id);
      }
    }
  });

  test('Sabit seed, değişen roller ve tekrarsız deste döngüsü', () {
    final a = testContainer(21);
    final b = testContainer(21);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    final ac = a.read(undercoverSessionProvider.notifier);
    final bc = b.read(undercoverSessionProvider.notifier);
    final drawnWords = <String>{};
    final assignments = <String>{};
    for (var i = 0; i < undercoverWords.length; i++) {
      ac.start(names(6));
      bc.start(names(6));
      final session = a.read(undercoverSessionProvider)!;
      expect(session.players, b.read(undercoverSessionProvider)!.players);
      expect(drawnWords.add(session.secretWord), isTrue);
      final spies = session.players.where((p) => p.role == UndercoverRole.spy);
      assignments.add(spies.map((p) => p.id).join(','));
    }
    expect(assignments.length, greaterThan(1));
    final last = a.read(undercoverSessionProvider)!.secretWord;
    final nextCycle = <String>{};
    for (var i = 0; i < undercoverWords.length; i++) {
      ac.start(names(6));
      final word = a.read(undercoverSessionProvider)!.secretWord;
      if (i == 0) expect(word, isNot(last));
      expect(nextCycle.add(word), isTrue);
    }
    expect(nextCycle, drawnWords);
  });

  UndercoverController startRound(ProviderContainer container, int count) {
    final controller = container.read(undercoverSessionProvider.notifier);
    controller.start(names(count));
    for (var id = 0; id < count; id++) {
      controller.reveal(id);
      controller.next(id);
    }
    return controller;
  }

  UndercoverSession session(ProviderContainer container) =>
      container.read(undercoverSessionProvider)!;

  void beginVotes(
    ProviderContainer container,
    UndercoverController controller,
  ) {
    expect(session(container).phase, UndercoverPhase.clue);
    controller.beginVoting(session(container).round!);
  }

  void voteFor(
    ProviderContainer container,
    UndercoverController controller,
    int Function(UndercoverRound, int) choose,
  ) {
    while (session(container).phase == UndercoverPhase.voting) {
      final round = session(container).round!;
      final voter = round.voter!;
      expect(voter, session(container).activeIds[round.votes.length]);
      controller.vote(round, voter, voter);
      expect(session(container).round, same(round));
      final target = choose(round, voter);
      controller.vote(round, voter, target);
      final after = session(container).round!;
      controller.vote(round, voter, target);
      expect(session(container).round, same(after));
    }
    expect(
      session(container).round!.phase,
      isIn([UndercoverPhase.tie, UndercoverPhase.elimination]),
    );
  }

  test(
    'Beraberlikte bir kez yeniden oylanır ve ikinci eşitlikte eleme olmaz',
    () {
      final container = testContainer(17);
      addTearDown(container.dispose);
      final controller = startRound(container, 6);
      beginVotes(container, controller);
      const targets = {0: 1, 1: 0, 2: 0, 3: 1, 4: 0, 5: 1};
      voteFor(container, controller, (_, voter) => targets[voter]!);
      final first = session(container).round!;
      expect(first.leaders, unorderedEquals([0, 1]));
      controller.continueTie(first);
      final runoff = session(container).round!;
      expect(runoff.votes, isEmpty);
      expect(runoff.runoffCandidates, unorderedEquals([0, 1]));
      voteFor(container, controller, (round, voter) {
        expect(
          round.candidates,
          unorderedEquals([0, 1].where((id) => id != voter)),
        );
        return targets[voter]!;
      });
      controller.continueTie(session(container).round!);
      expect(session(container).eliminatedIds, isEmpty);
      expect(session(container).round!.number, 2);
      expect(session(container).round!.order.first, first.order[0]);
    },
  );

  test(
    'Beraberlik bozulur ve elenen oyuncu sonraki ipucu ve oylamadan çıkar',
    () {
      final container = testContainer(17);
      addTearDown(container.dispose);
      final controller = startRound(container, 4);
      final original = session(container);
      final normal =
          original.players
              .firstWhere((p) => p.role == UndercoverRole.normal)
              .id;
      final other = original.activeIds.firstWhere((id) => id != normal);
      final rest =
          original.activeIds
              .where((id) => id != normal && id != other)
              .toList();
      beginVotes(container, controller);
      voteFor(
        container,
        controller,
        (_, voter) => voter == normal || voter == rest[0] ? other : normal,
      );
      controller.continueTie(session(container).round!);
      voteFor(
        container,
        controller,
        (_, voter) => voter == normal ? other : normal,
      );
      expect(session(container).eliminatedIds, {normal});
      expect(session(container).round!.eliminatedId, normal);
      expect(session(container).round!.winner, isNull);
      controller.continueElimination(session(container).round!);
      expect(session(container).round!.order, isNot(contains(normal)));
      expect(session(container).players, same(original.players));
      expect(session(container).secretWord, original.secretWord);
      beginVotes(container, controller);
      final round = session(container).round!;
      controller.vote(round, normal, round.candidates.first);
      controller.vote(round, round.voter!, normal);
      expect(session(container).round, same(round));
    },
  );

  for (final loser in UndercoverRole.values) {
    test('Kazanan hemen belirlenir ve yeni oy kabul edilmez: $loser', () {
      final container = testContainer(2);
      addTearDown(container.dispose);
      final controller = startRound(container, 3);
      final eliminated =
          session(container).players.firstWhere((p) => p.role == loser).id;
      beginVotes(container, controller);
      voteFor(
        container,
        controller,
        (round, voter) =>
            voter == eliminated ? round.candidates.first : eliminated,
      );
      expect(session(container).phase, UndercoverPhase.finished);
      final result = session(container).round!;
      expect(result.phase, UndercoverPhase.elimination);
      expect(
        result.winner,
        loser == UndercoverRole.spy
            ? UndercoverRole.normal
            : UndercoverRole.spy,
      );
      controller.vote(result, 0, 1);
      expect(session(container).round, same(result));
      controller.continueElimination(result);
      expect(session(container).round, same(result));
    });
  }

  testWidgets('Gizli oy onaylanmadan kaydedilmez ve sonraki oyuncuya sızmaz', (
    tester,
  ) async {
    final container = testContainer(10);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: UndercoverSetupScreen()),
      ),
    );
    final controller = startRound(container, 3);
    await tester.pumpAndSettle();
    Future<void> tap(String label) async {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    expect(find.text('Herkes sırayla bir ipucu versin!'), findsOneWidget);
    expect(find.text('İpucumu Söyledim'), findsNothing);
    await tap('Oylamaya Geç');
    final eliminated = session(
      container,
    ).players.firstWhere((p) => p.role == UndercoverRole.spy);
    for (var i = 0; i < 3; i++) {
      final round = session(container).round!;
      final voter = round.voter!;
      expect(find.text('${i + 1}. Oyuncu: ${names(3)[i]}'), findsOneWidget);
      await tap('Oy Vermeye Başla');
      expect(find.text(names(3)[voter]), findsNothing);
      final confirm = find.widgetWithText(FilledButton, 'Oyumu Onayla');
      expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
      final target =
          voter == eliminated.id ? round.candidates.first : eliminated.id;
      await tap(names(3)[target]);
      expect(session(container).round!.votes.length, i);
      if (i == 0) {
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        await tester.pumpAndSettle();
        expect(confirm, findsNothing);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();
        await tap('Oy Vermeye Başla');
        expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
        await tap(names(3)[target]);
      }
      await tap('Oyumu Onayla');
      expect(confirm, findsNothing);
      expect(find.text('Oylama Tamamlandı!'), findsNothing);
    }
    expect(find.text('${eliminated.name} Elendi!'), findsOneWidget);
    expect(find.text('CASUSTU!'), findsOneWidget);
    expect(find.text(session(container).secretWord), findsNothing);
    expect(find.text('SEN CASUSSUN!'), findsNothing);
    expect(find.text('NORMAL OYUNCULAR KAZANDI!'), findsOneWidget);
    await tap('Oyun Sonuçları');
    final completed = session(container);
    expect(
      find.byKey(const ValueKey('undercover-result-word')),
      findsOneWidget,
    );
    expect(find.text('Casuslar Kimdi?'), findsOneWidget);
    expect(
      find.byKey(ValueKey('undercover-result-spy-${eliminated.id}')),
      findsOneWidget,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('${eliminated.name} Elendi!'), findsOneWidget);
    expect(session(container), same(completed));
    await tap('Oyun Sonuçları');
    await tester.tap(find.text('Tekrar Oyna'));
    await tester.tap(find.text('Tekrar Oyna'));
    await tester.pumpAndSettle();
    expect(session(container).secretWord, isNot(completed.secretWord));
    expect(
      session(container).players.map((p) => p.name),
      completed.players.map((p) => p.name),
    );
    expect(session(container).eliminationOrder, isEmpty);
    expect(session(container).round, isNull);
    expect(session(container).index, 0);
    expect(find.text('Bilgimi Gör'), findsOneWidget);
    expect(find.byKey(const ValueKey('undercover-result-word')), findsNothing);
    expect(tester.takeException(), isNull);
    controller.exit();
  });

  for (final loser in UndercoverRole.values) {
    test(
      'Sonuçlar eleme sırasını tutar ve tekrar oyun tek kez başlar: $loser',
      () {
        final container = testContainer(31);
        addTearDown(container.dispose);
        final controller = startRound(container, 6);
        final eliminated = <int>[];
        final original = session(container);
        expect(controller.restartWithSamePlayers(original), isFalse);
        while (session(container).phase != UndercoverPhase.finished) {
          final target =
              session(container).players
                  .firstWhere(
                    (p) =>
                        p.role == loser &&
                        !session(container).eliminatedIds.contains(p.id),
                  )
                  .id;
          eliminated.add(target);
          beginVotes(container, controller);
          voteFor(
            container,
            controller,
            (round, voter) => voter == target ? round.candidates.first : target,
          );
          if (session(container).phase != UndercoverPhase.finished) {
            controller.continueElimination(session(container).round!);
          }
        }
        final completed = session(container);
        expect(completed.eliminationOrder, eliminated);
        expect(completed.players, same(original.players));
        expect(controller.restartWithSamePlayers(completed), isTrue);
        final fresh = session(container);
        expect(controller.restartWithSamePlayers(completed), isFalse);
        expect(session(container), same(fresh));
        expect(
          fresh.players.map((p) => p.name),
          original.players.map((p) => p.name),
        );
        expect(fresh.secretWord, isNot(completed.secretWord));
        expect(fresh.eliminationOrder, isEmpty);
        expect(fresh.round, isNull);
        expect(fresh.index, 0);
        expect(fresh.phase, UndercoverPhase.wordDistribution);
      },
    );
  }

  for (final brightness in Brightness.values) {
    testWidgets('Gizli dağıtım, geri ve yaşam döngüsü: $brightness', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final container = testContainer(5);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: const UndercoverSetupScreen(),
          ),
        ),
      );
      Future<void> tap(String label) async {
        final target = find.text(label);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      await tap('Oyunu Başlat');
      final players = container.read(undercoverSessionProvider)!.players;
      final hold = find.byKey(const ValueKey('undercover-hold'));
      final surface = find.descendant(
        of: hold,
        matching: find.byType(AnimatedContainer),
      );
      Color? cardColor() =>
          (tester.widget<AnimatedContainer>(surface).decoration
                  as BoxDecoration)
              .color;
      final word = session(container).secretWord;
      for (final player in players) {
        final spy = player.role == UndercoverRole.spy;
        final visible = spy ? 'SEN CASUSSUN!' : word;
        expect(find.text(player.name), findsOneWidget);
        expect(find.text(word), findsNothing);
        expect(find.text('SEN CASUSSUN!'), findsNothing);
        await tap('Bilgimi Gör');
        final seen = find.widgetWithText(FilledButton, 'Bilgimi Gördüm');
        expect(tester.widget<FilledButton>(seen).onPressed, isNull);
        expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);
        expect(find.text('Yalnızca sen görebilirsin'), findsOneWidget);
        final restingColor = cardColor();
        expect(
          restingColor,
          Theme.of(tester.element(surface)).colorScheme.primaryContainer,
        );
        await tester.ensureVisible(hold);
        await tester.pumpAndSettle();
        final gesture = await tester.startGesture(tester.getCenter(hold));
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text(visible), findsOneWidget);
        expect(find.text(spy ? word : 'SEN CASUSSUN!'), findsNothing);
        expect(find.text('KELİMEN'), spy ? findsNothing : findsOneWidget);
        expect(cardColor(), AppTheme.primary);
        expect(cardColor(), isNot(restingColor));
        expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 75));
        expect(tester.takeException(), isNull);
        expect(find.text('Casus'), findsNothing);
        expect(find.text('Normal oyuncu'), findsNothing);
        if (player.id == 0) {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
          await tester.pump();
          expect(find.text(word), findsNothing);
          expect(find.text('SEN CASUSSUN!'), findsNothing);
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tester.pump();
          expect(find.text(word), findsNothing);
          expect(find.text('SEN CASUSSUN!'), findsNothing);
        }
        if (player.id == 1) {
          await gesture.cancel();
        } else {
          await gesture.up();
        }
        await tester.pump();
        expect(find.text(word), findsNothing);
        expect(find.text('SEN CASUSSUN!'), findsNothing);
        expect(cardColor(), restingColor);
        await tester.pumpAndSettle();
        expect(find.text(word), findsNothing);
        expect(find.text('SEN CASUSSUN!'), findsNothing);
        await tap('Bilgimi Gördüm');
        if (player.id == 0) {
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.text('Oyundan çıkmak istiyor musun?'), findsOneWidget);
          expect(find.text(word), findsNothing);
          expect(find.text('SEN CASUSSUN!'), findsNothing);
          await tap('Oyunda Kal');
          expect(find.text(players[1].name), findsOneWidget);
        }
      }
      expect(find.text('Herkes sırayla bir ipucu versin!'), findsOneWidget);
      expect(find.text('Herkes Hazır mı?'), findsNothing);
      expect(
        container.read(undercoverSessionProvider)!.seenPlayerIds,
        hasLength(6),
      );
      expect(find.text(word), findsNothing);
      expect(find.text('SEN CASUSSUN!'), findsNothing);
      expect(find.text('İpucumu Söyledim'), findsNothing);
      expect(find.text('Oylamaya Geç'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
