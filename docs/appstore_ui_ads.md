# App Store öncesi UI ve reklam düzenlemeleri

Tarih: 11 Kasım 2026

## Uygulananlar

- İlk Flutter karesinde resmî kenarlıksız logo ve temaya uygun yüzey gösterilir. Flutter splash süresi 2.500 ms; son 350 ms ana ekranı açığa çıkaran fade geçişidir. Native splash süreleri/yapılandırmaları değiştirilmedi.
- Router alttaki ağaçta korunur; splash bittiğinde yeniden oluşturulmaz. Örtü kalkana kadar alttaki sayfaya dokunma ve erişilebilirlik odağı verilmez. Widget dispose sırasında animasyon denetleyicisi temizlenir.
- UMP/SDK başlangıcı splash kaldırıldıktan sonraki karede, sonucu beklenmeden başlatılır. UMP hatası veya bekleyen SDK işlemi ana ekranı bekletmez. Arka plandan dönüşte splash tekrar başlamaz; mevcut sınırlı rıza yeniden-deneme mekanizması korunur.
- Hero sloganı açık satır sonuyla `Eğlence` / `Bir Araya Getirir!` olarak gösterilir. Nunito, renkler ve illüstrasyon korunur. Başlık genişliğe göre ölçeklenir; büyük yazıda alt içerik alanı büyür ve üst mor dalga metnin arkasında kalır.
- Beyaz ok `context.go('/games')` ile mevcut StatefulShell Oyunlar dalına geçer. Yeni sayfa/rota eklenmedi. Alt navigasyon seçimi, oyun ekranından geri dönüş ve Ana Sayfa sekmesi test edilir.
- Ortak reklam servisinden iki oyunda bir koşulu kaldırıldı. İlk ve sonraki her tamamlanmış sonuç için çıkışta en fazla bir interstitial fırsatı vardır. Sayaç yalnızca tamamlanmış sonuç kimliğini bir kez kaydeder; sonuç açılışı reklam göstermez.
- Hazır reklam yoksa çıkış eşzamanlı devam eder. Gösterim hatası/kapanışı aynı navigasyona devam eder. UMP kontrolü, aynı sonuç için fırsatın bir kez tüketilmesi, QA manuel gösteriminin sayacı değiştirmemesi ve test/production birim ayrımı korunur.

## Doğrulama

- Gerçek Nunito fontuyla 320/375/430 px genişlik, açık/koyu tema, 1,0× ve 2,5× yazı ölçeği test edilir. İki satır, sınırlar ve okunabilir boyut denetlenir.
- Splash 2.150 ms bekleme + 350 ms fade, dokunma kilidi, bitiş geri çağrısı ve dönüşte tekrar görünmeme kontrolleri eklendi.
- Bekleyen UMP güncellemesi sırasında sekmelerin çalışabildiği test edildi.
- İlk ve sonraki dört tamamlanan oyun, aynı sonuç için çift çıkış, başarısız gösterim, hazır reklam olmaması, UMP engeli ve ortak sayaç testleri güncellendi.
- `fvm flutter analyze`: **No issues found**.
- `fvm flutter test`: **426 test başarılı** (önceki 409 + 17 yeni senaryo).
- `git diff --check`: temiz.
- Widget görsel önizleme testi: başarılı.

## Değişen dosyalar

- `lib/app/app.dart`: açılış katmanı ve reklam başlangıç yaşam döngüsü.
- `lib/app/launch_splash.dart`: yeni, yalnızca ilk açılışta kullanılan Flutter splash.
- `lib/features/home/presentation/home_screen.dart`: mevcut Oyunlar sekmesine geçiş.
- `lib/features/home/presentation/widgets/party_banner.dart`: iki satırlı responsive slogan ve mor yüzey sürekliliği.
- `lib/core/ads/ads_service.dart`: her tamamlanan sonuçta bir reklam fırsatı.
- `test/launch_home_test.dart`: splash ve 12 responsive slogan senaryosu.
- `test/admob_phase2_test.dart`: reklam/UMP/QA/açılış regresyonları.
- `test/widget_test.dart`: slogan ve ok navigasyonu doğrulamaları.
- `docs/ios_ads_qa.md`: güncel gösterim sıklığı açıklaması.
- `docs/appstore_ui_ads.md`: bu rapor.

## iOS/Android sınırları ve kalan cihaz kontrolü

Bu görevde Mac/Xcode, TestFlight veya fiziksel Android/iPhone testi yapılmadı; native derleme çalıştırılmadı. Flutter widget görselleri cihaz ekran görüntüsü değildir. Aynı Flutter katmanı iki platformda da kullanılır. Native açılıştan ilk Flutter karesine geçişin, sistem çubuklarının ve gerçek UMP modalının fiziksel cihazlarda soğuk açılışla yeniden kontrol edilmesi gerekir. Reklam fırsatı gerçek reklam gösterimi garantisi değildir; SDK rızası, bağlantı ve hazır reklam gereklidir.

Görsel önizlemeler ignored `build/home_ui_review/` klasörüne kaydedildi. Normal boyuttaki önizlemeler 320, 375 ve 430 px; büyük yazılı koyu tema 320 px / 2,5× örneğidir. Önizlemeler Nunito ve Material Icons fontlarıyla oluşturuldu; ok navigasyonu ayrıca widget testinde doğrulandı.

Commit veya push yapılmadı. Önceden mevcut `.vs/` klasörüne dokunulmadı. Pubspec, kilit dosyası, oyun kodları, reklam kimlikleri ve native platform dosyaları değiştirilmedi.
