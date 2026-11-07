# Ben Kimim? — Faz 6.3.2.1

Bu belge 6.3.2 ve önceki Hazırım düzeltmesinin sensör/kalibrasyon davranışını geçersiz kılar. Oyun kuralları, veri ve yön yönetimi korunur.

## 1. Hazırım'ı ne engelliyordu?
Önceki `_confirmReady` sensör kalibrasyon Future'ını bekliyordu. Kalibrasyon belirli bir fiziksel konum (X yerçekimi bileşeni yeterince büyük, Z küçük) istiyordu. Telefon düzken veya yeni konuma taşınırken bu koşul sağlanmayınca ilk kart ve sayaç açılmıyordu.

Şimdi `_confirmReady` doğrudan mevcut controller'ın confirmOrientation/resume yoluyla ilk kartı ve tam tur süresini başlatır. Sensör bağlantısı, kalibrasyon veya cihazın alnında tutulması oyun başlangıcı için koşul değildir. Yalnızca önceki fazın gerçek yatay ekran güvenliği korunur.

## 2. Hareketler neden kaybolabiliyordu?
Önceki sürüm sadece ivmeölçer yerçekimi açısını kullanıyordu. Güçlü doğrusal ivme, yan bileşen veya veri aralığı eşiklerinden biri aşılınca nötr mandalı kapatılıyor ve geçerli bir baş hareketi yarıda kaybolabiliyordu. İlk fiziksel konumun dar aralıkta kabul edilmesi, elle tutuş değişiklikleri ve nötre dönmeden başlanan hareketler de algılamayı engelliyordu. Önceki sabit ilk zaman ofseti için yapılan düzeltme tek başına bunları çözmüyordu.

Bunlar kod ve sahte verilerle yeniden üretilebilen mekanizmalardır. Kullanıcının önceki her başarısız hareketinin tam nedeni, o sırada tanı paneli bulunmadığı için kesin olarak ölçülemedi. Yeni panel bu ayrımı fiziksel cihazda görünür yapar; sadece eşikler düşürülmedi.

## 3. Yeni hareket modeli
- Fiziksel hareket ekseni cihazın doğal Y eksenidir: yatay telefonda uzun kenar boyunca baş sallama/eğme ekseni. Flutter ekran yönü bu ekseni yeniden tanımlamaz.
- Jiroskop Y açısal hızı rad/s'den dereceye entegre edilir: `-upSign * gyroY * dt`.
- Güvenilir ivmeölçer örneklerinin X/Z yerçekimi açısı, başlangıç referansına göre hesaplanır. Tamamlayıcı filtre, jiroskop kaymasını 1.5 saniye zaman sabitiyle düzeltir. Gyro yoksa yerçekimi filtresiyle devam edilir.
- Doğrusal ivme sırasında gyro izlenen hareket silinmez. Diğer eksenlerde baskın döndürme/roll bir cevap olarak kabul edilmez.
- İki yatay tutuş, mümkünse ölçülen yerçekimi X işaretiyle ayrılır. Telefon düzken Android display rotation / iOS interface orientation yalnızca işaret ipucu sağlar; hareket açısı bu bilgiden çıkarılmaz.
- Tetikleme ±40°, 80 ms doğrulama; nötr ±15°, 200 ms kararlılık. Cevap sonrası 400 ms mandal beklemesi; controller'ın mevcut 300 ms çift cevap koruması devam eder.
- Sensör ve dokunmatik cevaplar aynı `WhoController.answer` yolundadır. Reddedilen eski/çift olay debug panelinde başarılı işlem gibi kaydedilmez. Bitiş anındaki cevap controller tarafından reddedilir.

## 4. Otomatik referans
Aktif oyun başladıktan sonra 600 ms kararlı örnek penceresi toplanır. Düz masa dahil belirli bir alın/ekran pozisyonu zorunlu değildir. Hem native örnek zamanı hem monoton uygulama zamanı kontrol edilir; geçmiş toplu veri tek başına hazır sayılmaz. En az gecikmeli örnekle saat ofseti güncellenir; sırası bozuk/gecikmiş olaylar elenir.

4 saniyede referans oluşmazsa oyun sürer ve örnekleme devam eder. Sensör sonradan veri göndermeye başlayınca otomatik toparlar. İki saniyelik veri yokluğu panelde unavailable olur; skor/sayaç durmaz. Tam landscape tutuş değişimi algılanırsa yeni referans oyun durmadan toplanır. Üstteki küçük Sensörü yeniden ayarla kontrolü, yanlış ilk referansı veya başka tutuş değişikliğini kart/süre/puan sıfırlamadan yeniden örnekler.

Pause, arka plan, sonuç ve çıkışta iki abonelik de kapanır. Geri dönüşte Devam Et/Hazırım oyunu hemen açar ve sensörü yeniden arka planda hazırlar. Eski abonelikler epoch ve round/settings kontrolüyle yeni oyuncuyu etkileyemez.

