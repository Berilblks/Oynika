import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../domain/who_tilt_detector.dart';
import 'who_motion_service.dart';

final whoMotionPreferredProvider = Provider<bool>((ref) => true);
final whoMotionFactoryProvider = Provider<WhoMotionService Function()>(
  (ref) => () {
    final watch = Stopwatch()..start();
    return WhoMotionService(
      clock: () => watch.elapsed,
      source:
          () => accelerometerEventStream(
            samplingPeriod: const Duration(milliseconds: 20),
          ).map(
            (s) => WhoMotionSample(
              s.x,
              s.y,
              s.z,
              Duration(microseconds: s.timestamp.microsecondsSinceEpoch),
            ),
          ),
      gyroSource:
          () => gyroscopeEventStream(
            samplingPeriod: const Duration(milliseconds: 20),
          ).map(
            (s) => WhoMotionSample(
              s.x,
              s.y,
              s.z,
              Duration(microseconds: s.timestamp.microsecondsSinceEpoch),
            ),
          ),
      readUpSign:
          () async =>
              (await const MethodChannel(
                'oynika/who_motion',
              ).invokeMethod<num>('landscapeUpSign'))?.toDouble(),
    );
  },
);
