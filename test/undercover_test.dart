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
  test('250 farklı çift, 500 farklı doğal Unicode sözcük veya ifade', () {
    expect(undercoverPairs, hasLength(250));
    final words = <String>{};
    final pairs = <String>{};
    final allowed = RegExp(
      r'^[a-zA-ZçğıöşüÇĞİÖŞÜâîûÂÎÛ]+(?: [a-zA-ZçğıöşüÇĞİÖŞÜâîûÂÎÛ]+)*$',
    );
    for (final pair in undercoverPairs) {
      final canonical = [turkishKey(pair.first), turkishKey(pair.second)]
        ..sort();
      expect(pairs.add(canonical.join('|')), isTrue);
      for (final word in [pair.first, pair.second]) {
        expect(word, matches(allowed));
        expect(words.add(turkishKey(word)), isTrue);
      }
    }
    expect(words, hasLength(500));
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
      final normals = session.players.where(
        (p) => p.role == UndercoverRole.normal,
      );
      expect(spies, hasLength(expected));
      expect(spies.map((p) => p.word).toSet(), hasLength(1));
      expect(normals.map((p) => p.word).toSet(), hasLength(1));
      expect(spies.first.word, isNot(normals.first.word));
      expect([
        spies.first.word,
        normals.first.word,
      ], unorderedEquals([session.pair.first, session.pair.second]));
    }
  });

  test('Sabit seed, değişen roller ve tekrarsız deste döngüsü', () {
    final a = testContainer(21);
    final b = testContainer(21);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    final ac = a.read(undercoverSessionProvider.notifier);
    final bc = b.read(undercoverSessionProvider.notifier);
    final pairs = <WordPair>{};
    final assignments = <String>{};
    final orientations = <bool>{};
    for (var i = 0; i < 250; i++) {
      ac.start(names(6));
      bc.start(names(6));
      final session = a.read(undercoverSessionProvider)!;
      expect(session.players, b.read(undercoverSessionProvider)!.players);
      expect(pairs.add(session.pair), isTrue);
      final spies = session.players.where((p) => p.role == UndercoverRole.spy);
      assignments.add(spies.map((p) => p.id).join(','));
      orientations.add(spies.first.word == session.pair.first);
    }
    expect(assignments.length, greaterThan(1));
    expect(orientations, {true, false});
    final last = a.read(undercoverSessionProvider)!.pair;
    final nextCycle = <WordPair>{};
    for (var i = 0; i < 250; i++) {
      ac.start(names(6));
      final pair = a.read(undercoverSessionProvider)!.pair;
      if (i == 0) expect(pair, isNot(last));
      expect(nextCycle.add(pair), isTrue);
    }
    expect(nextCycle, pairs);
  });

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

      await tap('Oyuna Başla');
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
      for (final player in players) {
        expect(find.text(player.name), findsOneWidget);
        expect(find.text(player.word), findsNothing);
        await tap('Kelimemi Gör');
        final seen = find.widgetWithText(FilledButton, 'Kelimeyi Gördüm');
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
        expect(find.text(player.word), findsOneWidget);
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
          expect(find.text(player.word), findsNothing);
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tester.pump();
          expect(find.text(player.word), findsNothing);
        }
        if (player.id == 1) {
          await gesture.cancel();
        } else {
          await gesture.up();
        }
        await tester.pump();
        expect(find.text(player.word), findsNothing);
        expect(cardColor(), restingColor);
        await tester.pumpAndSettle();
        expect(find.text(player.word), findsNothing);
        await tap('Kelimeyi Gördüm');
        if (player.id == 0) {
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.text('Oyundan çıkmak istiyor musun?'), findsOneWidget);
          expect(find.text(player.word), findsNothing);
          await tap('Oyunda Kal');
          expect(find.text(players[1].name), findsOneWidget);
        }
      }
      expect(find.text('Herkes Hazır mı?'), findsOneWidget);
      expect(
        container.read(undercoverSessionProvider)!.seenPlayerIds,
        hasLength(6),
      );
      for (final player in players) {
        expect(find.text(player.word), findsNothing);
      }
      await tap('İpucu Turuna Geç');
      expect(find.text('İpucu turu Faz 5.3’te eklenecek.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
