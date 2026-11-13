# Tur sonu interstitial reklam sistemi

Tarih: 13 Kasım 2026

## Gösterim noktaları

| Oyun | Tamamlanan tur ve doğal geçiş |
|---|---|
| Tabu | 60/90/120 saniyelik tur skoru kaydedildikten sonra Sonraki Takım. Hedefe ulaşılan final turunda final sonuçtan çıkış. |
| Sessiz Sinema | Aynı şekilde Sonraki Takım; oyun tamamlanmadan da tur arası fırsat. |
| Ben Kimim? | Her oyuncunun süreli turunun kaydı sonrasında Sıradaki Oyuncu. Final turunda kazanan ekranının çıkış/tekrar aksiyonu. |
| Aramızdaki Casus | Eleme sonrasında Yeni Tura Geç; ikinci beraberlik sonrası yeni ipucu turuna geçiş. İlk beraberlikteki Yeniden Oyla geçişinde reklam yok. Final elemeden Oyun Sonuçları geçişi de fırsattır; bu tur sonuçlardan çıkarken yeniden reklam üretmez. |

Tur sonucu/kazanan ekranının açılması yalnızca kayıt ve ön yükleme yapar. Tam ekran reklam kullanıcı devam/geçiş aksiyonuna bastığında değerlendirilir. Oyun sırasında, kelime dağıtımında, oylamada veya süre işlerken reklam başlatılmaz. Bitmemiş oyundan geri/çıkış onayı reklam başlatmaz.

## Ortak servis ve kimlikler

- `AdsService.recordRound` ve `leaveRound` dört oyun için ortaktır. Var olan oyun tamamlanma sayacı QA uyumluluğu için korunur; ayrıca tamamlanan tur sayısı bulunur.
- Tur kimliği olarak skor kaydının değişmez nesnesi kullanılır: Tabu/Sessiz Sinema `RoundScore`, Ben Kimim? `WhoTurnResult`, Casus `UndercoverRound`. Ekran yeniden çizilmesi aynı turu yeniden saymaz. Yeni oturum yeni kayıt nesneleri üretir.
- Final sonuç aksiyonları aynı tur kimliğini kullanır. Reklam fırsatı ile navigasyon geçişi ayrı takip edilir: sonuçlara girip geri dönmek veya Ana Menü'ye çıkmak mümkün kalır; aynı final turundan ikinci reklam çıkmaz.
- Casus sonuçlara giriş anahtarı geri dönüldüğünde ve yeni oyun başlatıldığında yenilenir. Yeniden oynama önceki oyunun geçiş kilidine takılmaz.
- Bir reklam kapandıktan sonra en az **90 saniye** geçmeden başka tam ekran reklam başlatılmaz. Başlangıçtan başlangıca yerine kapanıştan sonraki başlangıca ölçülerek daha sıkı sınır uygulanır. Gösterim denemesi hata verirse de aynı muhafazakâr aralık kullanılır; oyun akışı devam eder.
- Süre kaynağı monoton Stopwatch'tır; testlerde saat enjekte edilir. Takip ve tur kayıtları mevcut servis gibi uygulama oturumunda bellektedir; uygulama işlemi kapatılınca sıfırlanır. Kalıcı veri deposu/paket eklenmedi.
- Hazır reklam yoksa, 90 saniye dolmadıysa veya UMP/SDK uygun değilse geçiş eşzamanlı devam eder. Sonradan yüklenen reklam geçmiş turun üstüne otomatik açılmaz.
- Gösterim/kapanış/hata sonrasında sonraki reklam önceden yüklenir. UMP `canRequestAds` yükleme ve gösterimde yeniden kontrol edilir. Kaybolmuş ekrana ait gecikmiş callback yeni turu başlatamaz.

## QA ve gizlilik

