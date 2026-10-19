# Oynika

Arkadaş ortamlarında oynanan beş parti oyununu bir araya getiren, Türkçe ve çevrimdışı Flutter uygulaması. Backend, üyelik ve giriş sistemi yoktur.

Faz 1 altyapısı tamamlandı. **Faz 2** onaylanan ana ekran tasarımını, oyun tanıtımlarını, alt navigasyonu ve tema seçimini içerir. **Faz 3** ile Tabu oynanabilir durumdadır; 250 çevrimdışı Türkçe kart içerir. Diğer dört oyun tanıtım aşamasındadır.

## Teknolojiler

- Flutter 3.29.0 / Dart 3.7.0
- Material 3
- flutter_riverpod 3.3.2
- go_router 17.0.0
- flutter_lints 5.0.0, Flutter SDK widget testleri
- Uygulamaya gömülü Nunito yazı tipi ve yerel PNG illüstrasyonları
- Android / iOS uygulama kimliği: com.oynika.app

Faz 2'de yeni paket eklenmedi. Tekrarlanabilir kurulum için pubspec.lock korunur. Uygulama sürümü: 0.1.0+1.

## Mimari

Feature-first yapı korunur:

```text
lib/
  main.dart
  app/
    app.dart
    router/app_router.dart
    theme/
      app_theme.dart
      theme_mode_provider.dart
  core/constants/app_dimensions.dart
  features/
    home/presentation/
      home_screen.dart
      widgets/
        home_header.dart
        party_banner.dart
    games/
      domain/party_game.dart
      presentation/
        games_screen.dart
        game_intro_screen.dart
    settings/presentation/settings_screen.dart
  shared/widgets/
    app_navigation_shell.dart
    game_art.dart
    game_card.dart
    game_collection.dart
    section_heading.dart
assets/
  fonts/
  illustrations/
  README.md
design_reference/home_screen.png
test/widget_test.dart
android/
ios/
```

Beş oyunun açıklamaları, renkleri, asset yolları ve temel oynanış açıklamaları PartyGame içinde tutulur. Tabu kendi modülünü kullanır; diğer tanıtımlar ortak GameIntroScreen şablonuyla üretilir; kullanılmayan boş oyun ekranları yoktur.

## Ekranlar ve rotalar

- `/`: Oynika logosu, slogan, organik mor karşılama alanı ve oyun kartları. Beyaz ok, oyunlar bölümüne animasyonla kaydırır. Ayarlar alt navigasyondan açılır.
- `/games`: Aynı oyun kartlarını kullanan oyun listesi.
- `/settings`: Sistem/Açık/Koyu tema, hakkında, sürüm ve açık kaynak lisansları.
- `/games/taboo`: Tabu kurulumu ve beş evreli gerçek oyun akışı.
- `/games/charades`
- `/games/who_am_i`
- `/games/five_seconds`
- `/games/never_have_i_ever`

Tanıtım ekranlarında oyun adı, illüstrasyon, kısa açıklama, nasıl oynanır adımları ve geliştirme bilgisi bulunur. Geri butonu önceki ekrana döner; doğrudan açılan tanıtımlarda oyun listesine gider. Geçersiz oyun adresleri oyun listesine yönlenir.

Alt navigasyon StatefulShellRoute ile üç sekmenin gezinme/kaydırma durumunu korur. Tanıtımlar sekmelerin üzerinde açılır. NavigationBar sistem safe area alanını kullanır.

## Tasarım ve tema

Referans: design_reference/home_screen.png. Telefon çerçevesi ve sistem çubuğu çizilmez. Ekran bir arka plan resmi değildir; kartlar, metinler, CustomPainter ile çizilen dalgalı şekil, butonlar ve navigasyon gerçek Flutter widget'larıdır.

Palet: koyu mor #46309B, lavanta #E8DDFB, krem #FFF9F1, mercan #FF8C85, sarı #FFE5A8, mint #D9F5E8, açık mavi #DCE9FF. Koyu tema, pastel kartları koyu yüzeylerle harmanlar ve açık renkli metinler kullanır. Yazı stilleri AppTheme, ölçüler AppDimensions içinde merkezidir.

Tema seçimi Riverpod ile uygulama açıkken korunur. Uygulama yeniden başladığında Sistem seçilir; diske kalıcı kayıt henüz eklenmedi.

