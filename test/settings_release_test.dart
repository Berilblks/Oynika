import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:oynika/app/app.dart';
import 'package:oynika/app/router/app_router.dart';
import 'package:oynika/app/theme/theme_mode_provider.dart';
import 'package:oynika/core/ads/ad_units.dart';
import 'package:oynika/core/ads/ads_diagnostics.dart';
import 'package:oynika/core/ads/ads_service.dart';
import 'package:oynika/core/ads/google_ads_backend.dart';
import 'package:oynika/core/constants/app_links.dart';
import 'package:oynika/core/utils/app_package_info.dart';
import 'package:oynika/core/utils/external_links.dart';
import 'package:oynika/features/games/domain/party_game.dart';

class _ConsentBackend implements AdsBackend {
  _ConsentBackend(this.required);
  final bool required;
  int opened = 0;

  @override
  Future<void> updateConsent() async {}
  @override
  Future<void> showConsentIfRequired() async {}
  @override
  Future<bool> privacyOptionsRequired() async => required;
  @override
  Future<void> showPrivacyOptions() async {
    opened++;
  }

  @override
  Future<bool> canRequestAds() async => false;
  @override
  Future<void> initialize() async {}
  @override
  Future<InterstitialPlacement?> loadInterstitial(String unit) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/url_launcher');
  final calls = <MethodCall>[];
  setUp(() {
    calls.clear();
    PackageInfo.setMockInitialValues(
      appName: 'Oynika',
      packageName: 'com.oynika.app',
      version: '9.8.7',
      buildNumber: '123',
      buildSignature: '',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return true;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<ProviderContainer> open(
    WidgetTester tester, {
    bool qa = false,
    bool dark = false,
    double width = 375,
    double scale = 1,
    ExternalLinkOpener? opener,
    _ConsentBackend? backend,
    Future<PackageInfo> Function()? package,
  }) async {
    tester.view.physicalSize = Size(width, 667);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final ads = AdsService(
      backend ?? _ConsentBackend(false),
      interstitialAdUnitFor(TargetPlatform.iOS, release: false),
      qaEnabled: qa,
    );
    addTearDown(ads.dispose);
    final container = ProviderContainer(
      overrides: [
        adsServiceProvider.overrideWithValue(ads),
        adsQaEnabledProvider.overrideWithValue(qa),
        if (opener != null)
          externalLinkOpenerProvider.overrideWithValue(opener),
        if (package != null)
          appPackageInfoProvider.overrideWith((ref) => package()),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(themeModeProvider.notifier)
        .select(dark ? ThemeMode.dark : ThemeMode.light);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const OynikaApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-settings')));
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('Privacy opens the central Turkish URL in an external browser', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, find.byKey(const ValueKey('privacy-policy')));
    expect(calls, hasLength(1));
    expect(calls.single.method, 'launch');
    final args = calls.single.arguments as Map;
    expect(args['url'], 'https://berilblks.github.io/Oynika/privacy.html');
    expect(args['useSafariVC'], isFalse);
    expect(args['useWebView'], isFalse);
    expect(
      AppLinks.privacyEn.toString(),
      'https://berilblks.github.io/Oynika/privacy-en.html',
    );
  });

  testWidgets(
    'Support opens the email app with the correct recipient and subject',
    (tester) async {
      await open(tester);
      await tap(tester, find.byKey(const ValueKey('support-contact')));
      expect(calls, hasLength(1));
      final uri = Uri.parse((calls.single.arguments as Map)['url'] as String);
      expect(uri.scheme, 'mailto');
      expect(uri.path, 'support.berilapps@gmail.com');
      expect(uri.queryParameters['subject'], 'Oynika - Destek Talebi');
      expect(uri.toString(), contains('Oynika%20-%20Destek%20Talebi'));
    },
  );

  for (final throws in [false, true]) {
    for (final support in [false, true]) {
      testWidgets('Link failure is safe: support=$support / throws=$throws', (
        tester,
      ) async {
        final container = await open(
          tester,
          opener: (_) async {
            if (throws) throw PlatformException(code: 'NO_HANDLER');
            return false;
          },
        );
        await tap(
          tester,
          find.byKey(ValueKey(support ? 'support-contact' : 'privacy-policy')),
        );
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text(
            support
                ? 'E-posta uygulaması açılamadı. support.berilapps@gmail.com adresine yazabilirsin.'
                : 'Gizlilik politikası açılamadı. Lütfen tekrar dene.',
          ),
          findsOneWidget,
        );
        expect(container.read(appRouterProvider).state.uri.path, '/settings');
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'About uses the new slogan, catalog titles and platform package metadata',
    (tester) async {
      await open(tester);
      expect(find.text('Eğlence Bir Araya Getirir!'), findsOneWidget);
      expect(find.text('4 Oyun, Tek Uygulama!'), findsNothing);
      expect(
        find.text(
          'Oynika, arkadaşların ve ailenle birlikte keyifli vakit geçirmen için hazırlanmış Türkçe parti oyunları uygulamasıdır. Tabu, Sessiz Sinema, Aramızdaki Casus ve Ben Kimim? ile eğlenceye katıl!',
        ),
        findsOneWidget,
      );
      for (final game in PartyGame.values) {
        expect(PartyGame.aboutDescription, contains(game.title));
      }
      expect(find.text('Sürüm 9.8.7 (123)'), findsOneWidget);
      expect(find.textContaining('Sürüm 0.1.0'), findsNothing);
      await tap(tester, find.text('Açık kaynak lisansları'));
      expect(find.text('9.8.7 (123)'), findsOneWidget);
    },
  );

  testWidgets('Package metadata can load asynchronously and fail safely', (
    tester,
  ) async {
    final pending = Completer<PackageInfo>();
    await open(tester, package: () => pending.future);
    expect(find.text('Sürüm bilgisi yükleniyor…'), findsOneWidget);
    pending.completeError(StateError('Package info unavailable'));
    await tester.pumpAndSettle();
    expect(find.text('Sürüm bilgisi alınamadı.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final qa in [false, true]) {
    testWidgets(
      'Privacy is always present, QA is gated, required UMP preferences work: $qa',
      (tester) async {
        final backend = _ConsentBackend(true);
        await open(tester, qa: qa, backend: backend);
        expect(find.text('Gizlilik ve Yasal'), findsOneWidget);
        expect(find.byKey(const ValueKey('privacy-policy')), findsOneWidget);
        expect(
          find.text('Reklam tanılama (QA)'),
          qa ? findsOneWidget : findsNothing,
        );
        await tap(tester, find.text('Reklam gizlilik seçenekleri'));
        expect(backend.opened, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final dark in [false, true]) {
    for (final width in [320.0, 375.0, 430.0]) {
      testWidgets(
        'Settings scrolls without overflow at 2.5x: $width / dark=$dark',
        (tester) async {
          final container = await open(
            tester,
            dark: dark,
            width: width,
            scale: 2.5,
          );
          for (final key in [
            'privacy-policy',
            'support-contact',
            'app-version',
          ]) {
            await tester.ensureVisible(find.byKey(ValueKey(key)));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          await tester.tap(find.byKey(const ValueKey('nav-games')));
          await tester.pumpAndSettle();
          expect(container.read(appRouterProvider).state.uri.path, '/games');
          await tester.tap(find.byKey(const ValueKey('nav-settings')));
          await tester.pumpAndSettle();
          expect(container.read(appRouterProvider).state.uri.path, '/settings');
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
