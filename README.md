# Oynika

Arkadaş ortamlarında oynanan dört parti oyununu bir araya getiren, Türkçe ve çevrimdışı Flutter uygulaması. Backend, üyelik ve giriş sistemi yoktur.

Faz 1 altyapısı tamamlandı. **Faz 2** onaylanan ana ekran tasarımını, oyun tanıtımlarını, alt navigasyonu ve tema seçimini içerir. **Faz 3** ile Tabu oynanabilir durumdadır; 1.000 çevrimdışı Türkçe kart içerir. Faz 4 ile Sessiz Sinema da 300 film ve 200 dizi kartıyla oynanabilir. Faz 5 ile Aramızdaki Casus da oynanabilir. Ben Kimim? Faz 6.3.1 ile 300 kart, gerçek tur, sayaç ve dokunmatik Doğru/Pas kontrolleriyle oynanabilir.

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

Dört oyunun sırası, açıklaması, renkleri, asset yolları, rotası ve oynanabilirlik durumu PartyGame içinde tutulur. Ana ekran ve Oyunlar sekmesi bu kataloğu kullanır. Oyun sayısı ve slogan katalogdan türetilir. Tabu, Sessiz Sinema ve Aramızdaki Casus kendi modüllerini kullanır; Ben Kimim? kendi ayar ve başlangıç modülünü kullanır.

## Ekranlar ve rotalar

- `/`: Oynika logosu, slogan, organik mor karşılama alanı ve oyun kartları. Beyaz ok, oyunlar bölümüne animasyonla kaydırır. Ayarlar alt navigasyondan açılır.
- `/games`: Aynı oyun kartlarını kullanan oyun listesi.
- `/settings`: Sistem/Açık/Koyu tema, hakkında, sürüm ve açık kaynak lisansları.
- `/games/taboo`: Tabu kurulumu ve beş evreli gerçek oyun akışı.
- `/games/charades`: Sessiz Sinema kurulumu ve beş evreli oyun akışı.
- `/games/who_am_i`: Oyuncu/süre ayarları, hazırlık, 3 saniyelik başlangıç, aktif tur, duraklatma ve tur sonuçları.
- `/games/undercover`: Gizli dağıtım, ipucu, oylama, eleme, sonuç ve tekrar oynama.

Tanıtım ekranlarında oyun adı, illüstrasyon, kısa açıklama, nasıl oynanır adımları ve geliştirme bilgisi bulunur. Geri butonu önceki ekrana döner; doğrudan açılan tanıtımlarda oyun listesine gider. Geçersiz oyun adresleri oyun listesine yönlenir.

Alt navigasyon StatefulShellRoute ile üç sekmenin gezinme/kaydırma durumunu korur. Tanıtımlar sekmelerin üzerinde açılır. NavigationBar sistem safe area alanını kullanır.

## Tasarım ve tema

Referans: design_reference/home_screen.png. Telefon çerçevesi ve sistem çubuğu çizilmez. Ekran bir arka plan resmi değildir; kartlar, metinler, CustomPainter ile çizilen dalgalı şekil, butonlar ve navigasyon gerçek Flutter widget'larıdır.

Palet: koyu mor #46309B, lavanta #E8DDFB, krem #FFF9F1, mercan #FF8C85, sarı #FFE5A8, mint #D9F5E8, açık mavi #DCE9FF. Koyu tema, pastel kartları koyu yüzeylerle harmanlar ve açık renkli metinler kullanır. Yazı stilleri AppTheme, ölçüler AppDimensions içinde merkezidir.

Tema seçimi Riverpod ile uygulama açıkken korunur. Uygulama yeniden başladığında Sistem seçilir; diske kalıcı kayıt henüz eklenmedi.

Dört kart, katalog sırasına göre iki sütun ve iki satırda gösterilir. Metinler kesilmeden sarılır, içerik kaydırılabilir, tabletlerde azami genişlik 720 mantıksal pikseldir. Kartlarda hafif basma animasyonu vardır. Ayrı AI illüstrasyonları ve Nunito fontunun kaynak/lisans bilgileri assets/README.md içindedir.

## V1 oyun kataloğu

1. Tabu — oynanabilir.
2. Sessiz Sinema — oynanabilir.
3. Aramızdaki Casus — oynanabilir.
4. Ben Kimim? — 300 kart ve dokunmatik kontrollerle oynanabilir.

Ana slogan: **4 Oyun, Tek Uygulama!**
Destekleyici metin: **Arkadaşlarınla eğlence Oynika'da!**

