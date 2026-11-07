import 'dart:async';
import '../domain/who_tilt_detector.dart';

enum WhoMotionState { idle, calibrating, active, unavailable, unstable }

class _Timeline {
  Duration? last, offset;
  bool accept(WhoMotionSample s, Duration arrival) {
    if (last != null && s.time <= last!) return false;
    final observed = arrival - s.time;
    if (offset == null || observed < offset!) offset = observed;
    if (arrival - (s.time + offset!) > const Duration(milliseconds: 250)) {
      return false;
    }
    last = s.time;
    return true;
  }
}

/// Nonblocking reference acquisition; game timing is owned by WhoController.
class WhoMotionService {
  WhoMotionService({
    required this.source,
    required this.clock,
    this.gyroSource,
    this.readUpSign,
  });
  final Stream<WhoMotionSample> Function() source;
  final Stream<WhoMotionSample> Function()? gyroSource;
  final Future<double?> Function()? readUpSign;
  final Duration Function() clock;
  final detector = WhoTiltDetector();
  WhoMotionState state = WhoMotionState.idle;
  void Function()? onChanged;
  void Function(WhoTiltDirection)? onTilt;
  StreamSubscription<WhoMotionSample>? _accel, _gyro;
  Timer? _watchdog;
  int _epoch = 0, received = 0, rejected = 0, gyroReceived = 0;
  WhoMotionSample? latest, latestGyro;
  WhoTiltDirection? lastDirection;
  String lastAction = '—';
  Duration? _lastArrival, _started, _lastNotice, _windowStart, _windowArrival;
  final _window = <WhoMotionSample>[];
  bool _running = false;
  void _notify({bool force = false}) {
    if (force ||
        _lastNotice == null ||
        clock() - _lastNotice! >= const Duration(milliseconds: 100)) {
      _lastNotice = clock();
      onChanged?.call();
    }
  }

  void _set(WhoMotionState value) {
    state = value;
    _notify(force: true);
  }

  void _clearWindow() {
    _window.clear();
    _windowStart = null;
    _windowArrival = null;
  }

  void startAutomatic() {
    stop();
    final epoch = ++_epoch;
    _running = true;
    _started = clock();
    _lastArrival = null;
    received = 0;
    rejected = 0;
    gyroReceived = 0;
    latest = null;
    latestGyro = null;
    lastDirection = null;
    lastAction = '—';
    _clearWindow();
    detector.reset();
    detector.orientationHint = null;
    final timeline = _Timeline(), gyroTimeline = _Timeline();
    _set(WhoMotionState.calibrating);
    if (readUpSign != null) {
      unawaited(() async {
        try {
          final sign = await readUpSign!();
          if (epoch == _epoch && (sign == 1 || sign == -1)) {
            detector.orientationHint = sign;
          }
        } catch (_) {}
      }());
    }
    try {
      _accel = source().listen(
        (s) {
          if (epoch != _epoch) return;
          received++;
          latest = s;
          final arrival = clock();
          if (!timeline.accept(s, arrival)) {
            rejected++;
            _notify();
            return;
          }
          _lastArrival = arrival;
          if (state == WhoMotionState.unavailable) {
            _clearWindow();
            _set(WhoMotionState.calibrating);
          }
          // A complete change of landscape grip is a new reference, not a
          // gameplay pause. Ordinary nods keep the same upward X sign.
          if (state == WhoMotionState.active &&
              WhoTiltDetector.valid(s) &&
              s.x * detector.landscapeUpSign! < -s.length * .7 &&
              s.y.abs() < s.length * .35) {
            _clearWindow();
            detector.reset();
            _set(WhoMotionState.calibrating);
          }
          if (state == WhoMotionState.calibrating ||
              state == WhoMotionState.unstable) {
            if (!WhoTiltDetector.valid(s)) {
              _clearWindow();
              rejected++;
              _notify();
              return;
            }
            if (_window.isNotEmpty) {
              final a = _window.first;
              if ((s.x - a.x).abs() + (s.y - a.y).abs() + (s.z - a.z).abs() >
                  1.5) {
                _clearWindow();
              }
            }
            _windowStart ??= s.time;
            _windowArrival ??= arrival;
            _window.add(s);
            if (s.time - _windowStart! >= WhoMotionTuning.calibrationHold &&
                arrival - _windowArrival! >= WhoMotionTuning.calibrationHold &&
                detector.calibrate(_window)) {
              _clearWindow();
              _set(WhoMotionState.active);
            }
            // Bounded rolling sample window even while waiting for a rotation hint.
            if (_window.length > 100) {
              _window.removeAt(0);
              _windowStart = _window.first.time;
            }
          } else if (state == WhoMotionState.active) {
            final direction = detector.add(s);
            if (direction != null) {
              lastDirection = direction;
              onTilt?.call(direction);
              _notify(force: true);
            }
          }
          _notify();
        },
        onError: (Object _) {
          if (epoch == _epoch) _set(WhoMotionState.unavailable);
        },
        onDone: () {
          if (epoch == _epoch) _set(WhoMotionState.unavailable);
        },
      );
    } catch (_) {
      _set(WhoMotionState.unavailable);
    }
    if (gyroSource != null) {
      try {
        _gyro = gyroSource!().listen(
          (s) {
            if (epoch != _epoch) return;
            gyroReceived++;
            latestGyro = s;
            if (gyroTimeline.accept(s, clock()) &&
                state == WhoMotionState.active) {
              detector.gyro(s);
            }
            _notify();
          },
          onError: (Object _) {
            if (epoch == _epoch) {
              latestGyro = null;
              _notify(force: true);
            }
          },
        );
      } catch (_) {
        latestGyro = null;
      }
    }
    _watchdog = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (epoch != _epoch) return;
      if (clock() - (_lastArrival ?? _started!) > const Duration(seconds: 2)) {
        if (state != WhoMotionState.unavailable) {
          _set(WhoMotionState.unavailable);
        }
      } else if (state == WhoMotionState.calibrating &&
          clock() - _started! > const Duration(seconds: 4)) {
        _set(WhoMotionState.unstable);
      }
    });
  }

  void resetReference() {
    if (!_running || state == WhoMotionState.unavailable) {
      startAutomatic();
      return;
    }
    _clearWindow();
    detector.reset();
    _started = clock();
    _set(WhoMotionState.calibrating);
  }

  void afterAnswer(String action) {
    if (latest != null) detector.disarm(latest!.time);
    lastAction = action;
    _notify(force: true);
  }

  String get diagnostics {
    final a = latest, g = latestGyro;
    String xyz(WhoMotionSample? s) =>
        s == null
            ? '—'
            : '${s.x.toStringAsFixed(1)},${s.y.toStringAsFixed(1)},${s.z.toStringAsFixed(1)}';
    return '${state.name} • ACC $received / GYR $gyroReceived • elenen $rejected\nA[${xyz(a)}] G[${xyz(g)}] • ${detector.usesGyro ? 'füzyon' : 'yerçekimi'}\nAçı ${detector.degrees.toStringAsFixed(1)}° • nötr ${detector.armed ? 'açık' : 'kilitli'} • yön ${lastDirection?.name ?? '—'} • son $lastAction';
  }

  void stop() {
    _running = false;
    _epoch++;
    _watchdog?.cancel();
    _watchdog = null;
    for (final sub in [_accel, _gyro]) {
      if (sub != null) unawaited(sub.cancel().catchError((Object _) {}));
    }
    _accel = null;
    _gyro = null;
    detector.reset();
    onTilt = null;
    _set(WhoMotionState.idle);
  }

  void dispose() {
    onChanged = null;
    stop();
  }
}
