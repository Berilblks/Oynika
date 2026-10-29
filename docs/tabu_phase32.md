# Faz 3.2 — Tabu ayar ekranı

Tabu ayarları, onaylanan görsel doğrultusunda kompakt başlık, küçük konuşma balonları, mavi/kırmızı takım alanları, eşit genişlikte süre seçenekleri ve 3+2 hedef puan seçenekleriyle düzenlendi. Varsayılan adlar Mavi Takım ve Kırmızı Takım; süre 90 saniye, hedef 20 puandır.

Oyuna Başla, Scaffold.bottomNavigationBar içindeki SafeArea alanında sabittir. Klavye açıldığında gizlenir; içerik yeniden boyutlanır ve alanlar kaydırılabilir. Klavye kapanınca buton görünür. Büyük yazı ölçeği kapatılmaz/kısıtlanmaz; dar cihazlarda içerik kaydırma ile erişilebilir kalır.

Sağ üst bilgi butonu dört kurallı, sürükleme göstergeli ve kaydırılabilir bottom sheet açar. Tamam, Başlayalım! yalnız sheet'i kapatır; ayarları ve oyun durumunu değiştirmez.

Takım renkleri ad yerine takım sırasına bağlıdır. Oynanış skorunda, tur öncesi/sonu tacında, tur sonu skor kartlarında ve kazanan panelinde mavi/kırmızı kimlik korunur. Diğer oyunların kullandığı ortak sunum bileşenlerine isteğe bağlı renk parametreleri eklendi; varsayılan renkleri değiştirilmedi. Sessiz Sinema dosyalarına dokunulmadı.

Oyun controller'ı, domain kuralları, üç pas, +1/0/-1 puanlama, hedef puan, sınırsız tur, deste seçimi ve iki kart JSON'u değişmedi. Yeni paket veya asset eklenmedi. Nunito ve mevcut illüstrasyon kullanıldı.

## Değişen dosyalar

- lib/features/games/tabu/presentation/tabu_screen.dart
- lib/features/games/tabu/presentation/tabu_setup_widgets.dart (yeni)
- lib/features/games/tabu/presentation/tabu_widgets.dart
- test/tabu_widget_test.dart
- test/widget_test.dart
- docs/tabu_phase32.md (bu belge)

## Doğrulama

Yeni widget testleri: varsayılan ad/renk/ayar, üç süre seçimi, 320/393/768 genişliklerde sabit buton ve klavye döngüsü, büyük yazıda kurallar modalı, modal kapatmanın oyunu başlatmaması. Mevcut hedef, pas, tur, kazanan ve Sessiz Sinema testleri korundu.

Commit veya push yapılmadı. Kullanıcı görsel onayı bekleniyor.

Komut sonuçları: flutter analyze temiz; flutter test --concurrency=1 ile 112 test başarılı (104 mevcut + 8 yeni). Debug APK başarıyla üretildi (assembleDebug 81,5 saniye). Geçici Gradle bellek ayarı işlem sonunda eski içeriğe döndürüldü; platform ayarlarında kalıcı değişiklik yok. APK build/app/outputs/flutter-apk/app-debug.apk konumundadır.


## Pixel 3 görsel kontrolü

Pixel 3 (1080×2160, 440 dpi) üzerinde APK kurularak normal ayarlar, kurallar modalı, gerçek Gboard klavyesi ve %130 sistem yazı ölçeği incelendi. Normal görünümde bütün ayarlar ve başlat butonu kaydırma olmadan görünüyor. Klavye açıkken alan düzenlenebiliyor ve başlat butonu gizleniyor; kapandığında geri geliyor. Modal kapatılınca oyun ayarlarında kalınıyor. Büyük yazıda ve bu görünümlerde RenderFlex taşması görülmedi; 320×568/%160 dahil daha dar senaryolar widget testlerinde kaydırılarak doğrulandı.

Ekran görüntüleri (build altında, Git dışı):

- build/tabu32-verification/01-setup.png
- build/tabu32-verification/02-rules.png
- build/tabu32-verification/03-keyboard.png
- build/tabu32-verification/04-large-text.png

Emülatörde font_scale ve donanım klavyesi için yapılan geçici sistem ayarları test sonunda önceki değerlerine döndürüldü. İlk Android açılışında System UI yanıt vermiyor uyarısı vardı; Bekle ile açılış tamamlandı. Uygulamanın Flutter logunda hata görülmedi. Görsel, referansın yerleşimini ve pastel dilini kullanır; mevcut Tabu görseli ve Material ikonlarıyla uygulanmıştır. Bilinen kalan uygulama hatası yoktur. Emülatör yeni Tabu ayar ekranında bırakıldı.
