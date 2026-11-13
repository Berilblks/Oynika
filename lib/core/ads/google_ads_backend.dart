import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_units.dart';
import 'ads_service.dart';
import 'ads_diagnostics.dart';

final adsServiceProvider = Provider<AdsService>((ref) {
  const testDevices = String.fromEnvironment('OYNIKA_ADMOB_TEST_DEVICE_IDS');
  final qa = ref.watch(adsQaEnabledProvider);
  final diagnostics = qa ? AdsDiagnostics() : null;
  if (diagnostics != null) ref.onDispose(diagnostics.dispose);
  final backend = GoogleAdsBackend(
    testDevices
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList(),
    diagnostics: diagnostics,
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
            qa: qa,
            testMode:
                const bool.fromEnvironment('OYNIKA_ADS_TEST_MODE') ||
                backend.testDevices.isNotEmpty,
          ),
    qaEnabled: qa,
    diagnostics: diagnostics,
  );
  ref.onDispose(service.dispose);
  return service;
});

void _logAdQa(String message) {
  if (kDebugMode) debugPrint('OynikaAds: $message');
}

class GoogleAdsBackend implements AdsBackend {
  GoogleAdsBackend(this.testDevices, {this.diagnostics});
  final AdsDiagnostics? diagnostics;
  final List<String> testDevices;

  @visibleForTesting
  bool get isIOS => Platform.isIOS;

  @override
  Future<void> updateConsent() {
    const forceEea = kDebugMode && bool.fromEnvironment('OYNIKA_UMP_DEBUG_EEA');
    final result = Completer<void>();
    _logAdQa('UMP update started (EEA override: $forceEea)');
    diagnostics?.set(AdQaField.umpUpdate, 'Güncelleniyor');
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
        diagnostics?.set(AdQaField.umpUpdate, 'Başarılı');
        result.complete();
      },
      (error) {
        final safe = safeAdError('UMP', error.errorCode, error.message);
        _logAdQa('UMP update failed: $safe');
        diagnostics?.set(AdQaField.umpUpdate, 'Başarısız — $safe');
        result.completeError(error);
      },
    );
    return result.future;
  }

  @override
  Future<void> showConsentIfRequired() =>
      ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) {
          final safe = safeAdError('UMP', error.errorCode, error.message);
          _logAdQa('UMP startup form failed: $safe');
          diagnostics?.event('UMP formu tamamlanamadı — $safe');
          throw error;
        }
        _logAdQa('UMP startup form flow completed');
      });

  @override
  Future<bool> privacyOptionsRequired() async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    _logAdQa('UMP privacy options: ${status.name}');
    diagnostics?.set(AdQaField.privacyOptions, status.name);
    if (diagnostics != null) {
      try {
        final consent = await ConsentInformation.instance
            .getConsentStatus()
            .timeout(const Duration(seconds: 2));
        diagnostics?.set(AdQaField.consent, consent.name);
      } catch (_) {
        diagnostics?.set(AdQaField.consent, 'Sorgulanamadı');
      }
    }
    return status == PrivacyOptionsRequirementStatus.required;
  }

  @override
  Future<void> showPrivacyOptions() =>
      ConsentForm.showPrivacyOptionsForm((error) {
        if (error != null) {
          final safe = safeAdError('UMP', error.errorCode, error.message);
          _logAdQa('UMP privacy form failed: $safe');
          diagnostics?.event('Gizlilik formu tamamlanamadı — $safe');
          throw error;
        }
        _logAdQa('UMP privacy form completed');
      });

  @override
  Future<bool> canRequestAds() async {
    final allowed = await ConsentInformation.instance.canRequestAds();
    _logAdQa('UMP canRequestAds(): $allowed');
    diagnostics?.set(AdQaField.canRequest, '$allowed');
    return allowed;
  }

  @override
  Future<void> initialize() async {
    if (isIOS) {
      try {
        await MobileAds.instance.setSameAppKeyEnabled(false);
      } catch (_) {
        _logAdQa('Publisher first-party ID configuration failed');
        diagnostics?.event('iOS reklam gizlilik yapılandırması tamamlanamadı');
        // Do not initialize or request ads with an unconfirmed privacy setting.
        // AdsService catches this failure and permits a later controlled retry.
        rethrow;
      }
    }
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
        request: Platform.isIOS
            ? const AdRequest(nonPersonalizedAds: true)
            : const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _logAdQa('Interstitial loaded');
            if (result.isCompleted) {
              _disposeAd(ad);
            } else {
              result.complete(_GoogleInterstitial(ad, diagnostics));
            }
          },
          onAdFailedToLoad: (error) {
            final safe = safeAdError(error.domain, error.code, error.message);
            _logAdQa('Interstitial load failed: $safe');
            diagnostics?.set(AdQaField.loadError, safe);
            if (!result.isCompleted) result.complete(null);
          },
        ),
      ).timeout(const Duration(seconds: 15));
      return await result.future.timeout(const Duration(seconds: 15));
    } catch (error) {
      diagnostics?.set(
        AdQaField.loadError,
        safeAdError(
          error is TimeoutException ? 'timeout' : 'platform',
          null,
          error is TimeoutException ? 'timeout' : 'SDK failed',
        ),
      );
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
  _GoogleInterstitial(this.ad, this.diagnostics);
  final AdsDiagnostics? diagnostics;
  final InterstitialAd ad;

  @override
  Future<void> show() async {
    final done = Completer<void>();
    void finish() {
      if (!done.isCompleted) done.complete();
    }

    void fail() {
      if (!done.isCompleted) {
        done.completeError(StateError('Ad presentation failed'));
      }
    }

    final watchdog = Timer(const Duration(seconds: 5), () {
      diagnostics?.event('Gösterim zaman aşımı');
      fail();
    });
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _logAdQa('Interstitial shown');
        diagnostics?.event('Reklam gösterildi');
        watchdog.cancel();
      },
      onAdDismissedFullScreenContent: (_) {
        _logAdQa('Interstitial dismissed');
        diagnostics?.event('Reklam kapatıldı');
        finish();
      },
      onAdFailedToShowFullScreenContent: (_, error) {
        final safe = safeAdError(error.domain, error.code, error.message);
        _logAdQa('Interstitial show failed: $safe');
        diagnostics?.event('Gösterim hatası — $safe');
        fail();
      },
    );
    try {
      unawaited(ad.show().catchError((Object _) => fail()));
      await done.future;
    } finally {
      watchdog.cancel();
    }
  }

  @override
  void dispose() => _disposeAd(ad);
}
