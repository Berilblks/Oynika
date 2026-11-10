# Oynika iOS yayın hazırlığı | Faz 1

9 Kasım 2026 · Windows üzerinde kaynak ve yapılandırma denetimi, Flutter testleri ve Android debug derlemesi. Native iOS doğrulaması Mac aşamasında yapılacak.

## 1. Proje durumu

Başlangıçta main temizdi ve origin/main ile 5687fcfc80ab96163611a52c5cc91f64f3fc73e2 commit'inde eşleşiyordu. Oynika çevrimdışı oynanan dört Türkçe oyun içeriyor. Flutter 3.29.0, Dart 3.7.0, Riverpod 3.3.2 ve sensors_plus 6.1.2 yerel araç ve bağımlılık çıktılarından doğrulandı. Flutter Doctor Android lisans uyarısı verdi. Bağımlılık ağacında iOS native eklentisi olarak sensors_plus bulunuyor. Doctor ve bağımlılık çıktıları build/ altında.

## 2. Apple 2026 koşulları

28 Nisan 2026'dan beri App Store Connect yüklemelerinde Xcode 26 veya üstü ve ilgili iOS/iPadOS 26 SDK veya üstü gerekiyor. Bu koşul build araçları için geçerli. Cihazın çalıştırabileceği en eski iOS sürümü deployment target ile belirlenir ve seçilen Xcode/SDK'nın destek aralığına tabidir. Apple'ın yükleme duyurusu iOS 13 deployment target şartı belirtmiyor. Apple'ın Xcode 26 tablosunda iOS ve iPadOS için desteklenen deployment aralığı 15'ten başlıyor. [Apple yükleme koşulları](https://developer.apple.com/news/upcoming-requirements/?id=04282026a) · [Xcode ve deployment target tablosu](https://developer.apple.com/xcode/system-requirements)

## 3. Flutter yükseltme planı

Flutter ekibi Xcode 26 ve iOS 26 desteğini Flutter 3.38 sürümünde duyurdu. Flutter 3.29 bu duyurudan önceki bir sürüm. Yayın için desteklenen ve güvenlik düzeltmeleri güncel bir stable sürümü, seçilen Xcode ile eşleştirip FVM üzerinden sabitle. 3.38 destek duyurusunun alt sınırı olarak referans alınabilir. 3.29'un bu projede Xcode 26 ile native build sonucu henüz bilinmiyor. [Flutter 3.38 duyurusu](https://flutter.dev/blog/whats-new-in-flutter-3-38) · [Flutter destek matrisi](https://docs.flutter.dev/reference/supported-platforms)

Yükseltmeyi ayrı değişiklikte yap. Yeni Flutter ile gelen Dart sürümünde pub get ve pub outdated sonuçlarını incele. Önce mevcut paket kısıtlarını çöz, yalnızca gerekli paketleri güncelle ve lockfile farkını gözden geçir. Sonra CocoaPods çözümlemesi, simulator build, unsigned cihaz build ve Android regresyonunu çalıştır. SwiftPM geçişi gerekirse ayrı değerlendir.

## 4. Minimum sürüm ve native ayarlar

| Alan | Mevcut durum |
|---|---|
| Kimlik | Runner bundle ID com.oynika.app, görünen ad Oynika |
| Sürüm | pubspec 0.1.0+1. Info.plist değerleri FLUTTER_BUILD_NAME ve FLUTTER_BUILD_NUMBER üzerinden geliyor |
| Minimum iOS | Xcode proje ayarları, Podfile ve AppFrameworkInfo.plist 12.0 |
| Cihazlar | iPhone ve iPad, TARGETED_DEVICE_FAMILY 1,2 |
| Yön | iPhone dikey ve iki yatay yön. iPad dört yön. Dart uygulamayı dikey başlatıyor ve Ben Kimim? aktif turunda iki yatay yönü istiyor |
| İzinler | Türkçe NSMotionUsageDescription mevcut. Runner plist içinde kamera, mikrofon, konum veya ATT kullanım açıklaması bulunmadı |
| CocoaPods | Debug ve Release xcconfig içinde Pods ve Generated include'ları var. sensors_plus 6.1.2 podspec iOS 12.0 ve Swift 5.0 belirtiyor |
| Native kanal | AppDelegate, Ben Kimim? için arayüz yönü işaretini döndürüyor. iOS 13+ ve eski API yolları ayrılmış |

iOS 15.0 önerilen hedef. iOS 12–14 cihazları bu yükseltmeden sonra güncellenen sürümü yükleyemez. Mevcut sensors_plus podspec alt sınırı 15 ile çelişmiyor. Seçilecek Flutter ve tüm çözülmüş pod'larla Mac build doğrulaması eksik olduğu için mevcut 12.0 bu fazda korundu. Yükseltmede Runner, test hedefleri, Podfile ve framework metadata'sındaki etkili değerleri birlikte doğrula. Son archive içindeki MinimumOSVersion ve SDK değerlerini kontrol et.

## 5. Dört oyun denetimi

