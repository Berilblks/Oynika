import 'dart:async';

import 'package:flutter/foundation.dart';

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
  AdsService(this._backend, this._interstitialUnit);

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

  Future<void> start() => _startup ??= _refreshConsent();

  Future<bool> openPrivacyOptions() async {
    if (!_status.value.privacyOptions || _status.value.busy || _disposed) {
      return false;
    }
    return _refreshConsent(privacy: true);
  }

  Future<bool> _refreshConsent({bool privacy = false}) async {
    if (_interstitialUnit == null || _disposed) return false;
    final generation = ++_generation;
    var privacyOptions = _status.value.privacyOptions;
    _interstitial?.dispose();
    _interstitial = null;
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
        } catch (_) {
          // After a startup failure, UMP can still authorize ads using its
          // consent state from a previous session.
        }
      }
      if (_disposed) return false;
      privacyOptions = await _backend.privacyOptionsRequired();
      if (await _backend.canRequestAds() && !_disposed) {
        await (_initialization ??= _backend.initialize().timeout(
          const Duration(seconds: 20),
        ));
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
    final generation = _generation;
    if (!_valid(generation) || _loading || _showing || _interstitial != null) {
      return;
    }
    _loading = true;
    try {
      if (!await _backend.canRequestAds() || !_valid(generation)) return;
      final ad = await _backend.loadInterstitial(_interstitialUnit!);
      if (_valid(generation)) {
        _interstitial = ad;
        _loadedAt = _clock.elapsed;
      } else {
        ad?.dispose();
      }
    } catch (_) {
      // Retry at a later completed game.
    } finally {
      _loading = false;
      if (!_disposed && generation != _generation && _status.value.ready) {
        unawaited(_preload());
      }
    }
  }

  void recordCompletion(Object result) {
    if (_disposed || _completions[result] != null) return;
    _completions[result] = ++_completed;
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
    final eligible =
        count != null && count % 2 == 0 && _adOpportunityUsed[result] != true;
    _adOpportunityUsed[result] = true;
    if (!_status.value.ready || !eligible || ad == null) {
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
    try {
      await ad.show();
    } catch (_) {
      // Continue the same exit after a failed presentation.
    } finally {
      ad.dispose();
      _showing = false;
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