- QA/test ve production birim seçimi, AdMob App ID'leri, iOS yapılandırması ve UMP rıza akışı değişmedi.
- Manuel QA reklamı oyun/tur sayaçlarını veya turun fırsatını tüketmez; bütün tam ekranlar için ortak 90 saniye sınırına uyar. QA göster butonu bu sırada pasiftir.
- QA ekranına tamamlanan tur sayısı, Tur #N biçiminde oturuma özgü fırsat kimliği ve monoton oturum saniyesiyle kapanış zamanı eklendi. Oyuncu adı veya kelime kaydedilmez. Olaylar mevcut sınırlı bellek listesinde tutulur.
- QA ekranının uzunluğunun artması nedeniyle görünürlük testleri her düğmeyi kaydırıp yerleşim tamamlandıktan sonra ayrı doğrular.

## Dosyalar

- `lib/core/ads/ads_service.dart`: ortak tur API'si, saat enjeksiyonu, 90 saniye sınırı ve geçiş/tur ayrımı.
- `lib/core/ads/ads_diagnostics.dart`: üç yeni güvenli QA alanı.
- `lib/features/games/tabu/presentation/tabu_screen.dart`: kayıt/sonraki takım/final kimliği.
- `lib/features/games/charades/presentation/charades_screen.dart`: aynı tur geçişi.
- `lib/features/games/who_am_i/presentation/who_game_screen.dart`: kayıt/sonraki oyuncu/final kimliği.
- `lib/features/games/undercover/presentation/undercover_setup_screen.dart`: eleme, ikinci beraberlik, final sonuçlar ve geri dönüş geçişleri.
- `test/admob_phase2_test.dart`: önceki oyun sonu regresyonları 90 saniyelik deterministik saat ile güncellendi; QA düğmeleri ayrı kaydırılarak doğrulanır.
- `test/round_ads_test.dart`: 20 yeni servis ve gerçek widget/controller entegrasyon testi.
- `docs/ios_ads_qa.md`: güncel reklam noktaları ve aralık.
- `docs/round_ads.md`: bu rapor.

Oyun controller'ları, puan kuralları, sensör eşikleri, kart havuzları, splash ve Ayarlar geliştirmeleri korunur. TestFlight Build 4 hazırlığında yalnızca pubspec sürümü 0.1.0+3 → **0.1.0+4** olarak yükseltildi.

## Doğrulama

- Odaklı reklam doğrulamasında 46 test geçti; son kaynak temizliği testiyle reklam test dosyaları toplam 47 senaryo içerir.
- Testler: Tabu/Sessiz Sinema 60/90/120 saniye, kaydedilmiş skor/takım değişimi, Ben Kimim? sonraki oyuncu ve toplamlar, Casus eleme/final/beraberlik, 89,999/90 saniye sınırı, geç QA kapanışında kaynak temizliği, reklam açıkken geçen sürenin hesaba katılması, yükleme gecikmesi, çift giriş, final çakışması, UMP ve QA aralığı, erken terk etme.
- `fvm flutter analyze`: **No issues found**.
- `fvm flutter test`: **462 test başarılı** (önceki 442 + 20 yeni test).
- `git diff --check`: başarılı.
- Bu görevde fiziksel Redmi/iPhone reklam SDK testi, native build veya TestFlight yüklemesi yapılmadı. Gerçek cihazda doğal geçiş ve kapanıştan sonraki 90 saniye davranışı ayrıca kontrol edilmelidir.

Build 4 son kontrolünde Tabu ve Sessiz Sinema 120 saniyelik tur testleri reklam gösterim hatasını, 60/90 saniyelik testler normal kapanışı kullanarak aynı skorla sonraki takıma geçildiğini doğrular. Test sayısı değişmez. `pubspec.yaml` da bu teslimin dosyalarına dahildir. Önceden mevcut `.vs/` yerel klasörü, geçici dosyalar ve build çıktıları commit dışında tutulur. API anahtarı ve imzalama yapılandırması değiştirilmedi.
