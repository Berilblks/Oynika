import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/app.dart';
import 'package:oynika/app/router/app_router.dart';
import 'package:oynika/app/theme/theme_mode_provider.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/features/games/tabu/application/game_controller.dart';
import 'package:oynika/features/games/tabu/data/card_repository.dart';
import 'package:oynika/features/games/tabu/domain/tabu_models.dart';
import 'package:oynika/features/games/tabu/presentation/tabu_widgets.dart';
import 'package:oynika/features/games/tabu/presentation/tabu_setup_widgets.dart';

void main() {
  testWidgets(
    'Küçük sayaç kapsülü, son 10 saniye kırmızı ve son 5 saniye vurgusu',
    (tester) async {
      for (final seconds in [90, 11, 10, 5, 0]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: TimerWidget(remaining: Duration(seconds: seconds)),
              ),
            ),
          ),
        );
        final capsule = tester.widget<Container>(
          find.byKey(const ValueKey('timer-capsule')),
        );
        final decoration = capsule.decoration! as BoxDecoration;
        expect(
          decoration.color,
          seconds <= 10 ? const Color(0xFF8C263D) : const Color(0xFF624398),
        );
        expect((decoration.border! as Border).top.width, seconds <= 5 ? 2 : 1);
        expect(
          tester.getSize(find.byKey(const ValueKey('timer-capsule'))).height,
          lessThan(50),
        );
        expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(
          find.text(
            seconds == 90
                ? '01:30'
                : '00:${seconds.toString().padLeft(2, '0')}',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );
  final deck = CardRepository.decode(
    File('assets/data/tabu_cards.json').readAsStringSync(),
  );
  testWidgets(
    'Uzun kelimeler büyütülmüş yazıyla sarılır; kart yüksekliği esnektir',
    (tester) async {
      final longest = [...deck]
        ..sort((a, b) => b.word.length.compareTo(a.word.length));
      final samples = [
        ...longest.take(4),
        deck.firstWhere((card) => card.word == 'Lunapark'),
      ];
      for (var i = 0; i < 5; i++) {
        final card = samples[i];
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: 260,
                    child: MediaQuery(
                      data: const MediaQueryData(
                        textScaler: TextScaler.linear(1.6),
                      ),
                      child: TabuCardWidget(
                        key: const ValueKey('measured-card'),
                        card: card,
                        color: tabuPastels[i],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final measured = tester.getSize(
          find.byKey(const ValueKey('measured-card')),
        );
        expect(measured.width, 260);
        expect(measured.height, greaterThan(300));
        for (final word in card.forbidden) {
          expect(find.text(word), findsOneWidget);
          expect(tester.widget<Text>(find.text(word)).style!.fontSize, 22);
          await tester.ensureVisible(find.text(word));
          await tester.pumpAndSettle();
          expect(find.text(word).hitTestable(), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      }
    },
  );
  late Duration now;
  Future<ProviderContainer> open(
    WidgetTester tester, {
    Size size = const Size(393, 786),
    bool dark = false,
    double scale = 1,
  }) async {
    now = Duration.zero;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final container = ProviderContainer(
      overrides: [
        tabuClockProvider.overrideWithValue(() => now),
        tabuCardsProvider.overrideWith((ref) async => deck),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(themeModeProvider.notifier)
        .select(dark ? ThemeMode.dark : ThemeMode.light);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const OynikaApp()),
    );
    container.read(appRouterProvider).go('/games/taboo');
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> tap(WidgetTester tester, String text) async {
    final target = find.text(text);
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Tur sonu pastel kartları doğru toplamları gösterir; tek butonla takım değişir',
    (tester) async {
      final container = await open(
        tester,
        size: const Size(320, 568),
        dark: true,
        scale: 1.4,
      );
      final control = container.read(tabuGameProvider.notifier);
      final names = ['Mor Yıldızlar Takımı', 'Pembe Yıldızlar Takımı'];
      control.configure(GameSession(names: names, seconds: 60), deck);
      await tester.pumpAndSettle();
      await tap(tester, 'Tura Başla');
      for (final outcome in [
        CardOutcome.correct,
        CardOutcome.correct,
        CardOutcome.taboo,
      ]) {
        control.answer(container.read(tabuGameProvider).card!.id, outcome);
        now += const Duration(milliseconds: 400);
      }
      now += const Duration(seconds: 60);
      control.tick();
      await tester.pumpAndSettle();
      expect(find.text('Tur Bitti!'), findsOneWidget);
      expect(find.text('2 kelime bildi!'), findsOneWidget);
      expect(find.text('Net puan: 1'), findsOneWidget);
      void checkTotals(List<int> totals) {
        for (var i = 0; i < 2; i++) {
          final panel = find.byKey(ValueKey('round-total-$i'));
          expect(
            find.descendant(of: panel, matching: find.text(names[i])),
            findsOneWidget,
          );
          final value = find.descendant(
            of: panel,
            matching: find.text('${totals[i]}'),
          );
          expect(value, findsOneWidget);
          expect(tester.widget<Text>(value).style!.fontSize, 34);
          expect(tester.widget<Text>(value).style!.fontWeight, FontWeight.w900);
          expect(
            (tester.widget<Container>(panel).decoration! as BoxDecoration)
                .color,
            TabuTeamColors.pastels[i],
          );
        }
        expect(find.text('Skoru Gör'), findsNothing);
        expect(find.text('Sonraki Takım'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }

      checkTotals([1, 0]);
      await tap(tester, 'Sonraki Takım');
      expect(container.read(tabuGameProvider).phase, GamePhase.preRound);
      expect(container.read(tabuGameProvider).activeTeam, 1);
      expect(find.text('Sıra Kimde?'), findsOneWidget);
      await tap(tester, 'Tura Başla');
      control.answer(
        container.read(tabuGameProvider).card!.id,
        CardOutcome.taboo,
      );
      now += const Duration(seconds: 60);
      control.tick();
      await tester.pumpAndSettle();
      checkTotals([1, -1]);
    },
  );

  testWidgets(
    'Pas (3) sayacı azalır; Pas (0) soluk, devre dışı ve aynı boyutta kalır',
    (tester) async {
      final container = await open(
        tester,
        size: const Size(320, 568),
        scale: 1.4,
      );
      await tap(tester, 'Oyuna Başla');
      await tap(tester, 'Tura Başla');
      final initialSize = tester.getSize(
        find.widgetWithText(ElevatedButton, 'Pas (3)'),
      );
      for (var remaining = 2; remaining >= 0; remaining--) {
        now += const Duration(milliseconds: 400);
        await tap(tester, 'Pas (${remaining + 1})');
        expect(find.text('Pas ($remaining)'), findsOneWidget);
        expect(container.read(tabuGameProvider).remainingPasses, remaining);
      }
      final disabled = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Pas (0)'),
      );
      expect(disabled.onPressed, isNull);
      expect(
        disabled.style!.backgroundColor!.resolve({WidgetState.disabled})!.a,
        lessThan(1),
      );
      expect(
        tester.getSize(find.widgetWithText(ElevatedButton, 'Pas (0)')),
        initialSize,
      );
      final card = container.read(tabuGameProvider).card!.id;
      await tap(tester, 'Pas (0)');
      expect(container.read(tabuGameProvider).card!.id, card);
      expect(container.read(tabuGameProvider).teams.first.score, 0);
      now += const Duration(seconds: 90);
      container.read(tabuGameProvider.notifier).tick();
      await tester.pumpAndSettle();
      await tap(tester, 'Sonraki Takım');
      await tap(tester, 'Tura Başla');
      expect(find.text('Pas (3)'), findsOneWidget);
      expect(tester.takeException(), isNull);
      container.read(appRouterProvider).go('/');
      await tester.pumpAndSettle();
    },
  );

  for (final target in [10, 15, 20, 25, 30]) {
    testWidgets('$target hedefi kurulumdan seçilir ve oyun ekranına taşınır', (
      tester,
    ) async {
      final container = await open(tester);
      await tap(tester, '$target puan');
      await tap(tester, 'Oyuna Başla');
      expect(container.read(tabuGameProvider).session!.targetScore, target);
      expect(find.text('0 / $target'), findsNWidgets(2));
      await tap(tester, 'Tura Başla');
      expect(find.text('0 / $target'), findsOneWidget);
      container.read(appRouterProvider).go('/');
      await tester.pumpAndSettle();
    });
  }

  testWidgets(
    'Hedef sonucu final puanları gösterir; tekrar oyun ve ana sayfa çalışır',
    (tester) async {
      final container = await open(
        tester,
        size: const Size(320, 568),
        dark: true,
        scale: 1.4,
      );
      await tap(tester, '10 puan');
      await tap(tester, 'Oyuna Başla');
      await tap(tester, 'Tura Başla');
      final control = container.read(tabuGameProvider.notifier);
      for (var game = 0; game < 2; game++) {
        for (var i = 0; i < 10; i++) {
          control.answer(
            container.read(tabuGameProvider).card!.id,
            CardOutcome.correct,
          );
          now += const Duration(milliseconds: 400);
        }
        await tester.pumpAndSettle();
        expect(find.text('Kazanan:'), findsOneWidget);
        expect(find.text('Hedef Puan: 10'), findsOneWidget);
        final score = tester.widget<ScoreWidget>(find.byType(ScoreWidget));
        expect(score.teams.map((team) => team.score), [10, 0]);
        expect(find.text('Doğru'), findsNothing);
        expect(tester.takeException(), isNull);
        if (game == 0) {
          await tap(tester, 'Tekrar Oyna');
          expect(container.read(tabuGameProvider).session!.targetScore, 10);
          expect(
            container
                .read(tabuGameProvider)
                .teams
                .every((team) => team.score == 0),
            isTrue,
          );
          await tap(tester, 'Tura Başla');
        } else {
          await tap(tester, 'Ana Sayfaya Dön');
          expect(container.read(appRouterProvider).state.uri.path, '/');
        }
      }
    },
  );

  testWidgets(
    'İsim alanları doğrulanır, düzenlenen isim ve 120 saniye korunur',
    (tester) async {
      final container = await open(tester);
      await tester.enterText(find.byKey(const ValueKey('team-0')), ' ');
      await tap(tester, 'Oyuna Başla');
      expect(find.text('Takım adı boş olamaz.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('team-0')),
        'Kırmızı Takım',
      );
      await tap(tester, 'Oyuna Başla');
      expect(find.text('Takım adları farklı olmalı.'), findsNWidgets(2));
      await tester.enterText(find.byKey(const ValueKey('team-0')), 'Yıldızlar');
      await tap(tester, '120');
      await tap(tester, 'Oyuna Başla');
      expect(container.read(tabuGameProvider).session!.seconds, 120);
      expect(container.read(tabuGameProvider).session!.targetScore, 20);
      expect(container.read(tabuGameProvider).teams.first.name, 'Yıldızlar');
      expect(find.text('Sıra Kimde?'), findsOneWidget);
    },
  );

  for (final size in [
    const Size(320, 568),
    const Size(393, 786),
    const Size(768, 1024),
  ]) {
    testWidgets('Beş ekran, koyu tema ve büyük yazı: ${size.width}', (
      tester,
    ) async {
      final container = await open(tester, size: size, dark: true, scale: 1.4);
      final control = container.read(tabuGameProvider.notifier);
      expect(tester.takeException(), isNull);
      await tap(tester, '60');
      await tap(tester, 'Oyuna Başla');
      expect(tester.takeException(), isNull);
      for (var round = 0; round < 6; round++) {
        await tap(tester, 'Tura Başla');
        expect(find.text('01:00'), findsOneWidget);
        final score = tester.widget<ScoreWidget>(find.byType(ScoreWidget));
        final activeTeam = container.read(tabuGameProvider).activeTeam;
        expect(score.teams, hasLength(1));
        final forbidden =
            container.read(tabuGameProvider).card!.forbidden.first;
        expect(
          tester.widget<Text>(find.text(forbidden)).style!.fontSize,
          size.width < 360 ? 22 : 24,
        );
        expect(
          score.teams.single.name,
          container.read(tabuGameProvider).teams[activeTeam].name,
        );
        expect(
          score.teams.single.score,
          container.read(tabuGameProvider).teams[activeTeam].score,
        );
        expect(
          find.text(activeTeam == 0 ? 'Kırmızı Takım' : 'Mavi Takım'),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
        if (round == 0) {
          await tester.tap(find.byTooltip('Duraklat'));
          await tester.pumpAndSettle();
          expect(find.text('Oyun Duraklatıldı'), findsOneWidget);
          expect(
            tester
                .widget<ElevatedButton>(
                  find.widgetWithText(ElevatedButton, 'Doğru'),
                )
                .onPressed,
            isNull,
          );
          await tap(tester, 'Devam Et');
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
          await tester.pumpAndSettle();
          expect(container.read(tabuGameProvider).paused, isTrue);
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tap(tester, 'Devam Et');
          await tap(tester, 'Doğru');
        }
        now += const Duration(seconds: 60);
        control.tick();
        await tester.pumpAndSettle();
        expect(find.text('Tur Bitti!'), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(find.text('Skoru Gör'), findsNothing);
        await tap(tester, 'Sonraki Takım');
      }
      expect(container.read(tabuGameProvider).phase, GamePhase.preRound);
      expect(find.text('Tur 7 • 60 saniye'), findsOneWidget);
      await tap(tester, 'Tura Başla');
      for (var i = 0; i < 19; i++) {
        control.answer(
          container.read(tabuGameProvider).card!.id,
          CardOutcome.correct,
        );
        now += const Duration(milliseconds: 400);
      }
      await tester.pumpAndSettle();
      expect(find.text('Kazanan:'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tap(tester, 'Tekrar Oyna');
      expect(find.text('Sıra Kimde?'), findsOneWidget);
      expect(container.read(tabuGameProvider).teams.first.score, 0);
      expect(container.read(tabuGameProvider).round, 0);
      expect(container.read(tabuGameProvider).deckCycle, 0);
      control.startRound();
      for (var i = 0; i < 20; i++) {
        control.answer(
          container.read(tabuGameProvider).card!.id,
          CardOutcome.correct,
        );
        now += const Duration(milliseconds: 400);
      }
      await tester.pumpAndSettle();
      expect(find.text('Kazanan:'), findsOneWidget);
      await tap(tester, 'Ana Sayfaya Dön');
      expect(container.read(appRouterProvider).state.uri.path, '/');
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Yeni ayarlar: varsayılan isim/renk, 90 saniye ve 20 puan', (
    tester,
  ) async {
    final container = await open(tester);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('team-0')))
          .controller!
          .text,
      'Mavi Takım',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('team-1')))
          .controller!
          .text,
      'Kırmızı Takım',
    );
    for (var i = 0; i < 2; i++) {
      final panel = tester.widget<Container>(
        find.byKey(ValueKey('tabu-team-panel-$i')),
      );
      expect(
        (panel.decoration as BoxDecoration).color,
        TabuTeamColors.surfaceFor(
          tester.element(find.byType(TabuSetupForm)),
          i,
        ),
      );
    }
    await tester.ensureVisible(find.text('30 puan'));
    await tester.pumpAndSettle();
    expect(find.text('30 puan').hitTestable(), findsOneWidget);
    expect(
      find.byKey(const ValueKey('tabu-start')).hitTestable(),
      findsOneWidget,
    );
    await tap(tester, 'Oyuna Başla');
    final session = container.read(tabuGameProvider).session!;
    expect(session.names, ['Mavi Takım', 'Kırmızı Takım']);
    expect(session.seconds, 90);
    expect(session.targetScore, 20);
  });

  for (final seconds in [60, 90, 120]) {
    testWidgets('$seconds saniye yeni ayar ekranından aktarılır', (
      tester,
    ) async {
      final container = await open(tester);
      await tester.tap(find.byKey(ValueKey('duration-$seconds')));
      await tap(tester, 'Oyuna Başla');
      expect(container.read(tabuGameProvider).session!.seconds, seconds);
    });
  }

  for (final scenario in [
    (const Size(320, 568), 1.6),
    (const Size(393, 786), 1.0),
    (const Size(768, 1024), 1.4),
  ]) {
    testWidgets('Sabit başlat, klavye ve kaydırma: ${scenario.$1.width}', (
      tester,
    ) async {
      await open(tester, size: scenario.$1, scale: scenario.$2, dark: true);
      expect(
        tester.getCenter(find.text('Tabu')).dx,
        closeTo(scenario.$1.width / 2, .5),
      );
      expect(
        tester
            .getCenter(find.text('Kelimeyi anlat, yasaklı kelimeleri söyleme!'))
            .dx,
        closeTo(scenario.$1.width / 2, .5),
      );
      final start = find.byKey(const ValueKey('tabu-start'));
      expect(start.hitTestable(), findsOneWidget);
      final original = tester.getRect(start);
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -450),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(start), original);
      await tester.ensureVisible(find.byKey(const ValueKey('team-1')));
      await tester.tap(find.byKey(const ValueKey('team-1')));
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      expect(start, findsNothing);
      await tester.enterText(
        find.byKey(const ValueKey('team-1')),
        'Uzun Kırmızı Takım İsmi',
      );
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(start.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      addTearDown(tester.view.resetViewInsets);
    });
  }

  testWidgets(
    'Kurallar modalı kayar, kapatma oyunu başlatmaz ve ayarlar korunur',
    (tester) async {
      final container = await open(
        tester,
        size: const Size(320, 568),
        scale: 1.6,
      );
      await tester.enterText(
        find.byKey(const ValueKey('team-0')),
        'Mavi Yıldızlar',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('target-25')));
      await tester.tap(find.byKey(const ValueKey('target-25')));
      await tester.tap(find.byTooltip('Oyun kuralları'));
      await tester.pumpAndSettle();
      expect(find.text('Oyunu Nasıl Oynarız?'), findsOneWidget);
      for (final text in [
        'Kelimeyi anlat',
        'Yasaklı kelimeleri söyleme',
        'Süre dolmadan anlat',
        'Hedef puana ulaş',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      await tester.ensureVisible(find.text('Tamam, Başlayalım!'));
      await tap(tester, 'Tamam, Başlayalım!');
      expect(find.text('Oyunu Nasıl Oynarız?'), findsNothing);
      expect(container.read(tabuGameProvider).phase, GamePhase.setup);
      await tap(tester, 'Oyuna Başla');
      expect(
        container.read(tabuGameProvider).session!.names.first,
        'Mavi Yıldızlar',
      );
      expect(container.read(tabuGameProvider).session!.targetScore, 25);
      expect(tester.takeException(), isNull);
    },
  );
  double contrast(Color foreground, Color background) {
    final a = foreground.computeLuminance();
    final b = background.computeLuminance();
    return ((a > b ? a : b) + .05) / ((a > b ? b : a) + .05);
  }

  for (final dark in [false, true]) {
    testWidgets(
      'Ayar/metin/buton kontrastı ve kurallar modalı: ${dark ? "koyu" : "açık"}',
      (tester) async {
        final container = await open(
          tester,
          size: const Size(320, 568),
          scale: 1.4,
          dark: dark,
        );
        final context = tester.element(find.byType(TabuSetupForm));
        final colors = Theme.of(context).colorScheme;
        expect(
          Theme.of(context).brightness,
          dark ? Brightness.dark : Brightness.light,
        );
        final start = find.byKey(const ValueKey('tabu-start'));
        expect(start.hitTestable(), findsOneWidget);
        final action = tester.widget<FilledButton>(start);
        final background = action.style!.backgroundColor!.resolve({})!;
        final foreground =
            tester.widget<Text>(find.text('Oyuna Başla')).style!.color!;
        expect(foreground, colors.onPrimary);
        expect(contrast(foreground, background), greaterThanOrEqualTo(4.5));
        expect(
          tester.widget<Text>(find.text('Oyuna Başla')).style!.fontVariations,
          AppTheme.titleWeight,
        );
        for (var i = 0; i < 2; i++) {
          final panel = tester.widget<Container>(
            find.byKey(ValueKey('tabu-team-panel-$i')),
          );
          final decoration = panel.decoration! as BoxDecoration;
          expect(
            (decoration.border! as Border).top.width,
            lessThanOrEqualTo(1),
          );
          final field = tester.widget<TextField>(
            find.descendant(
              of: find.byKey(ValueKey('team-$i')),
              matching: find.byType(TextField),
            ),
          );
          expect(field.decoration!.filled, isFalse);
          expect(
            contrast(field.style!.color!, decoration.color!),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            contrast(field.decoration!.labelStyle!.color!, decoration.color!),
            greaterThanOrEqualTo(4.5),
          );
        }
        for (final key in [
          'duration-60',
          'duration-90',
          'target-10',
          'target-20',
        ]) {
          final button = tester.widget<OutlinedButton>(
            find.byKey(ValueKey(key)),
          );
          final bg = button.style!.backgroundColor!.resolve({})!;
          final fg = button.style!.foregroundColor!.resolve({})!;
          expect(contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: key);
          expect(
            button.style!.side!.resolve({})!.width,
            lessThanOrEqualTo(1.5),
          );
        }
        await tester.tap(find.byKey(const ValueKey('tabu-rules')));
        await tester.pumpAndSettle();
        expect(find.text('Oyunu Nasıl Oynarız?'), findsOneWidget);
        expect(
          tester.widget<BottomSheet>(find.byType(BottomSheet)).backgroundColor,
          colors.surface,
        );
        await tester.ensureVisible(find.text('Tamam, Başlayalım!'));
        await tap(tester, 'Tamam, Başlayalım!');
        expect(container.read(tabuGameProvider).phase, GamePhase.setup);
        expect(start.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Sistem tema modu açık/koyu değişimini izlemeye devam eder', (
    tester,
  ) async {
    final container = await open(tester);
    container.read(themeModeProvider.notifier).select(ThemeMode.system);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    for (final brightness in [Brightness.dark, Brightness.light]) {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(TabuSetupForm))).brightness,
        brightness,
      );
      expect(container.read(themeModeProvider), ThemeMode.system);
      expect(
        find.byKey(const ValueKey('tabu-start')).hitTestable(),
        findsOneWidget,
      );
    }
  });
}
