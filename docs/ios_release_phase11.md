# Oynika | iOS Faz 1.1

9 Kasım 2026 · Windows araç zinciri ve iOS proje hazırlığı.

## Araç zinciri

Başlangıç Flutter 3.29.0 ve Dart 3.7.0. Hedef Flutter 3.38.10 stable ve birlikte dağıtılan Dart 3.10.9. Flutter 3.38 serisi Xcode 26 ve iOS 26 desteğini duyurdu. 3.38.10 bu serinin son stable yaması olarak seçildi. Proje FVM üzerinden sabitlenir. [Flutter 3.38 duyurusu](https://flutter.dev/blog/whats-new-in-flutter-3-38) · [Flutter SDK arşivi](https://docs.flutter.dev/install/archive)

Geliştirici komutları proje dizininde fvm flutter ile çalıştırılır. FVM SDK bağlantıları ve önbellekleri yereldir. Repo, sürüm pinini paylaşır. Başlangıç git status ve Flutter sürümü terminalde doğrulandı. Flutter Doctor ve pub outdated kayıtları build/ios_phase11/ altındadır.

## Bağımlılıklar

fvm flutter pub get, mevcut lockfile üzerinden çözüldü. pubspec.yaml araç zinciri tabanını Dart 3.10 ve Flutter 3.38.1 olarak ilan ediyor. Paket kısıtları korundu. flutter_riverpod ve riverpod 3.3.2, go_router 17.0.0 ve sensors_plus 6.1.2 korundu. Uygulama kodunda Riverpod veya go_router API geçişi gerekmedi.

| Dolaylı paket | Önce | Sonra |
|---|---:|---:|
| fake_async | 1.3.2 | 1.3.3 |
| leak_tracker | 10.0.8 | 11.0.2 |
| leak_tracker_flutter_testing | 3.0.9 | 3.0.10 |
| leak_tracker_testing | 3.0.1 | 3.0.2 |
| meta | 1.16.0 | 1.17.0 |
| test | 1.25.15 | 1.26.3 |
| test_api | 0.7.4 | 0.7.7 |
| test_core | 0.6.8 | 0.6.12 |
| vector_math | 2.1.4 | 2.2.0 |

Lockfile SDK alt sınırları pubspec ile eşleşiyor. Projenin fiilen kullandığı araç zinciri .fvmrc ile sabitlenen Flutter 3.38.10 ve Dart 3.10.9. PATH üzerindeki sistem Flutter'ı 3.29.0 ve Dart 3.7.0 olarak doğrulandı.

## iOS 15.0

- ios/Podfile platformu 15.0. Post-install, açıkça daha düşük sürüme ayarlanmış pod hedeflerini 15.0'a yükseltir ve daha yüksek minimumları korur.
- Xcode proje ayarlarında Debug, Profile ve Release 15.0. Runner ve RunnerTests her üç yapılandırmada proje hedefini devralır.
- AppFrameworkInfo.plist MinimumOSVersion 15.0.
- Statik doğrulama, dokuz proje/target yapılandırmasını, framework plist değerini ve Podfile platform değerini kapsadı.
- Xcode 26 ile desteklenen iOS deployment aralığı 15.0'dan başlar. App Store Connect yükleme koşulu iOS 26 SDK veya üstü. Minimum sürüm artışı, iOS 12–14 cihazlarının yeni uygulama sürümünü yükleyemeyeceği anlamına gelir. [Xcode gereksinimleri](https://developer.apple.com/xcode/system-requirements) · [Apple yükleme koşulları](https://developer.apple.com/news/upcoming-requirements/?id=04282026a)

## Mac doğrulaması

1. FVM ile pinli Flutter'ı kur. flutter doctor -v, xcodebuild -version ve xcrun --sdk iphoneos --show-sdk-version çıktılarında seçilen araç zincirini doğrula.
2. fvm flutter pub get ve ios dizininde pod install çalıştır. Runner.xcworkspace içinden Debug, Profile, Release ve RunnerTests için etkili deployment target değerlerini kontrol et.
3. iOS simulator build ve RunnerTests XCTest paketini çalıştır. iPhone'da dört oyunu, Ben Kimim?'in iki yatay yönünü, sensör eğimlerini, geri dönüşü ve yaşam döngüsünü doğrula.
4. Yetkili imzalama ortamında Release archive al. Bundle kimliği, minimum iOS, SDK, gizlilik manifestleri ve mağaza doğrulamasını kontrol et.

## Riskler

- Pod çözümlemesi, Xcode build ve iPhone davranışı Mac aşamasına bağlı.
- iOS 15 altındaki cihazlar yeni sürüm kapsamından çıkar.
- Android yapılandırması Flutter SDK varsayılanlarını kullanıyor. Yükseltmeyle minimum Android API 21 yerine 24, compileSdk ve targetSdk 35 yerine 36 oluyor. API 21–23 cihazlar yeni APK’yı yükleyemez. Android 36 davranışları cihazda ayrıca kontrol edilmeli.
- Flutter, mevcut Kotlin Gradle eklentisi 1.8.22 için gelecekte destekten çıkma uyarısı veriyor. Bu derleme sürüm denetimi açıkken başarılı oldu. Sonraki Android araç zinciri yükseltmesinde Kotlin uyumu yeniden değerlendirilmeli.
- 3.38.10 seçimi bu fazdaki yükseltme kapsamını sınırlıyor. Release öncesinde araç zincirinin güncel güvenlik yamaları ve Apple gereksinimleri tekrar kontrol edilmeli.

## Flutter API uyarlaması

İlk analiz, tema seçeneklerinin RadioListTile.groupValue ve onChanged kullanımlarında iki deprecation uyarısı verdi. Üç seçenek RadioGroup üzerinden aynı Riverpod seçimini kullanıyor. Metinler, ikonlar ve renkler korundu. Faz 1'in Tabu/Sessiz Sinema çıkış korumaları ve testleri çalışma ağacında. Bu fazda oyun koduna veya Ben Kimim? hareket yönü ve eşiklerine dokunulmadı.

## Son doğrulama

- FVM araç zinciri Flutter 3.38.10 stable ve Dart 3.10.9 olarak doğrulandı.
- fvm flutter analyze --no-pub temiz.
- fvm flutter test --concurrency=1 --no-pub ile mevcut 380 testin tamamı geçti. Test beklentileri değiştirilmedi.
- fvm flutter build apk --debug --no-pub başarılı. Çıktı build/app/outputs/flutter-apk/app-debug.apk. APK metadata’sı minSdk 24, compileSdk 36 ve targetSdk 36 olarak doğrulandı. ADB cihaz listesi boştu.
- iOS doğrulaması Windows üzerinde statik dosya denetimiyle sınırlı. Xcode, CocoaPods kurulumu, simulator, XCTest, iPhone ve Release archive adımları Mac aşamasında bekliyor.

## Git durumu

Başlangıç dalı main, HEAD ve origin/main 5687fcf. Faz 1’in iki ekran düzeltmesi, iki test dosyası ve raporu korundu. Faz 1.1 dosyaları .fvmrc, .gitignore, pubspec.yaml, pubspec.lock, ios/Podfile, ios/Runner.xcodeproj/project.pbxproj, ios/Flutter/AppFrameworkInfo.plist, lib/features/settings/presentation/settings_screen.dart ve bu rapor. Doğrulama logları build/ios_phase11/ altında Git dışında tutuluyor.

Son git diff --check temiz. main ve origin/main başlangıç commit’inde eşleşiyor. Değişiklikler çalışma ağacında, commit ve push yapılmadı.
