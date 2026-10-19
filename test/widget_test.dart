import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/app.dart';
import 'package:oynika/app/router/app_router.dart';
import 'package:oynika/app/theme/theme_mode_provider.dart';
import 'package:oynika/features/games/domain/party_game.dart';

void main() {
  Future<ProviderContainer> openApp(
    WidgetTester tester, {
    Size size = const Size(393, 852),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const OynikaApp()),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> tapVisible(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  // Faz 1'in açılış, oyun adları ve küçük ekran kontrolleri korunur;
  // slogan ve geliştirme bilgisi Faz 2'nin onaylanan yerleşimine uyarlanır.
  testWidgets('Uygulama hatasız açılır ve Oynika başlığı görünür', (
    tester,
  ) async {
    await openApp(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Oynika'), findsOneWidget);
    final logo = tester.widget<Image>(
      find.byKey(const ValueKey('official-logo')),
    );
    expect(
      (logo.image as AssetImage).assetName,
      'assets/branding/oynika_logo_borderless.png',
    );
    expect(logo.fit, BoxFit.contain);
    expect(
      find.text('Arkadaşlarını topla,\neğlence başlasın!'),
      findsOneWidget,
    );
    expect(find.text('PARTİ ZAMANI'), findsOneWidget);
  });

  testWidgets('Beş oyunun adı ve geliştirme durumu görünür', (tester) async {
    await openApp(tester);
    for (final game in PartyGame.values) {
      final title = find.text(game.title);
      expect(title, findsOneWidget);
      await tester.ensureVisible(title);
      await tester.pumpAndSettle();
      expect(title.hitTestable(), findsOneWidget);
    }
    await tester.ensureVisible(
      find.text(
        'Oyunlar geliştirme aşamasında. Şimdilik oyunları keşfedebilirsin.',
      ),
    );
    expect(tester.takeException(), isNull);
  });

  for (final game in PartyGame.values) {
    testWidgets('${game.title} doğru tanıtımı açar ve geri dönülebilir', (
      tester,
    ) async {
      final container = await openApp(tester);
      await tapVisible(tester, find.byKey(ValueKey('game-card-${game.asset}')));
      expect(container.read(appRouterProvider).state.uri.path, game.path);
      expect(find.text(game.title), findsOneWidget);
      expect(find.text('Nasıl oynanır?'), findsOneWidget);
      await tester.ensureVisible(find.text('Geliştirme aşamasında'));
      await tester.pumpAndSettle();
      expect(find.text('Geliştirme aşamasında').hitTestable(), findsOneWidget);
      await tester.tap(find.byTooltip('Geri'));
      await tester.pumpAndSettle();
      expect(container.read(appRouterProvider).state.uri.path, '/');
      expect(find.byKey(const ValueKey('nav-home')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Alt navigasyon üç sekmeyi açar ve oyunlar ekranı kartları kullanır',
    (tester) async {
      final container = await openApp(tester);
      await tester.tap(find.byKey(const ValueKey('nav-games')));
      await tester.pumpAndSettle();
      expect(container.read(appRouterProvider).state.uri.path, '/games');
      for (final game in PartyGame.values) {
        expect(find.byKey(ValueKey('game-card-${game.asset}')), findsOneWidget);
      }
      await tapVisible(tester, find.byKey(const ValueKey('game-card-taboo')));
      expect(find.text('Nasıl oynanır?'), findsOneWidget);
      await tester.tap(find.byTooltip('Geri'));
      await tester.pumpAndSettle();
      expect(container.read(appRouterProvider).state.uri.path, '/games');
      await tester.tap(find.byKey(const ValueKey('nav-settings')));
      await tester.pumpAndSettle();
      expect(find.text('Görünüm'), findsOneWidget);
      expect(find.byKey(const ValueKey('app-version')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-home')));
      await tester.pumpAndSettle();
      expect(find.text('Oynika'), findsOneWidget);
    },
  );

  testWidgets('Ayarlar dişli ikonu ve tema seçimi çalışır', (tester) async {
    final container = await openApp(tester);
    expect(find.byKey(const ValueKey('header-settings')), findsNothing);
    final settingsTab = find.byKey(const ValueKey('nav-settings'));
    expect(
      find.descendant(
        of: settingsTab,
        matching: find.byIcon(Icons.settings_rounded),
      ),
      findsWidgets,
    );
    await tester.tap(settingsTab);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: settingsTab,
        matching: find.byIcon(Icons.settings_rounded),
      ),
      findsWidgets,
    );
    expect(find.text('Oynika hakkında'), findsOneWidget);
    for (final mode in [ThemeMode.dark, ThemeMode.light, ThemeMode.system]) {
      await tapVisible(tester, find.byKey(ValueKey('theme-${mode.name}')));
      expect(container.read(themeModeProvider), mode);
      if (mode != ThemeMode.system) {
        expect(
          Theme.of(tester.element(find.text('Görünüm'))).brightness,
          mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
        );
      }
    }
    await tapVisible(tester, find.byKey(const ValueKey('theme-dark')));
    await tester.tap(find.byKey(const ValueKey('nav-home')));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Oynika'))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('Karşılama oku oyunlar bölümüne kaydırır', (tester) async {
    await openApp(tester, size: const Size(393, 650));
    final card = find.byKey(const ValueKey('game-card-taboo'));
    final before = tester.getTopLeft(card).dy;
    await tester.tap(find.byKey(const ValueKey('explore-games')));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(card).dy, lessThan(before));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Geçersiz oyun rotası oyun listesine yönlenir', (tester) async {
    final container = await openApp(tester);
    container.read(appRouterProvider).go('/games/bilinmeyen');
    await tester.pumpAndSettle();
    expect(container.read(appRouterProvider).state.uri.path, '/games');
    expect(find.byKey(const ValueKey('game-card-taboo')), findsOneWidget);
  });

  for (final size in [
    const Size(320, 568),
    const Size(393, 786),
    const Size(768, 1024),
  ]) {
    testWidgets('Küçük ekran/koyu tema: ${size.width} genişlikte taşma olmaz', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await openApp(tester, size: size);
      expect(
        Theme.of(tester.element(find.text('Oynika'))).brightness,
        Brightness.dark,
      );
      for (final game in PartyGame.values) {
        await tester.ensureVisible(
          find.byKey(ValueKey('game-card-${game.asset}')),
        );
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const ValueKey('nav-settings')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Büyük yazı ölçeğinde gezinme ve tanıtım taşma üretmez', (
    tester,
  ) async {
    final container = await openApp(
      tester,
      size: const Size(320, 568),
      textScale: 1.6,
    );
    await tapVisible(
      tester,
      find.byKey(const ValueKey('game-card-five_seconds')),
    );
    expect(
      container.read(appRouterProvider).state.uri.path,
      PartyGame.fiveSeconds.path,
    );
    await tester.ensureVisible(find.text('Geliştirme aşamasında'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
