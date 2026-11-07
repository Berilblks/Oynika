import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:oynika/features/games/who_am_i/domain/who_tilt_detector.dart';

WhoMotionSample sample(
  double angle,
  int ms, {
  double sign = 1,
  double g = 9.81,
}) => WhoMotionSample(
  sign * g * math.cos(angle * math.pi / 180),
  0,
  -g * math.sin(angle * math.pi / 180),
  Duration(milliseconds: ms),
);

class TiltHarness {
  final detector = WhoTiltDetector();
  int ms = 0;
  final events = <WhoTiltDirection>[];
  void calibrate({double sign = 1, double angle = 0}) {
    final window = [
      for (var i = 0; i < 20; i++) sample(angle, ms += 40, sign: sign),
    ];
    expect(detector.calibrate(window), isTrue);
  }

  void hold(double angle, int duration, {double sign = 1}) {
    for (var i = 0; i < duration; i += 20) {
      final result = detector.add(sample(angle, ms += 20, sign: sign));
      if (result != null) events.add(result);
    }
  }
}

void main() {
  for (final sign in [1.0, -1.0]) {
    test('Nötr kalibrasyon ve öne/arkaya eşlemesi: landscape $sign', () {
      final h = TiltHarness()..calibrate(sign: sign);
      expect(h.detector.landscapeUpSign, sign);
      h.hold(0, 300, sign: sign);
      h.hold(55, 600, sign: sign);
      expect(h.events, [WhoTiltDirection.forward]);
      h.hold(55, 1200, sign: sign);
      h.hold(-55, 600, sign: sign);
      expect(h.events.length, 1);
      h.hold(0, 800, sign: sign);
      h.hold(-55, 600, sign: sign);
      expect(h.events, [WhoTiltDirection.forward, WhoTiltDirection.backward]);
    });
  }
  test('Nötr referans mutlak cihaz açısı değildir', () {
    final h = TiltHarness()..calibrate(angle: 12);
    h.hold(12, 300);
    h.hold(50, 800);
    expect(h.events, isEmpty);
    h.hold(65, 500);
    expect(h.events, [WhoTiltDirection.forward]);
  });
  test('Titreme, küçük hareket ve tek örnek gürültüsü puan üretmez', () {
    final h = TiltHarness()..calibrate();
    h.hold(0, 300);
    for (var i = 0; i < 30; i++) {
      h.hold(i.isEven ? 10 : -10, 40);
    }
    h.hold(80, 20);
    h.hold(0, 500);
    expect(h.events, isEmpty);
  });
  test(
    'Sabit ivme değil yerçekimi açısı; darbe ve geçersiz veri reddedilir',
    () {
      final h = TiltHarness()..calibrate();
      h.hold(0, 300);
      expect(h.detector.add(sample(60, h.ms += 20, g: 25)), isNull);
      expect(
        h.detector.add(
          WhoMotionSample(double.nan, 0, 0, Duration(milliseconds: h.ms += 20)),
        ),
        isNull,
      );
      h.hold(55, 600);
      expect(h.events.length, 1);
      h.hold(0, 800);
      h.hold(55, 600);
      expect(h.events.length, 2);
    },
  );
  test(
    'Kalibrasyon düz masa, portrait, oynak veya eksik örneği kabul etmez',
    () {
      final d = WhoTiltDetector();
      expect(d.calibrate([sample(0, 0)]), isFalse);
      expect(
        d.calibrate([for (var i = 0; i < 20; i++) sample(90, i * 40)]),
        isFalse,
      );
      expect(
        d.calibrate([
          for (var i = 0; i < 20; i++)
            WhoMotionSample(0, 9.81, 0, Duration(milliseconds: i * 40)),
        ]),
        isFalse,
      );
      expect(
        d.calibrate([
          for (var i = 0; i < 20; i++) sample(i.isEven ? 20 : -20, i * 40),
        ]),
        isFalse,
      );
    },
  );
  test('Nötr kararlılığı ve histerezis olmadan tekrar yok', () {
    final h = TiltHarness()..calibrate();
    h.hold(0, 300);
    h.hold(55, 600);
    h.hold(0, 180);
    h.hold(55, 600);
    expect(h.events.length, 1);
    h.hold(0, 800);
    h.hold(55, 600);
    expect(h.events.length, 2);
  });
  test('Dokunmatik cevap da hareket mandalını kapatır', () {
    final h = TiltHarness()..calibrate();
    h.hold(0, 300);
    h.detector.disarm(Duration(milliseconds: h.ms));
    h.hold(55, 600);
    expect(h.events, isEmpty);
    h.hold(0, 800);
    h.hold(55, 600);
    expect(h.events.length, 1);
  });
  test('Eski veya aynı zaman damgası ve reset hareketi tetiklemez', () {
    final h = TiltHarness()..calibrate();
    h.hold(0, 300);
    expect(h.detector.add(sample(80, 10)), isNull);
    h.detector.reset();
    h.hold(55, 1000);
    expect(h.events, isEmpty);
  });
  for (final sign in [1.0, -1.0]) {
    test(
      'Gyro Y göreli açı: doğrusal ivme altında hareket kaybolmaz $sign',
      () {
        final h = TiltHarness()..calibrate(sign: sign);
        h.hold(0, 300, sign: sign);
        h.detector.gyro(WhoMotionSample(0, 0, 0, Duration(milliseconds: h.ms)));
        for (var i = 0; i < 30; i++) {
          h.ms += 20;
          h.detector.gyro(
            WhoMotionSample(
              0,
              i < 20 ? -sign * 2.4 : 0,
              0,
              Duration(milliseconds: h.ms),
            ),
          );
          final event = h.detector.add(sample(0, h.ms, g: 18, sign: sign));
          if (event != null) h.events.add(event);
        }
        expect(h.detector.usesGyro, isTrue);
        expect(h.events, [WhoTiltDirection.forward]);
      },
    );
  }
  test(
    'Düz konum fiziksel yön ipucuyla kabul edilir ve referans sıfırlanabilir',
    () {
      final d = WhoTiltDetector()..orientationHint = -1;
      expect(
        d.calibrate([for (var i = 0; i < 20; i++) sample(90, i * 40)]),
        isTrue,
      );
      expect(d.landscapeUpSign, -1);
      expect(d.degrees, 0);
    },
  );
}