## 5. Debug paneli
Kartın üzerinde ayrı, kompakt bir alan; kelimenin üstüne bindirilmez:
- idle/calibrating/active/unavailable/unstable bağlantı/referans durumu
- ACC ve GYR örnek sayıları, elenen veri sayısı
- ham ivme A[x,y,z] ve açısal hız G[x,y,z]
- füzyon/yerçekimi modu ve hesaplanan göreli açı
- nötr açık/kilitli, son algılanan forward/backward yönü
- controller'ın kabul ettiği son Doğru +1 / Pas işlemi

`kDebugMode` koşulu ile release ve profile sürümlerinde panel üretilmez. Tanı değerleri ağa veya dosyaya gönderilmez. Sadece bellekte tutulur.

## 6. Dosyalar
- domain/who_tilt_detector.dart: göreli açı ve gyro/yerçekimi füzyonu
- application/who_motion_service.dart: bekletmeyen otomatik referans, iki abonelik, tanı sayaçları
- application/who_motion_provider.dart: sensors_plus ivme + gyro adaptörü, native işaret ipucu
- presentation/who_game_screen.dart: anında başlatma, ortak cevap yolu, yeniden ayarlama
- presentation/who_landscape_board.dart: aynı oyun düzeninde kompakt kontrol/panel
- presentation/who_motion_debug_panel.dart: debug derleme koruması
- Android MainActivity ve iOS AppDelegate: yalnızca Ben Kimim? yön ipucu kanalı; mevcut Undercover privacy kanalı korunur
- PartyGame.whoAmI.instructions, README ve bu belge
- İlgili motion service/widget/detector testleri güncellendi; debug paneli testleri eklendi

Tabu, Sessiz Sinema ve Aramızdaki Casus feature kodları, 300 kartlık JSON ve oyun controller'ının puanlama kuralları değiştirilmedi. Yeni paket yok; mevcut sensors_plus 6.1.2 kullanılır.

## 7. Redmi test prosedürü
1. Ben Kimim? → Oyunu Başlat → Başlamaya Hazırım → Hazırım. Telefonu alnına koymadan da kelime ve sayaç hemen görünmeli.
2. Panelde ACC/GYR sayıları artmalı. Kısa süre sabit tutulunca active görünmeli; nötr açık olunca öne eğ: +1 Doğru. Eğik beklemek ikinci kartı geçirmemeli.
3. İlk konuma dönüp kısa süre bekle; arkaya eğ: Pas, puan değişmez. Diğer yatay tutuşta da dene.
4. Telefona yeni tutuş verdikten sonra açı/nötr kilidi uygun değilse üstte Sensörü yeniden ayarla ikonuna bas; oyun durmadan yeni referans oluşmalı.
5. HOME/ekran kapatma sonrası kelime gizlenmeli. Geri dönüş otomatik cevap algılamamalı; manuel devam ile oyun hemen açılmalı.
6. Sorun varsa panelde ACC/GYR sayaçlarının artıp artmadığını, açı değerini, active/referans durumunu ve nötr açık/kilitli bilgisini bildir.

## 8. Sınırlamalar ve kanıt
Fiziksel Redmi üzerinde insanın öne/arkaya baş hareketlerini uzaktan gerçekleştiremiyoruz. Sahte sensör testleri ve Pixel 3 sanal sensör kontrolleri fiziksel hareket doğrulaması olarak raporlanmaz. iOS native derleme Windows üzerinde yapılmadı; gerçek iPhone tutuş testleri gerekir. Büyük doğrusal hareket, karmaşık eksen dönüşleri ve başlangıç tutuşunun çok değişmesi için yeniden ayarlama gerekebilir. Eşikler gerçek kullanıcı onayı sonrasında gerekirse ayarlanabilir.

Kaynaklar: https://developer.android.com/develop/sensors-and-location/sensors/sensors_motion ve sensors_plus yerel Android/iOS kaynakları (gyro rad/s, ivme m/s² ve eksen normalizasyonu).

Loglar ve görüntüler `build/who6321/` içinde (Git dışında). Önceki çalışma ağacı korunur. Commit/push yapılmaz.

## Son çalıştırma sonuçları
- flutter analyze: No issues found.
- flutter test --concurrency=1: 284 başarılı test. Önceki sensör davranışına ait bekletme/pozisyon zorunluluğu beklentileri yeni gereksinimlere göre güncellendi; diğer oyun testleri korundu.
- flutter build apk --debug: başarılı.
- Pixel 3: düz konumda Hazırım → kelime ve tam süre hemen açık; panel calibrating iken gerçek tur devam ediyor. Native sanal gyro/ivme verisi → 1 Doğru ve 1 Pas; panelde active/füzyon, örnek sayıları, açı ve son Pas görüldü. Bu fiziksel Redmi hareket doğrulaması değildir.
- Ekran görüntüleri: build/who6321/pixel-immediate-flat-light.png, pixel-immediate-light.png, pixel-forward-fusion-light.png, pixel-backward-fusion-light.png.
- Redmi 155e6b22: son debug APK install -r başarılı; başlatma komutu gönderildi. Son gözlenen odak NotificationShade/kilit ekranı; kullanıcı kilidi açmalı. Gerçek baş hareketleri kullanıcı onayını bekliyor.
- Git: main; önceki ve yeni değişiklikler çalışma ağacında. Stage, commit ve push yok. build/ logları/görüntüleri Git dışında.
