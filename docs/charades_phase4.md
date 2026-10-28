# Faz 4 — Sessiz Sinema

## Kapsam ve kurallar

Beş evre: Oyun Ayarları, Sıra Kimde?, Canlandırma, Tur Sonu, Kazanan. `/games/charades` ayarları açar. Ana Sayfa ve Oyunlar kartları bu rotayı kullanır. Diğer üç oyun tanıtım aşamasındadır; Tabu kodu ve 500 kartlık havuzu değiştirilmedi.

Tam iki takım, düzenlenebilir ve boş olmayan farklı isimler. Süre 60/90/120 (varsayılan 90), hedef 10/15/20/25/30 (varsayılan 20). Tur sınırı yok; takımlar dönüşümlü oynar. Doğru +1, Pas 0; tur başına üç pas, butonda kalan hak. Sıfırda pas kapanır ama Doğru çalışır. Negatif puan ve yanlış/tabu işlemi yoktur. Hedefe ulaşınca sayaç iptal edilir ve kart ilerletilmeden sonuç açılır. Süresi biten açık kart puanlanmaz.

Hazırım seçilene kadar kart görünmez ve süre işlemez. Duraklatma/uygulamanın etkinliğini kaybetmesi kartı gizler, süre ve pası korur; dönüşte kullanıcı devam eder. Aktif oyundan çıkış onayı vardır. Kazanan ekranından geri veya Oyunlara Dön, `/games` rotasına gider; yeniden giriş temiz kurulumu açar. Tekrar Oyna isim/süre/hedefi korur, skor/tur/pas/deste geçmişini sıfırlar. Timer provider kapatılınca temizlenir.

## Mimari ve görsel bileşenler

Yeni modül `lib/features/games/charades/` altında domain, data, application ve presentation katmanlarıdır. Oyun controller'ı UI'dan ayrıdır; monoton saat Riverpod ile enjekte edilir. CharadesCard, CharadesState ve CharadesOutcome (yalnızca correct/pass) bağımsızdır. Önceden test edilmiş GameSession, Team, GamePhase/RoundScore değer tipleri ve saf sunum widget'ları Tabu modülünden değişiklik yapılmadan yeniden kullanılır. Bu aşamada ortak kodu taşımak için kapsamlı refactor yapılmadı; iki oyunun provider'ları, sayaçları, desteleri ve oturumları ayrıdır.

Nunito, mevcut pastel palet, 34 sp tur sonu skor kartları, küçük süre kapsülü ve üç pas tasarımı kullanılır. Kart, krem yüzeyde ortalı büyük yapım adı, Film/Dizi etiketi ve Konuşmadan anlat! metnidir; yasaklı kelimeler bulunmaz. Uzun adlar kesilmeden sarılır. Dar/büyük yazılı ekranlarda içerik kaydırılır; tabletlerde içerik 480 dp genişlikle sınırlıdır. Mevcut charades illüstrasyonu ve Flutter çizimleri kullanıldı; yeni bağımlılık yoktur.

## 500 kart ve kaynak kontrolü

`assets/data/sessiz_sinema_cards.json` tam 300 Film ve 200 Dizi içerir. Diğer kategoriler kaldırılmıştır. Her kayıtta yalnızca `id`, `title`, `category`, `difficulty` bulunur. Zorluk dağılımı 265 Kolay, 210 Orta, 25 Zor'dur; filtre veya kategori seçimi yoktur. Zorluk, adın tanınırlığı ve hareketle anlatılabilirliği üzerinden editoryal değerlendirmedir, oyuncu ölçümü değildir.

Türk ve yabancı yapımlar seçildi; yaygın Türkçe adlar, Friends/Stranger Things gibi Türkiye'de özgün adıyla tanınan markalar korundu. Aynı Türkçe ada sahip farklı filmler ayırt edilir: Can Dostum (1997 / Good Will Hunting) ve Can Dostum (2011 / The Intouchables) farklı yapımlardır. Serilerin bağımsız filmleri ayrı karttır; aynı yapımın takma/çeviri adı ikinci kart değildir.

