import 'dart:async';

import 'package:flutter/foundation.dart';

import 'ad_units.dart';
import 'ads_diagnostics.dart';

abstract interface class InterstitialPlacement {
  Future<void> show();
  void dispose();
}

abstract interface class AdsBackend {
  Future<void> updateConsent();
  Future<void> showConsentIfRequired();
  Future<bool> privacyOptionsRequired();
  Future<void> showPrivacyOptions();
  Future<bool> canRequestAds();
  Future<void> initialize();
  Future<InterstitialPlacement?> loadInterstitial(String unit);
}

typedef AdsStatus = ({bool ready, bool privacyOptions, bool busy});

class AdsService {
  AdsService(
    this._backend,
    this._interstitialUnit, {
    this.diagnostics,
    bool qaEnabled = false,
    this.retryCooldown = const Duration(seconds: 15),
  }) : qaEnabled =
           qaEnabled && isGoogleTestInterstitialUnit(_interstitialUnit) {
    diagnostics?.set(
      AdQaField.unitType,
      _interstitialUnit == null
          ? 'unsupported'
          : isGoogleTestInterstitialUnit(_interstitialUnit)
          ? 'test'
          : 'production',
    );
    diagnostics?.set(AdQaField.completed, '0');
    diagnostics?.set(AdQaField.initialization, 'Başlatılmadı');
    diagnostics?.set(AdQaField.load, 'Yüklenmedi');
    diagnostics?.set(AdQaField.loadError, 'Yok');
    diagnostics?.set(AdQaField.show, 'Henüz gösterim girişimi yok');
  }

  final AdsDiagnostics? diagnostics;
  final bool qaEnabled;
  final Duration retryCooldown;

  final AdsBackend _backend;
  final String? _interstitialUnit;
  final _status = ValueNotifier<AdsStatus>((
    ready: false,
    privacyOptions: false,
    busy: false,
  ));
  ValueListenable<AdsStatus> get status => _status;

  final _completions = Expando<int>();
  final _departed = Expando<bool>();
  final _adOpportunityUsed = Expando<bool>();
  int _completed = 0;
  int get completedGames => _completed;
  int _generation = 0;
  bool _disposed = false;
  bool _loading = false;
  bool _showing = false;
  Future<void>? _startup;
  Future<void>? _initialization;
  InterstitialPlacement? _interstitial;
  final _clock = Stopwatch()..start();
  Duration? _loadedAt;
  Duration? _lastConsentAttempt;
  int _automaticRetries = 0;

  bool get qaCanLoad =>
      qaEnabled && !_disposed && !_status.value.busy && !_loading && !_showing;
  bool get qaCanShow =>
      qaCanLoad && _status.value.ready && _interstitial != null;

  /// Explicit requests are rate limited. Resume retries are capped per session.
  Future<bool> retryConsent({bool automatic = false}) async {
    if (_disposed ||
        _status.value.busy ||
        _showing ||
        (automatic && (_status.value.ready || _automaticRetries >= 3)) ||
        (_lastConsentAttempt != null &&
            _clock.elapsed - _lastConsentAttempt! < retryCooldown)) {
      return false;
    }
    if (automatic) _automaticRetries++;
    return _refreshConsent();
  }

  Future<void> loadQaTestAd() async {
    if (!qaCanLoad) return;
    if (!_status.value.ready) {
      diagnostics?.set(
        AdQaField.load,
        'Önce rıza ve SDK durumunu yeniden dene',
      );
      return;
    }
    await _preload();
  }

  Future<void> showQaTestAd(bool Function() isCurrent) async {
    if (!qaCanShow || !isCurrent()) return;
    final generation = _generation;
    _showing = true;
    try {
      if (!await _backend.canRequestAds() ||
          !_valid(generation) ||
          !isCurrent()) {
        diagnostics?.set(
          AdQaField.show,
          'UMP veya ekran durumu gösterime izin vermedi',
        );
        _interstitial?.dispose();
        _interstitial = null;
        diagnostics?.set(
          AdQaField.load,
          'Gösterim uygunluğu yok; reklam bırakıldı',
        );
        _showing = false;
        return;
      }
      _discardExpired();
      final ad = _interstitial;
      if (ad == null) {
        diagnostics?.set(AdQaField.show, 'Hazır test reklamı yok');
        _showing = false;
        return;
      }
      _interstitial = null;
      await _show(ad, isCurrent, () {});
    } catch (_) {
      _showing = false;
      diagnostics?.set(AdQaField.show, 'Gösterim uygunluğu doğrulanamadı');
    } finally {
      _showing = false;
      diagnostics?.event('QA gösterim denemesi sona erdi');
    }
  }

  Future<void> start() => _startup ??= _refreshConsent();

  Future<bool> openPrivacyOptions() async {
    if (!_status.value.privacyOptions ||
        _status.value.busy ||
        _disposed ||
        _showing) {
      return false;
    }
    return _refreshConsent(privacy: true);
  }