Dört oyun da uygulama içinden oynanabilir. App Store yayın/hak ve cihaz incelemeleri ayrı hazırlık aşamasıdır. [V1 kapsamı](docs/v1_product_structure.md).

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

Faz 1'in açılış, başlık, dört oyun ve küçük ekran kontrolleri korunup yeni tasarımın sloganına/yerleşimine uyarlandı. Faz 2'de toplam 15 widget testi:

- Ana ekranın hatasız açılması, slogan ve dört oyunun erişilebilir olması
- Her kartın doğru oyun tanıtımını açması ve geri dönüş
- Üç alt sekme, Oyunlar ekranından tanıtım, alt Ayarlar ikonu
- Sistem/Açık/Koyu seçimi ve sekmeler arasında temanın korunması
- Karşılama okunun oyunlara kaydırması
- Geçersiz oyun rotasının yönlendirilmesi
- 320, 393 ve 768 piksel genişlikte koyu tema
- 320 pikselde 1.6 kat yazı ölçeğiyle gezinme

Faz 2 doğrulaması (18 Ekim 2026): pub get başarılı, analyze temiz, 15 test başarılı, debug APK başarılı. Pixel 3 emülatöründe açık/koyu tema, sekmeler ve tanıtım ekranları görsel olarak doğrulandı.

## Bilinen sınırlar

- Dört oyun oynanabilir. Ben Kimim? hareket sensörleri sonraki faza bırakıldı; bu sürüm dokunmatik kontroller kullanır.
- Tema seçimi yalnızca oturum boyunca korunur.
- Üretilen illüstrasyonlar referansın yeniden yorumudur; birebir aynı çizimler değildir.
- iOS derleme/cihaz testi yapılmadı.

## Faz 2.1 — resmî logo ve uygulama ikonu

Resmî kaynak logo assets/branding/oynika_logo.png konumundadır. Android launcher/adaptive/monochrome ikonları, iOS AppIcon kataloğu ve native splash görselleri bu kaynaktan üretildi; yeni paket eklenmedi. Ana ekrandaki başlık ve slogan korunarak resmî logo eklendi.

Üretim betiği, boyutlar, kaynak hash'i ve platform sınırlamaları: [Marka entegrasyonu](assets/branding/README.md).

## Faz 3 — oynanabilir Tabu

Kurallar, mimari, 500 kartın kategori/zorluk dağılımı, araştırma kaynakları, testler ve emülatör doğrulaması: [Faz 3 teknik notları](docs/tabu_phase3.md).

Modül: lib/features/games/tabu/ (domain, data, application, presentation). Kart asset'i: assets/data/tabu_cards.json. Yeni testler: test/tabu_controller_test.dart ve test/tabu_widget_test.dart. Toplam 72 test; oyun oturumu yalnızca bellekte tutulur.

Tabu güncel kuralı: tur sınırı yoktur; 10/15/20/25/30 hedef puanından seçilene ilk ulaşan takım kazanır. Varsayılan hedef 20'dir. Kart havuzu tükenince yeniden karıştırılır ve oyun sürer.

Her Tabu turunda en fazla 3 pas kullanılabilir. Oynanışta küçük süre kapsülü ve aktif takımın puan/hedefi gösterilir. Tur Sonu ekranında iki pastel toplam skor kartı ve yalnızca Sonraki Takım butonu bulunur.

Faz 3.1: mevcut 250 kart korunarak 250 yeni kart eklendi. Her kategoride 50 kart bulunur. Veri doğrulaması, içerik yaklaşımı ve yeni örnekler: [500 kartlık havuz raporu](docs/tabu_phase31.md).

## Faz 4 — Sessiz Sinema

500 yapım kartı (300 Film / 200 Dizi), sınırsız dönüşümlü tur, hedef puan, sınırsız pas ve konuşmadan anlatım. Ekranlar, mimari, kaynak doğrulaması, 30 örnek ve test bilgileri: [Faz 4 raporu](docs/charades_phase4.md). Yeni bağımlılık eklenmedi.


## Faz 6.1 — Ben Kimim? ayarları

`lib/features/games/who_am_i/` altında domain, application ve presentation katmanları bulunur. 2–20 oyuncu (varsayılan 4), düzenlenebilir benzersiz isimler ve 60/90/120 saniye (varsayılan 90) seçimi desteklenir. Başlatma ayarları doğrular ve geçici başlangıç ekranını açar. Kartlar, sensör, puanlama ve geri sayım bu fazda yoktur; katalogda oyun hâlâ geliştirme aşamasındadır. [Faz 6.1 raporu](docs/who_phase61.md).


