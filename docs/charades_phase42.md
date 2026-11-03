# Faz 4.2 — Sessiz Sinema ayar ekranı

Tabu ayar ekranının onaylanan boşlukları, ince kenarlıklı takım kartları ve seçim bileşenleri referans alındı. Tabu dosyaları değiştirilmedi; oyuna özgü başlık ve beş maddelik kurallar nedeniyle Sessiz Sinema formu ayrı tutuldu. Mevcut ortak skor, taç ve panel bileşenleri kullanıldı.

- Sinema ikonlu, ortalanmış kompakt başlık ve açıklama.
- Varsayılan Mavi Takım / Kırmızı Takım; renkler takım indeksine bağlı, ad değişiminden etkilenmez.
- Süre 60/90/120 (varsayılan 90), hedef 10/15/20/25/30 (varsayılan 20).
- SafeArea içinde sabit başlatma butonu; klavyede gizlenir, kapanınca geri gelir. Mor zemin, beyaz ikon/metin.
- Bilgi ikonu beş kuralı gösterir; Anladım yalnızca modalı kapatır.
- Tema renklerinden türetilen yüzeyler ve metinler; koyu ayarlarda düz arka plan.
- Dar ekran/büyük yazıda içerik kaydırılır, başlatma butonu içerikle kaymaz.
- Diğer evrelerde yalnızca takım renkleri güncellendi; kart havuzu, kontrolcü ve oyun kuralları değişmedi.

## Doğrulama

`flutter analyze`: sorun yok. `flutter test --concurrency=1`: 118 test başarılı. `flutter build apk --debug`: başarılı. Widget testleri 320×568, 393×786 ve 768×1024 ekranlarını, büyük yazıyı, iki temayı, klavyeyi, seçimleri, düzenlenen isimleri ve modalın oyun başlatmamasını kapsar. Mevcut oyun testleri korundu.

Pixel 3 görüntüleri (Git dışında): `build/charades42-verification/`. Emülatörde depolama sorunu nedeniyle yalnızca emülatörün eski Oynika kurulumu kaldırılıp yeniden yüklendi.

Commit veya push yapılmadı.
