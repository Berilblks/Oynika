# Ben Kimim? — Faz 6.5 kalite ve iOS hazırlık raporu

Tarih: 7 Kasım 2026. Ortam: Windows, Flutter 3.29.0 / Dart 3.7.0. Bu rapor Android doğrulaması ile Windows üzerinde yapılabilen iOS statik incelemesini ayırır. Gerçek iOS build/cihaz testi yapılmadı.

## 1. Bulunan sorunlar
| Bulgu | Etki / kanıt |
|---|---|
| Gecikmiş ikinci Hazırım çağrısının aktif turda kabul edilmesi | Skor tekrar artmasa bile sensör aboneliği/kalibrasyon yeniden başlıyordu. Yeni test düzeltme öncesi başarısız oldu; build/who65/reproduced-hazir.log saklandı. |
| Eski Dokunmatik Devam Et callback'inin aktif turu etkilemesi | Önce sensörü kapatıp modu değiştiriyor, sonra oyun durumunu kontrol ediyordu. Gecikmiş çağrı çalışan sensörü kapatabiliyordu. |
| Kazanan ekranındaki eski Tekrar Oyna/Oyunlara Dön callback'lerinin oturum korumasının olmaması | Tekrarlı çağrı yeni ayar kimliğini tekrar sıfırlayabilir veya kapanmış ekran context'ine erişebilirdi. Yeni oturum/çıkış sonrası callback regresyon testi eklendi. |
| iOS yatay arayüz yönü işaretinin ters yorumlanması | UIInterfaceOrientation.landscapeLeft Home soldadır; doğal cihaz X aşağı bakar. Önceki düz konum ipucu bunun tersiydi. Bu bulgu statiktir; fiziksel iPhone hatası ölçülmüş gibi sunulmaz. |
| CocoaPods giriş yapılandırmasının repoda bulunmaması | ios/Podfile yoktu; Debug/Release xcconfig sadece Generated.xcconfig içeriyordu. Yeni Mac checkout'u için standart entegrasyon hazırlığı eksikti. Native build yapılmadan kesin derleme hatası iddia edilmiyor. |
| Kurallar modalında nötre dönüş açıklaması eksikti | Hazırım ekranında vardı; modal da yeni hareket için düz konuma dönmeyi artık açıkça anlatır. |

