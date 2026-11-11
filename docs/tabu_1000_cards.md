# Tabu — 1.000 kartlık havuz kalite raporu

Tarih: 11 Kasım 2026

## Sonuç

- Önceki havuz: 500 kart. Eklenen: 500. Güncel havuz: 1.000 benzersiz ID ve hedef.
- Yeni ID aralığı: `tabu-501`–`tabu-1000`. Şema değişmedi: id, word, forbidden, category, difficulty.
- Kullanıcı kararı doğrultusunda eski kategori etiketleri korundu. Yeni kartlarda talep edilen 10 kategori kullanıldı; birleşik havuzda 17 kategori etiketi bulunur.
- Her kartta tam 5 dolu, birbirinden farklı ve hedefin kendisi olmayan yasaklı kelime vardır.

## Kategori dağılımı

| Kategori | Önceki | Eklenen | Toplam |
|---|---:|---:|---:|
| Günlük yaşam | 50 | 90 | 140 |
| Yemek ve içecek | 50 | 0 | 50 |
| Spor | 50 | 0 | 50 |
| Meslekler | 50 | 40 | 90 |
| Teknoloji | 50 | 40 | 90 |
| Doğa | 50 | 0 | 50 |
| Eğlence | 50 | 0 | 50 |
| Kültür | 50 | 0 | 50 |
| Seyahat | 50 | 0 | 50 |
| Nesneler | 50 | 0 | 50 |
| Yiyecek ve içecek | 0 | 60 | 60 |
| Hayvanlar ve doğa | 0 | 50 | 50 |
| Türkiye ve kültür | 0 | 50 | 50 |
| Spor ve eğlence | 0 | 40 | 40 |
| Duygular ve ilişkiler | 0 | 50 | 50 |
| Seyahat ve mekânlar | 0 | 40 | 40 |
| Deyimler ve popüler ifadeler | 0 | 40 | 40 |
| **Toplam** | **500** | **500** | **1.000** |

## Zorluk

| Havuz | Kolay | Orta | Zor |
|---|---:|---:|---:|
| Önceki 500 | 300 | 160 | 40 |
| Yeni 500 | 200 (%40) | 225 (%45) | 75 (%15) |
| Güncel 1.000 | 500 (%50) | 385 (%38,5) | 115 (%11,5) |

İstenen %40/%45/%15 dağılımı yeni 500 karta uygulandı. Önceki zorluk değerleri değiştirilmedi. Zorluk etiketleri editoryal değerlendirmedir; arkadaş gruplarıyla ölçülmüş istatistikler değildir.

## İçerik ve düzeltmeler

- Eski 500 kartta normalleştirilmiş hedef tekrarı veya eksik yasaklı kelime saptanmadı. Anlamsız olduğu kesinleşen eski hedef bulunmadı.
- `tabu-275`: **Önyargı → Ön yargı**. TDK birleşik kelime yazım kuralıyla doğrulanan bu düzeltme dışında eski 500 kartın alanları ve sırası korunur. Eski 250 kart tamamen aynıdır.
- Eski havuzun değişiklik öncesi kopyası `test/fixtures/tabu_cards_500.json` içinde tutulur. Regresyon testi yalnızca yukarıdaki yazım düzeltmesine izin verir.
- Yeni kartlar hazır kart listelerinden aktarılmadı. Her hedef için doğal çağrışımlardan beş yasaklı kelime ayrı ayrı yazıldı ve gözden geçirildi.
- Taslakta Sportmenlik/Fair play, Kahve/Türk kahvesi, Kararsızlık/İkilem gibi anlam çakışmaları elendi. Pansiyonculuk gibi yapay türetmeler kullanılmadı. Hedeflerin eşanlamlı yazılışları için seçilmiş bir eşleştirme listesiyle ek test yapılır.
- Taslaktaki Antenn → Anten ve Kiril harfi içeren Olta yazımı düzeltildi. Dimyat’a pirince giderken evdeki bulgurdan olmak ifadesi kaynak yazımıyla düzenlendi.
- Günlük sözcüklerden bilinen deyimlere doğru çeşitlilik sağlandı. Zor kartlar da anlatılabilir kavramlardan seçildi; aşırı teknik terimler veya geçici internet akımları kullanılmadı.

## Araştırma ve doğrulama sınırları

