import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/features/games/who_am_i/data/who_card_repository.dart';
import 'package:oynika/features/games/who_am_i/domain/who_models.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_landscape_board.dart';

void main() {
  final cards = WhoCardRepository.decode(
    File(WhoCardRepository.assetPath).readAsStringSync(),
  );
  for (final dark in [false, true]) {
    for (final size in [
      const Size(480, 240),
      const Size(568, 320),
      const Size(844, 390),
    ]) {
      testWidgets('Üç bölüm, büyük kelime, gizli debug: $dark/$size', (
        t,
      ) async {
        t.view.physicalSize = size;
        t.view.devicePixelRatio = 1;
        t.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        final s = WhoGameSession(
          settings: WhoGameSettings(names: ['Deniz', 'Ece']),
          phase: WhoPhase.playing,
          card: cards.reduce((a, b) => a.name.length > b.name.length ? a : b),
          correct: 7,
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
                  onResetMotion: () {},
                  motionDiagnostics: 'active ACC GYR',
                ),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(find.text('7 puan'), findsOneWidget);
        expect(find.text('Deniz'), findsOneWidget);
        expect(find.textContaining('ACC'), findsNothing);
        expect(find.textContaining('GYR'), findsNothing);
        expect(find.byType(SingleChildScrollView), findsNothing);
        final word = find.byKey(const ValueKey('who-active-card')),
            card = find.byKey(const ValueKey('who-word-surface'));
        expect(
          t.renderObject<RenderParagraph>(word).didExceedMaxLines,
          isFalse,
        );
        expect(
          t.widget<Text>(word).style!.fontSize! * 2,
          greaterThanOrEqualTo(28),
        );
        expect((t.getCenter(word) - t.getCenter(card)).distance, lessThan(1));
        for (final label in ['Doğru +1', 'Pas']) {
          final f = find.widgetWithText(FilledButton, label);
          expect(f.hitTestable(), findsOneWidget);
          expect(t.getRect(f).bottom, lessThanOrEqualTo(size.height));
        }
        expect(t.takeException(), isNull);
      });
    }
  }
}
