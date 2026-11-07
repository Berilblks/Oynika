# Ben Kimim? — Faz 6.3.2

## Kapsam ve bağımlılık
Yalnızca Ben Kimim? için hareketle Doğru/Pas eklendi. Yatay oyun düzeni, 300 kart, puanlar, sınırsız pas, oyuncu sırası, gerçek zamanlı sayaç ve önceki yön yönetimi korunur.

`sensors_plus: 6.1.2` sabit kararlı sürümü kullanılır. Flutter 3.29 / Dart 3.7 yükseltilmedi. Güncel 7.1.1 daha yeni Kotlin/AGP/Gradle gerektirir; mevcut AGP 8.7 / Gradle 8.10.2 ile 6.1.2 seçildi. Android NDK sistemde kurulu 27.0.12077973 sürümüne eşitlendi. Yeni Android izni gerekmez; iOS Info.plist'e Türkçe NSMotionUsageDescription eklendi. Paket dolaylı olarak sensors_plus_platform_interface ve plugin_platform_interface getirir.

## Mimari
- `domain/who_tilt_detector.dart`: UI ve eklentiden bağımsız veri örneği, eşikler, kalibrasyon, filtre, histerezis ve nötr mandalı.
- `application/who_motion_service.dart`: tek sensör aboneliği, kalibrasyon penceresi, hata/timeout, eski olayların reddi, kaynak temizliği ve oturum sürümü.
- `application/who_motion_provider.dart`: Riverpod üzerinden enjekte edilebilir kaynak/fabrika; accelerometer 20 ms istenir (gerçek hız cihaza bağlıdır).
- `presentation/who_game_screen.dart`: yalnızca uygun görünüm ve yaşam döngüsünde kalibrasyon/aktivasyon. Sensör ve dokunma mevcut controller.answer yolunu kullanır; ayrı puanlama yoktur.
- `who_landscape_board.dart`: mevcut düzen içinde 300 ms yeşil/turuncu vurgu, büyük ikon ve +1 Doğru/Pas. Yeni kelime vurgu bitince görünür.

## Kalibrasyon ve eşikler
Hazırım sonrasında sensörden en az 8 örnek ve 600 ms kararlı pencere toplanır. Kalibrasyonda kelime açılmaz ve tur süresi azalmaz. 4 saniyede kararlılık sağlanmazsa tekrar deneme veya Dokunmatik Devam Et sunulur. Masa üzerinde düz veya portrait tutuş referans kabul edilmez. Oyun sırasında sensör kesilirse dokunmatik kontroller kullanılabilir; bir saniyelik veri kesintisi watchdog ile fark edilir.

Başlangıç değerleri `WhoMotionTuning` içinde merkezi yönetilir:
- Tetikleme: nötr referansa göre ±40°, en az 80 ms.
- Nötr: ±15° içinde 200 ms kararlılık.
- Yerçekimi alçak geçiren filtre zaman sabiti: 100 ms.
- Cevap sonrası hareket mandalı beklemesi: 400 ms; controller mevcut 300 ms çift cevap korumasını korur.
- 7.8–11.8 m/s² dışındaki büyüklükler, geçersiz veriler ve büyük yan dönüşler reddedilir. Yalnızca sabit ivme eşiği kullanılmaz; filtrelenmiş yerçekimi eğimi hesaplanır.
- Gecikmiş (>250 ms), zaman sırası bozuk veya eski abonelikten gelen olaylar uygulanmaz.

## Fiziksel yön eşlemesi
Android sensörleri ekran dönüşünden bağımsız doğal cihaz koordinatlarını kullanır. iOS sensors_plus 6.1.2 uygulaması CoreMotion ivmesini -9.81 ile çarparak işaret ve birimi Android ile eşitler; ekstra iOS işaret terslemesi yapılmaz.

Kalibrasyonda yerçekiminin X işareti iki landscape tutuşundan hangisinin fiziksel olarak yukarı baktığını belirler. Yukarı bileşen `x * referansX.sign`; dış ekran normali Z'dir. Eğim `atan2(-z, yukarı)` ile hesaplanır ve nötr açı çıkarılır. Ekranın zemine doğru yatırılması (öne eğme) pozitif göreli açı/Doğru; ters yön Pas olur. Sabit bir X işareti veya yalnızca Flutter Orientation.landscape bilgisi kullanılmaz. Landscape tutuşu ters çevrilirse otomatik duraklatılır, devamda yeniden kalibrasyon gerekir.

Bu eşleme dokümantasyon, eklenti kodu ve sahte/sanal sensör verisiyle denetlendi. Gerçek Redmi'de fiziksel baş hareketleri henüz kullanıcı tarafından doğrulanmalıdır; emülatör doğrulaması fiziksel cihaz testi değildir.

## Yaşam döngüsü
Hazırlık ve geri sayımda sensör aboneliği yoktur. Kalibrasyon sadece referans toplar. Active turda hareket kabul edilir. Pause, inactive, hidden, ekran kapatma, tur sonucu, çıkış ve dispose aboneliği kapatır; bekleyen kalibrasyon geçersizleşir. Geri dönüş kendiliğinden sensörü başlatmaz; Devam Et / Hazırım ve yeni kalibrasyon gerekir. Controller süre kontrolünü cevaptan önce yaptığı için bitiş anındaki hareket puan kazandırmaz.

