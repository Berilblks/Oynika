# Ben Kimim? — Faz 6.3.1

## Gerçek oyun akışı

Ayarlar → oyuncu hazırlığı → 3/2/1 → aktif tur → tur sonucu → sıradaki oyuncu. Son oyuncudan sonra ilk oyuncuya dönülür; tur sınırı ve genel kazanan ekranı yoktur.

60/90/120 saniye korunur. Hazırlık sayacı tur süresinden düşmez. Aktif turda gerçek 300 kartlık asset havuzu kullanılır. Doğru +1 puan ve bir doğru; Pas 0 puan ve bir pas kazandırır. Pas sınırsızdır. Yanıtlanan kart ve sonuç immutable tur geçmişinde saklanır; süre bitince yanıtsız kart puanlanmadan kaldırılır.

## Controller ve zaman

`WhoGameSession`: ready, countdown, playing, paused, roundResult. Ayarlar, aktif oyuncu, süreler, aktif kart, doğru/pas sayıları, yanıt geçmişi, tur puanı, toplamlar, tur numarası ve deste ilerlemesi tutulur.

`whoClockProvider` monoton Stopwatch verir; testlerde saat enjekte edilir. 100 ms Timer yalnızca durumu tazeler; kalan süre `deadline - elapsed` ile hesaplanır. Tekrarlanan tick süreyi azaltmaz; geciken tick gerçek geçen süreyi yakalar. İlk kart gerçekten açılınca seçilen tam tur süresi başlar.

Her yanıt öncesi süre kontrol edilir. Kart kimliği ve 300 ms geçiş kilidi, eski callback/çift dokunmayı reddeder. Kısa yeşil/turuncu geri bildirim sırasında butonlar kapalıdır. Sıfırda timer kapanır, kart temizlenir ve yanıtlar engellenir.

Arka plan/inactive/hidden geçişinde aktif tur ve başlangıç sayacı duraklar. Kart state'ten ve widget ağacından kaldırılır; özel alanda korunur. Geri dönüş otomatik sürdürmez. Manuel devam yeni deadline'ı kalan süre üzerinden kurar. Çıkış/yeniden başlatma onayı açılırken de kart gizlenir; iptal edilirse kullanıcı manuel devam eder.

Timer, reset/yeniden başlatma/tur sonu/provider dispose sırasında iptal edilir. Oyun widget'ı dispose olurken de timer ayrıca durdurulur; provider temizliğinin zamanlamasına bağlı kalınmaz. Lifecycle observer kaldırılır.

## Deste entegrasyonu

Faz 6.2 `whoDeckProvider` gerçek yerel repository'yi yükler. Oyun ekranı provider'ı izleyerek desteyi canlı tutar. Yükleme sırasında Hazırım butonu kapalıdır; hata halinde yeniden deneme vardır. Yeni turda mevcut deste kullanılır. Yeni oyun yeni settings kimliğiyle yeni deste oluşturur; eski oturuma ait Hazırım callback'i kabul edilmez.

Doğru ve Pas sıradaki karta geçer. Kartlar aynı 300 kartlık döngüde tekrarlanmaz; yeniden karıştırmada döngü sınırı korunur. Süre sonunda yanıtsız görülen kart desteye geri konmaz. Toplam puanlar oyuncu geçişinde korunur; yeniden başlatma aynı isim ve süreyle sıfırlar.

## Dosyalar

Yeni:
- `lib/features/games/who_am_i/presentation/who_game_screen.dart`
- `test/who_game_controller_test.dart`
- `test/who_game_widget_test.dart`
- Bu rapor.

Güncellenen:
- `lib/features/games/who_am_i/domain/who_models.dart`
- `lib/features/games/who_am_i/application/who_controller.dart`
- `lib/features/games/who_am_i/presentation/who_page.dart`
- `lib/features/games/who_am_i/presentation/who_screen.dart`
- `lib/features/games/domain/party_game.dart`: yalnızca Ben Kimim? kuralları/oynanabilirlik ve tamamlanan katalog durum metni.
- `test/who_widget_test.dart`, `test/widget_test.dart`
- `README.md`, `docs/v1_product_structure.md`

Eski geçici başlangıç `who_start_screen.dart` kullanılmadığı doğrulanıp kaldırıldı. Kart JSON'u, repository ve deste algoritması değişmedi. Diğer üç oyunun feature dosyaları değişmedi; yeni paket eklenmedi. Router aynı route'u kullanır.

## Doğrulama

Analyze temiz; tam test paketi **226 başarılı test**. Bu fazda 13 yeni controller ve 8 yeni widget senaryosu vardır. 60/90/120, 3/2/1, 301 pas, deste sınırı, sekiz tur ve oyuncu dönüşü, toplamlar, süre bitiminde yanıt reddi, saat kayması, duraklatma, manuel devam, çıkış/yeniden başlatma, timer dispose, 320×568 / 393×786 ve 1.6 yazı ölçeği iki temada test edildi.

`flutter build apk --debug` başarılı. Ekran görüntüleri `build/who631/` altında tutulur ve Git'e dahil edilmez.

## Sınırlar

Hareket sensörleri, genel kazanan ekranı ve kalıcı oturum kaydı bu fazda yoktur. İşletim sistemi uygulamayı tamamen kapatırsa oturum kaybolur. Çok büyük sistem yazılarında içerik kaydırılabilir; alt kontroller sabittir. Kart adları için Faz 6.2'de belirtilen yayın/hak incelemesi halen gereklidir.

Ben Kimim? uygulama içinden erişilebilir gerçek dokunmatik akışı tamamlandığı için oynanabilir olarak işaretlendi. Commit/push yapılmadı; önceki V1 ve Faz 6 çalışmaları korunur.

Pixel 3 native kontrolü tamamlandı: 60 saniyelik gerçek turda Doğru/Pas sonrası 1 doğru, 1 pas ve 1 puan görüldü; HOME ile arka planda otomatik duraklatıldı ve manuel devam edildi. Süre sonunda sonuç, ardından Oyuncu 2 hazırlığı açıldı.

Kaydedilen görüntüler: `pixel-ready-light.png`, `pixel-countdown-light.png`, `pixel-playing-light.png`, `pixel-playing-dark.png`, `pixel-paused-light.png`, `pixel-paused-dark.png`, `pixel-result-light.png`, `pixel-result-dark.png`, `pixel-next-player-light.png`.
