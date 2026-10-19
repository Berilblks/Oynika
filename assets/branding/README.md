# Oynika — Faz 2.1 marka entegrasyonu

## Kaynak logo
- Kaynak: assets/branding/oynika_logo.png
- Kullanıcının eklediği onaylı 1254 × 1254 PNG, bu yol başlangıçta mevcut olmadığından birebir kopyalandı.
- SHA-256: BAA2D7B7CD737D7E709EA9BDBD6F0FEEE82ACD55CB6FE8A83D805F62EFFF5EB6
- Kaynak dosyaya kırpma, yeniden çizim, renk veya oran değişikliği uygulanmadı.

## Tekrar üretim
Windows üzerinde, ek Dart/Python paketi gerektirmeyen PowerShell ve System.Drawing betiği:

```powershell
pwsh -NoProfile -File tool/generate_branding.ps1
```

Betik kaynak dosyanın hash'ini üretim öncesi ve sonrasında karşılaştırır. Yüksek kaliteli bicubic örnekleme kullanılır; kaynak dosya en büyük 1024 piksel çıktıyı karşılar. Önizlemeler yalnızca build/branding-verification altında oluşturulur.

## Android
- Eski launcher: mdpi 48, hdpi 72, xhdpi 96, xxhdpi 144, xxxhdpi 192 piksel.
- Android 8+ adaptive icon: mipmap-anydpi-v26/ic_launcher.xml.
- 108 dp ön plan katmanının merkezinde 72 dp çerçevesiz logo ve krem arka plan. Görünür alan doldurulur; yazı ve küçük dekorlar merkezde korunur. Dış köşe desenlerini launcher kendi şekline göre maskeler.
- Android 13+ override: mipmap-anydpi-v33/ic_launcher.xml; ayrı ic_launcher_monochrome alpha maskesi.
- Monochrome maskesi renkli PNG'nin doğrudan kullanımı değildir. Orta alandaki yazı, gülümseme ve küçük dekorların silueti çıkartılır; sınırı kesen arka plan parçaları dışlanır. Sistem bu beyaz/şeffaf maskeyi kullanıcının tema rengine boyar.
- Daire, squircle ve yuvarlatılmış kare önizlemeleri üretildi.
- Android application label: Oynika.

## iOS
- Mevcut AppIcon.appiconset kataloğundaki iPhone, iPad ve 1024 × 1024 App Store ikonları çerçevesiz logo sürümünden üretildi.
- Çıktılar kare, RGB PNG; alpha kanalı yoktur.
- İkonlara yeni bir köşe maskesi uygulanmadı; kaynak logonun onaylı dekoru aynen korunur.
- CFBundleDisplayName ve CFBundleName: Oynika.
- Windows ortamında iOS derlemesi/cihaz testi yapılmaz; macOS/Xcode doğrulaması gerekir.

## Native splash
- Android 11 ve öncesi: launch_background.xml üzerinden ortalanmış 144 dp logo.
- Android 12+: windowSplashScreenAnimatedIcon, 288 dp tuval içinde 128 dp kare logo. Böylece tam kare, sistemin 192 dp çapındaki görünür dairesine sığar.
- Her iki Android sürümünde sade beyaz zemin; bekleme süresi, özel animasyon veya splash Activity eklenmedi.
- iOS LaunchScreen.storyboard: ortalı 168 × 168 punto logo; 1x/2x/3x görseller, aspect-fit.
- Flutter'ın ilk karesi hazır olduğunda normal başlangıç akışı devam eder.

## Ana ekran
Başlık ve sloganın yerleşimi korunur. Dış beyaz çerçevesi kaldırılmış resmî logo üst bölümün sağında statik bir görsel olarak 43 × 43 mantıksal pikselde, BoxFit.contain ile gösterilir. Bu görsel bir ayarlar butonu değildir. Kaynak logo boyanmaz veya kırpılmaz. Karşılama alanı ve oyun ekranları değiştirilmedi.

## Kontroller
- flutter pub get, flutter analyze, flutter test ve flutter build apk --debug çalıştırılır.
- Widget testlerinde resmî asset'in yüklenmesi ve contain yerleşimi de kontrol edilir.
- Tüm iOS ikonları kare/RGB olarak doğrulandı.
- Kaynak SHA-256 üretim sonrası değişmedi.
- Themed ikonun gerçek görünümü launcher'ın themed icon desteğine ve kullanıcı tercihine bağlıdır.

## Platform kaynakları
- https://developer.android.com/develop/ui/compose/system/icon_design_adaptive
- https://developer.android.com/develop/ui/views/launch/splash-screen
- https://developer.apple.com/documentation/xcode/configuring-your-app-icon

## Doğrulama sonucu
- flutter pub get başarılı; flutter analyze temiz; 15 widget testi başarılı.
- Debug APK oluşturuldu.
- Pixel 3 emülatöründe uygulama kaldırılıp yeniden kuruldu; launcher ikonu ve Oynika adı doğrulandı.
- Android native splash üzerinde Oynika logosu görüntülendi.
- Daire/squircle/yuvarlatılmış kare ve tek renkli tema önizlemeleri build/branding-verification altında incelendi. Gerçek themed icon görünümü kullanıcı/launcher ayarına bağlıdır.
- Bir derleme denemesinde ana bilgisayar belleği tükendi. Derleme geçici düşük JVM bellek sınırıyla başarılı oldu; android/gradle.properties kaynak ayarı geri yüklendi.

- Son test çalıştırmasında C: geçici dizininde alan kalmadı. TEMP/TMP yalnızca komut oturumu için D:/Projects/Oynika/build/tool-tmp konumuna yönlendirilerek 15 test tekrar başarıyla tamamlandı. Sistem ayarı veya kullanıcı dosyaları değiştirilmedi. C: sürücüsündeki sınırlı boş alan geliştirme araçlarını etkileyebilir.

- Standart AVD disk kontrolü nedeniyle son oturum için aynı Pixel 3 profilinin geçici bir kopyası build/branding-verification/avd altında oluşturuldu. Orijinal AVD dosyaları değiştirilmedi.

Dış çerçeve düzeltmesi ve üretim prompt'ları: [borderless-logo.md](borderless-logo.md).
