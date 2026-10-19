# Faz 3 — Tabu

## Güncel oyun kuralları

İki takım vardır; varsayılan adlar Mor Takım ve Pembe Takım'dır. Adlar düzenlenir; boş/boşluk veya Türkçe büyük-küçük harf açısından aynı adlar reddedilir. Tur süresi 60/90/120 saniye, varsayılan 90'dır. Hedef puan 10/15/20/25/30, varsayılan 20'dir.

Tur sınırı yoktur. Takımlar sırayla oynar; yalnızca hedefe ilk ulaşan veya geçen takım oyunu kazanır. Hedef kontrolü her kabul edilen yanıttan sonra yapılır. Hedefte sayaç hemen durur, yeni karta geçilmez ve sonraki yanıtlar reddedilir. Süresi biten açık kart puanlanmaz; Tur Sonu ekranından Sonraki Takım ile devam edilir.

Doğru +1, Tabu −1, Pas 0 puandır; negatif skora izin verilir. Her tur üç pasla başlar. Pas (3), Pas (2), Pas (1), Pas (0) gösterilir; sıfırda buton soluk ve devre dışıdır. Controller da dördüncü pası engeller. Doğru/Tabu, duraklatma veya deste yenilenmesi pas hakkını sıfırlamaz. Yeni turda hak üçe döner.

Kart kimliği ve 350 ms basış kilidi çift puanlamayı engeller. Destedeki tüm kartlar görülmeden tekrar olmaz; tur sonunda açık kalan kart da o döngüde tekrar gösterilmez. Havuz tükenince deste yeniden karıştırılır, kullanıcıya bilgi verilir ve oyun sürer. Birden fazla kart varsa önceki kart hemen yeniden gösterilmez.

Tekrar Oyna isimleri, süreyi ve hedefi korur; skorları, tur sırasını, pas kullanımını, kart geçmişini ve deste döngüsünü sıfırlar. İlk takım yeniden başlar. Ana Sayfaya Dön mevcut go_router akışını kullanır.

## Mimari ve ekranlar

`lib/features/games/tabu/`:

- `domain/tabu_models.dart`: TabuCard, Team, GameSession, GameState, RoundScore ve evreler.
- `data/card_repository.dart`: yerel JSON yükleme ve veri doğrulama; Riverpod FutureProvider.
- `application/game_controller.dart`: puanlama, pas sınırı, deste ve tur sırası; enjekte edilebilir monoton saat.
- `presentation/tabu_screen.dart`: kurulum, oyun öncesi, oynanış, tur sonu ve oyun sonucu.
- `presentation/tabu_widgets.dart`: klasik kart, küçük süre kapsülü, skorlar, pastel tur sonu kartları ve kutlama çizimleri.

`/games/taboo` gerçek oyunu açar. Ana ekran ve oyun listesindeki yalnızca artık geçersiz olan geliştirme metinleri güncellendi. Diğer dört oyunun tanıtımları ve alt navigasyon korunur. Yeni bağımlılık eklenmedi.

Sayaç Tura Başla ile çalışır. Stopwatch ve 100 ms yenileme kullanılır; duvar saati değişiklikleri süreyi etkilemez. Uygulama etkinliğini kaybedince duraklar; kullanıcı Devam Et ile sürdürür. Duraklatmada kart gizlenir ve yanıt butonları kapanır. Ekran kapatıldığında timer temizlenir.

Oynanışta yalnızca aktif takımın adı ve puan/hedef gösterilir. Küçük saat ikonlu mor süre kapsülü son 10 saniyede kırmızı, son 5 saniyede belirgin çerçevelidir. Yasaklı kelimeler 22–24 sp, ortalı, gerektiğinde sarılan ve aralıklı metinlerdir. Kartın pastel başlığı, koyu lacivert gövdesi, beyaz yasaklıları, köşeleri ve hafif geçişi korunur.

Tur Sonu ekranında taç, Tur Bitti!, oynayan takım, doğru/net puan ve iki takımın toplamları bulunur. Skorlar lavanta/açık pembe kartlarda 34 sp kalın yazılır; uzun takım adları sarılır. Altta yalnızca Sonraki Takım vardır. Oyun Sonu kazananı, iki final skorunu, hedefi, kısa kupa animasyonunu ve tekrar oyun/ana sayfa eylemlerini gösterir.

