# Ben Kimim? — Faz 6.4

## Değişiklikler
Ayarlar ekranına 10/15/20/25/30 hedef puanı (varsayılan 20) eklendi. Oyuncu sayısı, isimler, süre, kurallar modalı, sabit başlatma ve klavye davranışı korunur. Aktif yatay ekran ve sensör kaynaklarına dokunulmadı.

## Kazanma algoritması
Her normal tur sırası bütün oyuncuları içerir. Doğru +1 ve Pas 0; hedefe ulaşmak aktif turu veya kalan oyuncuları durdurmaz. Süre dolunca tur sonucu ve geçmişi kaydedilir. Sıranın son oyuncusu tamamlandığında:
1. Kimse hedefe ulaşmamışsa aynı oyuncularla yeni normal sıra başlar.
2. Hedefe ulaşan tek en yüksek toplam varsa kazanan belirlenir.
3. En yüksek toplam eşitse sadece o liderlerden oluşan ek sıra başlar. Ek sıranın tamamı oynanır; tek lider varsa kazanır, eşitlik sürerse sadece hâlâ eşit liderler devam eder.

Puanlar ek turlarda korunur. Eşitliğin çözümünde oyuncu ID'si veya kart sırası belirleyici değildir. Genel tablodaki eşit puanlı oyuncular aynı sıra numarasını alır; ID yalnızca eşit satırların ekranda sabit yerleşmesi içindir.

`round` mevcut oyuncu turu numarasını korur. `cycle` tam normal/ek tur sırasını sayar; `history` tamamlanan oyuncu turlarını tutar. Kazanan ekranı hem toplam oynanan oyuncu turunu hem tamamlanan tur sırası sayısını gösterir.

## Genel tablo ve kazanan
Her sonuçta oyuncular toplam puana göre sıralanır. Ad, son turdaki doğru/pas/puan ve toplam gösterilir; henüz oynamayanlar belirtilir. Sıradaki oyuncu mor çerçeve ve metinle vurgulanır. Önceki sıraya ait değerler yanıltmamak için Son tur olarak etiketlenir.

Ayrı portrait kazanan ekranında kupa, kazanan adı/toplamı, hedef, diğer oyuncular, tur sayıları, Tekrar Oyna ve Oyunlara Dön vardır. Tekrar Oyna isim/süre/hedefi korur; puan, geçmiş ve sıra sıfırlanır. Yeni settings kimliği, mevcut Riverpod deste sağlayıcısının yeni karıştırılmış bir deste oluşturmasını sağlar. Oyunlara Dön mevcut go_router ile /games adresini açıp oturumu temizler.

## Yeni 300 kart
| Kategori | Adet |
|---|---:|
| Türk şarkıcı ve müzisyen | 75 |
| Türk oyuncu ve televizyon ünlüsü | 65 |
| Yabancı ünlü | 65 |
| Sporcu | 40 |
| Tarihî veya tanınmış kişi | 25 |
| Film/dizi/çizgi film insan karakteri | 30 |
| **Toplam** | **300** |

Zorluk: **240 kolay, 60 orta, 0 zor**. Tanınırlık/zorluk editoryal değerlendirmedir; kullanıcılarla oynanarak iyileştirilebilir. İnsan karakterleri arasında İnek Şaban, Mahmut Hoca, Polat Alemdar, Sherlock Holmes, Harry Potter, Homer Simpson ve Heidi gibi insan kimlikleri bulunur. İnsan olmayan eski karakterler, hayvanlar, nesneler, meslek ve genel kavramlar çıkarıldı. Gerçek kişi ve canlandırdığı kurgu karakter farklı kimliklerdir; örneğin Kemal Sunal ve İnek Şaban iki ayrı karttır.

JSON şeması yine yalnızca id/name/category/difficulty; yeni enumlar ve Türkçe sunum etiketleri kullanılır. 300 ID ve normalleştirilmiş ad benzersiz; yaygın alternatif adlar için ek tekrar kontrolleri var. Sayı/şema/fixture/alias kontrolleri otomatiktir; bir ismin gerçekten insan karakteri olduğunu test kodu tek başına kanıtlamaz, içerik seçimi editoryal olarak yapıldı. Biyografi, iddia, replik veya telifli görsel eklenmedi.