  Future<bool> _refreshConsent({bool privacy = false}) async {
    if (_interstitialUnit == null || _disposed) return false;
    _lastConsentAttempt = _clock.elapsed;
    final generation = ++_generation;
    var privacyOptions = _status.value.privacyOptions;
    _interstitial?.dispose();
    _interstitial = null;
    diagnostics?.set(AdQaField.load, 'Hazır reklam yok');
    _status.value = (ready: false, privacyOptions: privacyOptions, busy: true);
    var ready = false;
    var success = false;
    try {
      if (privacy) {
        await _backend.showPrivacyOptions();
      } else {
        try {
          await _backend.updateConsent().timeout(const Duration(seconds: 15));
          if (_disposed) return false;
          await _backend.showConsentIfRequired();
        } catch (error) {
          if (error is TimeoutException) {
            diagnostics?.set(
              AdQaField.umpUpdate,
              'Zaman aşımı; önceki durum sorgulanıyor',
            );
          }
          // After a startup failure, UMP can still authorize ads using its
          // consent state from a previous session.
        }
      }
      if (_disposed) return false;
      privacyOptions = await _backend.privacyOptionsRequired();
      if (await _backend.canRequestAds() && !_disposed) {
        diagnostics?.set(AdQaField.initialization, 'Başlatılıyor');
        try {
          await (_initialization ??= _backend.initialize().timeout(
            const Duration(seconds: 20),
          ));
        } catch (_) {
          _initialization = null;
          diagnostics?.set(
            AdQaField.initialization,
            'Başarısız; yeniden denenebilir',
          );
          rethrow;
        }
        if (_disposed) return false;
        diagnostics?.set(AdQaField.initialization, 'Hazır');
        ready = true;
      }
      success = true;
    } catch (_) {
      // UMP and SDK failures are optional monetization failures.
    } finally {
      if (!_disposed && generation == _generation) {
        _status.value = (
          ready: ready,
          privacyOptions: privacyOptions,
          busy: false,
        );
        if (ready) unawaited(_preload());
      }
    }
    return success && !_disposed;
  }

  bool _valid(int generation) =>
      !_disposed && _status.value.ready && generation == _generation;

  Future<void> _preload() async {
    if (_disposed) return;
    _discardExpired();
    final generation = _generation;
    if (!_valid(generation) || _loading || _showing || _interstitial != null) {
      return;
    }
    _loading = true;
    try {
      if (!await _backend.canRequestAds() || !_valid(generation)) {
        diagnostics?.set(AdQaField.load, 'UMP reklam isteğine izin vermedi');
        return;
      }
      diagnostics?.set(AdQaField.load, 'Yükleniyor');
      final ad = await _backend.loadInterstitial(_interstitialUnit!);
      if (_valid(generation)) {
        _interstitial = ad;
        _loadedAt = _clock.elapsed;
        diagnostics?.set(AdQaField.load, ad == null ? 'Yüklenemedi' : 'Hazır');
      } else {
        ad?.dispose();
      }
    } catch (_) {
      diagnostics?.set(AdQaField.load, 'Yükleme tamamlanamadı');
      // Retry at a later completed game.
    } finally {
      _loading = false;
      diagnostics?.event('Yükleme denemesi tamamlandı');
      if (!_disposed && generation != _generation && _status.value.ready) {
        unawaited(_preload());
      }
    }
  }

  void recordCompletion(Object result) {
    if (_disposed || _completions[result] != null) return;
    _completions[result] = ++_completed;
    diagnostics?.set(AdQaField.completed, '$_completed');
    _discardExpired();
    unawaited(_preload());
  }

  void _discardExpired() {
    final loadedAt = _loadedAt;
    if (loadedAt != null &&
        _clock.elapsed - loadedAt >= const Duration(minutes: 55)) {
      _interstitial?.dispose();
      _interstitial = null;
      _loadedAt = null;
    }
  }

  // No asynchronous wait on the navigation path unless a loaded ad is shown.
  void leaveResult(
    Object result,
    bool Function() isCurrent,
    FutureOr<void> Function() leave,
  ) {
    if (_disposed || _showing || _departed[result] == true || !isCurrent()) {
      return;
    }
    recordCompletion(result);
    _discardExpired();
    _departed[result] = true;
    void continueExit() {
      final action = leave();
      if (action is Future<void>) {
        unawaited(
          action.whenComplete(() {
            // A native replay prerequisite can fail and leave the result visible.
            if (!_disposed && isCurrent()) _departed[result] = null;
          }),
        );
      }
    }

    final count = _completions[result];
    final ad = _interstitial;
    final eligible = count != null && _adOpportunityUsed[result] != true;
    _adOpportunityUsed[result] = true;
    if (!_status.value.ready || !eligible || ad == null) {
      diagnostics?.set(
        AdQaField.show,
        !eligible
            ? 'Bu sonuç için reklam fırsatı yok'
            : !_status.value.ready
            ? 'UMP veya SDK hazır değil'
            : 'Hazır reklam yok',
      );
      continueExit();
      return;
    }
    _interstitial = null;
    _showing = true;
    unawaited(_show(ad, isCurrent, continueExit));
  }

  Future<void> _show(
    InterstitialPlacement ad,
    bool Function() isCurrent,
    VoidCallback leave,
  ) async {
    diagnostics?.set(AdQaField.show, 'Gösterim istendi');
    diagnostics?.set(AdQaField.load, 'Hazır reklam tüketildi');
    try {
      if (!await _backend.canRequestAds() ||
          _disposed ||
          !_status.value.ready ||
          !isCurrent()) {
        diagnostics?.set(
          AdQaField.show,
          'UMP veya ekran durumu gösterime izin vermedi',
        );
        return;
      }
      await ad.show();
      diagnostics?.set(AdQaField.show, 'Gösterim tamamlandı');
    } catch (_) {
      diagnostics?.set(AdQaField.show, 'Gösterim tamamlanamadı');
      // Continue the same exit after a failed presentation.
    } finally {
      ad.dispose();
      _showing = false;
      diagnostics?.event('Gösterim akışı sona erdi');
      if (!_disposed && isCurrent()) leave();
      unawaited(_preload());
    }
  }

  void dispose() {
    _disposed = true;
    _interstitial?.dispose();
    _interstitial = null;
    _status.dispose();
  }
}