- [Hasbro Tabu kuralları](https://instructions.hasbro.com/tr-tr/instruction/tabu): hedefi anlatırken doğal çağrışım kelimelerinin yasaklanması yaklaşımı incelendi.
- [Hasbro aile sürümü](https://instructions.hasbro.com/tr-tr/instruction/tabu-aile-boyu-eglence): erişilebilirlik ve farklı yaş grupları yaklaşımı incelendi. Kaynaklar standart kategori yüzdeleri veya evrensel zorluk oranı yayımlamaz; bu çalışmadaki oranlar kullanıcı talebidir.
- [TDK ayrı yazılan birleşik kelimeler](https://tdk.gov.tr/icerik/yazim-kurallari/ayri-yazilan-birlesik-kelimeler/): ön yargı yazımı kontrol edildi.
- [TDK inisiyatif kaydı](https://sozluk.gov.tr/gts?ara=inisiyatif) ve [dil maddesi](https://sozluk.gov.tr/gts?ara=dil): hedef ve deyim yazımı için erişilebilen kayıtlar incelendi.
- [TDK Güncel Kullanımdan Türkçe Sözlük İçin Katkılar](https://tdk.gov.tr/wp-content/uploads/2018/01/2_Nevzat-G%C3%96ZAYDIN-_-G%C3%BCncel-Kullan%C4%B1mdan-T%C3%BCrk%C3%A7e-S%C3%B6zl%C3%BCk-i%C3%A7in-Katk%C4%B1lar.pdf): Dimyat ve dostlar alışverişte görsün ifadeleri kontrol edildi.
- TDK sözlük servisine bazı doğrudan sorgular bağlantı hatası verdi. Bütün 500 yeni hedefin ayrı ayrı TDK kaydıyla doğrulandığı iddia edilmez. Erişilen kaynak kontrolleri, Türkçe yazım incelemesi ve otomatik bütünlük denetimleri birlikte kullanıldı.
- Anlam eşdeğerliği ve yasaklı kelime kalitesi yalnızca otomatik testle kesin ispatlanamaz. Seçilmiş eşanlamlı kontrolleri ve editoryal inceleme uygulandı; oyun gruplarından gelecek geri bildirimlerle içerik geliştirilebilir.

## Teknik kapsam ve testler

- Yalnızca Tabu veri deposundaki kategori listesi ve içerik doğrulaması güncellendi. Controller, UI, puanlama, pas hakkı, sayaç ve deste seçimi değiştirilmedi.
- Türkçe harf/aksan, büyük-küçük harf, boşluk ve noktalama farklarını normalleştiren `tabuWordKey` yalnızca Tabu içerik doğrulamasında kullanılır. Bu geniş karşılaştırma tüm Türkçe sözcükler için anlamsal eşitlik iddiası değildir.
- Yeni kartların yasaklıları için basit çekim/ünsüz yumuşaması kontrolü eklenmiştir; bu tam bir Türkçe biçimbilim çözümleyicisi değildir.
- Mevcut uzun kelime widget testi doğrudan güncel destenin en uzun dört hedefini seçer; 260 piksel kart genişliği ve 1,6 yazı ölçeğinde denetler.
- Odaklı veri/controller testleri: 48 başarılı.
- `fvm flutter analyze`: başarılı, **No issues found**.
- `fvm flutter test --concurrency=1`: **409 test başarılı** (önceki 404 + 5 yeni test). Güncel havuzun en uzun hedeflerini kullanan widget testi ve diğer oyunların regresyonları geçti.
- `git diff --check`: başarılı.
- Bu görevde APK derlemesi veya fiziksel cihaz testi yapılmadı; içerik ve doğrulama kapsamı korundu.

## Değişen dosyalar

- `assets/data/tabu_cards.json`
- `lib/features/games/tabu/data/card_repository.dart`
- `test/tabu_card_data_test.dart`
- `test/tabu_controller_test.dart`
- `test/fixtures/tabu_cards_500.json` (yeni)
- `README.md`
- `docs/tabu_1000_cards.md` (bu rapor)

## Git

Commit veya push yapılmadı. Önceden mevcut `.vs/` yerel klasörüne dokunulmadı. Taslak üretim dosyaları ignored `build/tabu1000/` altında kalır. Başka oyunların dosyaları değiştirilmedi.
