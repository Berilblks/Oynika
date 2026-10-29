# Faz 3.3 — Tabu ayarlarında tema ve görsel hiyerarşi

29 Ekim 2026. Mevcut ThemeModeController, ThemeData ve sistem temasını izleyen uygulama yapısı korundu. Telefonun koyu modu bir hata olarak ele alınmadı. Açık temada krem/pastel, koyu temada mevcut mor yüzeyler kullanılmaya devam eder.

## Düzenlemeler

- Bölüm başlıkları, başlık/açıklama aralığı ve grup boşlukları dengelendi.
- Takım alanlarındaki iç içe dolu kutular kaldırıldı. Tema yüzeyi üzerinde hafif mavi/kırmızı ton ve tek ince kenarlık kullanıldı; odağa gelince ince alt çizgi beliriyor. İsim, etiket ve temizleme ikonunun renkleri temadan türetiliyor.
- Süre/hedef seçeneklerinde aynı tonal yüzey, köşe, yazı ağırlığı ve ince çerçeve kullanıldı. Seçili seçenek primaryContainer/onPrimaryContainer, diğerleri surfaceContainerLow/onSurfaceVariant çiftlerini kullanıyor.
- Oyuna Başla, primary/onPrimary çifti ve açık Nunito ağırlığıyla gösteriliyor. Koyu temada yazı rengi zorla beyaz yapılmıyor; açık lavanta buton üzerinde temanın koyu onPrimary rengi kullanılıyor.
- Bilgi ikonu odak/klavyeyi bırakıp kurallar modalını açıyor. Modal yüzeyi ve ikon renk çiftleri temaya uyuyor. Kapatma eylemi oyunu başlatmıyor.
- Sabit alt alan kendi tema yüzeyini kullanıyor. Klavye açıkken buton gizlenmeye, kapanınca görünmeye devam ediyor; küçük ekran/büyük yazıda içerik kaydırılabiliyor.

## Doğrulama

flutter analyze temiz. flutter test --concurrency=1 ile 115 test başarılı. Yeni üç regresyon testi açık/koyu temada takım metni/etiketi, seçili/seçili olmayan seçenekler ve başlat metni için 4,5:1 kontrast eşiğini; modalın temasını/kapatılmasını ve ThemeMode.system platform değişimini izlemeyi doğruluyor. İki temada 320×568 ve büyük yazı senaryoları da kontrol edildi. Kontrast hesapları çözümlenmiş tema renklerinden hesaplandı; ekran fotoğrafına dayanan ölçüm değildir.

Oyun controller'ı, domain, kart JSON'ları, diğer oyun dosyaları, ThemeData ve ThemeMode dosyaları değiştirilmedi. Önceki Faz 3.2 ortak widget düzenlemeleri çalışma ağacında korunuyor. Bu aşamada değişen dosyalar: tabu_setup_widgets.dart, tabu_screen.dart, test/tabu_widget_test.dart ve bu belge. Yeni paket yok. Commit/push yapılmayacak; görsel onay bekleniyor.

## APK ve Pixel 3

Debug APK derlemesi başarılı (assembleDebug 31,1 saniye). Pixel 3'te güncel APK kuruldu. Uygulamanın tema tercihi sistem modunda bırakılarak Android açık/koyu modu değiştirildi; iki görünümde ayarlar ve sabit başlat butonu taşmadan ekranda görüldü. Başlat yazısı açık temada mor üzerinde açık, koyu temada açık lavanta üzerinde koyu renkte ve kalın görünüyor. Bilgi ikonuyla iki temada kurallar sheet'i açıldı; kapatma sonrası ayarlarda kalındı. Koyu mod kaldırılmadı, açık renk zorlanmadı. Test sonunda emülatörün önceki sistem tema ayarı (night no) geri yüklendi. Redmi telefonunun sistem tema ayarı değiştirilmedi.

Görüntüler: build/tabu33-verification/01-light.png, 02-light-rules.png, 03-dark.png, 04-dark-rules.png. Build altında tutuluyor; Git'e alınmıyor.

Android System UI ilk kontrolde yanıt vermiyor uyarısı gösterdi; Bekle ile kontrol sürdürüldü. Uygulama Flutter logunda hata görülmedi. Tema dosyaları, oyun controller/domain dosyaları ve kart havuzları git diff ile değişmemiş olarak doğrulandı. Commit/push yapılmadı; görsel onay bekleniyor.

## Son onaylanan düzenlemeler

Başlık ve açıklama büyütüldü; iki yandaki görsellere eşit genişlik verilerek yatay merkezleri ekran merkezine hizalandı. Hizalama 320, 393 ve 768 genişliklerinde test edilir. Bölümler arası boşluk artırıldı. Dar ekranlarda tüm seçenekler kaydırılarak erişilebilir; başlat butonu sabit kalır. Ayar ekranında üst çubuktaki tekrar eden Tabu yazısı kaldırıldı; geri ve bilgi ikonları korundu. Koyu ayar ekranındaki dekoratif şekiller kaldırılarak mevcut tema yüzeyi tek renk kullanıldı. Bu son düzenlemeler Redmi Note 8 üzerinde kullanıcı tarafından onaylandı. Oynanış, tur sonu ve kazanan ekranları son onaylanan halleriyle korunur.