UIKit yön tanımı: [Apple — UIInterfaceOrientation.landscapeLeft](https://developer.apple.com/documentation/uikit/uiinterfaceorientation/landscapeleft). Arayüz yönü isimleri UIDeviceOrientation isimleriyle karıştırılmadı. iOS ipucu düzeltilirken Android kodu ve hareket eşikleri değiştirilmedi.

## 2. Düzeltmeler
- Hazırım/dokunmatik devam yalnızca ilgili orienting veya manuel resume durumunda, canlı ekranda kabul edilir. Mod değişikliği durum kontrolünden sonra yapılır. Aktif turdaki gecikmiş ikinci çağrı etkisizdir.
- Tekrar Oyna ve Oyunlara Dön callback'leri canlı ekran ve ait oldukları oyun ayar kimliğiyle sınırlandı. Dispose sonrası cevap/başlatma callback'leri güvenli biçimde yok sayılır.
- iOS yön ipucu küçük, XCTest ile çağrılabilir bir fonksiyona alındı: interface landscapeLeft → -1, landscapeRight → +1. Kanal closure'ı view controller'ı weak tutar; ölçülmüş bir native bellek sızıntısı iddiası yoktur.
- Flutter 3.29'un yerel resmi Podfile-ios-swift şablonu kullanıldı; platform iOS 12.0 açıkça belirtildi. Debug/Release xcconfig'e standart isteğe bağlı Pods include'ları eklendi. İmzalama/proje target ayarları değiştirilmedi.
- Kurallara tek bir nötr dönüş cümlesi eklendi; onaylanan ekran tasarımı korunur.

## 3. Değiştirilen dosyalar
- lib/features/games/who_am_i/presentation/who_game_screen.dart
- lib/features/games/domain/party_game.dart (yalnızca Ben Kimim? kural metni)
- ios/Runner/AppDelegate.swift
- ios/Podfile (yeni)
- ios/Flutter/Debug.xcconfig, ios/Flutter/Release.xcconfig
- ios/RunnerTests/RunnerTests.swift
- test/who_motion_widget_test.dart
- test/who_score_widget_test.dart
- test/who_widget_test.dart
- test/who_quality_test.dart (yeni)
- README.md ve docs/who_phase65.md

## 4. Test sayısı ve sonuçlar
- flutter analyze: **No issues found**.
- flutter test --concurrency=1: **322 başarılı Flutter testi** (önceki 309 + 13 ek kalite testi).
- Yeni kapsam: çift/gecikmiş Hazırım, eski dokunmatik callback, tekrar/çıkış callback'lerinin yeni oturuma etkisizliği, hızlı geri, dispose sonrası iki sensör aboneliği/timer temizliği, küçük ekranlar ve her iki tarafta asimetrik çentik ile 2.5× yazı/açık-koyu tema.
- Önceki tam akış, beş hedef puan, daralan eşitlik turları, Tekrar Oyna, router'a dönüş, 300 kart, deste tekrarsızlığı, sensör/dokunmatik regresyonları ve diğer üç oyunun testleri geçiyor.
- **3 native iOS XCTest yazıldı, Windows üzerinde çalıştırılmadı. Bu 3 test 322 sayısına dahil değildir.**
- Sensör callback'lerinin eski abonelik sürümünden gelmesi, tur sonunda cevap reddi ve nötr mandalı mevcut testlerle denetlendi; hesaplama/eşik değişikliği yapılmadı.

## 5. APK
flutter build apk --debug başarılı. Çıktı build/app/outputs/flutter-apk/app-debug.apk. Loglar build/who65/ altında. Release IPA veya iOS uygulaması üretilmedi.

## 6. Veri, performans ve Android incelemesi
300 kart ve kategori dağılımı korunur: 75 Türk müzisyen, 65 Türk oyuncu/TV, 65 yabancı ünlü, 40 sporcu, 25 tarihî/tanınmış kişi, 30 insan karakteri. Zorluk 240 kolay / 60 orta. ID, temiz isim, normalleştirilmiş tekrar, alias, kategori, eski insan dışı içerik ve fixture testleri geçti. İsim listesinin incelemesinde değiştirmeyi gerektiren bir kart saptanmadı; otomatik testin gerçek dünyadaki insan kimliğini tek başına kanıtladığı iddia edilmiyor.

Başlangıç/bitiş SHA-256 karşılaştırmasında JSON, tilt detector, motion service, oyun controller'ı, aktif yatay ekran, Android MainActivity ve Xcode project.pbxproj aynı. Tasarım, kazanan kuralları, Redmi hareket yönleri/eşikleri ve imzalama hedefleri korunur.

Timer ve iki sensör stream'i duraklama/arka plan/sonuç/çıkış/dispose yollarında kapanır. Eski abonelikler epoch kontrolünden geçemez. Debug paneli varsayılan kapalıdır ve normal UI ham sensör değişiklikleriyle rebuild edilmez. 100 ms oyun timer'ı ve kısa geri bildirim animasyonu korunur; gereksiz kapsamlı performans refactor'u yapılmadı. CPU/GPU profil ölçümü veya bellek benchmark'ı yapılmış gibi raporlanmaz.

## 7. iOS statik durum ve Mac/Xcode kontrol listesi
Windows üzerinde doğrulananlar:
- Project'in Debug/Profile/Release deployment target'ı ve Flutter AppFramework minimumu 12.0; sabit sensors_plus 6.1.2 podspec minimumu 12.0 ve Swift 5.0 ile tutarlı.
- Flutter 3.29 / Dart 3.7 korunur; paket/sürüm yükseltilmedi.
- Bundle ID com.oynika.app, ad Oynika, NSMotionUsageDescription mevcut ve Türkçe/bozuk karakter içermiyor.
- iPhone portrait + LandscapeLeft/Right izinleri, iPad yön listesi, storyboard ve AppIcon/LaunchImage dosyaları mevcut.
- Native iOS API availability kontrolleri iOS 12/13 ayrımını içerir; kaynak incelemesi native derleme kanıtı değildir.
- Swift XCTest yön eşlemesi, portrait ve unknown durumlarını kapsar.
- Statik plist/asset/xcconfig denetim çıktısı build/who65/ios-static.json. CocoaPods/Ruby/Xcode Windows'ta çalıştırılmadı.

Mac üzerinde tamamlanacak işler:
1. Aynı repo ve Flutter sürümüyle flutter doctor -v; seçilen Xcode/SDK ve Flutter 3.29 uyumunu doğrula.
2. flutter pub get; ardından ios klasöründe pod install. Generated.xcconfig ve plugin registrant Mac üzerinde üretilmeli; Windows SDK yolları taşınmamalı.
3. Runner.xcworkspace'i aç; iPhone simulator için flutter build ios --simulator --debug çalıştır.
4. RunnerTests'in **3 XCTest** testini Xcode Test ile çalıştır. İstenirse xcrun simctl list devices available ile alınan UDID kullanılarak xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,id=<UDID>' test çalıştır.
5. Küçük iPhone, çentikli/Dynamic Island'lı iPhone ve iki yatay tutuşta SafeArea, geri/çıkış, pause/resume, tur sonucu/winner portrait dönüşünü simulator üzerinde doğrula.
6. Fiziksel iPhone'da öne Doğru/arkaya Pas, nötr mandalı, gyro/ivme akışı, otomatik referans, kilit/arka plan ve dokunmatik fallback'i doğrula. Simulator hareket testi fiziksel cihaz doğrulaması sayılmaz.
7. iPad/çoklu pencere desteklenecekse yön kilidi davranışını ayrıca kontrol et; bu fazda UIRequiresFullScreen gibi global politika değişikliği yapılmadı. [Flutter orientation platform sınırları](https://api.flutter.dev/flutter/services/SystemChrome/setPreferredOrientations.html).
8. Release derlemede debug panelinin görünmediğini ve mevcut Apple imzalama yapılandırmasıyla cihaz/Archive doğrulamasını yetkili Mac üzerinde tamamla. Sertifika, profil, takım ve App Store Connect ayarları bu fazda değiştirilmedi.

Bu liste tamamlanmadan iOS için yayınlanmaya hazır/derlendi/fiziksel cihazda test edildi denmez.

## 8. Bilinen sınırlamalar
- Oturum bellektedir; süreç kapanırsa oyun devam kaydı yoktur (mevcut tasarım).
- Hedef/eşitlik kuralı gereği sıfır puanlı ek turlar eşitlik çözülene kadar sürebilir.
- iOS native build, XCTest ve gerçek iPhone hareket testi bekliyor. iPad çoklu pencere ve büyük ekran orientation politikaları platform sınırlarıdır.
- Android QA ve widget viewport simülasyonu tüm gerçek telefonların donanım doğrulaması yerine geçmez. Mevcut sensör eşikleri fiziksel Redmi'de önceki fazda kullanıcı tarafından onaylandı; bu fazda değiştirilmedi.

## 9. Git durumu
Branch main; HEAD 5410836. Önceki V1 ve Ben Kimim? geliştirmeleri zaten çalışma ağacında bekliyordu; korundu. Bu fazda yalnızca yukarıdaki kalite/iOS hazırlık/test/dokümantasyon dosyaları değiştirildi. Stage, commit ve push yapılmadı. APK, ekran görüntüleri, geçici scriptler ve loglar build/who65 altında Git dışında tutulur.

## Android son doğrulama ve ekran görüntüleri
Pixel 3 üzerinde güncel APK ile iki oyunculu, 60 saniye ve hedef 10 tam oyun oynandı (dokunmatik alternatif). Oyuncu 1 hedef 10'a ulaşınca süre/tur devam etti; Oyuncu 2'nin turu tamamlandıktan sonra kazanan 10–0 olarak gösterildi. Tur sonucu portrait, aktif oyun landscape açıldı. Tekrar Oyna ile Oyuncu 1 hazırlığına dönüldü; toplam 0, süre 60 ve hedef 10 korundu. Emülatörde fiziksel sensör doğrulaması yapıldığı iddia edilmez.

Ekran görüntüleri:
- build/who65/pixel-setup.png
- build/who65/pixel-playing-target10.png
- build/who65/pixel-round-result.png
- build/who65/pixel-next-player.png
- build/who65/pixel-second-player.png
- build/who65/pixel-winner.png
- build/who65/pixel-replay.png

Redmi (155e6b22): güncel debug APK `adb install -r` ile **Success** sonucu verdi. MainActivity başlatıldı; ancak `mCurrentFocus` NotificationShade/kilit ekranında kaldı. Bu nedenle uygulamanın görünür açılışı veya bu fazın fiziksel sensör testi tamamlandı diye raporlanmaz. Cihazın kilidi açılarak Oynika kontrol edilmeli.

Son `git diff --check` hatasızdır; yalnızca mevcut Git LF/CRLF dönüşüm uyarıları vardır. Tabu, Sessiz Sinema ve Aramızdaki Casus feature klasörlerinin HEAD'e göre diff'i boştur. Çalışma ağacı önceki onaylanmış geliştirmeler ve bu fazın dosyaları nedeniyle temiz değildir; hiçbir dosya stage edilmedi. Tam durum build/who65/git-status.txt altında saklandı. Commit/push yapılmadı.