## Redmi kontrol listesi
1. Ben Kimim? → Oyunu Başlat → Başlamaya Hazırım → telefonu yatay ve ekran dışarı bakacak şekilde alnında tut → Hazırım. Kısa süre sabit tut.
2. Öne eğ: yalnızca bir +1/yeşil tik olmalı. Eğik tutmaya devam et: ikinci kart geçmemeli.
3. Nötre dönüp kısa süre sabit tut; arkaya eğ: yalnızca bir Pas/turuncu vurgu, puan değişmemeli.
4. Aynısını telefonun diğer yatay tutuşunda yeni kalibrasyonla dene. İşaret ters çıkarsa hangi tutuşta/öne mi arkaya mı olduğunu bildir; fiziksel onay verilmeden eşikleri kesinleşmiş saymıyoruz.
5. Küçük titreme, hızlı art arda eğme, nötre kısa dokunup tekrar eğme yanlış çift cevap üretmemeli.
6. Dokunmatik butona basıp hemen eğ; aynı kart iki kez puanlanmamalı. Nötre dönünce yeni hareket çalışmalı.
7. Duraklat, uygulamayı arka plana al/ekranı kapat ve geri dön. Kelime gizlenmeli, süre korunmalı; manuel devam yeniden kalibre etmeli.
8. Süre sonunda sonuç dikey açılmalı; hareket sonuç puanını değiştirmemeli. Sonraki oyuncuda yeni kalibrasyon yapılmalı.
9. Dokunmatik Devam Et seçimi sensör açmadan çalışmalı.

## Sınırlamalar
Windows üzerinde iOS native build/cihaz testi yapılmadı. Tutuş geometrisi, sensör üreticisi ve güçlü doğrusal hareketler gerçek cihazda değerlendirilmelidir. Bu fazda gyro füzyonu veya sensörle ekran yönü kilidi eklenmedi. Sensör verisi cihazda bellekte işlenir; ağa gönderilmez ve kaydedilmez.

## Kaynaklar
- https://pub.dev/packages/sensors_plus/versions/6.1.2
- https://pub.dev/packages/sensors_plus
- https://developer.android.com/develop/sensors-and-location/sensors/sensors_overview
- Yerel indirilen sensors_plus 6.1.2 iOS FPPStreamHandlerPlus.swift (işaret/birim normalizasyonu) ve Android sensör uygulaması incelendi.

Commit veya push yapılmadı. Önceki V1 ve Ben Kimim? çalışma ağacı değişiklikleri korundu. Log ve ekran görüntüleri `build/who632/` altındadır ve Git'e dahil edilmez.

## Son doğrulama
- flutter analyze: temiz.
- flutter test --concurrency=1: 273 başarılı test (önceki 250 + 23 yeni sensör testi).
- flutter build apk --debug: başarılı; NDK uyumsuzluğu giderildi.
- Pixel 3 sanal ivme: iki X işaretinde ayrı kalibrasyon sonrası öne hareket Doğru; nötre dönüş ve arkaya hareket Pas; eğik beklerken tekrar puan yok; tur sonunda portrait sonuç. Tutuş ters çevrilince duraklama ve yeni kalibrasyon; HOME sonrası kelime gizli, süre korunmuş portrait duraklama doğrulandı.
- Ekranlar: pixel-turning-light.png, pixel-calibration-dark.png, pixel-sensor-game-light.png, pixel-sensor-game-dark.png, pixel-opposite-landscape-dark.png, pixel-background-paused-dark.png, pixel-result-light.png. pixel-after-* hareketten sonraki gerçek ekranlardır; sample-* gerçek fontlarla üretilen sentetik responsive/geri bildirim örnekleridir.
- Redmi 155e6b22: son APK install -r başarılı; açılış komutu gönderildi. Kilit ekranı/NotificationShade nedeniyle kullanıcı kilidi açmalıdır. Fiziksel hareket onayı bekleniyor.

Eklenen dosyalar: who_tilt_detector.dart, who_motion_service.dart, who_motion_provider.dart; test/who_tilt_detector_test.dart, who_motion_service_test.dart, who_motion_widget_test.dart; docs/who_phase632.md.
Güncellenenler: who_game_screen.dart, who_landscape_board.dart, who_widget_test.dart, who_game_widget_test.dart, who_landscape_test.dart; PartyGame.whoAmI.instructions; pubspec.yaml/lock; Android app build.gradle.kts; iOS Runner/Info.plist; README.md. Diğer üç oyunun feature dosyaları değişmedi. Git main üzerinde önceki ve yeni kaydedilmemiş geliştirmeler duruyor; stage, commit veya push yapılmadı.

### Hazırım sonrası Redmi kalibrasyon düzeltmesi
Gecikmiş/toplu ilk native örneğe sabitlenen saat ofseti, sonraki taze örnekleri gelecekte sanıp reddedebiliyordu. Ofset artık en az gecikmeli örneğe göre güncellenir; eski örnek filtresi korunur. Kalibrasyon hem sensör zamanında hem uygulamanın monoton saatinde 600 ms kararlılık ister, böylece tek bir geçmiş veri paketiyle erken başlamaz. Yeniden üreten regresyon testi eklendi. Uygun olmayan tutuşta ekranın karşıya bakması gerektiği ve tekrar/dokunmatik seçenekleri açıkça anlatılır. Son doğrulama: analyze temiz, 274 test başarılı, debug APK başarılı; Redmi'ye güncelleme yüklendi. Fiziksel kalibrasyon oyuncunun telefonu alnında dik tutmasını gerektirir.