Kart ID'leri who-001..who-300 olarak içerik yenilemesinde yeniden eşlendi; yeni fixture test/fixtures/who_phase64_card_identities.json. Önceki fazın fixture'ı geçici build/who64 arşivine alındı; uygulama eski kartları yüklemez. Kalıcı oyun/veritabanı olmadığından eski bir kaydı dönüştürme gereksinimi yoktur.

Repository, karıştırma algoritması, döngü içi tekrarsızlık, sınırda ardışık tekrar koruması ve oyuncular arası deste devamlılığı aynen korunur.

## Dosyalar
- assets/data/who_am_i_cards.json
- domain/who_card.dart, who_models.dart
- application/who_controller.dart (sadece hedef/sonuç/sıra/restart alanları)
- presentation/who_card_labels.dart, who_screen.dart, who_game_screen.dart
- presentation/who_scoreboard.dart, who_winner_screen.dart (yeni)
- PartyGame.whoAmI.instructions; diğer üç oyunun tanımları değiştirilmez
- test/who_card_data_test.dart, who_widget_test.dart, yeni who_score_system_test.dart ve who_score_widget_test.dart
- test/fixtures/who_phase64_card_identities.json; eski phase62 fixture kaldırıldı
- README.md ve bu belge

## Testler ve sınırlar
Beş hedef, varsayılan/değer doğrulama, normal sıra adaleti, erken hedefe rağmen sıranın tamamlanması, sıra sonunda en yüksek puanın kazanması, üçlü eşitliğin daralması, sıfır puanlı tekrarlanan ek turlar, sonuç sonrası değişmezlik, tur istatistikleri ve reset testleri eklendi. Widget testlerinde hedef seçimi, tablo/sıradaki oyuncu, kazanan/portrait, büyük yazı/iki tema, yeni deste ve router'a dönüş doğrulanır. Mevcut sensör/dokunmatik/yatay ekran testleri sürer.

Tüm oturum bellektedir; süreç kapatılırsa devam kaydı yoktur. Eşitlik sıfır puanlarla sonsuza kadar sürebilir; bu istenen kurala uygundur. iOS native build ve fiziksel iPhone testi Windows'ta yapılmadı. Emülatör doğrulaması fiziksel Redmi hareket testi olarak sunulmaz.

Loglar, ekran görüntüleri ve geçici araçlar build/who64/ altında; Git'e dahil edilmez. Commit ve push yapılmadı. Önceki çalışma ağacı korunur.

## Son doğrulama sonuçları
- flutter analyze: temiz.
- flutter test --concurrency=1: 309 başarılı test.
- flutter build apk --debug: başarılı.
- Pixel 3 native dokunmatik tam oyun: 2 oyuncu, 60 saniye, hedef 10. Birinci oyuncu 10 puana ilk saniyelerde ulaştı, kalan süresi devam etti; portrait sonuç ve ikinci oyuncu turu açıldı. İkinci oyuncu tam turunu 0 puanla tamamladı; ilk oyuncu kazandı. Kazanan ekranı iki temada görüntülendi. Tekrar Oyna sonrası isimler/60 saniye/10 hedefi korundu ve puan 0 oldu.
- Ek turlar ve daralan çoklu eşitlik otomatik testlerle doğrulandı; native emülatördeki tam oyun tek kazanan senaryosudur.
- Görüntüler: pixel-setup-target10.png, pixel-target-reached-playing.png, pixel-scoreboard-next.png, pixel-second-player-playing.png, pixel-winner-light.png, pixel-winner-dark.png, pixel-replay-ready.png.
- Sensör servisi, detector, provider/adaptör, aktif yatay board, repository ve deck algoritmasının SHA-256 değerleri başlangıçla aynı.
- Redmi 155e6b22: son APK güncellemesi başarılı; uygulamayı başlatma komutu gönderildi. Fiziksel cihazdaki yeni kazanma/içerik onayı kullanıcıdan bekleniyor.
- Yeni paket eklenmedi. Git main üzerinde önceki ve yeni değişiklikler korunuyor; stage/commit/push yapılmadı.
