# Oynika | TestFlight reklam QA sürümü

11 Kasım 2026

Bu sürüm gerçek iPhone'da UMP, Mobile Ads başlatması ve geçiş reklamı yükleme sonucunu cihaz içinde incelemek için hazırlanmıştır.

## Derleme seçenekleri

QA ekranını açan seçenek aşağıdadır. Debug, profile ve release derlemelerde aynı şekilde çalışır.

```text
--dart-define=OYNIKA_ADS_QA=true
```

Bu seçenek QA ekranıyla birlikte resmî Google test geçiş reklamı birimini zorunlu kılar. Mevcut OYNIKA_ADS_TEST_MODE seçeneği ayrıca desteklenir. Önerilen QA derlemesinde niyeti açık tutmak için ikisini birlikte kullan.

```sh
fvm flutter build ipa --release --dart-define=OYNIKA_ADS_QA=true --dart-define=OYNIKA_ADS_TEST_MODE=true
```

Bu komut Mac/Xcode, CocoaPods ve uygun Apple imzalaması gerektirir. Windows'ta iOS arşivi oluşturulmadı. Codemagic derlemesini QA geliştirmesini içeren uzak dal veya commit üzerinden başlat.

Normal mağaza derlemesinde her iki seçeneği kaldır veya false yap. OYNIKA_ADMOB_TEST_DEVICE_IDS kullanılıyorsa normal mağaza iş akışında onu da boş bırak. Varsayılan release mevcut üretim birimini seçer ve QA ekranına yönlendirme yapmaz. AdMob uygulama kimlikleri ve üretim reklam birimleri değiştirilmedi.

## Codemagic Workflow Editor

1. Codemagic'te Oynika uygulamasını ve iOS QA için kullanılacak iş akışını aç.
2. Build for platforms alanında iOS'u seç.
3. Build bölümünde Flutter sürümünü 3.38.10 olarak ayarla. Mevcut çalışan Xcode/CocoaPods ve imzalama yapılandırmasını kullan. Build mode alanını Release seç.
4. Aynı Build bölümündeki ek derleme argümanları alanına yalnızca aşağıdaki argümanları yaz. Alanın başlığı arayüz sürümüne göre Build arguments veya Additional build arguments olabilir.

```text
--dart-define=OYNIKA_ADS_QA=true --dart-define=OYNIKA_ADS_TEST_MODE=true
```

5. Çalışan workflow'daki mevcut build numarası yöntemini kullanarak TestFlight için yeni bir numara ver. Mevcut signing ve App Store Connect yayınlama entegrasyonunu kullan. Apple API anahtarlarını Flutter argümanlarına veya kaynak dosyalara ekleme.
6. QA kodunu içeren dal/commit üzerinden yeni build başlat. Derleme komutunda iki dart-define değerinin bulunduğunu doğrula.
7. App Store'a gönderilecek normal workflow'dan QA/test seçeneklerini kaldır. Environment variables alanına sadece OYNIKA_ADS_QA=true yazılması Dart derleme sabitini tek başına ayarlamaz. Değer flutter build komutuna --dart-define olarak aktarılmalıdır.