| Oyun | Windows üzerinde incelenen akış | Cihazda doğrulanacak |
|---|---|---|
| Tabu | Ayarlar, iki takım, süre ve hedef, kart, Doğru/Tabu/Pas, tur sonu, kazanan ve geri gezinme. Tekrarlanan çıkış onayı düzeltildi | Kenardan geri hareketi, kilit/uyandırma, gerçek klavye |
| Sessiz Sinema | 300 film + 200 dizi, takım sırası, sınırsız pas, süre, skorlar, kazanan, tekrar oynama. Tekrarlanan çıkış onayı düzeltildi | Aynı cihaz kontrolleri ve uzun yapım adları |
| Aramızdaki Casus | 3–20 oyuncu, otomatik casus sayısı, gizli gösterim ve devir, oylama/beraberlik, rol açıklama ve kazanma. Yaşam döngüsü gizli bilgiyi ve açık oyu kapatıyor | App Switcher anlık görüntüsü, ekran kaydı, haptik. Android FLAG_SECURE iOS'ta uygulanmıyor |
| Ben Kimim? | 300 kart, hazırlık/3-2-1/Hazırım, yatay kart, sensör ve dokunmatik yol, hedef/eşitlik, sonuç ve tekrar. Yön, sensör ve lifecycle için mevcut testler korundu | Gerçek Core Motion, her iki yatay tutuş, iPad çoklu pencere ve tur sonu dikeye dönüş |

Tabu ve Sessiz Sinema ekranları odak kaybında sayacı duraklatıyor. Controller'lar tur bitişi ve dispose sırasında timer'ı temizliyor. Ben Kimim? sensör aboneliklerini duraklamada ve çıkışta kapatıyor ve eski olayları reddediyor. Testlerdeki yaşam döngüsü olayları fiziksel kilit veya iOS App Switcher ölçümü yerine geçmez. Süreç kapanınca oturumun kaybolması mevcut V1 davranışı.

## 6. iPhone yerleşim ve erişilebilirlik

| Mantıksal boyut | Simüle dikey SafeArea üst/alt |
|---|---:|
| 375×667 | 20/0 |
| 390×844 | 47/34 |
| 393×852 | 59/34 |
| 430×932 | 59/34 |

32 kurulum senaryosu dört oyunu, dört boyutu ve iki temayı kapsıyor. Normal ve 1,6× metin, sabit başlatma düğmesi, uzun ad düzenleme ve 300 px simüle klavye alanı kontrol edildi. Sekiz kart testi en uzun Tabu ve Sessiz Sinema kartlarını iki temada 1,6× metinle ölçüyor. On altı Ben Kimim? yatay testi iki çentik yönünde 2× metin, tam kart metni, görünür Doğru/Pas ve kaydırmasız ekranı doğruluyor. Bu ölçüler Flutter widget simülasyonudur. VoiceOver, gerçek klavye ve cihaz SafeArea kontrolleri Mac/iPhone listesinde.

## 7. Marka varlıkları

AppIcon kataloğundaki 19 iPhone, iPad ve mağaza kaydı mevcut. Boyutlar katalogdaki ölçeklerle eşleşiyor ve PNG'ler opak. 1024×1024 mağaza ikonu renkli Oynika logosunu gösteriyor. Android adaptive ve klasik ikonları aynı marka kaynağını kullanıyor. LaunchScreen, mevcut logo için ortalı 168 pt aspect-fit düzeni ve 168/336/504 px kaynakları içeriyor. Native açılış zemini beyaz. Uygulamanın açık/koyu tema davranışı açılıştan sonra başlıyor. Eksik varlık saptanmadı. Xcode asset derleyicisi ve gerçek iPhone açılışı Mac aşamasında kontrol edilecek.

## 8. AdMob ön incelemesi