İlk dört kart iki sütundur; Ben Hiç... kartı tam genişliktedir. Metinler kesilmeden sarılır, içerik kaydırılabilir, tabletlerde azami genişlik 720 mantıksal pikseldir. Kartlarda hafif basma animasyonu vardır. Ayrı AI illüstrasyonları ve Nunito fontunun kaynak/lisans bilgileri assets/README.md içindedir.

## Planlanan oyunlar

1. Tabu
2. Sessiz Sinema
3. Ben Kimim?
4. 5 Saniyede Söyle!
5. Ben Hiç...

## Kurulum ve doğrulama

Flutter SDK'yı PATH'e ekleyin; Android Studio, Android SDK ve bir Android sanal cihazı kurun.

```powershell
cd D:\Projects\Oynika
flutter doctor
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Lisans uyarısı varsa lisansları inceleyip kabul etmek için:

```powershell
flutter doctor --android-licenses
```

## Android emülatöründe çalıştırma

```powershell
flutter emulators
flutter emulators --launch Pixel_3
flutter devices
flutter run -d emulator-5554
```

Pixel_3 bu bilgisayardaki AVD adıdır. Başka ortamda flutter emulators ve flutter devices çıktılarındaki kimlikleri kullanın. Bağlı telefon için flutter run -d TELEFON_KIMLIGI kullanılabilir.

Debug APK: build/app/outputs/flutter-apk/app-debug.apk

iOS yapılandırmaları korunmuştur; Windows ortamında iOS derlenmez. iOS cihaz doğrulaması macOS ve Xcode gerektirir. Yayın imzalama ayarları bu fazın dışındadır.

## Testler

Faz 1'in açılış, başlık, beş oyun ve küçük ekran kontrolleri korunup yeni tasarımın sloganına/yerleşimine uyarlandı. Faz 2'de toplam 15 widget testi:

- Ana ekranın hatasız açılması, slogan ve beş oyunun erişilebilir olması
- Her kartın doğru oyun tanıtımını açması ve geri dönüş
- Üç alt sekme, Oyunlar ekranından tanıtım, alt Ayarlar ikonu
- Sistem/Açık/Koyu seçimi ve sekmeler arasında temanın korunması
- Karşılama okunun oyunlara kaydırması
- Geçersiz oyun rotasının yönlendirilmesi
- 320, 393 ve 768 piksel genişlikte koyu tema
- 320 pikselde 1.6 kat yazı ölçeğiyle gezinme

Faz 2 doğrulaması (18 Ekim 2026): pub get başarılı, analyze temiz, 15 test başarılı, debug APK başarılı. Pixel 3 emülatöründe açık/koyu tema, sekmeler ve tanıtım ekranları görsel olarak doğrulandı.

## Bilinen sınırlar

- Tabu oynanabilir; diğer dört oyun geliştirme aşamasındadır.
- Tema seçimi yalnızca oturum boyunca korunur.
- Üretilen illüstrasyonlar referansın yeniden yorumudur; birebir aynı çizimler değildir.
- iOS derleme/cihaz testi yapılmadı.

## Faz 2.1 — resmî logo ve uygulama ikonu

Resmî kaynak logo assets/branding/oynika_logo.png konumundadır. Android launcher/adaptive/monochrome ikonları, iOS AppIcon kataloğu ve native splash görselleri bu kaynaktan üretildi; yeni paket eklenmedi. Ana ekrandaki başlık ve slogan korunarak resmî logo eklendi.

Üretim betiği, boyutlar, kaynak hash'i ve platform sınırlamaları: [Marka entegrasyonu](assets/branding/README.md).

## Faz 3 — oynanabilir Tabu

Kurallar, mimari, 250 kartın kategori/zorluk dağılımı, araştırma kaynakları, testler ve emülatör doğrulaması: [Faz 3 teknik notları](docs/tabu_phase3.md).

Modül: lib/features/games/tabu/ (domain, data, application, presentation). Kart asset'i: assets/data/tabu_cards.json. Yeni testler: test/tabu_controller_test.dart ve test/tabu_widget_test.dart. Toplam 64 test; oyun oturumu yalnızca bellekte tutulur.

Tabu güncel kuralı: tur sınırı yoktur; 10/15/20/25/30 hedef puanından seçilene ilk ulaşan takım kazanır. Varsayılan hedef 20'dir. Kart havuzu tükenince yeniden karıştırılır ve oyun sürer.

Her Tabu turunda en fazla 3 pas kullanılabilir. Oynanışta küçük süre kapsülü ve aktif takımın puan/hedefi gösterilir. Tur Sonu ekranında iki pastel toplam skor kartı ve yalnızca Sonraki Takım butonu bulunur.
