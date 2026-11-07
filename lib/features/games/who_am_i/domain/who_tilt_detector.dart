import 'dart:math' as math;

/// Natural device axes: accelerometer m/s² or gyroscope rad/s; native timestamp.
class WhoMotionSample {
  const WhoMotionSample(this.x, this.y, this.z, this.time);
  final double x, y, z;
  final Duration time;
  double get length => math.sqrt(x * x + y * y + z * z);
  bool get finite => x.isFinite && y.isFinite && z.isFinite;
}

enum WhoTiltDirection { forward, backward }

class WhoMotionTuning {
  static const triggerDegrees = 40.0, neutralDegrees = 15.0;
  static const neutralHold = Duration(milliseconds: 200);
  static const triggerHold = Duration(milliseconds: 80);
  static const calibrationHold = Duration(milliseconds: 600);
  static const feedback = Duration(milliseconds: 400);
  static const filterSeconds = .10;
}

/// Nod axis is device Y (the phone's long edge), independent of Flutter layout.
/// Integrates gyro around this axis, correcting drift with gravity when reliable.
class WhoTiltDetector {
  double? orientationHint;
  double? _neutral, _angle, _upSign;
  Duration? _lastAccel,
      _lastGyro,
      _neutralSince,
      _candidateSince,
      _blockedUntil;
  Duration? _otherRotationUntil;
  WhoTiltDirection? _candidate;
  bool _armed = false;
  bool get armed => _armed;
  bool get usesGyro =>
      _lastAccel != null &&
      _lastGyro != null &&
      (_lastAccel! - _lastGyro!).abs() < const Duration(milliseconds: 150);
  double get degrees => _angle ?? 0;
  double? get landscapeUpSign => _upSign;
  static double _wrap(double a) {
    while (a > 180) {
      a -= 360;
    }
    while (a < -180) {
      a += 360;
    }
    return a;
  }

  static bool valid(WhoMotionSample s) =>
      s.finite && s.length >= 7.8 && s.length <= 11.8;
  bool calibrate(List<WhoMotionSample> samples) {
    reset();
    if (samples.length < 8) return false;
    final x = samples.map((s) => s.x).reduce((a, b) => a + b) / samples.length;
    final y = samples.map((s) => s.y).reduce((a, b) => a + b) / samples.length;
    final z = samples.map((s) => s.z).reduce((a, b) => a + b) / samples.length;
    final g = math.sqrt(x * x + y * y + z * z);
    if (g < 7.8 || g > 11.8) return false;
    for (final s in samples) {
      if (!valid(s) ||
          math.sqrt(
                math.pow(s.x - x, 2) +
                    math.pow(s.y - y, 2) +
                    math.pow(s.z - z, 2),
              ) >
              1.2) {
        return false;
      }
    }
    // Gravity disambiguates the grip when possible; native display rotation is
    // only a sign hint when flat. It never supplies the measured motion angle.
    final sign = x.abs() / g > .25 ? x.sign : orientationHint;
    if (sign == null) return false;
    _upSign = sign;
    _neutral = math.atan2(-z, x * sign) * 180 / math.pi;
    _angle = 0;
    _lastAccel = samples.last.time;
    _armed = false;
    return true;
  }

  void reset() {
    _neutral = null;
    _angle = null;
    _upSign = null;
    _lastAccel = null;
    _lastGyro = null;
    _neutralSince = null;
    _candidateSince = null;
    _blockedUntil = null;
    _otherRotationUntil = null;
    _candidate = null;
    _armed = false;
  }

  void disarm(Duration time) {
    _armed = false;
    _neutralSince = null;
    _candidate = null;
    _candidateSince = null;
    _blockedUntil = time + WhoMotionTuning.feedback;
  }

  void gyro(WhoMotionSample s) {
    if (_neutral == null ||
        !s.finite ||
        (_lastGyro != null && s.time <= _lastGyro!)) {
      return;
    }
    final previous = _lastGyro;
    _lastGyro = s.time;
    if (previous == null) return;
    final dt = (s.time - previous).inMicroseconds / 1000000;
    if (dt <= 0 || dt > .15 || s.length > 15) return;
    if (s.x.abs() + s.z.abs() > s.y.abs() * 2 + .8) {
      _otherRotationUntil = s.time + const Duration(milliseconds: 300);
      disarm(s.time);
      return;
    }
    final rate = s.y.abs() < .025 ? 0.0 : s.y;
    _angle = _angle! - _upSign! * rate * dt * 180 / math.pi;
  }

  WhoTiltDirection? add(WhoMotionSample s) {
    if (_neutral == null || (_lastAccel != null && s.time <= _lastAccel!)) {
      return null;
    }
    final dt = (s.time - _lastAccel!).inMicroseconds / 1000000;
    _lastAccel = s.time;
    if (_otherRotationUntil != null && s.time < _otherRotationUntil!) {
      return null;
    }
    if (dt > .5) {
      _armed = false;
      _neutralSince = null;
      _candidate = null;
      _candidateSince = null;
      return null;
    }
    if (valid(s) && math.sqrt(s.x * s.x + s.z * s.z) > s.length * .3) {
      final gravityAngle = _wrap(
        math.atan2(-s.z, s.x * _upSign!) * 180 / math.pi - _neutral!,
      );
      final alpha =
          1 - math.exp(-dt / (usesGyro ? 1.5 : WhoMotionTuning.filterSeconds));
      _angle = _angle! + alpha * _wrap(gravityAngle - _angle!);
    } else if (!usesGyro) {
      return null;
    }
    // Linear acceleration does not reset a gyro-tracked gesture mid-motion.
    if (_blockedUntil != null && s.time < _blockedUntil!) return null;
    if (_angle!.abs() <= WhoMotionTuning.neutralDegrees) {
      _candidate = null;
      _candidateSince = null;
      _neutralSince ??= s.time;
      if (s.time - _neutralSince! >= WhoMotionTuning.neutralHold) _armed = true;
      return null;
    }
    _neutralSince = null;
    if (!_armed ||
        _angle!.abs() < WhoMotionTuning.triggerDegrees ||
        _angle!.abs() > 100) {
      _candidate = null;
      _candidateSince = null;
      return null;
    }
    final direction =
        _angle! > 0 ? WhoTiltDirection.forward : WhoTiltDirection.backward;
    if (_candidate != direction) {
      _candidate = direction;
      _candidateSince = s.time;
      return null;
    }
    if (s.time - _candidateSince! < WhoMotionTuning.triggerHold) return null;
    disarm(s.time);
    return direction;
  }
}
