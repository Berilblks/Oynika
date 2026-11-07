import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/features/games/domain/party_game.dart';
import 'package:oynika/features/games/who_am_i/application/who_controller.dart';
import 'package:oynika/features/games/who_am_i/domain/who_models.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_screen.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_game_screen.dart';

Future<ProviderContainer> open(
  WidgetTester tester, {
  bool dark = false,
  Size size = const Size(393, 786),
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final c = ProviderContainer();
  addTearDown(c.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: const WhoScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return c;
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Varsayılan 4 oyuncu ve 90 saniye başlangıca aktarılır', (
    tester,
  ) async {
    final c = await open(tester);
    expect(find.text('4 oyuncu'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    for (final seconds in [60, 90, 120]) {
      expect(find.byKey(ValueKey('who-duration-$seconds')), findsOneWidget);
    }
    final button = find.byKey(const ValueKey('who-start'));
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(button.hitTestable(), findsOneWidget);
    await tap(tester, button);
    expect(
      c.read(whoSessionProvider)!.settings.duration,
      WhoRoundDuration.standard,
    );
    expect(c.read(whoSessionProvider)!.settings.players.map((p) => p.name), [
      'Oyuncu 1',
      'Oyuncu 2',
      'Oyuncu 3',
      'Oyuncu 4',
    ]);
    expect(find.byType(WhoGameScreen), findsOneWidget);
    expect(
      find.text('Arkadaşlarının verdiği ipuçlarıyla kelimeyi tahmin et.'),
      findsOneWidget,
    );
    expect(find.text('Başlamaya Hazırım'), findsOneWidget);
    expect(PartyGame.whoAmI.isPlayable, isTrue);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tap(tester, find.text('Çık'));
    expect(c.read(whoSessionProvider), isNull);
    expect(find.text('4 oyuncu'), findsOneWidget);
  });
  testWidgets('İsimler, 2–20 sınırı ve azaltıp artırırken koruma', (
    tester,
  ) async {
    await open(tester);
    final first = find.byKey(const ValueKey('who-name-0'));
    await tester.ensureVisible(first);
    await tester.enterText(first, 'Deniz');
    final fourth = find.byKey(const ValueKey('who-name-3'));
    await tester.ensureVisible(fourth);
    await tester.enterText(fourth, 'Ece');
    for (var i = 0; i < 2; i++) {
      await tap(tester, find.byKey(const ValueKey('who-minus')));
    }
    expect(find.text('2 oyuncu'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('who-minus')))
          .onPressed,
      isNull,
    );
    for (var i = 2; i < 20; i++) {
      await tap(tester, find.byKey(const ValueKey('who-plus')));
    }
    expect(find.text('20 oyuncu'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.byKey(const ValueKey('who-plus')))
          .onPressed,
      isNull,
    );
    expect(tester.widget<TextFormField>(first).controller!.text, 'Deniz');
    expect(tester.widget<TextFormField>(fourth).controller!.text, 'Ece');
    expect(tester.takeException(), isNull);
  });
  testWidgets('Boş/tekrar isim başlamaz, düzeltme ve süre seçimi korunur', (
    tester,
  ) async {
    final c = await open(tester);
    final first = find.byKey(const ValueKey('who-name-0'));
    await tester.ensureVisible(first);
    await tester.enterText(first, ' ');
    await tap(tester, find.byKey(const ValueKey('who-start')));
    expect(find.text('Oyuncu adı boş olamaz.'), findsOneWidget);
    expect(c.read(whoSessionProvider), isNull);
    await tester.ensureVisible(first);
    await tester.enterText(first, ' oyuncu 2 ');
    await tap(tester, find.byKey(const ValueKey('who-start')));
    expect(find.text('Oyuncu isimleri farklı olmalı.'), findsNWidgets(2));
    expect(c.read(whoSessionProvider), isNull);
    await tester.ensureVisible(first);
    await tester.enterText(first, ' Ece ');
    await tap(tester, find.byKey(const ValueKey('who-duration-120')));
    await tap(tester, find.byKey(const ValueKey('who-duration-60')));
    await tap(tester, find.byKey(const ValueKey('who-start')));
    expect(
      c.read(whoSessionProvider)!.settings.duration,
      WhoRoundDuration.short,
    );
    expect(c.read(whoSessionProvider)!.settings.players.first.name, 'Ece');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tap(tester, find.text('Çık'));
    expect(tester.widget<TextFormField>(first).controller!.text, 'Ece');
  });
  testWidgets('Kurallar hareket yönlerini açıklar ve yalnızca kapanır', (
    tester,
  ) async {
    final c = await open(tester);
    await tap(tester, find.byTooltip('Oyun kuralları'));
    expect(find.text('Nasıl Oynanır?'), findsOneWidget);
    expect(
      find.text(
        'Doğru cevap +1, Pas 0 puandır. Öne eğ: Doğru; arkaya eğ: Pas. Yeni hareket için telefonu düz konuma getir. Dokunmatik butonlar da kullanılabilir.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('Herkes eşit sayıda normal tur oynar.'),
      findsOneWidget,
    );
    await tap(tester, find.text('Tamam, Başlayalım!'));
    expect(find.byType(BottomSheet), findsNothing);
    expect(c.read(whoSessionProvider), isNull);
  });
  for (final dark in [false, true]) {
    for (final size in [const Size(320, 568), const Size(768, 1024)]) {
      testWidgets('Şeffaf barlar, büyük yazı ve klavye: $dark/$size', (
        tester,
      ) async {
        await open(tester, dark: dark, size: size, scale: 1.6);
        expect(
          tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
          Colors.transparent,
        );
        expect(
          tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
          Colors.transparent,
        );
        expect(
          find.byKey(const ValueKey('who-start')).hitTestable(),
          findsOneWidget,
        );
        final field = find.byKey(const ValueKey('who-name-0'));
        await tester.ensureVisible(field);
        await tester.enterText(
          field,
          'Çok Uzun Oyuncu İsmi Deneme Deneme Deneme',
        );
        tester.view.viewInsets = const FakeViewPadding(bottom: 220);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('who-start')), findsNothing);
        expect(tester.takeException(), isNull);
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        await tap(tester, find.byKey(const ValueKey('who-start')));
        expect(find.byType(WhoGameScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