Workflow Editor iOS kurulum ve ek argüman alanını Build bölümünde sunar. [Codemagic Flutter yapılandırması](https://docs.codemagic.io/flutter-configuration/flutter-projects/) · [Codemagic ortam değişkenleri](https://docs.codemagic.io/flutter-configuration/using-environment-variables/)

## iPhone'da kullanım

Ayarlar → Reklam tanılama (QA) ekranını aç. Reklam birimi türü test olmalı. UMP güncelleme sonucunu, ConsentStatus, PrivacyOptionsRequirementStatus, canRequestAds, Mobile Ads durumunu ve reklam yükleme sonucunu kontrol et.

Test reklamını yükle düğmesi mevcut rıza ve SDK uygunluğuyla yükleme yapar. Hazır reklam zaten varsa onu korur. Test reklamını göster yalnızca resmî test birimi, hazır reklam, geçerli ekran ve SDK'nın reklam isteği izni birlikte varsa çalışır. Manuel gösterimler tamamlanan oyun sayacını artırmaz ve normal sonuç çıkışındaki reklam fırsatını tüketmez. Güncel akışta her tamamlanan oyun için sonuç ekranından çıkılırken en fazla bir interstitial fırsatı vardır; reklam hazır değilse navigasyon bekletilmez.

Rıza ve SDK durumunu yeniden dene düğmesi, örneğin internet bağlantısı geri geldikten sonra yeniden değerlendirme sağlar. Denemeler arasında en az 15 saniye vardır. Uygulama yeniden ön plana geldiğinde yalnızca reklam servisi hazır değilse otomatik yeniden deneme yapılır. Bu otomatik yol oturum başına en fazla üç kez çalışır. Aynı anda yeni rıza yenilemesi başlatılmaz. SDK başlatma hatası ve zaman aşımı sonraki denemeyi kalıcı olarak engellemez.

Türkiye'de UMP formunun gerekmemesi normal olabilir. canRequestAds SDK kararıdır ve reklam kişiselleştirmesi için rıza anlamına gelmez. UMP required döndürürse mevcut Reklam gizlilik seçenekleri düğmesi görünür. ATT akışı eklenmedi. QA ekranı izin vermeyi zorlamaz.

Mevcut OYNIKA_UMP_DEBUG_EEA yalnızca debug derlemede etkilidir. Bu seçeneği TestFlight release argümanlarına eklemek AEA simülasyonu sağlamaz. AEA testi ayrı debug iPhone derlemesinde, SDK test cihazı yapılandırmasıyla yapılabilir. [Google UMP](https://developers.google.com/admob/flutter/privacy)

## Tanı verileri ve hata dayanıklılığı

Tanı verileri yalnızca QA derlemesinde, geçici uygulama belleğinde tutulur. Son 40 durum/olay saklanır. Dosyaya, sunucuya veya analitik servisine gönderilmez. Uygulama işlemi kapanınca kayıt sıfırlanır.

Ham hata mesajları gösterilmez. Bilinen SDK domain'leri korunur, diğer domain'ler other olarak gösterilir. Kod korunur. Mesaj bilinen ağ, zaman aşımı, yapılandırma, reklam bulunamaması veya uygulama hazır olmaması nedenlerinden birine dönüştürülür. Eşleşmeyen mesaj için genel SDK hata açıklaması görünür. Böylece reklam veya cihaz kimliği, IP, e-posta, URL ve ham rıza metni tanı ekranına taşınmaz. [Google reklam yükleme hataları](https://developers.google.com/admob/flutter/ad-load-errors)

Normal oyunlarda sayaç ortak kalır. İkinci, dördüncü ve sonraki çift tamamlamalarda sonuçtan çıkış sırasında hazır reklam için fırsat oluşur. Sonuç açılırken reklam gösterilmez. Reklam hazır değilse veya gösterim başarısızsa geçiş devam eder. Gösterim öncesinde de SDK reklam uygunluğu yeniden sorgulanır.

## Değişen dosyalar

- lib/core/ads/ad_units.dart
- lib/core/ads/ads_diagnostics.dart
- lib/core/ads/ads_qa_screen.dart
- lib/core/ads/ads_service.dart
- lib/core/ads/google_ads_backend.dart
- lib/app/app.dart
- lib/app/router/app_router.dart
- lib/features/settings/presentation/settings_screen.dart
- test/admob_phase2_test.dart
- docs/ios_ads_qa.md

## Doğrulama ve kalan işler

fvm flutter analyze temiz. fvm flutter test --concurrency=1 ile 404 test geçti. Önceki 393 teste QA kapısı, güvenli hata mesajları, manuel test reklamı, yeniden deneme ve başlatma hatasından toparlanma için 11 test eklendi.
Android release QA APK derlemesi başarılı, çıktı build/app/outputs/flutter-apk/app-release.apk. Windows farklı sürücü kaynakları nedeniyle Kotlin artımlı önbellek hatası yazdı; Gradle tam derlemeye geçerek tamamlandı. Derlemede mevcut ikon/font ve Java 8 uyarıları da bulundu.

Pixel 3 Android emülatöründe release QA ekranı açıldı. Reklam türü test, UMP güncellemesi başarılı, ConsentStatus ve PrivacyOptionsRequirementStatus notRequired, canRequestAds true, Mobile Ads SDK ve reklam hazır olarak göründü. Manuel test reklamı gösterilip kapatıldı. QA ekranına dönüşte gösterim/kapanış olayları kaydedildi ve tamamlanan oyun sayacı 0 kaldı. Görüntüler build/ads_qa/status.png, test-ad.png ve after-show.png.

iOS native derleme, CocoaPods çözümlemesi, TestFlight yüklemesi ve fiziksel iPhone testi Codemagic/Mac aşamasında bekliyor.
