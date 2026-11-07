# Ben Kimim? — Faz 6.1

## Kapsam

2–20 oyuncu, varsayılan 4 oyuncu. Varsayılan isimler Oyuncu 1, Oyuncu 2 vb. Alanlar düzenlenebilir; boş ve Türkçe büyük/küçük harfle tekrarlanan isimler reddedilir. İsimler başlatılırken kırpılır. Azaltılan oyuncuların isim controller'ları tutulur ve sayı artırılınca geri gelir.

60/90/120 saniye seçenekleri eşit genişliktedir; varsayılan 90 saniye. SafeArea içindeki sabit mor başlatma butonu klavyede gizlenir. İçerik kaydırılabilir; şeffaf üst/alt alanların arkasında aynı krem/lavanta veya koyu mor arka plan devam eder. Mevcut `who_am_i.png` illüstrasyonu kullanılır, başka oyunların ikonları değiştirilmez.

## Mimari

- `domain/who_models.dart`: WhoPlayer, doğrulanan ve immutable WhoGameSettings, WhoRoundDuration ve başlangıç WhoGameSession. Başlangıç oyuncu indeksi 0'dır; oynanış ilerlemesi yoktur.
- `application/who_controller.dart`: Riverpod autoDispose oturumu, doğrulanan başlatma ve ayarlara dönüş için reset. İkinci başlatma aktif hazırlığı değiştirmez.
- `presentation/who_screen.dart`: Oyuncu/süre formu, isim doğrulama, kurallar modalı.
- `presentation/who_page.dart`: Yalnızca bu oyuna ait şeffaf Scaffold ve tema uyumlu sistem çubukları.
- `presentation/who_start_screen.dart`: Geçici başlangıç ve seçilen ayarlar. Gerçek sayaç veya oyun kartı içermez.

`/games/who_am_i` yeni modülü açar. Başlangıç ayrı bir URL gerektirmez; yalnızca doğrulanmış controller oturumuyla gösterilir. Android geri ve Ayarlara Dön, oturumu temizler ve mevcut formdaki isimleri/süreyi korur. Ayarlar geri butonu önceki route'a, doğrudan girişte oyun listesine döner.

Kurallar modalının “Tamam, Başlayalım!” butonu yalnızca modalı kapatır. Sensör geliştirme notu kullanıcıya gösterilmez. Katalogdaki `isPlayable` false kalır.

## Sınırlar

Gerçek oynanış, sensör, kart havuzu, puanlama, pas işlemleri ve geri sayım uygulanmadı. Oturum yalnızca bellekte tutulur. Ben Kimim? yayına hazır bir oyun olarak işaretlenmedi. Önceki dört oyunluk ürün yapısı değişiklikleri korunur. Commit veya push yapılmaz.

## Doğrulama

`flutter analyze` temiz. `flutter test --concurrency=1`: 173 test başarılı (21 yeni domain/controller/widget senaryosu). `flutter build apk --debug`: başarılı.

Pixel 3'te varsayılan 4 oyuncu, artı/eksi kontrolü, Deniz ismine düzenleme, 120 saniye seçimi, kurallar modalının yalnızca kapanması, başlangıçta 4 oyuncu/120 saniye aktarımı ve geri dönüş kontrol edildi. Açık/koyu tema, klavye, uzun isimler, 320×568 / 768×1024 ve 1.6 yazı ölçeği test kapsamındadır. Native klavye kontrolünde emülatörün Gboard tanıtımı kapatıldı; uygulama koduna klavye veya sensör özelliği eklenmedi.

Güncellenen entegrasyon dosyaları: `lib/app/router/app_router.dart`, `test/widget_test.dart`, `README.md`, `docs/v1_product_structure.md`. Yeni testler `test/who_controller_test.dart` ve `test/who_widget_test.dart`. Tabu, Sessiz Sinema ve Aramızdaki Casus feature dosyaları değişmedi.

Görseller, Git'in ignore ettiği `build/who61/` klasöründe: `pixel-setup-light.png`, `pixel-setup-dark.png`, `pixel-keyboard-light.png`, `pixel-duration-light.png`, `pixel-duration-dark.png`, `pixel-rules-light.png`, `pixel-rules-dark.png`, `pixel-start-light.png`, `pixel-start-dark.png`.
