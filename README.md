# Oynika — Faz 1

Arkadaş ortamlarında oynanabilecek, Türkçe ve çevrimdışı bir parti oyunları uygulaması. Faz 1 yalnızca proje altyapısını ve geçici ana ekranı içerir. Backend, veritabanı, üyelik veya giriş sistemi yoktur. Oyunlar henüz oynanamaz.

## Teknolojiler
- Flutter 3.29.0 / Dart 3.7.0
- Material 3, sistem ayarına göre açık/koyu tema
- flutter_riverpod 3.3.2: uygulama kapsamı ve router yaşam döngüsü
- go_router 17.0.0: yönlendirme
- flutter_lints 5.0.0 ve Flutter SDK widget testleri
- Android ve iOS uygulama kimliği: com.oynika.app

Doğrudan bağımlılıklar mevcut SDK ile uyumlu kararlı sürümlerdir. Tekrarlanabilir kurulum için pubspec.lock dosyasını koruyun.

## Klasör mimarisi
Feature-first yapı:
- lib/main.dart: ProviderScope ile başlangıç
- lib/app/app.dart: uygulama yapılandırması
- lib/app/router/app_router.dart: ana ekran (/) ve ileride eklenecek rotalar
- lib/app/theme/app_theme.dart: renkler, ortak yazı stilleri ve temalar
- lib/core/constants/app_dimensions.dart: boşluklar, köşe yarıçapı ve içerik genişliği
- lib/features/home/presentation/home_screen.dart: geçici ana ekran
- test/widget_test.dart: açılış, başlık, oyun adları ve küçük ekran/koyu tema testleri
- android/ ve ios/: platform projeleri

İhtiyaç doğduğunda shared/widgets, core/utils ve features altında taboo, charades, who_am_i, five_seconds, never_have_i_ever eklenecek. Şimdilik boş dosya veya kullanılmayan sınıf oluşturulmadı.

## Kurulum
Flutter SDK'yı PATH'e ekleyin; Android Studio, Android SDK ve bir Android sanal cihazı kurun.

```powershell
cd D:\Projects\Oynika
flutter doctor
flutter pub get
flutter analyze
flutter test
```

Android araçları lisans uyarısı verirse lisansları inceleyip kabul etmek için:
```powershell
flutter doctor --android-licenses
```

## Android emülatöründe çalıştırma
```powershell
flutter emulators
flutter emulators --launch Pixel_3
flutter devices
flutter run -d <emulator-device-id>
```

flutter devices çıktısındaki gerçek emülatör kimliğini kullanın (örneğin emulator-5554). Pixel_3 bu bilgisayardaki AVD adıdır; başka bilgisayarda mevcut AVD adını kullanın.

Debug APK:
```powershell
flutter build apk --debug
```

Çıktı: build/app/outputs/flutter-apk/app-debug.apk

iOS derlemesi ve cihaz doğrulaması macOS üzerinde Xcode gerektirir; Faz 1 Windows ortamında zorunlu değildir. Yayın imzalama ayarları sonraki yayın hazırlığına aittir.

## Planlanan oyunlar
1. Tabu
2. Sessiz Sinema
3. Ben Kimim?
4. 5 Saniyede Söyle!
5. Ben Hiç...

Geçici palet: Primary #7255E8, Secondary #FF725E, açık arka plan #F8F7FC. Tasarım Faz 2'de kullanıcıyla birlikte değiştirilebilir.

## Faz 1 doğrulaması (17 Ekim 2026)
- flutter pub get: başarılı.
- flutter analyze: sorun bulunmadı.
- flutter test: 3 widget testi başarılı.
- flutter build apk --debug: başarılı.
- Pixel_3 / emulator-5554 üzerinde flutter run ile açılış ve beş oyun adı doğrulandı.
- iOS derlemesi Windows ortamında çalıştırılmadı.
- Ortam notu: flutter doctor bazı Android SDK lisanslarının kabul edilmediğini bildiriyor; mevcut debug derlemesini engellemedi. Emülatörün ilk açılışında System UI yanıt vermiyor uyarısı bir kez görüldü; Bekle seçildikten sonra uygulama açık kaldı. Uygulama çalışma zamanı kayıtlarında hata görülmedi.
