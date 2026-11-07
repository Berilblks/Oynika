import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/features/games/who_am_i/data/who_card_repository.dart';
import 'package:oynika/features/games/who_am_i/domain/who_models.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_page.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_landscape_board.dart';

void main() {
  final cards = WhoCardRepository.decode(
    File(WhoCardRepository.assetPath).readAsStringSync(),
  );
  for (final dark in [false, true]) {
    for (final left in [false, true]) {
      for (final size in [const Size(568, 320), const Size(852, 393)]) {
        testWidgets('QA notch iki yatay yön, 2.5x yazı: $dark/$left/$size', (
          t,
        ) async {
          t.view.physicalSize = size;
          t.view.devicePixelRatio = 1;
          final inset = size.width > 800 ? 59.0 : 20.0;
          t.view.padding = FakeViewPadding(
            left: left ? inset : 0,
            right: left ? 0 : inset,
            bottom: 21,
          );
          t.platformDispatcher.textScaleFactorTestValue = 2.5;
          addTearDown(t.view.resetPhysicalSize);
          addTearDown(t.view.resetDevicePixelRatio);
          addTearDown(t.view.resetPadding);
          addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
          final s = WhoGameSession(
            settings: WhoGameSettings(names: ['Uzun Oyuncu İsmi', 'Deniz']),
            phase: WhoPhase.playing,
            card: cards.reduce((a, b) => a.name.length > b.name.length ? a : b),
          );
          await t.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.dark : AppTheme.light,
              home: WhoPage(
                landscapeGame: true,
                showAppBar: false,
                onBack: () {},
                body: WhoLandscapeBoard(
                  session: s,
                  onCorrect: () {},
                  onPass: () {},
                  onPause: () {},
                  onExit: () {},
                  onResetMotion: () {},
                ),
              ),
            ),
          );
          await t.pumpAndSettle();
          expect(find.byType(Scrollable), findsNothing);
          expect(
            t
                .renderObject<RenderParagraph>(
                  find.byKey(const ValueKey('who-active-card')),
                )
                .didExceedMaxLines,
            isFalse,
          );
          for (final label in ['Doğru +1', 'Pas']) {
            final f = find.widgetWithText(FilledButton, label);
            expect(f.hitTestable(), findsOneWidget);
            final r = t.getRect(f);
            expect(r.left, greaterThanOrEqualTo(left ? inset : 0));
            expect(r.right, lessThanOrEqualTo(size.width - (left ? 0 : inset)));
            expect(r.bottom, lessThanOrEqualTo(size.height - 21));
          }
          expect(t.takeException(), isNull);
        });
      }
    }
  }
}