- İncelenen google_mobile_ads 9.2.0 kaynak metadatası Flutter 3.38.1+ ve Dart 3.10+ istiyor. iOS podspec tabanı 13.0, Google Mobile Ads SDK bağımlılığı 13.11 serisi. Seçilecek sürümde WebView eklentileri ve native bağımlılıkların etkili minimumunu yeniden çöz. [Paket manifesti](https://raw.githubusercontent.com/googleads/googleads-mobile-flutter/main/packages/google_mobile_ads/pubspec.yaml) · [iOS podspec](https://raw.githubusercontent.com/googleads/googleads-mobile-flutter/main/packages/google_mobile_ads/ios/google_mobile_ads.podspec)
- Gelecekte gerçek iOS AdMob uygulama kimliği Info.plist içindeki GADApplicationIdentifier alanına girilir. Reklam birimi kimliği ayrı bir değerdir. SKAdNetworkItems listesi seçilen SDK ve arabuluculuk ağlarının güncel dokümanından alınmalı. [Flutter kurulumu](https://developers.google.com/admob/flutter/quick-start) · [iOS reklam gizliliği](https://developers.google.com/admob/ios/privacy/strategies)
- ATT ihtiyacı gerçek takip ve IDFA kullanımına bağlı. Takip varsa uygun açıklama ve Apple izni gerekir. UMP akışında her açılışta izin durumunu güncelle, gereken formu göster, gerekli yerlerde gizlilik seçeneklerini erişilebilir yap ve reklam isteğini canRequestAds sonucuna bağla. [Apple ATT](https://developer.apple.com/documentation/apptrackingtransparency) · [Google UMP](https://developers.google.com/admob/flutter/privacy)
- Yayında gizlilik politikası URL'si gerekir. App Store Privacy yanıtları gerçek uygulama ve SDK veri davranışına göre hazırlanmalı. Reklam entegrasyonundan sonra toplama, ilişkilendirme ve takip alanları yeniden değerlendirilmeli. [Apple App Privacy](https://developer.apple.com/app-store/app-privacy-details/) · [App Store Connect yardım](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/)

## 9. Düzeltilen sorun

Tabu ve Sessiz Sinema'nın geri çağrısı peş peşe tetiklenince iki çıkış onayı açılıyordu. Her oyunda düzeltme öncesi test iki AlertDialog gördü. Çıkış onayı açıkken yeni çağrı reddediliyor ve kaldırılmış ekranın callback'i güvenle yok sayılıyor. Onay kapatıldıktan sonra sonraki geri isteği normal çalışıyor. Yeni testler iki davranışı da kapsıyor.

## 10. Mac/Xcode kontrol listesi

1. Desteklenen Flutter stable ve Xcode sürümünü sabitle. xcodebuild -version, xcrun --sdk iphoneos --show-sdk-version ve flutter doctor -v ile araç zincirini doğrula.
2. flutter pub get, ios altında pod install, ardından Runner.xcworkspace ve Debug/Profile/Release build ayarlarını kontrol et. 15.0 hedefini ayrı değişiklikte etkinleştir. Pod sürümleri ve minimum hedefleri doğrula.
3. Simulator debug build, RunnerTests ve flutter build ios --release --no-codesign çalıştır. Etkili bundle ID, sürüm/build, deployment target, desteklenen yönler, ikon ve LaunchScreen'i build çıktısından doğrula.
4. Küçük ve çentikli iPhone ile iPad üzerinde dört oyunu oyna. İki tema, VoiceOver, Dynamic Type, klavye, kenar hareketi, kilit/arka plan ve tekrar oynama kontrolü yap. Ben Kimim?'de iki yatay tutuşta eğim yönlerini ve dokunmatik alternatifi fiziksel cihazda dene.
5. Oluşan ürünün privacy manifest'lerini ve gerekli API beyanlarını kontrol et. sensors_plus kendi PrivacyInfo.xcprivacy dosyasını pod kaynak paketiyle ekliyor. Runner kaynak ağacında ayrı manifest yok. Engine/SDK manifestleri ve archive sonucu Mac üzerinde değerlendirilecek.
6. Sonraki yetkili yayın aşamasında sürüm/build numarasını kesinleştir, gizlilik politikasını ve mağaza yanıtlarını hazırla, imzalı archive ve dağıtım doğrulamasını yap.

## 11. Değiştirilen dosyalar

- lib/features/games/tabu/presentation/tabu_screen.dart
- lib/features/games/charades/presentation/charades_screen.dart
- test/ios_navigation_guard_test.dart
- test/ios_release_layout_test.dart
- docs/ios_release_phase1.md

## 12. Doğrulama sonuçları

- flutter analyze temiz.
- flutter test --concurrency=1 ile 380 test geçti. Önceki 322 teste 56 yerleşim ve iki geri gezinme testi eklendi.
- flutter build apk --debug başarılı. Çıktı build/app/outputs/flutter-apk/app-debug.apk. ADB listesi boş olduğundan Redmi kurulumu bu çalışmada doğrulanamadı.
- Windows üzerinde native iOS derlemesi, Xcode testleri ve fiziksel iPhone testi yapılmadı.
- git diff --check temiz. main ve origin/main başlangıç commit'inde eşleşiyor. Beş faz dosyası çalışma ağacında. Commit, push veya mağaza gönderimi yapılmadı.

Doğrulama logları build/ios_release_phase1/ altında.

## 13. Riskler

| Risk | Öncelik | Kapatma ölçütü |
|---|---|---|
| Flutter 3.29 ve Xcode 26 araç zinciri uyumu | Yüksek | Desteklenen Flutter ile simulator ve unsigned cihaz build geçer |
| iOS 15 ve pod'ların etkili minimumu | Yüksek | Runner ve tüm bağımlılıklar çözülür, archive minimumu doğrulanır |
| iPad çoklu pencere ve orientation | Orta | İki yatay yön, giriş ve dikey dönüş gerçek iPad'de çalışır |
| Core Motion, haptik, gizli içerik ve App Switcher | Yüksek | Fiziksel iPhone senaryoları kaydedilir |
| Gelecekteki reklam paketleri ve veri açıklamaları | Yüksek | Ayrı reklam fazında pinlenen SDK, UMP ve mağaza beyanları doğrulanır |

## 14. Sonraki faz önerisi

Önce Mac'te Flutter/Xcode yükseltme ve iOS 15 denemesi. Ardından dört oyun için fiziksel cihaz kontrolü. Reklam ve yayın ayarlarını bu doğrulama sonrasında ayrı fazlarda ele al.
