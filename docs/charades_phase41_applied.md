# Faz 4.1 — Onaylanan kart değişiklikleri

28 Ekim 2026. Yalnız onaylanan 3 ad düzeltmesi ve 18 bire bir yapım değişikliği uygulandı. Faz 4.1 inceleme raporu, değişiklik öncesi analiz olarak korundu; bu belge uygulanan son durumu açıklar.

## Eski ve yeni isimler

| Kart ID | Tür | Eski ad | Yeni ad | Son zorluk |
|---|---|---|---|---|
| charades-027 | Film | Polizei | Felekten Bir Gece | Orta |
| charades-044 | Film | Recep İvedik 2 | Kutsal Damacana | Kolay |
| charades-045 | Film | Recep İvedik 3 | Eyyvah Eyvah | Kolay |
| charades-046 | Film | Recep İvedik 4 | Aşk Tesadüfleri Sever | Orta |
| charades-234 | Film | John Wick 3: Parabellum | Maymunlar Cehennemi | Kolay |
| charades-241 | Film | Erin Brockovich | Ölümlü Dünya | Kolay |
| charades-244 | Film | Cast Away: Yeni Hayat | Yeni Hayat | Kolay |
| charades-407 | Dizi | Seinfeld | Ruhsar | Orta |
| charades-408 | Dizi | Frasier | Çılgın Bediş | Orta |
| charades-410 | Dizi | Scrubs | Cennet Mahallesi | Kolay |
| charades-412 | Dizi | Community | Hayat Şarkısı | Orta |
| charades-421 | Dizi | Futurama | Küçük Ağa | Kolay |
| charades-422 | Dizi | BoJack Horseman | Yılan Hikayesi | Kolay |
| charades-450 | Dizi | The X-Files | Gizli Dosyalar | Orta |
| charades-463 | Dizi | The Tudors | Bir İstanbul Masalı | Orta |
| charades-465 | Dizi | Downton Abbey | Sefirin Kızı | Orta |
| charades-472 | Dizi | Band of Brothers | Kardeşler Takımı | Kolay |
| charades-475 | Dizi | 1899 | Küçük Sırlar | Kolay |
| charades-482 | Dizi | Glee | Gönül Dağı | Kolay |
| charades-492 | Dizi | Jessica Jones | Adanalı | Orta |
| charades-496 | Dizi | Andor | Kardeşlerim | Kolay |

## Kaynak ve yapım kimliği

Üç ad düzeltmesinde ID, kategori, zorluk ve kaynak kimliği korundu. Yeni adlar aynı filme/diziye bağlıdır. 18 yapım değişikliğinde eski kaynak kimliği kaldırıldı, yeni yapımın kendine ait kimliği, kanonik adı, yayıncı/doğrulama bağlantısı, yıl, IMDb kimliği ve ad varyantları kaydedildi. Kart JSON şeması yine yalnız id/title/category/difficulty alanlarıdır; ek metadata sadece docs/charades_title_sources.json içindedir.