Nunito ve mevcut Oynika paleti kullanılır. Taç vektörle, kupa Material simgesiyle çizilir; referanstaki üç boyutlu çizimlerin birebir kopyası değildir. Kart konusunda yazılı talimattaki koyu gövde tercih edilmiştir. Tasarım referansı yerel `design_reference/tabu_phase3.png` dosyasıdır; kullanıcı isteğiyle ekran görüntüleri Git'e dahil edilmez. Uygulama ekran görüntüsünü arka plan olarak kullanmaz.

## İçerik ve araştırma

`assets/data/tabu_cards.json`: 250 Türkçe kart; her kartta hedef, tam beş yasaklı kelime, kategori ve zorluk bulunur. Her kategoride 25 kart vardır: Günlük yaşam, Yemek ve içecek, Spor, Meslekler, Teknoloji, Doğa, Eğlence, Kültür, Seyahat, Nesneler. Dağılım 150 Kolay (%60), 80 Orta (%32), 20 Zor (%8). Kategori/zorluk filtresi bu fazda yoktur.

19 Ekim 2026 araştırması:

- [Hasbro Türkçe resmî açıklama](https://instructions.hasbro.com/tr-tr/instruction/tabu): hedefi güçlü çağrışımları söylemeden anlatma ve Türkçe kart yapısı.
- [Hasbro Türkçe oyun kılavuzu](https://www.hasbro.com/common/documents/dad288731c4311ddbd0b0800200c9a66/D460136A50569047F54C80BAE0985712.pdf): anlatıcı, karşı takım denetimi ve kelime kısıtları.
- [Kelimoji](https://kelimoji.com/): yemek, spor, teknoloji ve kültür gibi gündelik kategori örnekleri; kart listesi içe aktarılmadı.
- [TDK Güncel Türkçe Sözlük](https://sozluk.gov.tr/arama): yazım başvuru kaynağı; her karta ayrı sözlük sorgusu yapıldığı iddia edilmez.

Başka oyunun listesi toplu kopyalanmadı. Kartlar proje için yaygın Türkçe hedefler ve güçlü çağrışımlar seçilerek yazıldı; kullanıcının örnekleri kalite ölçütü oldu. Yapısal testler hedef/kimlik benzersizliğini, tam beş farklı yasaklıyı, hedefin yasaklılar arasında bulunmamasını ve kategori/zorluk alanlarını doğrular. Dilsel kalite ve zorluk değerlendirmesi gerçek oyuncu geri bildirimiyle geliştirilebilir. Çalışma sırasında ağ erişimi gerekmez.

## Doğrulama

`flutter analyze` ve `flutter test` kullanılır. Toplam 64 test; önceki uygulama testleri korunup oynanabilir Tabu rotasına uyarlandı. Oyun kuralı/saat/veri testleri ve küçük ekran widget testleri eklendi. Zaman testleri gerçek süre beklemez; Riverpod ile enjekte edilen saat ilerletilir.

Test kapsamı: beş hedef seçeneği, anında kazanma ve bitiş kilidi, 20 tur devam, negatif skorlar, üç pas sınırı, yeni tur/tekrar oyunda sıfırlama, duraklatma/yaşam döngüsü, deste döngüleri, tek kartlık havuz, uzun kelimeler ve adlar, küçük sayaç uyarıları, tur sonu toplam skorlar ve navigasyon. 320×568, 393×786, 768×1024; koyu tema ve büyük yazı ölçekleri kontrol edilir.

Debug APK `build/app/outputs/flutter-apk/app-debug.apk` konumundadır. Pixel 3 ve Redmi Note 8 üzerinde çalıştırıldı. Son Pixel 3 Tur Sonu görüntüsü `build/tabu-verification/round-result-score-cards.png` dosyasıdır. Build, doğrulama görüntüleri, günlükler ve geçici betikler Git'e alınmaz.

## Sınırlar

Oturum bellektedir; işletim sistemi uygulamayı tamamen sonlandırırsa sıfırlanır. Sözlü doğru/tabu kararını oyuncular verir; ses tanıma yoktur. Ses, titreşim, reklam, hesap, backend ve diğer oyun mekanikleri eklenmedi. iOS derleme/cihaz kontrolü Windows üzerinde yapılmadı.
