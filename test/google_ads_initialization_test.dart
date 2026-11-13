import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// Use the SDK's channel codec to return its native initialization response.
// ignore: implementation_imports
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:oynika/core/ads/google_ads_backend.dart';

class _Backend extends GoogleAdsBackend {
  _Backend(this.ios) : super(['test-device']);
  final bool ios;

  @override
  bool get isIOS => ios;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  Completer<void>? privacyGate;
  var failPrivacy = false;

  setUp(() {
    calls.clear();
    privacyGate = null;
    failPrivacy = false;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messenger.setMockMethodCallHandler(instanceManager.channel, (call) async {
      // Plugin channel bootstrap is separate from Mobile Ads SDK initialization.
      if (call.method == '_init') return null;
      calls.add(call);
      if (call.method == 'MobileAds#setSameAppKeyEnabled') {
        if (failPrivacy) throw PlatformException(code: 'configuration-failed');
        await privacyGate?.future;
      }
      if (call.method == 'MobileAds#initialize') {
        return InitializationStatus(<String, AdapterStatus>{});
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(instanceManager.channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  test(
    'iOS awaits first-party ID opt-out before configuration and initialization',
    () async {
      privacyGate = Completer<void>();
      final pending = _Backend(true).initialize();
      await Future<void>.delayed(Duration.zero);
      expect(calls.map((c) => c.method), ['MobileAds#setSameAppKeyEnabled']);
      expect(calls.single.arguments, {'isEnabled': false});
      privacyGate!.complete();
      await pending;
      expect(calls.map((c) => c.method), [
        'MobileAds#setSameAppKeyEnabled',
        'MobileAds#updateRequestConfiguration',
        'MobileAds#initialize',
      ]);
    },
  );

  test('Android does not change first-party ID configuration', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await _Backend(false).initialize();
    expect(calls.map((c) => c.method), [
      'MobileAds#updateRequestConfiguration',
      'MobileAds#initialize',
    ]);
  });

  test(
    'failed privacy configuration blocks SDK initialization and can retry',
    () async {
      final backend = _Backend(true);
      failPrivacy = true;
      await expectLater(
        backend.initialize(),
        throwsA(isA<PlatformException>()),
      );
      expect(calls.map((c) => c.method), ['MobileAds#setSameAppKeyEnabled']);
      failPrivacy = false;
      calls.clear();
      await backend.initialize();
      expect(calls.first.method, 'MobileAds#setSameAppKeyEnabled');
      expect(calls.last.method, 'MobileAds#initialize');
    },
  );
}
