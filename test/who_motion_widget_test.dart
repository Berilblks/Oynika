import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/app/theme/app_theme.dart';
import 'package:oynika/core/utils/app_orientation.dart';
import 'package:oynika/features/games/who_am_i/application/who_controller.dart';
import 'package:oynika/features/games/who_am_i/application/who_motion_provider.dart';
import 'package:oynika/features/games/who_am_i/application/who_motion_service.dart';
import 'package:oynika/features/games/who_am_i/data/who_card_repository.dart';
import 'package:oynika/features/games/who_am_i/domain/who_models.dart';
import 'package:oynika/features/games/who_am_i/domain/who_tilt_detector.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_orientation_provider.dart';
import 'package:oynika/features/games/who_am_i/presentation/who_screen.dart';

void main() {
  late ProviderContainer c;
  late StreamController<WhoMotionSample> stream;
  late StreamController<WhoMotionSample> gyro;
  late WhoMotionService service;
  var now = Duration.zero;
  var cancels = 0, listens = 0;
  WhoGameSession getSession() => c.read(whoSessionProvider)!;
  Future<void> tap(WidgetTester t, String label) async {
    final f = find.text(label);
    await t.ensureVisible(f);
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> feed(WidgetTester t, double angle, int ms) async {
    for (var i = 0; i < ms; i += 20) {
      now += const Duration(milliseconds: 20);
      stream.add(
        WhoMotionSample(
          9.81 * math.cos(angle * math.pi / 180),
          0,
          -9.81 * math.sin(angle * math.pi / 180),
          now + const Duration(seconds: 100),
        ),
      );
      await t.pump(const Duration(milliseconds: 20));
    }
  }

  Future<void> open(
    WidgetTester t, {
    bool dark = false,
    Size size = const Size(393, 786),
    double scale = 1,
  }) async {
    now = Duration.zero;
    cancels = 0;
    listens = 0;
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = size;
    t.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    stream = StreamController<WhoMotionSample>.broadcast(
      sync: true,
      onListen: () => listens++,
      onCancel: () => cancels++,
    );
    gyro = StreamController<WhoMotionSample>.broadcast(sync: true);
    service = WhoMotionService(
      source: () => stream.stream,
      gyroSource: () => gyro.stream,
      readUpSign: () async => 1,
      clock: () => now,
    );
    c = ProviderContainer(
      overrides: [
        whoOrientationProvider.overrideWithValue(AppOrientation((_) async {})),
        whoMotionFactoryProvider.overrideWithValue(() => service),
        whoClockProvider.overrideWithValue(() => now),
        whoCardsProvider.overrideWith(
          (ref) async => WhoCardRepository.decode(
            File(WhoCardRepository.assetPath).readAsStringSync(),
          ),
        ),
      ],
    );
    addTearDown(() {
      service.dispose();
      unawaited(stream.close());
      unawaited(gyro.close());
      c.dispose();
    });
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: const WhoScreen(),
        ),
      ),
    );
    await t.pumpAndSettle();
    await tap(t, 'Oyunu Başlat');
    await tap(t, 'Başlamaya Hazırım');
    now += const Duration(seconds: 3);
    c.read(whoSessionProvider.notifier).tick();
    t.view.physicalSize = Size(size.height, size.width);
    await t.pumpAndSettle();
  }

  Future<void> close(WidgetTester t) async {
    await t.pumpWidget(const SizedBox());
    await t.pump();
  }

  testWidgets('Gyro + ivme füzyonu gerçek controller Doğru yoluna ulaşır', (
    t,
  ) async {
    await open(t);
    await tap(t, 'Hazırım');
    await feed(t, 0, 1100);
    gyro.add(WhoMotionSample(0, 0, 0, now + const Duration(seconds: 100)));
    for (var i = 0; i < 30; i++) {
      now += const Duration(milliseconds: 20);
      final time = now + const Duration(seconds: 100);
      gyro.add(WhoMotionSample(0, i < 20 ? -2.4 : 0, 0, time));
      stream.add(WhoMotionSample(18, 0, 0, time));
      await t.pump(const Duration(milliseconds: 20));
    }
    expect(getSession().correct, 1);
    expect(service.lastAction, 'Doğru +1');
    expect(service.detector.usesGyro, isTrue);
    await close(t);
  });

  testWidgets(
    'Hazırım sensör verisi gelmeden kelime ve sayacı hemen başlatır',
    (t) async {
      await open(t);
      await tap(t, 'Hazırım');
      expect(getSession().phase, WhoPhase.playing);
      expect(find.byKey(const ValueKey('who-active-card')), findsOneWidget);
      expect(getSession().remaining, const Duration(seconds: 90));
      expect(service.state, WhoMotionState.calibrating);
      now += const Duration(seconds: 5);
      await t.pump(const Duration(seconds: 5));
      expect(getSession().remaining.inSeconds, 85);
      expect(service.state, WhoMotionState.unavailable);
      await tap(t, 'Doğru +1');
      expect(getSession().correct, 1);
      await close(t);
    },
  );
  testWidgets(
    'Sensör/dokunma ortak koruma, nötr mandalı, süre sonunda kapanma',
    (t) async {
      await open(t);
      await tap(t, 'Hazırım');
      await feed(t, 0, 1100);
      expect(service.state, WhoMotionState.active);
      final stale =
          t
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Doğru +1'),
              )
              .onPressed!;
      await feed(t, 55, 400);
      expect(getSession().correct, 1);
      stale();
      await t.pump();
      expect(getSession().correct, 1);
      await feed(t, 55, 800);
      expect(getSession().correct, 1);
      await feed(t, 0, 800);
      await feed(t, -55, 400);
      expect(getSession().passed, 1);
      expect(getSession().totals.first, 1);
      now += const Duration(seconds: 91);
      c.read(whoSessionProvider.notifier).tick();
      await t.pumpAndSettle();
      expect(getSession().phase, WhoPhase.roundResult);
      expect(service.state, WhoMotionState.idle);
      expect(cancels, 1);
      await feed(t, 55, 500);
      expect(getSession().correct, 1);
      await tap(t, 'Sıradaki Oyuncu');
      expect(getSession().currentPlayerIndex, 1);
      await close(t);
    },
  );
  testWidgets('Oyun içinde yeniden ayarla kartı/süreyi/puanı sıfırlamaz', (
    t,
  ) async {
    await open(t);
    await tap(t, 'Hazırım');
    await feed(t, 0, 800);
    final card = getSession().card!.id;
    final left = getSession().remaining;
    await t.tap(find.byTooltip('Sensörü yeniden ayarla'));
    await t.pump();
    expect(service.state, WhoMotionState.calibrating);
    expect(getSession().phase, WhoPhase.playing);
    expect(getSession().card!.id, card);
    expect(getSession().remaining, left);
    await feed(t, 20, 800);
    expect(service.state, WhoMotionState.active);
    await close(t);
  });
  testWidgets('Arka plan kapatır; Devam/Hazırım sensörü beklemeden açar', (
    t,
  ) async {
    await open(t);
    await tap(t, 'Hazırım');
    await feed(t, 0, 800);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await t.pump();
    expect(getSession().phase, WhoPhase.paused);
    expect(service.state, WhoMotionState.idle);
    expect(find.byKey(const ValueKey('who-active-card')), findsNothing);
    expect(cancels, 1);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await t.pumpAndSettle();
    await tap(t, 'Devam Et');
    await tap(t, 'Hazırım');
    expect(getSession().phase, WhoPhase.playing);
    expect(service.state, WhoMotionState.calibrating);
    expect(listens, 2);
    await close(t);
    expect(cancels, 2);
  });
  testWidgets(
    'Bozuk sensör veya kararsız referans oyunu kesmez, sonra toparlar',
    (t) async {
      await open(t);
      await tap(t, 'Hazırım');
      stream.addError(StateError('no sensor'));
      await t.pumpAndSettle();
      expect(service.state, WhoMotionState.unavailable);
      expect(getSession().phase, WhoPhase.playing);
      await feed(t, 0, 800);
      expect(service.state, WhoMotionState.active);
      now += const Duration(seconds: 1);
      await t.pump(const Duration(seconds: 1));
      expect(getSession().remaining.inSeconds, lessThan(90));
      await close(t);
    },
  );
  testWidgets('Dokunmatik alternatif sensör aboneliği açmaz', (t) async {
    await open(t);
    await tap(t, 'Dokunmatik Devam Et');
    expect(getSession().phase, WhoPhase.playing);
    expect(listens, 0);
    await tap(t, 'Doğru +1');
    expect(getSession().correct, 1);
    await close(t);
  });
  testWidgets(
    'Tur kalibrasyonda biterse veya çıkılırsa geç olay oyunu açamaz',
    (t) async {
      await open(t);
      await tap(t, 'Hazırım');
      now += const Duration(seconds: 91);
      c.read(whoSessionProvider.notifier).tick();
      await t.pumpAndSettle();
      expect(service.state, WhoMotionState.idle);
      await feed(t, 0, 1000);
      expect(getSession().phase, WhoPhase.roundResult);
      await close(t);
    },
  );
  for (final dark in [false, true]) {
    testWidgets('Küçük ekran 2x yazı ve debug paneli kelimeyi kapatmaz $dark', (
      t,
    ) async {
      await open(t, dark: dark, size: const Size(320, 568), scale: 2);
      await tap(t, 'Hazırım');
      expect(getSession().phase, WhoPhase.playing);
      expect(find.byKey(const ValueKey('who-motion-debug')), findsNothing);
      expect(find.textContaining('ACC'), findsNothing);
      expect(find.textContaining('GYR'), findsNothing);
      expect(
        find.widgetWithText(FilledButton, 'Pas').hitTestable(),
        findsOneWidget,
      );
      expect(t.takeException(), isNull);
      await close(t);
    });
  }
  testWidgets('Gecikmiş ikinci Hazırım sensörü tekrar başlatamaz', (t) async {
    await open(t);
    final old =
        t
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Hazırım'))
            .onPressed!;
    old();
    await t.pumpAndSettle();
    await feed(t, 0, 800);
    expect(service.state, WhoMotionState.active);
    expect(listens, 1);
    old();
    await t.pump();
    expect(listens, 1);
    expect(service.state, WhoMotionState.active);
    await close(t);
  });
  testWidgets('Eski dokunmatik devam çağrısı aktif sensörü kapatamaz', (
    t,
  ) async {
    await open(t);
    final old =
        t
            .widget<TextButton>(
              find.widgetWithText(TextButton, 'Dokunmatik Devam Et'),
            )
            .onPressed!;
    await tap(t, 'Hazırım');
    await feed(t, 0, 800);
    old();
    await t.pump();
    expect(service.state, WhoMotionState.active);
    expect(cancels, 0);
    await close(t);
  });
  testWidgets(
    'Çıkış/dispose sonrası timer, gyro ve ivme aboneliği temiz; eski callback güvenli',
    (t) async {
      await open(t);
      final old =
          t
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Hazırım'),
              )
              .onPressed!;
      await tap(t, 'Hazırım');
      await feed(t, 0, 1100);
      final correct =
          t
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Doğru +1'),
              )
              .onPressed!;
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      await tap(t, 'Çık');
      expect(service.state, WhoMotionState.idle);
      expect(stream.hasListener, isFalse);
      expect(gyro.hasListener, isFalse);
      old();
      correct();
      await feed(t, 55, 1000);
      await t.pump(const Duration(minutes: 2));
      expect(c.read(whoSessionProvider), isNull);
      expect(t.takeException(), isNull);
      await close(t);
    },
  );
  testWidgets('Hızlı geri iki ayrı onay penceresi açmaz', (t) async {
    await open(t);
    await tap(t, 'Hazırım');
    await t.binding.handlePopRoute();
    await t.pump();
    await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(find.byType(AlertDialog).evaluate().length, lessThanOrEqualTo(1));
    expect(getSession().phase, WhoPhase.paused);
    expect(service.state, WhoMotionState.idle);
    await close(t);
  });
}
