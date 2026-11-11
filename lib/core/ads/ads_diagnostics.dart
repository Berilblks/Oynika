import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adsQaEnabledProvider = Provider<bool>(
  (_) => const bool.fromEnvironment('OYNIKA_ADS_QA'),
);

enum AdQaField {
  unitType('Reklam birimi türü'),
  umpUpdate('UMP güncellemesi'),
  consent('ConsentStatus'),
  privacyOptions('PrivacyOptionsRequirementStatus'),
  canRequest('canRequestAds'),
  initialization('Mobile Ads SDK'),
  load('Interstitial yükleme'),
  loadError('Son yükleme hatası'),
  completed('Tamamlanan oyun'),
  show('Son gösterim girişimi');

  const AdQaField(this.label);
  final String label;
}

/// A bounded, memory-only QA record. Callers supply status labels, never IDs.
class AdsDiagnostics extends ChangeNotifier {
  final _values = <AdQaField, String>{};
  final _events = <String>[];
  bool _disposed = false;

  String value(AdQaField field) => _values[field] ?? 'Henüz sorgulanmadı';
  List<String> get events => List.unmodifiable(_events);

  void set(AdQaField field, String value) {
    if (_disposed || _values[field] == value) return;
    _values[field] = value;
    event('${field.label} — $value');
  }

  void event(String message) {
    if (_disposed) return;
    _events.add(message);
    if (_events.length > 40) _events.removeAt(0);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Raw SDK messages can contain device IDs and URLs. Keep only known reasons.
String safeAdError(String domain, int? code, String message) {
  final safeDomain = switch (domain) {
    'com.google.admob' ||
    'com.google.android.gms.ads' ||
    'com.google.android.gms.ads.nonagon.render.e' ||
    'UMP' ||
    'timeout' ||
    'platform' => domain,
    _ => 'other',
  };
  final text = message.toLowerCase();
  final reason = switch (text) {
    _ when text.contains('no fill') || text.contains('no ad config') =>
      'Uygun reklam bulunamadı',
    _ when text.contains('not approved') || text.contains('not ready') =>
      'Uygulama veya hesap reklam sunumuna hazır değil',
    _ when text.contains('misconfiguration') || text.contains('invalid') =>
      'Yapılandırma veya istek hatası',
    _
        when text.contains('network') ||
            text.contains('internet') ||
            text.contains('making request') =>
      'Ağ bağlantısı hatası',
    _ when text.contains('timeout') || text.contains('timed out') =>
      'İşlem zaman aşımına uğradı',
    _ => 'SDK işlemi tamamlayamadı',
  };
  return '$safeDomain / ${code ?? '-'} / $reason';
}