| ID | Eski kimlik | Yeni kimlik | Yapım / doğrulama kaydı |
|---|---|---|---|
| charades-027 | wikidata:Q1712554 | wikidata:Q219315 | [Katalog](https://www.wikidata.org/wiki/Q219315) · [Yayıncı/katalog kontrolü](https://www.netflix.com/tr/title/70113002) · 2009 · tt1119646 |
| charades-044 | wikidata:Q934763 | wikidata:Q12810477 | [Katalog](https://www.wikidata.org/wiki/Q12810477) · [Yayıncı/katalog kontrolü](https://www.kanald.com.tr/sinemalar/kutsal-damacana) · 2007 · tt1092011 |
| charades-045 | wikidata:Q1573810 | wikidata:Q5423075 | [Katalog](https://www.wikidata.org/wiki/Q5423075) · [Yayıncı/katalog kontrolü](https://www.startv.com.tr/film/eyyvah-eyvah) · 2010 · tt1594918 |
| charades-046 | wikidata:Q17378488 | wikidata:Q4808148 | [Katalog](https://www.wikidata.org/wiki/Q4808148) · [Yayıncı/katalog kontrolü](https://boxofficeturkiye.com/film/ask-tesadufleri-sever--2010746) · 2011 · tt1807950 |
| charades-234 | wikidata:Q52951815 | wikidata:Q469624 | [Katalog](https://www.wikidata.org/wiki/Q469624) · [Yayıncı/katalog kontrolü](https://www.disneyplus.com/tr-tr/browse/entity-5a604256-5a73-4d19-bde2-f408c202bea3) · 2001 · tt0133152 |
| charades-241 | wikidata:Q220955 | wikidata:Q47520467 | [Katalog](https://www.wikidata.org/wiki/Q47520467) · [Yayıncı/katalog kontrolü](https://boxofficeturkiye.com/film/olumlu-dunya--2013696) · 2018 · tt7748244 |
| charades-244 | wikidata:Q213411 | wikidata:Q213411 | [Katalog](https://www.wikidata.org/wiki/Q213411) |
| charades-407 | tvmaze:530 | tvmaze:94093 | [Katalog](https://www.tvmaze.com/shows/94093/ruhsar) · [Yayıncı/katalog kontrolü](https://www.kanald.com.tr/ruhsar) · 1998 · tt0846614 |
| charades-408 | tvmaze:540 | wikidata:Q6101177 | [Katalog](https://www.wikidata.org/wiki/Q6101177) · [Yayıncı/katalog kontrolü](https://www.kanald.com.tr/cilgin-bedis) · 1996 · tt1162451 |
| charades-410 | tvmaze:532 | tvmaze:60030 | [Katalog](https://www.tvmaze.com/shows/60030/cennet-mahallesi) · [Yayıncı/katalog kontrolü](https://www.showtv.com.tr/dizi/tanitim/cennet-mahallesi/976) · 2004 · tt0424619 |
| charades-412 | tvmaze:318 | tvmaze:15471 | [Katalog](https://www.tvmaze.com/shows/15471/hayat-sarkisi) · [Yayıncı/katalog kontrolü](https://www.kanald.com.tr/hayat-sarkisi) · 2016 · tt5302120 |
| charades-421 | tvmaze:538 | tvmaze:35823 | [Katalog](https://www.tvmaze.com/shows/35823/kucuk-aga) · [Yayıncı/katalog kontrolü](https://www.kanald.com.tr/kucuk-aga) · 2014 · tt3776084 |
| charades-422 | tvmaze:184 | tvmaze:54429 | [Katalog](https://www.tvmaze.com/shows/54429/yilan-hikayesi) · [Yayıncı/katalog kontrolü](https://www.kanald.com.tr/yilan-hikayesi) · 1999 · tt0287285 |
| charades-450 | tvmaze:430 | tvmaze:430 | [Katalog](https://www.tvmaze.com/shows/430/the-x-files) |
| charades-463 | tvmaze:712 | wikidata:Q3556357 | [Katalog](https://www.wikidata.org/wiki/Q3556357) · [Yayıncı/katalog kontrolü](https://www.atv.com.tr/bir-istanbul-masali/hakkinda) · 2003 · tt0421297 |
| charades-465 | tvmaze:251 | tvmaze:45360 | [Katalog](https://www.tvmaze.com/shows/45360/sefirin-kizi) · [Yayıncı/katalog kontrolü](https://www.startv.com.tr/dizi/sefirin-kizi) · 2019 · tt11256614 |
| charades-472 | tvmaze:465 | tvmaze:465 | [Katalog](https://www.tvmaze.com/shows/465/band-of-brothers) |
| charades-475 | tvmaze:39749 | tvmaze:18868 | [Katalog](https://www.tvmaze.com/shows/18868/kucuk-sirlar) · [Yayıncı/katalog kontrolü](https://www.startv.com.tr/dizi/kucuk-sirlar) · 2010 · tt1755473 |
| charades-482 | tvmaze:8 | tvmaze:51098 | [Katalog](https://www.tvmaze.com/shows/51098/gonul-dagi) · [Yayıncı/katalog kontrolü](https://www.trt1.com.tr/diziler/gonul-dagi/oyuncu) · 2020 · tt12872884 |
| charades-492 | tvmaze:1370 | tvmaze:18901 | [Katalog](https://www.tvmaze.com/shows/18901/adanali) · [Yayıncı/katalog kontrolü](https://www.atv.com.tr/adanali/hakkinda) · 2008 · tt1428614 |
| charades-496 | tvmaze:52341 | tvmaze:53620 | [Katalog](https://www.tvmaze.com/shows/53620/kardeslerim) · [Yayıncı/katalog kontrolü](https://www.atv.com.tr/kardeslerim/hakkinda) · 2021 · tt13550498 |

Maymunlar Cehennemi: Tim Burton’ın 2001 filmi (tt0133152). Küçük Ağa: 2014 Kanal D dizisi (tt3776084). Çılgın Bediş: 1996 televizyon dizisi (Q6101177), aynı adlı karikatür (Q6024529) değil. Ölümlü Dünya: 2018 Türkiye vizyonlu Ali Atay filmi (Q47520467); aynı başlıklı 1960 filmi veya anlam ayrımı sayfası değil. Yılan Hikayesi TVmaze kaydında prömiyer alanı boş olduğundan 1999 yılı TVmaze’den alınmış gibi gösterilmedi; Türkçe yapım kaydı ve yayıncı karşılaştırmasıyla belirtildi.

Yeni yapımların Wikidata P31 film/dizi türleri veya TVmaze Scripted türü kontrol edildi. Yayıncı ve yerel kataloglarda ad, kadro ve uygun sürüm karşılaştırıldı. TVmaze ve Wikidata topluluk/metadata kaynaklarıdır; yayıncının kendisi değildir. Kayıtlar geliştirme sırasında kontrol edildi, oyun internetsiz çalışmaya devam eder.

## Yeni 18 kartın zorluk gerekçeleri

| ID | Kart | Zorluk | Gerekçe |
|---|---|---|---|
| charades-027 | Felekten Bir Gece | Orta | Gece/parti jesti var; felek deyimi soyut. |
| charades-044 | Kutsal Damacana | Kolay | Damacana ve kutsama somut jestlerle bölünebilir. |
| charades-045 | Eyyvah Eyvah | Kolay | Şaşkınlık ve korku mimikleri; ses çıkarılmaz. |
| charades-046 | Aşk Tesadüfleri Sever | Orta | Aşk somut jestle desteklenir; tesadüf/sevmek ilişkisi daha soyut. |
| charades-234 | Maymunlar Cehennemi | Kolay | Maymun, gezegen ve korku hareketleri güçlü; 2001 filmi. |
| charades-241 | Ölümlü Dünya | Kolay | Ölmek ve dünya jestiyle bölünebilir; ilk Türkiye vizyonu 2018. |
| charades-407 | Ruhsar | Orta | Hayalet karakteri yardımcı; özel adın kendisi zor. |
| charades-408 | Çılgın Bediş | Orta | Çılgın davranış somut; Bediş özel ad ve dizi bilgisi gerektirir. |
| charades-410 | Cennet Mahallesi | Kolay | Melek, mahalle ve dans hareketleri. |
| charades-412 | Hayat Şarkısı | Orta | Şarkı söyleme sessiz jestle mümkün; hayat daha soyut. |
| charades-421 | Küçük Ağa | Kolay | Boy/çocuk ve otorite jesti; 2014 Kanal D dizisi. |
| charades-422 | Yılan Hikayesi | Kolay | Yılan ve hikâye/kitap hareketleri somut. |
| charades-463 | Bir İstanbul Masalı | Orta | Masal anlatma ve şehir jesti; İstanbul özel adı orta yük. |
| charades-465 | Sefirin Kızı | Orta | Kız anlatılabilir; sefir kelimesi ve temsilci kavramı orta yük. |
| charades-475 | Küçük Sırlar | Kolay | Küçük ve sır saklama hareketleri. |
| charades-482 | Gönül Dağı | Kolay | Kalp ve dağ hareketleri. |
| charades-492 | Adanalı | Orta | Polis karakteri yardımcı; şehir adının kendisi özel bilgi gerektirir. |
| charades-496 | Kardeşlerim | Kolay | Kardeş/aile hareketleriyle anlatılabilir. |

Yeni yapımlar: 10 Kolay, 8 Orta. Tüm havuz: 275 Kolay, 208 Orta, 17 Zor. Eski zor kartlar topluca değiştirilmedi; yalnızca onaylanan 18 yeni yapım yeniden derecelendirildi. Geriye kalan kartlarda difficulty dahil hiçbir alan değiştirilmedi. Değerlendirme editoryaldir; oyuncu başarı ölçümü değildir.

## Veri ve kapsam kontrolleri

- 500 kart, 300 Film ve 200 Dizi; 500 benzersiz kart ID’si ve 500 ayrı kaynak/yapım kimliği.
- Mevcut ad, kanonik/özgün ad ve yeni ad varyantları Türkçe harf dönüşümü, Unicode ve noktalama normalleştirmesiyle tarandı: 760 farklı ad anahtarı; farklı yapımlar arasında çakışma yok. Tek yapımın kendi ad varyantları birden fazla kart sayılmadı.
- Yeni 18 IMDb kimliği birbirinden farklı; önceki havuzun değiştirilmeyen ve IMDb kimliği bulunan kayıtlarıyla da çakışmıyor. Önceki kayıtlarda eksik IMDb alanları mevcut olduğundan IMDb denetimi tek başına tüm 500 yapım için eksiksiz otorite sayılmadı; kaynak kimliği ve kanonik ad denetimleri birlikte kullanıldı.
- 453 korunacak + 26 inceleme kartı = 479 kart, değişiklik öncesi fixture ile alan bazında aynı. Kaynak kayıtları da karşılaştırıldı; 479 kayıt aynı.
- Üç isim düzeltmesinde kartların sadece title alanı ve kaynak kaydının title alanı değişti; yapım kimliği, kategori ve zorluk korundu.
- Mevcut Rastgele deste, iki takım, süre/hedef/tur/pas kuralları, ekran tasarımı ve Tabu dosyaları değiştirilmedi. Yeni bağımlılık yok.

## Test ve dosyalar

test/charades_data_test.dart dosyasına dört regresyon testi eklendi: yalnız 21 kartın değişmesi/479 kartın korunması, üç adın kimlik koruması, 18 yeni yapımın doğru kimlik/zorluk/sürüm bilgisi, Türkçe/kanonik ad çakışma denetimi. Mevcut oyun ve widget testleri korundu.

Fixture dosyaları, değişiklik öncesi 500 kartı ve kaynak kimliklerini saklar: test/fixtures/charades_phase4_cards.json ve test/fixtures/charades_phase4_identities.json. Oyuna asset olarak eklenmezler.

Bu görevde değişen/eklenen kalıcı dosyalar:

- assets/data/sessiz_sinema_cards.json
- docs/charades_title_sources.json
- test/charades_data_test.dart
- test/fixtures/charades_phase4_cards.json
- test/fixtures/charades_phase4_identities.json
- docs/charades_phase41_applied.md

Kart JSON SHA-256: `4aa7b8b5d5fc8b7b2cb45d24f6b28b9e7fcf8126992d5738933a846950754ccf`.

## Komut sonuçları

| Komut | Sonuç |
|---|---|
| flutter analyze | No issues found |
| flutter test --concurrency=1 | 104 test başarılı (önceki 100 + 4 yeni regresyon testi) |
| flutter build apk --debug | Başarılı; assembleDebug 30,3 saniye |

APK: build/app/outputs/flutter-apk/app-debug.apk. APK içindeki Flutter kart asset’inin kaynak JSON ile SHA-256 eşitliği de kontrol edildi. Derleyicide Android x86 desteğinin gelecek Flutter sürümünde kaldırılacağına ilişkin mevcut SDK uyarısı var; bu derlemede hata değil. Bellek için kullanılan geçici Gradle JVM ayarı derleme sonunda eski içeriğine döndürüldü; platform yapılandırmasında kalıcı değişiklik yok.

Son kapsam denetiminde mevcut dosyalardan yalnız kart JSON’u, kaynak JSON’u ve ilgili veri testi değişti. İki baseline fixture ve bu uygulama raporu eklendi. Önceden var olan diğer lib/test/assets/docs ve üst düzey proje ayarları hash karşılaştırmasıyla korundu. Kaynak dağılımı son durumda 309 Wikidata / 191 TVmaze; bu sayılar oyun kategorileri değil doğrulama sağlayıcılarıdır. 500 ayrı kaynak kimliği ve 760 ad anahtarı korundu. Commit/push yapılmadı; kullanıcı onayı bekleniyor.
