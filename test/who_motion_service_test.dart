import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/features/games/who_am_i/application/who_motion_service.dart';
import 'package:oynika/features/games/who_am_i/domain/who_tilt_detector.dart';

class MotionHarness {
  MotionHarness() {
    stream = StreamController<WhoMotionSample>.broadcast(
      sync: true,
      onListen: () => listens++,
      onCancel: () => cancels++,
    );
    gyro = StreamController<WhoMotionSample>.broadcast(
      sync: true,
      onCancel: () => gyroCancels++,
    );
    service = WhoMotionService(
      source: () => stream.stream,
      gyroSource: () => gyro.stream,
      readUpSign: () async => 1,
      clock: () => now,
    );
  }
  late final StreamController<WhoMotionSample> stream, gyro;
  late final WhoMotionService service;
  var now = Duration.zero;
  int listens = 0, cancels = 0, gyroCancels = 0;
  Future<void> feed(
    WidgetTester t,
    double angle,
    int ms, {
    double sign = 1,
  }) async {
    for (var i = 0; i < ms; i += 20) {
      now += const Duration(milliseconds: 20);
      stream.add(
        WhoMotionSample(
          sign * 9.81 * math.cos(angle * math.pi / 180),
          0,
          -9.81 * math.sin(angle * math.pi / 180),
          now + const Duration(seconds: 100),
        ),
      );
      await t.pump(const Duration(milliseconds: 20));
    }
  }

  void close() {
    service.dispose();
    unawaited(stream.close());
    unawaited(gyro.close());
  }
}

void main() {
  testWidgets(
    'Gecikmiş ilk paket taze referansı engellemez; geçmiş paket tek başına aktive etmez',
    (t) async {
      final h = MotionHarness();
      addTearDown(h.close);
      h.service.startAutomatic();
      h.now = const Duration(seconds: 2);
      for (var ms = 100000; ms <= 101000; ms += 20) {
        h.stream.add(WhoMotionSample(9.81, 0, 0, Duration(milliseconds: ms)));
      }
      await t.pump();
      expect(h.service.state, WhoMotionState.calibrating);
      await h.feed(t, 0, 800);
      expect(h.service.state, WhoMotionState.active);
      h.close();
    },
  );
  for (final sign in [1.0, -1.0]) {
    testWidgets('Otomatik referans ve sensör olayı callback: $sign', (t) async {
      final h = MotionHarness();
      addTearDown(h.close);
      h.service.startAutomatic();
      final events = <WhoTiltDirection>[];
      h.service.onTilt = events.add;
      await h.feed(t, 0, 1100, sign: sign);
      expect(h.service.state, WhoMotionState.active);
      await h.feed(t, 55, 500, sign: sign);
      expect(events, [WhoTiltDirection.forward]);
      await h.feed(t, 55, 1000, sign: sign);
      expect(events.length, 1);
      await h.feed(t, 0, 800, sign: sign);
      await h.feed(t, -55, 500, sign: sign);
      expect(events.last, WhoTiltDirection.backward);
      h.close();
    });
  }
  testWidgets(
    'Sensör geç başlarsa otomatik toparlar; oyunla ilgili bekleyen Future yok',
    (t) async {
      final h = MotionHarness();
      addTearDown(h.close);
      h.service.startAutomatic();
      h.now += const Duration(seconds: 5);
      await t.pump(const Duration(seconds: 5));
      expect(h.service.state, WhoMotionState.unavailable);
      await h.feed(t, 0, 800);
      expect(h.service.state, WhoMotionState.active);
      h.close();
    },
  );
  testWidgets('Masa üzerinde de referans oluşur; konum önkoşulu yok', (
    t,
  ) async {
    final h = MotionHarness();
    addTearDown(h.close);
    h.service.startAutomatic();
    await t.pump();
    await h.feed(t, -90, 1000);
    expect(h.service.state, WhoMotionState.active);
    h.close();
  });
  testWidgets(
    'Hatalı ilk konum referansı turu durdurmadan yeniden örneklenebilir',
    (t) async {
      final h = MotionHarness();
      addTearDown(h.close);
      h.service.startAutomatic();
      await h.feed(t, 0, 800);
      h.service.resetReference();
      await h.feed(t, 25, 800);
      expect(h.service.state, WhoMotionState.active);
      expect(h.service.detector.degrees.abs(), lessThan(1));
      expect(h.listens, 1);
      h.close();
    },
  );
  testWidgets('Gyro aktarımı, eksik gyro fallback ve hata panel durumu', (
    t,
  ) async {
    final h = MotionHarness();
    addTearDown(h.close);
    h.service.startAutomatic();
    await h.feed(t, 0, 800);
    h.gyro.add(WhoMotionSample(0, 0, 0, h.now + const Duration(seconds: 100)));
    await t.pump();
    expect(h.service.gyroReceived, 1);
    h.gyro.addError(StateError('no gyro'));
    await t.pump();
    expect(h.service.state, WhoMotionState.active);
    expect(h.service.diagnostics, contains('ACC'));
    h.stream.addError(StateError('no accelerometer'));
    await t.pump();
    expect(h.service.state, WhoMotionState.unavailable);
    h.close();
  });
  testWidgets(
    'Stop/dispose iki aboneliği temizler, eski tur verisi uygulanmaz',
    (t) async {
      final h = MotionHarness();
      addTearDown(h.close);
      h.service.startAutomatic();
      await h.feed(t, 0, 800);
      final events = <WhoTiltDirection>[];
      h.service.onTilt = events.add;
      h.service.stop();
      expect(h.cancels, 1);
      expect(h.gyroCancels, 1);
      await h.feed(t, 55, 800);
      expect(events, isEmpty);
      h.service.startAutomatic();
      await h.feed(t, 0, 800);
      expect(h.listens, 2);
      h.close();
      expect(h.cancels, 2);
    },
  );
  testWidgets('Sırası bozuk ve gecikmiş örneklerin elendiği ölçülebilir', (
    t,
  ) async {
    final h = MotionHarness();
    addTearDown(h.close);
    h.service.startAutomatic();
    await h.feed(t, 0, 800);
    h.stream.add(const WhoMotionSample(5, 0, -8, Duration(seconds: 100)));
    h.now += const Duration(milliseconds: 400);
    h.stream.add(
      const WhoMotionSample(5, 0, -8, Duration(milliseconds: 100820)),
    );
    await t.pump();
    expect(h.service.rejected, 2);
    h.close();
  });
  testWidgets('Landscape tutuşu değişince otomatik yeniden referans oluşur', (
    t,
  ) async {
    final h = MotionHarness();
    addTearDown(h.close);
    h.service.startAutomatic();
    await h.feed(t, 0, 800);
    await h.feed(t, 0, 1000, sign: -1);
    expect(h.service.state, WhoMotionState.active);
    expect(h.service.detector.landscapeUpSign, -1);
    h.close();
  });
}
