# Ben Kimim? — Faz 6.3.2.2

## Kapsam
Yalnızca yatay oyun sunumu ve debug görünürlüğü güncellendi. Sensör servisi, tilt detector, provider/adaptör, controller, modeller ve 300 kartlık JSON dosyasının SHA-256 değerleri işlem başında kaydedilip sonunda karşılaştırıldı. Hesaplama, eşikler, otomatik referans, Doğru/Pas yönleri, nötr mandalı ve tur akışı değiştirilmedi.

## Yeni görünüm
- İnce üst çubuk: solda oyuncu, tam ortada süre kapsülü, sağda mevcut turun puanı. Geri, yeniden ayarlama ve duraklatma erişimi korunur.
- Ana odak geniş, yumuşak mor gradyanlı karttır. Kalın beyaz Nunito, yatay/dikey merkezleme ve gerçek font ölçümüyle bir veya iki satır; ellipsis/kırpma yoktur.
- Alt bölümde aynı genişlikte yeşil Doğru +1 ve turuncu Pas butonları. Geri bildirim süresi/controller davranışı korunur; kart kısa renk vurgusu ve ikon gösterir.
- Açık modda lavanta, koyu modda koyu mor oyun arka planı. Bu arka plan sadece aktif yatay WhoPage için seçilir; diğer ekranlar değişmez.
- Kenar boşlukları, header ve buton yükseklikleri LayoutBuilder kısıtlarına göre uyarlanır; kart Expanded ile kalan alanı kullanır. SafeArea devam eder; normal oyunda kaydırma yoktur.

## Debug paneli
Varsayılan debug APK'da ve normal oyunda hiçbir sensör metni üretilmez. Teknik panel ancak geliştirici açıkça şu derleme seçeneğini kullanırsa gösterilir:

```powershell
flutter run --dart-define=OYNIKA_WHO_MOTION_DEBUG=true
```

Aynı seçenek debug APK oluştururken de kullanılabilir. `kDebugMode` ek koruması nedeniyle seçenek verilse bile release/profile sürümlerinde panel gösterilmez. Varsayılan çalışmada UI sensör tanı değişiklikleri için yeniden çizilmez; sensör abonelikleri ve hesaplamaları devam eder. Normal APK komutunda dart-define verilmez.

## Değiştirilen dosyalar
- lib/features/games/who_am_i/presentation/who_landscape_board.dart
- lib/features/games/who_am_i/presentation/who_motion_debug_panel.dart
- lib/features/games/who_am_i/presentation/who_game_screen.dart (yalnızca debug görünürlüğü/UI observer)
- lib/features/games/who_am_i/presentation/who_page.dart (aktif oyun için isteğe bağlı arka plan)
- test/who_motion_debug_test.dart
- test/who_motion_widget_test.dart
- test/who_landscape_design_test.dart (yeni)
- README.md ve bu rapor

## Doğrulama yaklaşımı
Varsayılan gizli panel, açıkça etkinleştirme ve release koşulu koruması; sensör ve dokunmatik ortak cevap yolu; hemen başlayan tur; duraklama; sonuçta portrait dönüşü; önceki regresyonlar korunur. Ek görsel testler 480×240, 568×320 ve 844×390 ölçülerinde iki tema ve 2× yazı ölçeğini kapsar. Önceki çentik ve 932×430 testleri de sürer. En uzun gerçek veri kartının kırpılmadığı, ortalandığı, yeterince büyük kaldığı ve butonların ekranda olduğu denetlenir.

Ekran görüntüleri ve loglar: build/who6322/ (Git dışında). `sample-*` gerçek fontlarla üretilmiş sentetik küçük/çentikli ekran örnekleridir; `pixel-*` gerçek çalışan Android emülatör görüntüleridir. Emülatör testi fiziksel Redmi hareket doğrulaması olarak sunulmaz. iOS cihaz testi Windows üzerinde yapılmadı.

Commit veya push yapılmaz. Önceki çalışma ağacı korunur; yalnızca bu fazın UI/test/dokümantasyon dosyaları değiştirilir.

## Sonuçlar
- flutter analyze: temiz.
- flutter test --concurrency=1: 291 başarılı test.
- flutter build apk --debug: başarılı.
- Pixel 3 gerçek çalışan uygulama: açık/koyu görünüm kaydedildi, teknik panel yok; arka plan/duraklama sonrası manuel devam ve Hazırım akışı kontrol edildi.
- build/who6322/pixel-game-light.png
- build/who6322/pixel-game-dark.png
- build/who6322/sample-568-light-text2x.png ve sample-568-dark-text2x.png; sample-844-light-text2x.png ve sample-844-dark-text2x.png (sentetik uzun kart, 2× yazı örnekleri).
- Sensör servisi, detector, provider, controller, model ve 300 kart JSON: başlangıç/bitiş SHA-256 değerleri aynı.
- Redmi 155e6b22: son APK install -r başarılı; açılış komutu gönderildi. Son odak NotificationShade/kilit ekranı olduğundan kullanıcı kilidi açmalı.
- Git main üzerinde önceki ve yeni kaydedilmemiş değişiklikler bulunuyor; commit ve push yapılmadı. build/ içeriği hariç tutulmaya devam ediyor.