28 Ekim 2026 tarihinde kaynak eşleştirmesi yapıldı. `docs/charades_title_sources.json`, 500 kartın her biri için kanonik yapım adı, benzersiz kaynak kimliği, URL ve kontrol tarihini tutar. Bu dosya oyun asset'inin parçası değildir ve çalışma sırasında ağa erişilmez. Film ve dizi özetleri, replikleri, görselleri veya tam kataloglar uygulamaya aktarılmadı.

- 193 dizi [TVmaze](https://www.tvmaze.com/api) katalog kimliğiyle eşleştirildi. TVmaze, kendi kataloğunu yayımlayan bir metadata sağlayıcısıdır; yayıncının kendisi değildir. Aynı adlı sonuçlarda yıl/uyarlama kontrolü yapıldı: Sihirli Annem 2003, Anne 2016, Çalıkuşu 2013, One Piece 1999, The Flash 2014, Doctor Who 2005. TVmaze kayıtlarına doğrudan bağlantılar kaynak dosyasındadır.
- 300 film ve 7 dizi, [Wikidata](https://www.wikidata.org/) kimliği ve medya türüyle eşleştirildi. Wikipedia başlık/redirect ve Wikidata P31 türü birlikte kontrol edildi; aynı adlı kitap, kişi veya kavram kayıtları doğrulama sayılmadı. Bu kaynaklar topluluk tarafından düzenlenen kataloglardır; hata olasılıkları sıfır değildir. Kanonik kimliklerle mükerrer yapımlar denetlendi.
- Seçili yapımlar ayrıca birincil kaynaklarla karşılaştırıldı: [Avrupa Yakası / atv](https://www.atv.com.tr/avrupa-yakasi/hakkinda), [Aşk-ı Memnu / Ay Yapım](https://www.ayyapim.com/tr-tr/ask-i-memnu), [Stranger Things / Netflix](https://www.netflix.com/tr/title/80057281), [Karlar Ülkesi / Disney+](https://www.disneyplus.com/tr-tr/browse/entity-04c97b72-504b-47f2-9c6f-fe13d9aea82f).

500 başlığın tamamının yayıncı sitelerinden tek tek doğrulandığı veya tüm Türkçe yerelleştirmelerin resmî dağıtım adı olduğu iddia edilmez. Katalog kimliği/türü kontrolü ile yerelleştirme editoryal tercihi ayrı tutulur. Tanınırlık ve zorluk gerçek oyuncu geri bildirimiyle iyileştirilebilir. Araştırma sırasındaki ham kataloglar ve geçici betikler yalnızca ignore edilen build klasöründedir; depoya eklenmez.

## Deste ve test yaklaşımı

Oyun başında tüm 500 kart Random/shuffle ile karıştırılır. Gösterilen sıra takım değişiminde ve duraklatmada korunur. Tüm kartlar bitince deste yeniden karıştırılır; son kart yeni destenin ilk kartı olamaz (tek kartlık test havuzu istisnası). Kart kimliği kontrolü ve 350 ms kilit aynı karta/çok hızlı basışa çift puan verilmesini önler.

Unit testleri kontrollü saatle çalışır: iki takım doğrulaması, üç süre, beş hedef, +1/0 puan, üç pas, yeni tur, sınırsız tur, ikinci takımın kazanması, zaman aşımı, duraklatma, tekrar oyun ve 500 kartın tamamının takım geçişleri boyunca tekrarlanmaması. Widget testleri 320×568, 393×786 ve 768×1024 boyutlarında koyu tema/büyük yazı, beş evre, gizlilik, çıkış onayı, yaşam döngüsü, pas/sonuç/navigasyon ve uzun adları kontrol eder. Veri testleri 300/200 dağılımını, benzersiz ID/ad/yapım kimliklerini ve yalnızca dört alanlı şemayı doğrular. Eski 72 test de korunur.

## Bilinen sınırlar

Oturum bellektedir; işletim sistemi uygulamayı tamamen kapatırsa oyun sıfırlanır. Doğru tahmin kararını oyuncular verir; kamera/mikrofon/ses tanıma yoktur. iOS cihaz derlemesi Windows'ta yapılmadı. İnternet yalnızca geliştirme sırasında ad araştırmasında kullanıldı; oyunun internet gereksinimi yoktur.

## 30 örnek kart

Güncellenen kapsam iki kategori olduğu için toplam 30 örnek, 15 Film + 15 Dizi olarak verilir.

| Kategori | Yapım adı | Zorluk |
|---|---|---|
| Film | Hababam Sınıfı | Kolay |
| Film | Tosun Paşa | Kolay |
| Film | Babam ve Oğlum | Kolay |
| Film | G.O.R.A. | Orta |
| Film | Aile Arasında | Kolay |
| Film | Esaretin Bedeli | Orta |
| Film | Titanik | Kolay |
| Film | Matrix | Kolay |
| Film | Yüzüklerin Efendisi: İki Kule | Kolay |
| Film | Harry Potter ve Felsefe Taşı | Kolay |
| Film | Karayip Korsanları: Siyah İnci'nin Laneti | Orta |
| Film | Evde Tek Başına | Kolay |
| Film | Örümcek Adam | Kolay |
| Film | Karlar Ülkesi | Kolay |
| Film | Şrek | Kolay |
| Dizi | Avrupa Yakası | Kolay |
| Dizi | Leyla ile Mecnun | Kolay |
| Dizi | Muhteşem Yüzyıl | Orta |
| Dizi | Aşk-ı Memnu | Orta |
| Dizi | Çukur | Kolay |
| Dizi | Şahsiyet | Zor |
| Dizi | Kızılcık Şerbeti | Kolay |
| Dizi | Friends | Kolay |
| Dizi | Prison Break | Kolay |
| Dizi | Game of Thrones | Kolay |
| Dizi | Stranger Things | Orta |
| Dizi | Black Mirror | Kolay |
| Dizi | La Casa de Papel | Kolay |
| Dizi | Squid Game | Kolay |
| Dizi | Simpsonlar | Kolay |

## Son doğrulama

- flutter pub get: başarılı; yeni paket eklenmedi.
- flutter analyze: No issues found. Build altındaki geçici Flutter test dosyalarının analiz edilmemesi için analysis_options.yaml içinde build/** dışlandı.
- flutter test --concurrency=1: 100 test başarılı (mevcut 72 + yeni 28).
- flutter build apk --debug: APK üretildi ve Pixel 3 emülatörüne başarıyla kuruldu: build/app/outputs/flutter-apk/app-debug.apk.
- Pixel 3: kurulum, kartı gizleyen oyun öncesi ekranı, Film/Dizi kartı, üç pasın tükenmesi, duraklatma/devam, süre sonunda tur sonucu, sıradaki takım, Pembe Takımın 20 puanda kazanması ve tekrar oyunda 0/0 kontrol edildi. İncelenen ekranlarda taşma görülmedi.
- Görüntüler: build/charades-verification/01-setup.png, 02-pre-round.png, 03-gameplay.png, 03-pass-zero.png, 03-paused.png, 04-round-result.png, 04-next-team.png, 05-winner.png, 06-replay.png. Build altındadır; Git'e alınmaz.
- Emülatör ilk açılışta Android System UI yanıt vermiyor uyarısı gösterdi; Bekle seçilerek açılış tamamlandı. Uygulamada Flutter hata kaydı görülmedi. Testler ve emülatör eşzamanlı çalıştırıldığında Windows bellek baskısı oluştuğu için testler emülatör kapalıyken tek eşzamanlı süreçle tamamlandı.
- Tabu kaynakları ve Tabu JSON dosyasında değişiklik yoktur. Commit/push yapılmadı.
