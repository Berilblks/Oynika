import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/features/games/tabu/data/card_repository.dart';
import 'package:oynika/features/games/tabu/presentation/tabu_screen.dart';
import 'package:oynika/features/games/tabu/presentation/tabu_widgets.dart';
import 'package:oynika/features/games/charades/presentation/charades_card_widget.dart';
import 'package:oynika/features/games/charades/data/charades_repository.dart';
import 'package:oynika/features/games/charades/presentation/charades_screen.dart';
import 'package:oynika/features/games/undercover/presentation/undercover_setup_screen.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_screen.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_page.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_landscape_board.dart';
import 'package:oynika/features/games/who_am_i/domain/who_models.dart';
import 'package:oynika/features/games/who_am_i/data/who_card_repository.dart';

const devices = [
  (Size(375, 667), 20.0, 0.0),
  (Size(390, 844), 47.0, 34.0),
  (Size(393, 852), 59.0, 34.0),
  (Size(430, 932), 59.0, 34.0),
];
void main() {
  final tabu = CardRepository.decode(
    File('assets/data/tabu_cards.json').readAsStringSync(),
  );
  final charades = CharadesRepository.decode(
    File('assets/data/sessiz_sinema_cards.json').readAsStringSync(),
  );
  final who = WhoCardRepository.decode(
    File(WhoCardRepository.assetPath).readAsStringSync(),
  );
  for (final (size, top, bottom) in devices) {
    for (final dark in [false, true]) {
      for (final (name, screen, startLabel) in <(String, Widget, String)>[
        ('Tabu', const TabuScreen(), 'Oyuna Başla'),
        ('Sinema', const CharadesScreen(), 'Oyuna Başla'),
        ('Casus', const UndercoverSetupScreen(), 'Oyunu Başlat'),
        ('Kimim', const WhoScreen(), 'Oyunu Başlat'),
      ]) {
        testWidgets('iPhone $size/$dark $name SafeArea, yazı, klavye', (
          t,
        ) async {
          t.view.physicalSize = size;
          t.view.devicePixelRatio = 1;
          t.view.padding = FakeViewPadding(top: top, bottom: bottom);
          addTearDown(t.view.resetPhysicalSize);
          addTearDown(t.view.resetDevicePixelRatio);
          addTearDown(t.view.resetPadding);
          addTearDown(t.view.resetViewInsets);
          addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
          final c = ProviderContainer(
            overrides: [
              tabuCardsProvider.overrideWith((ref) async => tabu),
              charadesCardsProvider.overrideWith((ref) async => charades),
            ],
          );
          addTearDown(c.dispose);
          await t.pumpWidget(
            UncontrolledProviderScope(
              container: c,
              child: MaterialApp(
                theme: (dark ? AppTheme.dark : AppTheme.light).copyWith(
                  platform: TargetPlatform.iOS,
                ),
                home: screen,
              ),
            ),
          );
          await t.pumpAndSettle();
          for (final scale in [1.0, 1.6]) {
            t.platformDispatcher.textScaleFactorTestValue = scale;
            await t.pumpAndSettle();
            final start = find.text(startLabel);
            expect(start.hitTestable(), findsOneWidget);
            final initial = t.getRect(start);
            expect(initial.bottom, lessThanOrEqualTo(size.height - bottom));
            await t.ensureVisible(find.byType(TextFormField).last);
            await t.pumpAndSettle();
            expect(t.getRect(start), initial);
            expect(t.takeException(), isNull);
          }
          final field = find.byType(TextFormField).last;
          await t.ensureVisible(field);
          await t.enterText(field, 'Uzun İsimli Oyuncu Çağrı Şahin');
          t.view.viewInsets = const FakeViewPadding(bottom: 300);
          await t.pumpAndSettle();
          await t.ensureVisible(field);
          await t.pumpAndSettle();
          expect(find.text(startLabel), findsNothing);
          expect(field.hitTestable(), findsOneWidget);
          expect(t.takeException(), isNull);
          t.view.resetViewInsets();
          t.testTextInput.hide();
          await t.pumpAndSettle();
          expect(find.text(startLabel).hitTestable(), findsOneWidget);
          await t.pumpWidget(const SizedBox.shrink());
          await t.pumpAndSettle();
        });
      }
      testWidgets('iPhone $size/$dark uzun Tabu ve yapım kartı', (t) async {
        t.view.physicalSize = size;
        t.view.devicePixelRatio = 1;
        t.view.padding = FakeViewPadding(top: top, bottom: bottom);
        t.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        addTearDown(t.view.resetPadding);
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        final longestTabu = tabu.reduce(
          (a, b) => a.word.length > b.word.length ? a : b,
        );
        final longestFilm = charades.reduce(
          (a, b) => a.title.length > b.title.length ? a : b,
        );
        for (final card in <Widget>[
          TabuCardWidget(card: longestTabu, color: Colors.purple),
          CharadesCardWidget(card: longestFilm),
        ]) {
          await t.pumpWidget(
            MaterialApp(
              theme: (dark ? AppTheme.dark : AppTheme.light).copyWith(
                platform: TargetPlatform.iOS,
              ),
              home: Scaffold(
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: card,
                  ),
                ),
              ),
            ),
          );
          await t.pumpAndSettle();
          expect(t.takeException(), isNull);
          for (final paragraph in t.renderObjectList<RenderParagraph>(
            find.byType(RichText),
          )) {
            expect(paragraph.didExceedMaxLines, isFalse);
          }
        }
      });
      for (final left in [false, true]) {
        testWidgets('iPhone $size/$dark yatay $left uzun kart', (t) async {
          final landscape = Size(size.height, size.width);
          t.view.physicalSize = landscape;
          t.view.devicePixelRatio = 1;
          t.view.padding = FakeViewPadding(
            left: left ? top : 0,
            right: left ? 0 : top,
            bottom: bottom == 0 ? 0 : 21,
          );
          t.platformDispatcher.textScaleFactorTestValue = 2;
          addTearDown(t.view.resetPhysicalSize);
          addTearDown(t.view.resetDevicePixelRatio);
          addTearDown(t.view.resetPadding);
          addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
          final session = WhoGameSession(
            settings: WhoGameSettings(names: ['Uzun Oyuncu İsmi', 'Deniz']),
            phase: WhoPhase.playing,
            card: who.reduce((a, b) => a.name.length > b.name.length ? a : b),
          );
          await t.pumpWidget(
            MaterialApp(
              theme: (dark ? AppTheme.dark : AppTheme.light).copyWith(
                platform: TargetPlatform.iOS,
              ),
              home: WhoPage(
                landscapeGame: true,
                showAppBar: false,
                onBack: () {},
                body: WhoLandscapeBoard(
                  session: session,
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
          final paragraph = t.renderObject<RenderParagraph>(
            find.byKey(const ValueKey('who-active-card')),
          );
          expect(
            paragraph.text.toPlainText(),
            session.card!.name.toUpperCase(),
          );
          expect(paragraph.didExceedMaxLines, isFalse);
          for (final label in ['Doğru +1', 'Pas']) {
            final f = find.widgetWithText(FilledButton, label);
            expect(f.hitTestable(), findsOneWidget);
            final rect = t.getRect(f);
            expect(rect.left, greaterThanOrEqualTo(left ? top : 0));
            expect(
              rect.right,
              lessThanOrEqualTo(landscape.width - (left ? 0 : top)),
            );
          }
          expect(t.takeException(), isNull);
        });
      }
    }
  }
}
