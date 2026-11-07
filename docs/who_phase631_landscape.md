# Ben Kimim? — Faz 6.3.1.1

## Akış
Ayarlar ve oyuncu hazırlığı dikeydir. Başlamaya Hazırım sonrası 3/2/1 ile telefon döndürme mesajı gösterilir; bu süre gerçek tur süresinden düşmez. Native landscape isteği tamamlanmalı ve Flutter görünümü gerçekten yatay olmalıdır. Ardından kullanıcı Hazırım ile telefonunu konumlandırdığını onaylar. Fiziksel yön sensörü kullanılmaz.

## Yön ve yaşam döngüsü
`lib/core/utils/app_orientation.dart` tüm native yön isteklerini sıraya alır. İstek sürümü ve ekran sahipliği, gecikmiş callback veya eski ekranın dispose işleminin yeni ekran yönünü bozmasını önler. Uygulama başlangıcı portraitUp; oyun landscapeLeft/landscapeRight; sonuç, çıkış, gerçek arka plan ve dispose tekrar portraitUp ister.

Hazırlık geçidinde yön değişiminin kısa süreli inactive/odak kaybı dönüşü iptal etmez; bu sırada kelime görünmez. Hidden/paused durumunda hazırlık da duraklar. Aktif oyunda inactive dahil odak kaybı kartı hemen gizler ve süreyi korur. Devam Et yeniden yatay görünüm ve Hazırım onayı ister. Sayaç aynı anda ikinci kez başlatılmaz.

## Yerleşim
SafeArea içinde sabit Column: oyuncu/süre/istatistik satırı, esnek mor kart, yan yana Doğru +1 ve Pas. Gereksiz AppBar ve kaydırma yoktur. Kelime, gerçek Nunito fontu ve erişilebilirlik ölçeğiyle TextPainter üzerinden ölçülerek bir veya iki satıra sığdırılır. Başlık/metaveriler gerektiğinde ölçeklenir. Puanlama, 300 kart, deste devamlılığı ve sınırsız pas korunur.

## Doğrulama
- Orientation istek sırası, dispose, eski sahip ve platform hatası testleri.
- API onayı ve gerçek yatay ölçüm olmadan kart/süre başlamaması; 3/2/1, çıkış ve arka plan testleri.
- Açık/koyu, 568×320 / 667×375 / 844×390 / 932×430, normal ve 2× yazı, uzun isim, çentik ve alt sistem alanı testleri.
- Ekran görüntüleri ve araç logları: `build/who631_landscape/` (Git dışında). `pixel-*` gerçek Android görüntüleri; `sample-*` gerçek font ve en uzun veri kartıyla oluşturulan sentetik responsive örneklerdir.

## Platform sınırları
iOS yapılandırmasında mevcut yatay yön desteği korunur; Windows üzerinde iOS native derleme/cihaz doğrulaması yapılmadı. iPad çoklu pencere veya Android büyük ekran yön politikaları landscape kilidini reddedebilir. Bu durumda kelime/süre açılmaz; kullanıcı yatay tam ekran kullanmaya yönlendirilir. Fiziksel duruş algılama ve hareketle yanıt bu fazda yoktur.

Flutter platform kısıtları: https://api.flutter.dev/flutter/services/SystemChrome/setPreferredOrientations.html

Commit/push yapılmadı. Önceki V1 ve Ben Kimim? fazlarının çalışma ağacındaki değişiklikleri korundu.

## Son çalıştırma sonuçları
- flutter analyze: No issues found.
- flutter test --concurrency=1: 250 başarılı test.
- Ek son landscape regresyon çalıştırması: 19 başarılı test.
- flutter build apk --debug: başarılı.
- Pixel 3: gerçek landscape tur, Doğru/Pas, HOME ile gizleme/duraklama, manuel devam, 60 saniye sonunda portrait sonuç, sonraki oyuncu ve diğer üç oyunun portrait ayar ekranları doğrulandı.
- Redmi 155e6b22: APK güncellemesi başarılı; başlatma komutu gönderildi. Güvenli kilit/NotificationShade görünümü nedeniyle kullanıcı kilidi açmalı.

Bu fazda eklenen/değiştirilen kod: main.dart; core/utils/app_orientation.dart; who_am_i/application/who_controller.dart; who_am_i/domain/who_models.dart; who_am_i/presentation/who_game_screen.dart, who_page.dart, who_landscape_board.dart, who_orientation_provider.dart. Testler: app_orientation_test.dart, who_landscape_test.dart, who_game_controller_test.dart, who_game_widget_test.dart. Dokümantasyon: bu dosya ve README.md. Önceki faz dosyaları Git durumunda ayrıca görünür.