## Faz 6.2 — Ben Kimim? kart havuzu

300 yerel kart `assets/data/who_am_i_cards.json` içindedir. Kategori/zorluk enumları, asset repository, enjekte edilebilir rastgelelik ve oturuma bağlı tekrarsız deste servisi eklendi. Faz 6.1 ekranları korunur; oynanış ve sensörler bu fazda yoktur. [Kategori, zorluk ve yayın incelemesi raporu](docs/who_phase62.md).


## Faz 6.3.1 — Ben Kimim? gerçek oynanış

Ayarlar → oyuncu hazırlığı → 3/2/1 → aktif tur → tur sonucu → sıradaki oyuncu. Doğru +1, Pas 0 ve sınırsız pas; sınırsız oyuncu turları ve korunmuş toplam puanlar. Süre monoton saate dayanır; arka planda kart gizlenip tur duraklar ve manuel devam gerekir. 300 kartlık deste oturum boyunca korunur; yeniden başlatma yeni deste ve sıfır puanlarla başlar. [Faz 6.3.1 raporu](docs/who_phase631.md).

## Faz 6.3.1.1 — yatay oynanış

Oyuncu hazırlığı dikey; 3/2/1 sonrası yatay görünüm ve Hazırım onayıyla tur başlar. Mor karttaki büyük beyaz kelime ve alt Doğru/Pas kontrolleri yatay ekrana uyarlanır. Sonuç ve çıkışta dikeye dönülür. [Yön yönetimi ve doğrulama](docs/who_phase631_landscape.md).

## Faz 6.3.2 — hareketle Doğru/Pas

Hazırım sonrasında kısa nötr kalibrasyon, öne eğerek Doğru ve arkaya eğerek Pas. Her yeni hareket için kararlı nötr pozisyona dönüş gerekir. Sensör kullanmadan dokunmatik devam seçeneği korunur. [Sensör mimarisi, eşikler ve Redmi kontrol listesi](docs/who_phase632.md).

## Faz 6.3.2.1 — anında başlatma ve sensör tanısı

Hazırım kelimeyi ve süreyi hemen başlatır. Gyro/yerçekimi referansı arka planda oluşur; sensör oyunu engellemez. Üstte yeniden ayarlama kontrolü ve yalnızca debug derlemesinde sensör paneli bulunur. [Düzeltme raporu ve Redmi test adımları](docs/who_phase6321.md).

## Faz 6.3.2.2 — sade yatay oyun ekranı

İnce oyuncu/süre/tur puanı çubuğu, büyük mor kelime kartı ve iki alt kontrol. Sensör tanısı debug APK'da da varsayılan gizlidir; release'te gösterilmez. [Görsel düzen ve geliştirici debug seçeneği](docs/who_phase6322.md).

## Faz 6.4 — hedef puan, genel tablo ve insan kartları

Ben Kimim? artık varsayılan 20 hedef puanıyla oynanır; bütün oyuncular normal tur sırasını tamamlamadan kazanan belirlenmez. Eşit liderler ek tur oynar. Genel tablo ve kazanan ekranı eklendi. Kart havuzu 300 insan/insan karakteri adıyla yenilendi. [Kurallar, kategori dağılımı ve doğrulama](docs/who_phase64.md).

## Faz 6.5 — kalite kontrolü ve iOS hazırlığı

Gecikmiş/çift arayüz çağrılarına karşı korumalar, iOS yön ipucu düzeltmesi ve CocoaPods hazırlığı tamamlandı. Onaylanan sensör eşikleri ve tasarım korundu. [Kalite raporu ve Mac/Xcode kontrol listesi](docs/who_phase65.md).

## Tabu — 1.000 kartlık güncel havuz

Mevcut 500 karta 500 özgün kart eklendi. Eski kategori etiketleri korunur; yeni kartlar istenen 10 kategoriye ayrılır. Yeni kartların zorluk dağılımı %40 kolay, %45 orta, %15 zordur. Bir önceki havuzda yalnızca “Önyargı” yazımı “Ön yargı” olarak düzeltildi. Dağılım, kalite kontrolü ve doğrulama sonuçları: [1.000 kart raporu](docs/tabu_1000_cards.md). Önceki faz raporları tarihsel sonuçları içerir.
