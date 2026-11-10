import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_units.dart';
import 'ads_service.dart';

final adsServiceProvider = Provider<AdsService>((ref) {
  const testDevices = String.fromEnvironment('OYNIKA_ADMOB_TEST_DEVICE_IDS');
  final backend = GoogleAdsBackend(
    testDevices
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList(),
  );
  // Flutter's visual platform can be overridden by tests and themes.
  final platform = kIsWeb
      ? null
      : Platform.isAndroid
      ? TargetPlatform.android
      : Platform.isIOS
      ? TargetPlatform.iOS
      : null;
  final service = AdsService(
    backend,
    platform == null
        ? null
        : interstitialAdUnitFor(
            platform,
            release: kReleaseMode,
            testMode:
                const bool.fromEnvironment('OYNIKA_ADS_TEST_MODE') ||
                backend.testDevices.isNotEmpty,
          ),
  );
  ref.onDispose(service.dispose);
  return service;
});

void _logAdQa(String message) {
  if (kDebugMode) debugPrint('OynikaAds: $message');
}

class GoogleAdsBackend implements AdsBackend {
  GoogleAdsBackend(this.testDevices);
  final List<String> testDevices;

  @override
  Future<void> updateConsent() {
    const forceEea = kDebugMode && bool.fromEnvironment('OYNIKA_UMP_DEBUG_EEA');
    final result = Completer<void>();
    _logAdQa('UMP update started (EEA override: $forceEea)');
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(
        consentDebugSettings: testDevices.isEmpty && !forceEea
            ? null
            : ConsentDebugSettings(
                testIdentifiers: testDevices,
                debugGeography: forceEea
                    ? DebugGeography.debugGeographyEea
                    : null,
              ),
      ),
      () {
        _logAdQa('UMP update succeeded');
        result.complete();
      },
      (error) {
        _logAdQa(
          'UMP update failed (code ${error.errorCode}): ${error.message}',
        );
        result.completeError(error);
      },
    );
    return result.future;
  }

  @override
  Future<void>
  showConsentIfRequired() => ConsentForm.loadAndShowConsentFormIfRequired((
    error,
  ) {
    if (error != null) {
      _logAdQa(
        'UMP startup form failed (code ${error.errorCode}): ${error.message}',
      );
      throw error;
    }
    _logAdQa('UMP startup form flow completed');
  });

  @override
  Future<bool> privacyOptionsRequired() async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    _logAdQa('UMP privacy options: ${status.name}');
    return status == PrivacyOptionsRequirementStatus.required;
  }

  @override
  Future<void> showPrivacyOptions() => ConsentForm.showPrivacyOptionsForm((
    error,
  ) {
    if (error != null) {
      _logAdQa(
        'UMP privacy form failed (code ${error.errorCode}): ${error.message}',
      );
      throw error;
    }
    _logAdQa('UMP privacy form completed');
  });

  @override
  Future<bool> canRequestAds() async {
    final allowed = await ConsentInformation.instance.canRequestAds();
    _logAdQa('UMP canRequestAds(): $allowed');
    return allowed;
  }

  @override
  Future<void> initialize() async {
    if (testDevices.isNotEmpty) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: testDevices),
      );
    }
    await MobileAds.instance.initialize();
  }

  @override
  Future<InterstitialPlacement?> loadInterstitial(String unit) async {
    final result = Completer<InterstitialPlacement?>();
    try {
      await InterstitialAd.load(
        adUnitId: unit,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _logAdQa('Interstitial loaded');
            if (result.isCompleted) {
              _disposeAd(ad);
            } else {
              result.complete(_GoogleInterstitial(ad));
            }
          },
          onAdFailedToLoad: (error) {
            _logAdQa('Interstitial load failed (code ${error.code})');
            if (!result.isCompleted) result.complete(null);
          },
        ),
      ).timeout(const Duration(seconds: 15));
      return await result.future.timeout(const Duration(seconds: 15));
    } catch (_) {
      if (result.isCompleted) {
        (await result.future)?.dispose();
      } else {
        result.complete(null);
      }
      return null;
    }
  }
}

void _disposeAd(Ad ad) => unawaited(ad.dispose().catchError((Object _) {}));

class _GoogleInterstitial implements InterstitialPlacement {
  _GoogleInterstitial(this.ad);
  final InterstitialAd ad;

  @override
  Future<void> show() async {
    final done = Completer<void>();
    void finish() {
      if (!done.isCompleted) done.complete();
    }

    final watchdog = Timer(const Duration(seconds: 5), finish);
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _logAdQa('Interstitial shown');
        watchdog.cancel();
      },
      onAdDismissedFullScreenContent: (_) {
        _logAdQa('Interstitial dismissed');
        finish();
      },
      onAdFailedToShowFullScreenContent: (_, error) {
        _logAdQa('Interstitial show failed (code ${error.code})');
        finish();
      },
    );
    try {
      unawaited(ad.show().catchError((Object _) => finish()));
      await done.future;
    } finally {
      watchdog.cancel();
    }
  }

  @override
  void dispose() => _disposeAd(ad);
}
