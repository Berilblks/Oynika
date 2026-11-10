# Oynika | AdMob Faz 2

10 Kasım 2026 · Flutter 3.38.10, Dart 3.10.9, iOS hedefi 15.0.

## SDK ve platform

google_mobile_ads 9.2.0 tam sürüm olarak sabitlendi. Paket Flutter 3.38.1+ ve Dart 3.10+ istiyor. iOS podspec tabanı 13.0. Android eklentisi minSdk 24 ve compileSdk 36 kullanıyor. Mevcut Flutter pinine ve iOS 15 hedefine uyuyor. Paketle gelen WebView bağımlılıkları dışında mevcut oyun paketleri yükseltilmedi. [Paket ve sürüm notları](https://pub.dev/packages/google_mobile_ads/versions/9.2.0)

İlk Android denemesi, webview_flutter_android 4.12.0'ın compilerOptions API'si ile Kotlin 1.8.22 uyuşmadığı için durdu. Proje Kotlin 2.3.0, AGP 8.13.2 ve Gradle 8.13 ile eşleştirildi. Uygulamanın Kotlin JVM 11 hedefi compilerOptions sözdizimine taşındı. Android SDK seviyeleri ve NDK pini korundu. Windows'ta proje ve pub önbelleği farklı sürücülerde olduğunda Kotlin artımlı önbelleği hata verdi ve Gradle tam derlemeye geçti. Hem bu derleme hem son artımlı APK derlemesi tamamlandı. [Android Gradle uyumluluğu](https://developer.android.com/build/releases/agp-8-13-0-release-notes)

Kullanıcının Android ve iOS uygulama kimlikleri AndroidManifest.xml ve Info.plist'e yazıldı. Reklam birimi seçimleri lib/core/ads/ad_units.dart içinde. Android/iOS dışı hedefler ve web reklam isteği yapmaz. Debug, profile ve release QA resmi Google test birimlerini kullanabilir. Normal release ilgili platformun üretim birimini seçer. QA için release komutuna --dart-define=OYNIKA_ADS_TEST_MODE=true ekle. OYNIKA_ADMOB_TEST_DEVICE_IDS ile virgülle ayrılmış SDK test cihazı kimlikleri verilirse build de test birimlerini seçer. [Geçiş test birimleri](https://developers.google.com/admob/flutter/interstitial)

## UMP ve başlatma

İlk Flutter karesinden sonra bir kez rıza durumu güncellenir. Gerekli form gösterildikten ve UMP canRequestAds onayı geldikten sonra reklam SDK'sı en fazla bir kez başlatılır. Her yükleme UMP uygunluğunu tekrar kontrol eder. UMP güncelleme veya form hatasında SDK önceki oturumdan kalan duruma göre reklam isteğine izin verebilir. UMP izin vermediğinde veya reklam SDK’sı başlatılamadığında oyun reklamsız devam eder. Ayarlar, UMP gerekli dediğinde Reklam gizlilik seçenekleri düğmesini gösterir. Bu form açılırken eski reklamlar kaldırılır ve form tamamlandığında uygunluk yeniden değerlendirilir. [Google UMP akışı](https://developers.google.com/admob/flutter/privacy)

ATT isteği veya NSUserTrackingUsageDescription bu fazda eklenmedi. iOS'ta IDFA ve takip stratejisi, gerçek SDK davranışı ve mağaza beyanları doğrulandıktan sonra ayrı ele alınmalı. [Apple ATT](https://developer.apple.com/documentation/apptrackingtransparency)

## Banner

Ana ekranda reklam alanı bulunmaz. Android ve iOS sürümleri banner isteği göndermez.

## Geçiş reklamı

Tek servis terminal sonuç nesnesini kimliğine göre yalnızca bir kez sayar. 2, 4, 6… numaralı tamamlamalar, hazır reklam varsa sonuç ekranından ayrılma anında bir fırsat alır. İlk tamamlama, erken terk, normal tur sonucu, gizli rol ve oylama gösterim başlatmaz. Tekrar oynama eski tamamlamayı tekrar saymaz. Yeni oyun ancak kendi sonucu oluşunca sayılır.

Reklam önceden yüklenir. Hazır reklam yoksa çıkış eşzamanlı devam eder. Gösterim başarısızlığı veya kapanış, aynı ve hâlâ geçerli navigasyonu devam ettirir. Çift tetiklemeler ve eski sonuç callback'leri engellenir. Reklam nesnesi tüketilir ve dispose edilir. Sayaç uygulama süreci boyunca ortaktır ve uygulama kapanınca sıfırlanır.

## Doğrulama

Otomatik testler Tabu ve Sessiz Sinema arasında ortak sayacı, erken çıkışı, ikinci ve dördüncü sonuçtan ayrılırken gösterimi, reklam hazır olmadığında geçişi ve kapanıştan sonra navigasyonu kapsar. Ana ekranın alt navigasyona kadar uzandığı ve reklam widget’ı içermediği de doğrulanır.

## Mac ve AdMob paneli

- AdMob Privacy & messaging bölümünde Android ve iOS için doğru uygulamalara gereken bölgesel UMP mesajlarını oluştur ve yayımla. İlgili gizlilik politikası URL'si, rıza verme/reddetme ve seçenekleri yeniden açma senaryolarını doğrula.
- Üretim birimlerinin platform ve format eşleşmesini, uygulama durumunu ve test cihazı ayarlarını panelde kontrol et. QA release her zaman test modu tanımıyla üretilmeli.
- Mac üzerinde pod install, Xcode 26/iOS 26 SDK ile simulator build ve gerçek iPhone'da UMP, geçiş reklamı ve kapatma/navigasyon testi yap. iOS yayın öncesinde SKAdNetwork listesi, ATT/IDFA stratejisi, privacy manifest, App Store Privacy ve gizlilik politikası yeniden değerlendirilmeli. [Google iOS gizlilik rehberi](https://developers.google.com/admob/ios/privacy/strategies)

## Dosyalar ve Git

- lib/core/ads/ içinde merkezi kimlikler, SDK adaptörü, rıza/gösterim servisi.
- lib/app/app.dart ve Ayarlar ekranında reklam başlatma ve gizlilik seçenekleri.
- Dört oyunun presentation ekranlarında terminal sonuç ve çıkış bağlantıları. Oyun controller'ları, kartlar, skor kuralları ve sensör eşikleri korunuyor.
- AndroidManifest.xml, Info.plist, Android Gradle/Kotlin sürümleri, pubspec.yaml ve pubspec.lock.
- test/admob_phase2_test.dart ve bu rapor.

main, başlangıçta origin/main ile 5687fcf commit'inde eşleşiyordu. Faz 1/1.1'in kaydedilmemiş değişiklikleri çalışma ağacında korundu. Geçici çıktı ve loglar build/admob_phase2/ altında. Commit ve push yapılmadı.
