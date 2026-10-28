# Oynika — Faz 4.1 Sessiz Sinema kart kalitesi ve Türkçeleştirme incelemesi

Tarih: 28 Ekim 2026. Durum: yalnızca analiz ve öneri; kullanıcı onayı bekleniyor.

## Özet tablo

| Ölçüt | Sayı |
|---|---:|
| Toplam kart | 500 |
| Film / Dizi | 300 / 200 |
| 1. Aynen korunacak | 453 |
| 2. Yerleşik Türkçe adıyla değiştirilecek | 3 |
| 3. Türkçe karşılığı/ad tercihi ayrıca değerlendirilecek | 26 |
| 4. Başka yapımla değiştirilmesi önerilecek | 18 |
| 5. Doğrulanamayan veya mükerrer olduğu için düzeltilecek | 0 |

Her kart tam bir ana gruptadır: 453 + 3 + 26 + 18 + 0 = 500. Tüm değişiklik adayları aşağıda (47 kart); 500 kartın eksiksiz A–F dökümü Ek A’dadır. Grup 3 karar bekleyen bir listedir, uygulanacak isim değişikliği listesi değildir. Grup 4 bir kalite önerisidir; mevcut yapımın sahte veya hatalı olduğu anlamına gelmez.

## Yöntem, kanıt ve sınırlar

Girdi doğrudan assets/data/sessiz_sinema_cards.json dosyasıdır. docs/charades_title_sources.json içindeki önceki 500 yapım kaydı kart ID’leriyle eşleştirildi; önceki araştırma önbelleği kanonik ad, farklı sürüm ve uyarlama kontrolünde yardımcı olarak okundu. Önceki kayıtların tümü bugün yeniden ağdan indirilmiş değildir. Ek A’daki “K” varlık kanıtı, önceki kayıt bağlantısı bulundu demektir; 500 yapımın tamamı resmî yayıncıdan bugün yeniden doğrulandı demek değildir. Seçili ihtilaflı adlar ve önerilen 18 alternatif için bu incelemede ayrıca web kontrolü yapıldı.

A: yapımın varlığı/katalog kimliği; B: Türkiye için tercih edilen ad; C: özgün marka/Türkçe tercih; D: hareketle anlatım; E: Türkiye karma arkadaş grubunda tanınma beklentisi; F: aynı yapımın başka adla tekrarı. Ek A her altı alanı kapsar. D ve E araştırmacı değerlendirmesidir; izleyici anketi, reyting sonucu veya ölçülmüş başarı olasılığı değildir. Yüksek/orta/düşük tanınma, kuşak, yaş, yabancı dizi izleme alışkanlığı ve ortak kültüre bağlıdır. Bir yayıncıda yer almak tek başına yüksek tanınma kanıtı değildir.

Güven düzeyi önerinin kanıt gücünü gösterir. Yüksek: doğrudan yerel yayıncı/katalog ad eşleştirmesi ve açık somut gerekçe. Orta: yapım gerçek, fakat tanınırlık/anlatım üstünlüğü editoryal varsayım veya yerelleştirme ek kontrol bekliyor. Düşük: bir öneriyi savunacak yeterli kanıt yok. Bu raporda düşük güvenli kesin isim değişikliği önerilmedi.

“Aynen korunacak” başlık/kimlik bakımından mevcut kartın tutulması önerisidir; Ek A’daki yeni D değerlendirmesi, JSON’daki mevcut difficulty değerini değiştirmez. Korunan zor kartlar vardır. İsimdeki kişi/yer adlarını tamamen kaldırmak veya her İngilizce sözcüğü çevirmek hedef değildir.

## İstenen dört oyun referansından çıkarımlar

- [Sogepps](https://sogepps.tr/sessizsinema/): bölgesel gösterim adlarını ve klasik jestleri öne çıkarıyor. Oynika için yerleşik yerel başlığı seçme ilkesine destek; oradaki kartları almadım.
- [Chardz](https://chardz.app/tr/): kısa turlar ve geniş konu çeşitliliği sunuyor. Kendi kuralı ses taklidine de izin verebiliyor; bu kural Oynika’ya taşınmamalı. Oynika’nın yalnız Film/Dizi kapsamı korunmalı.
- [Imposter rehberi](https://imposter.hu/tr/blog/sessiz-sinema-kelimeleri/): somut hareket, ortak bilgi ve zorluk dengesi üzerinde duruyor. Bazı bölümleri çizim/tarif modlarını da kapsadığından bu tavsiyeler Oynika’nın sessiz hareket kuralına süzülerek uygulandı.
- [Takiye](https://takiye.com/sessiz-sinema-kelimeleri/): film adını parçalama ve ikonik sahne yolunu gösteriyor. Kolay/zor sınıfları grubun bilgisine bağlı; listedeki adlar ve etiketler doğrulama otoritesi olarak kullanılmadı.

Bu kaynakların uygulama/listelerinden toplu kart aktarımı yapılmadı. Araştırma, mevcut 500 karttan başladı. Referans uygulamaların kategori, süre, ses, yanlış cezası veya tur kuralları öneri kapsamına alınmadı.

## Yapısal denetim ve mükerrer kontrolü

- 500 kayıt, 300 Film, 200 Dizi; her kart yalnız id/title/category/difficulty alanlarına sahip.
- 500 benzersiz ID; Türkçe büyük-küçük harf, Unicode ve noktalama normalleştirmesinde de 500 benzersiz ad.
- Önceki kaynak dosyasında 500 benzersiz kaynak kimliği (193 TVmaze, 307 Wikidata). Farklı kaynak sistemlerindeki ID’lerin farklı olması tek başına farklı yapım garantisi değildir; kanonik başlıklar ve bilinen takma/çeviri adları da karşılaştırıldı.
- Önceki araştırma önbelleğinde 500 ayrı Wikidata kimliği ve 478 kartta IMDb kimliği bulundu; bu 478 kimlikte tekrar çıkmadı. Önbellekteki bazı ilk dizi QID’leri manga/kitap kavramına bağlanabildiğinden bu ek kontrol nihai dizi türü doğrulaması sayılmadı; nihai TVmaze/yapım kaydı esas alındı. Kalan 22 IMDb alanının eksikliği “yapım yok” demek değildir.
- İncelemede aynı gerçek yapımın iki ayrı kart olduğu bir örnek veya uydurma yapım saptanmadı; 5. grupta bu nedenle 0 kart var. Bu, bütün takma adların eksiksiz evrensel bir otoriteyle doğrulandığı iddiası değildir.
- Can Dostum (89, Good Will Hunting, 1997) ve Can Dostum (2011) (103, The Intouchables) farklı filmlerdir. Aynı Türkçe ad oyuncu açısından belirsizlik yaratabilir; ikisi 3. gruptadır.
- Hekimoğlu / House, Mucize Doktor / The Good Doctor ayrı uyarlamalardır. Avatar animasyonu, One Piece 1999 anime, Sabrina 1996 sitcom, Çalıkuşu 2013 ve Doctor Who 2005 kimlikleri korunmalı. Dizi/film yeniden çevrimi eklenirse var olan kartın takma adı gibi ele alınmamalı.
- Film serilerinin numaralı devamları ayrı filmlerdir. Fazla devam filmi, mükerrer değil içerik çeşitliliği sorunudur. Örneğin dört Recep İvedik kartından üçü alternatif adayına ayrıldı; ilk film korundu.

## Öncelikli kararlar

1. Yüksek güvenli üç ad sadeleştirmesi: Yeni Hayat, Gizli Dosyalar, Kardeşler Takımı.
2. Tanınan markaları koru: Matrix, Friends, Lost, Wednesday ve Harry Potter çevrilmemeli. Şrek/Shrek aynı markadır; Netflix Türkiye Şrek kullanıyor. Kullanıcının Shrek örneği, özgün markayı koruma ilkesidir; mevcut Şrek yazımı tek başına hata sayılmadı. İlk iki kart korunuyor, üçüncü kartın seri yazımı ayrıca inceleniyor.
3. The Good Place → İyi Yer ve The Queen’s Gambit → Vezir Gambiti otomatik dönüşümü yapılmamalı. İlki açıklamadaki mekân, ikincisi ayrıca kitabın Türkçe adıdır; dizi başlıkları yayıncıda İngilizce kalıyor.
4. İngilizce ve özel ada dayalı zor kartların tamamını silme. Forrest Gump, Schindler’in Listesi, G.O.R.A., Şahsiyet, The Mandalorian ve Severance gibi kartlar zor dilimi sağlayabilir; bilinirlik ile anlatım kolaylığı farklıdır.
5. 18 bire bir alternatif yalnız onay sonrası değerlendirilmeli. Altısı film, on ikisi dizi: uygulanırsa yine 300/200 ve 500 kalır. Alternatifler mevcut havuzdaki adlarla çakışmıyor. Aynı yapımın farklı adla çakışmaması için uygulama öncesi yeni kanonik ID’leri de kaydetmek gerekir.

## Tüm değişiklik adayları

Aşağıdaki tablolar istenen Kart ID, Film/Dizi, mevcut ad, öneri, neden, kaynak/doğrulama ve güven alanlarını içerir. Uzun açıklamalar mobil ekranda yatay kaydırma gerektirebilir.

### 2. Yerleşik Türkçe adıyla değiştirilecek (3 kart)

| Kart ID | Film/Dizi | Mevcut ad | Önerilen ad / alternatif | Değişiklik nedeni | Kaynak veya doğrulama durumu | Güven |
|---|---|---|---|---|---|---|
| charades-244 | Film | Cast Away: Yeni Hayat | Yeni Hayat | Yerleşik Türkçe başlık yeterli; Cast Away öneki anlatımda ek İngilizce yük oluşturuyor. | [Sinema TV](https://sinematv.com.tr/CAST-AWAY), [Box Office Türkiye](https://boxofficeturkiye.com/film/yeni-hayat--2001029): aynı 2000 filmi ve Türkçe başlık karşılaştırıldı. | Yüksek |
| charades-450 | Dizi | The X-Files | Gizli Dosyalar | Türkiye katalog adı, gizli belge/dosya hareketleriyle bölünebilir. 1993 dizisi esas alınmalı; 1998 filmi değil. | [JustWatch Türkiye](https://www.justwatch.com/tr/tv-sovu/gizli-dosyalar): 1993 dizi ve özgün ad birlikte listeleniyor. | Yüksek |
| charades-472 | Dizi | Band of Brothers | Kardeşler Takımı | Yerleşik ad, kardeşlik/takım/asker hareketleriyle İngilizce başlıktan daha erişilebilir. | [JustWatch Türkiye](https://www.justwatch.com/tr/tv-sovu/kardesler-takimi): 2001 mini dizi ve özgün ad karşılaştırıldı. | Yüksek |

### 3. Türkçe karşılığı/ad tercihi ayrıca değerlendirilecek (26 kart)

| Kart ID | Film/Dizi | Mevcut ad | Önerilen ad / alternatif | Değişiklik nedeni | Kaynak veya doğrulama durumu | Güven |
|---|---|---|---|---|---|---|
| charades-089 | Film | Can Dostum | Can Dostum (1997) değerlendirmesi | 103 ile aynı yapım değil. İki farklı filmin Türkçe başlığı çok yakın; sadece 103 yıl taşıdığı için oyuncu açısından asimetri var. Yıl gösterimi hareketle anlatmayı da zorlaştırabilir. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.wikidata.org/wiki/Q193835). | Orta |
| charades-103 | Film | Can Dostum (2011) | Can Dostum (2011) korunsun; 89 ile birlikte adlandırma kararı | The Intouchables ile Good Will Hunting farklı filmler. Birini silmek mükerrer temizliği değildir. Oyuncunun hangi filmi kastettiğini ayıran ad/yıl politikası gerekir. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.wikidata.org/wiki/Q595). | Orta |
| charades-117 | Film | Jaws | Jaws / Denizin Dişleri — Jaws geçici tercih | Türkçe karşılık önceki katalogda var; Jaws da yaygın marka. Köpekbalığı hareketi iki ad için de güçlü. Salt çeviri uğruna tanınan adı kaybetmeyelim. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.wikidata.org/wiki/Q189505). | Orta |
| charades-134 | Film | Yıldız Savaşları: İmparator | Yıldız Savaşları: İmparatorun Dönüşü — tam başlık kontrolü | Mevcut İmparator, alt başlığı kısaltıyor. Önceki Wikidata Türkçe etiketi ile Wikipedia başlığı farklı; kesin dağıtım yazımı ayrıca teyit edilmeli. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.wikidata.org/wiki/Q181795). | Orta |
| charades-173 | Film | Babam Bir Kahraman | Babam Bir Kahraman korunsun; 1996 kimliği editoryal kayıtta netleşsin | Jingle All the Way (1996) kastediliyor. Benzer Türkçe ad taşıyan başka filmlerle karıştırılmamalı; bu havuzda ikinci bir Babam Bir Kahraman yok. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.wikidata.org/wiki/Q1064530). | Orta |
| charades-221 | Film | Batman ve Superman: Adaletin Şafağı | Batman ve Superman: Adaletin Şafağı / Batman v Superman — dağıtım yazımı kontrolü | İki karakter çok tanınır; çevirisi değil bağlaç ve tam marka yazımı belirsiz. Uzun adın tümü için süre baskısı var. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.wikidata.org/wiki/Q14772351). | Orta |
| charades-293 | Film | Şrek 3 | Şrek 3 / Shrek 3 / Üçüncü Şrek — mevcut ad geçici tercih | Ayrı üçüncü film; mükerrer değil. Serinin ilk iki başlığıyla yazım tutarlılığı korunmalı, doğrulanmamış Üçüncü Şrek çevirisi otomatik uygulanmamalı. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.wikidata.org/wiki/Q486588). | Orta |
| charades-409 | Dizi | Two and a Half Men | Two and a Half Men / İki Buçuk Adam — mevcut ad geçici tercih | İki Buçuk Adam hareketle daha kolay; Türkiye yayıncı başlığının baskınlığı bu çalışmada teyit edilemedi. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.tvmaze.com/shows/130/two-and-a-half-men). | Orta |
| charades-411 | Dizi | The Good Place | The Good Place korunsun; İyi Yer otomatik uygulanmasın | Netflix Türkiye başlığı İngilizce; İyi Yer açıklamada bir mekân adı. Açıklamadaki çeviri dizi başlığı kanıtı değildir. Kolay etiketi ayrıca iyimser. | [Netflix Türkiye](https://www.netflix.com/tr/title/80113701): başlık ve açıklama ayrı kontrol edildi. [Mevcut kimlik](https://www.tvmaze.com/shows/2790/the-good-place). | Orta |
| charades-414 | Dizi | Sabrina | Sabrina / Genç Cadı Sabrina (1996) — kimlik korunarak karar | Kaynak 1996 sitcomunu gösteriyor. Netflixteki Sabrina’nın Tüyler Ürperten Maceraları farklı uyarlama; sadece Sabrina çok anlamlı. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.tvmaze.com/shows/976/sabrina-the-teenage-witch). | Orta |
| charades-423 | Dizi | Avatar: Son Hava Bükücü | Avatar: Son Hava Bükücü / Avatar: Son Havabükücü — yazım kontrolü | Mevcut kart 2005 animasyonu; 2024 canlı çekim dizi veya 2010 filmle değiştirilmemeli. Kataloglarda birleşik yazım görülüyor. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.tvmaze.com/shows/555/avatar-the-last-airbender). | Orta |
| charades-426 | Dizi | Dragon Ball | Dragon Ball korunsun; Ejder Topu yalnız kullanım teyidiyle | Somut ejder/top çağrışımı avantaj; bir sözlük çevirisi yerleşik Türkçe başlık sayılmaz. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.tvmaze.com/shows/2102/dragon-ball). | Orta |
| charades-429 | Dizi | Death Note | Death Note korunsun; Ölüm Defteri kullanım testi | Ölüm Defteri anlatılabilir; anime/manga ve canlı çekim filmler farklı kayıtlar. Mevcut anime kimliği korunmalı, adın baskınlığı ölçülmeli. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.tvmaze.com/shows/40/death-note). | Orta |
| charades-430 | Dizi | Attack on Titan | Attack on Titan korunsun; Titanlara Saldırı kullanım testi | Anime adı özgün markayla tanınabilir; dev/saldırı jesti var. Türkçe kullanımın yaygınlığı için yeterli birincil kanıt yok. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.tvmaze.com/shows/919/attack-on-titan). | Orta |
| charades-441 | Dizi | House | House / Doktor House — mevcut ad geçici tercih | Ev kelimesiyle veya doktor jestiyle anlatılabilir; sırf House = ev diye Ev yapılmamalı. Hekimoğlu (386) ayrı Türk uyarlaması. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.tvmaze.com/shows/118/house). | Orta |
| charades-443 | Dizi | The Good Doctor | The Good Doctor / İyi Doktor — mevcut ad geçici tercih | Mucize Doktor (385) aynı yapım değildir. İyi Doktor ifadesinin yerleşik başlık olduğu ayrıca teyit edilmeli. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.tvmaze.com/shows/21845/the-good-doctor). | Orta |
| charades-446 | Dizi | The Vampire Diaries | The Vampire Diaries / Vampir Günlükleri | Vampir ve defter jestleri güçlü; önceki Türkçe katalog bağlantısı çeviri adını destekliyor ama baskın yayıncı yazımı yeni kontrolde kesinleşmedi. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.tvmaze.com/shows/63/the-vampire-diaries). | Orta |
| charades-448 | Dizi | Teen Wolf | Teen Wolf / Genç Kurt | Kurt taklidi kolay; özgün marka ile eski Türkçe yayın adının hangisinin daha tanındığı grup yaşına bağlı. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.tvmaze.com/shows/176/teen-wolf). | Orta |
| charades-461 | Dizi | Spartacus | Spartacus / Spartaküs | Tanınan karakter korunmalı; Türkçe yazım ile yayıncı Latin yazımı arasında tutarlılık kararı gerekiyor. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.tvmaze.com/shows/716/spartacus). | Orta |
| charades-471 | Dizi | Chernobyl | Chernobyl / Çernobil | Nükleer kaza hareketiyle anlatılabilir, ancak yer adı tek başına zor. Türkçe yer adı her zaman dizi marka başlığı değildir. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.tvmaze.com/shows/30770/chernobyl). | Orta |
| charades-473 | Dizi | The Queen's Gambit | The Queen's Gambit korunsun; Vezir Gambiti alternatifinin bilinirliği test edilsin | Netflix Türkiye başlığı İngilizce. Netflix kitap yazısında Vezir Gambiti geçiyor; kitap çevirisi otomatik dizi başlığı kanıtı değildir. Satranç hareketi güçlü. | [Netflix dizi sayfası](https://www.netflix.com/tr/title/80234304), [Netflix kitap yazısı](https://about.netflix.com/tr/news/an-exciting-new-chapter-for-books-with-netflix-adaptations): kullanım farkı görüldü. [Mevcut kimlik](https://www.tvmaze.com/shows/41428/the-queens-gambit). | Orta |
| charades-481 | Dizi | Gossip Girl | Gossip Girl / Dedikoducu Kız (2007) | Türkçe katalog karşılığı var; 2021 yeniden çevrimi farklı yapım. Genç gruplarda özgün marka daha tanınabilir. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.tvmaze.com/shows/567/gossip-girl). | Orta |
| charades-483 | Dizi | Desperate Housewives | Desperate Housewives / Umutsuz Evkadınları (2004) | Umutsuz Ev Kadınları Türk uyarlaması da var. Yalnız Türkçe ad, mevcut ABD yapımının kimliğini belirsizleştirebilir; bu bir mükerrer kart kanıtı değildir. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.tvmaze.com/shows/550/desperate-housewives). | Orta |
| charades-490 | Dizi | Superman ve Lois | Superman ve Lois / Superman & Lois | Çeviri gerekmiyor; bağlaç/marka yazımı için yayıncı tutarlılığı değerlendirilmeli. Superman somut jest sağlar, Lois özel ad olarak zor. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.wikidata.org/wiki/Q93281114). | Orta |
| charades-498 | Dizi | Invincible | Invincible korunsun; Yenilmez otomatik uygulanmasın | Prime Video Türkçe sayfası INVINCIBLE kullanıyor. Yenilmez adlı filmler de var; kolay görünen çeviri yapım adını karıştırabilir. | [Prime Video Türkçe](https://www.primevideo.com/-/tr/detail/0KRK7IABRYDORGPDYP1XO3OT0Q): özgün marka korunuyor. [Mevcut kimlik](https://www.tvmaze.com/shows/37196/invincible). | Orta |
| charades-500 | Dizi | Büyük Küçük Yalanlar | Büyük Küçük Yalanlar / Big Little Lies | Mevcut Türkçe ad anlatılabilir; önceki kimlik Big Little Lies. Özgün markayı mı Türkçe karşılığı mı grubun daha iyi bildiği ayrıca değerlendirilmeli. | Önceki yapım kimliği mevcut; aday Türkçe adın baskınlığı/dağıtım yazımı bu aşamada ayrıca doğrulanmadı. Ek A kaynak bağlantısı; onay öncesi kontrol gerekir. [Mevcut kimlik](https://www.wikidata.org/wiki/Q19873404). | Orta |

### 4. Başka yapımla değiştirilmesi önerilecek (18 kart)

| Kart ID | Film/Dizi | Mevcut ad | Önerilen ad / alternatif | Değişiklik nedeni | Kaynak veya doğrulama durumu | Güven |
|---|---|---|---|---|---|---|
| charades-027 | Film | Polizei | Felekten Bir Gece (2009) | Polizei Almanca başlık ve daha dar bir Kemal Sunal repertuvarı gerektiriyor; polis jesti mümkün olsa da komedi çeşitliliği için aday. Alternatif anlatım yolu: gece/parti/uykusuzluk. | [Alternatif yapım kaydı](https://www.netflix.com/tr/title/70113002) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-044 | Film | Recep İvedik 2 | Kutsal Damacana (2007) | Recep İvedik serisinde dört kart var; ikinci film numarası farklı sahne olmadan ayrışmıyor. Ayrı film olduğu için veri hatası değil, çeşitlilik önerisi. Alternatif anlatım yolu: büyük su şişesi/korku. | [Alternatif yapım kaydı](https://www.kanald.com.tr/sinemalar/kutsal-damacana) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-045 | Film | Recep İvedik 3 | Eyyvah Eyvah (2010) | Aynı karakterin üçüncü film numarasına dayanan tekrar hissini azaltır. Yeni ad korku/şaşkınlık mimikleriyle anlatılabilir. Alternatif anlatım yolu: şaşkınlık/klarnet hareketi. | [Alternatif yapım kaydı](https://www.startv.com.tr/film/eyyvah-eyvah) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-046 | Film | Recep İvedik 4 | Aşk Tesadüfleri Sever (2011) | Dördüncü Recep İvedik yerine başka bir romantik komedi tonu; ad kelimelere bölünür. Daha kolay olduğu garanti değil. Alternatif anlatım yolu: kalp/karşılaşma. | [Alternatif yapım kaydı](https://boxofficeturkiye.com/film/ask-tesadufleri-sever--2010746) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-234 | Film | John Wick 3: Parabellum | Maymunlar Cehennemi (2001) | John Wick üçüncü filminde Parabellum özel adı ve seri numarası baskın; farklı somut hayvan teması öneriliyor. 2001 Tim Burton filmi özellikle seçildi. Alternatif anlatım yolu: maymun/gezegen. | [Alternatif yapım kaydı](https://www.disneyplus.com/tr-tr/browse/entity-5a604256-5a73-4d19-bde2-f408c202bea3) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-241 | Film | Erin Brockovich | Ölümlü Dünya (Türkiye vizyonu 2018) | Erin Brockovich bir özel ad; adını jestle kurmak güç ve karakter taklidi filmi izlemeyi gerektiriyor. Yerli komedi alternatifi daha erişilebilir olabilir. Alternatif anlatım yolu: ölmek/dünya. | [Alternatif yapım kaydı](https://boxofficeturkiye.com/film/olumlu-dunya--2013696) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-407 | Dizi | Seinfeld | Ruhsar (1998) | Seinfeld güçlü sitcom markası olsa da soyadı tek başına somut ipucu vermiyor; genel Türkiye grubu için yerli nostalji alternatifi. Alternatif anlatım yolu: hayalet karakteri. | [Alternatif yapım kaydı](https://www.kanald.com.tr/ruhsar) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-408 | Dizi | Frasier | Çılgın Bediş (1996) | Frasier karakter özel adına dayanır; Türkiye dışı kültürel bilgi yükü yüksek. Bediş de özel ad ama çılgın davranışlar ve okul karakteri destekler. Alternatif anlatım yolu: çılgınlık/öğrenci. | [Alternatif yapım kaydı](https://www.kanald.com.tr/cilgin-bedis) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-410 | Dizi | Scrubs | Cennet Mahallesi (2004) | Scrubs hastane jestiyle anlatılabilir ama İngilizce kıyafet terimi ve görece dar tanınırlık yükü var; yerli topluluk komedisi seçeneği. Alternatif anlatım yolu: melek/mahalle/dans. | [Alternatif yapım kaydı](https://www.showtv.com.tr/dizi/tanitim/cennet-mahallesi/976) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-412 | Dizi | Community | Hayat Şarkısı (2016) | Community topluluk anlamıyla soyut ve belirli sitcom izleyicisini gerektiriyor; şarkı kelimesi ses çıkarmadan söyleme hareketiyle anlatılabilir. Alternatif anlatım yolu: yaşam/şarkı söyleme jesti. | [Alternatif yapım kaydı](https://www.kanald.com.tr/hayat-sarkisi) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-421 | Dizi | Futurama | Küçük Ağa (2014 Kanal D dizisi) | Futurama bilinmeyen izleyici için soyut marka; Küçük Ağa boy/çocuk/otorite jestleri sağlar. 1983 TRT uyarlaması değil 2014 dizi kastediliyor. Alternatif anlatım yolu: küçük/çocuk/ağa. | [Alternatif yapım kaydı](https://www.kanald.com.tr/kucuk-aga) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-422 | Dizi | BoJack Horseman | Yılan Hikayesi (1999) | BoJack Horseman at/adam olarak canlandırılabilir ama hem isim hem yetişkin animasyonu niş kalabilir; yerli polisiye ve yılan hareketiyle çeşitlilik. Alternatif anlatım yolu: yılan/kitap hikâyesi/polis. | [Alternatif yapım kaydı](https://www.kanald.com.tr/yilan-hikayesi) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-463 | Dizi | The Tudors | Bir İstanbul Masalı (2003) | The Tudors hanedan bilgisi ve İngilizce özel ad gerektirir; İstanbul/masal çağrışımı daha bölünebilir. Alternatif anlatım yolu: şehir/masal/âşık çift. | [Alternatif yapım kaydı](https://www.atv.com.tr/bir-istanbul-masali/hakkinda) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-465 | Dizi | Downton Abbey | Sefirin Kızı (2019) | Downton Abbey yer adı ve dönem dizisi bilgisi gerektirir; kız kelimesi ve temsilci jestleri daha açık. Sefir kelimesi yine orta zorluktur. Alternatif anlatım yolu: elçi/kız. | [Alternatif yapım kaydı](https://www.startv.com.tr/dizi/sefirin-kizi) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-475 | Dizi | 1899 | Küçük Sırlar (2010) | 1899 salt sayı olduğundan jestle cevap çok mekanik; küçük ve sır saklama hareketleri daha çeşitli. Alternatif anlatım yolu: küçük/sır saklamak. | [Alternatif yapım kaydı](https://www.startv.com.tr/dizi/kucuk-sirlar) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-482 | Dizi | Glee | Gönül Dağı (2020) | Glee şarkı/dansla anlatılabilir ancak sözcük ve müzikal dizinin genel grupta tanınması sınırlı olabilir; gönül/dağ somut yolu sağlar. Alternatif anlatım yolu: kalp/dağ. | [Alternatif yapım kaydı](https://www.trt1.com.tr/diziler/gonul-dagi/oyuncu) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-492 | Dizi | Jessica Jones | Adanalı (2008) | Jessica Jones soyadına ve Marvel alt dizilerine aşinalık gerektirir; polis karakteri ve şehir çağrışımı olan yerli dizi denenebilir. Alternatif anlatım yolu: polis/karakter taklidi. | [Alternatif yapım kaydı](https://www.atv.com.tr/adanali/hakkinda) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |
| charades-496 | Dizi | Andor | Kardeşlerim (2021) | Andor özgün karakter soyadı ve Star Wars yan hikâyesi bilgisine dayanır; kardeşlik ve aile hareketleri daha erişilebilir. Alternatif anlatım yolu: kardeşler/aile. | [Alternatif yapım kaydı](https://www.atv.com.tr/kardeslerim/hakkinda) kontrol edildi; mevcut yapım kaydı Ek A’da. Daha yüksek tanınırlık beklentisi editoryal tahmindir, ölçülmüş sonuç değildir. | Orta |

### 5. Doğrulanamayan veya mükerrer olduğu için düzeltilecek (0 kart)

Doğrulanamayan veya mükerrer olduğu için zorunlu düzeltme önerilen kart saptanmadı.

## Zorluk ve içerik dengesi

Mevcut JSON etiketleri: 265 Kolay, 210 Orta, 25 Zor. Ek A’daki bağımsız hareketle anlatım incelemesi: 284 Kolay, 92 Orta, 124 Zor. Bu ikinci dağılım mevcut 500 kartın değerlendirmesidir; alternatifler uygulanmış nihai deste dağılımı değildir.

Zorluk yalnız sözcük sayısıyla belirlenmemeli: Forrest Gump iki sözcük olmasına rağmen özel addır; Çöpçüler Kralı somut parçalar içerir. İngilizce bir ad tanınsa bile oyuncunun onu kelimelere ayırması zor olabilir. Uzun bir Harry Potter alt başlığı ana karakter jestiyle bulunabilse de tam alt başlığın ayrımı orta/zor kalabilir.

Onay sonrası içerik düzenlemesinde yaklaşık %50–60 kolay, %25–35 orta ve %10–20 zor, başlangıç editoryal aralığı olarak denenebilir; bunlar bilimsel eşik değildir. Küçük bir karma grupta kart başına bulunma süresi, pas ve hiç tanımama notu toplanarak ayarlanması daha güvenilir olur. İki farklı yaş grubu ve yabancı dizi izleme düzeyi olan oyuncularla kör ad tanıma testi özellikle 3. grup için yararlı olur. Bu aşamada bir test/grup araştırması yapılmadı.

Bütün destenin rastgele gelmesi korunmalı. Kolay/zor sıralaması, kategori seçimi, yeni filtre veya mekanik değişikliği önerilmiyor; denge kartların editoryal dağılımında kurulmalı.

## Ek A — 500 kartın A–F değerlendirmesi

Kısaltmalar: K = önceki katalog kaydıyla varlığı destekli, bağlantı A sütunundadır; TR = mevcut yerli ad/yerleşik Türkçe ad tercih ediliyor; Ö = tanınan özgün marka/özel ad tercih ediliyor; Karma = marka + Türkçe alt ad; İncele = 3. grup veya 2. grup kararına bak. C bir dil tespit algoritması değildir, kart için adlandırma tercihidir. D üç seviyeli hareketle anlatım yüküdür; E tanınma beklentisidir. F “Saptanmadı”, eldeki kayıtlarda aynı yapım tekrarına rastlanmadığını belirtir. G4 satırlarında B yeni alternatifin adı değil, mevcut yapım için korunabilecek addır; alternatif üst tabloda ayrı tutulur.

| ID | Tür | A: varlık / kanonik kayıt | B: Türkiye için ad tercihi | C | D: anlatım | E: tanınma | F: mükerrer | Ana grup |
|---|---|---|---|---|---|---|---|---|
| charades-001 | Film | [K: Hababam Sınıfı](https://www.wikidata.org/wiki/Q1218009) | Hababam Sınıfı | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-002 | Film | [K: Hababam Sınıfı Sınıfta Kaldı](https://www.wikidata.org/wiki/Q6088721) | Hababam Sınıfı Sınıfta Kaldı | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-003 | Film | [K: The Chaos Class Is Waking Up](https://www.wikidata.org/wiki/Q6087318) | Hababam Sınıfı Uyanıyor | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-004 | Film | [K: Hababam Sınıfı Tatilde](https://www.wikidata.org/wiki/Q5636593) | Hababam Sınıfı Tatilde | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-005 | Film | [K: The Chaos Class Is Fretting Over](https://www.wikidata.org/wiki/Q6094986) | Hababam Sınıfı Dokuz Doğuruyor | TR | Zor | Orta | Saptanmadı | G1 |
| charades-006 | Film | [K: Tosun Paşa](https://www.wikidata.org/wiki/Q7827905) | Tosun Paşa | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-007 | Film | [K: Süt Kardeşler](https://www.wikidata.org/wiki/Q4807991) | Süt Kardeşler | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-008 | Film | [K: Şabanoğlu Şaban](https://www.wikidata.org/wiki/Q8082379) | Şaban Oğlu Şaban | TR | Zor | Orta | Saptanmadı | G1 |
| charades-009 | Film | [K: The King of the Street Cleaners](https://www.wikidata.org/wiki/Q7744599) | Çöpçüler Kralı | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-010 | Film | [K: Kibar Feyzo](https://www.wikidata.org/wiki/Q1740774) | Kibar Feyzo | TR | Zor | Yüksek | Saptanmadı | G1 |
| charades-011 | Film | [K: Davaro](https://www.wikidata.org/wiki/Q6806566) | Davaro | Ö | Zor | Yüksek | Saptanmadı | G1 |
| charades-012 | Film | [K: Abbas in Flower](https://www.wikidata.org/wiki/Q4663809) | Çiçek Abbas | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-013 | Film | [K: Happy Days](https://www.wikidata.org/wiki/Q6084541) | Neşeli Günler | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-014 | Film | [K: Gülen Gözler](https://www.wikidata.org/wiki/Q5626835) | Gülen Gözler | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-015 | Film | [K: Aile Serefi](https://www.wikidata.org/wiki/Q6079722) | Aile Şerefi | TR | Orta | Orta | Saptanmadı | G1 |
| charades-016 | Film | [K: Our Family](https://www.wikidata.org/wiki/Q19473356) | Bizim Aile | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-017 | Film | [K: Sakar Şakir](https://www.wikidata.org/wiki/Q6085441) | Sakar Şakir | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-018 | Film | [K: Kapıcılar Kralı](https://www.wikidata.org/wiki/Q12810220) | Kapıcılar Kralı | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-019 | Film | [K: İnek Şaban](https://www.wikidata.org/wiki/Q6062891) | İnek Şaban | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-020 | Film | [K: Salako](https://www.wikidata.org/wiki/Q6074383) | Salako | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-021 | Film | [K: Zübük](https://www.wikidata.org/wiki/Q6094318) | Zübük | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-022 | Film | [K: Queer World](https://www.wikidata.org/wiki/Q6084591) | Düttürü Dünya | TR | Zor | Orta | Saptanmadı | G1 |
| charades-023 | Film | [K: Fearless Coward](https://www.wikidata.org/wiki/Q6087774) | Korkusuz Korkak | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-024 | Film | [K: Sahte Kabadayı](https://www.wikidata.org/wiki/Q6086814) | Sahte Kabadayı | TR | Orta | Orta | Saptanmadı | G1 |
| charades-025 | Film | [K: Doktor Civanim](https://www.wikidata.org/wiki/Q6074914) | Doktor Civanım | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-026 | Film | [K: Ortadirek Şaban](https://www.wikidata.org/wiki/Q6063936) | Ortadirek Şaban | TR | Zor | Orta | Saptanmadı | G1 |
| charades-027 | Film | [K: Polizei](https://www.wikidata.org/wiki/Q1712554) | Polizei | Ö | Zor | Düşük | Saptanmadı | G4 |
| charades-028 | Film | [K: The Girl with the Red Scarf](https://www.wikidata.org/wiki/Q2278004) | Selvi Boylum Al Yazmalım | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-029 | Film | [K: Jolly Life](https://www.wikidata.org/wiki/Q12811143) | Neşeli Hayat | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-030 | Film | [K: The Bandit](https://www.wikidata.org/wiki/Q635848) | Eşkıya | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-031 | Film | [K: My Father and My Son](https://www.wikidata.org/wiki/Q797577) | Babam ve Oğlum | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-032 | Film | [K: Vizontele](https://www.wikidata.org/wiki/Q624599) | Vizontele | Ö | Zor | Yüksek | Saptanmadı | G1 |
| charades-033 | Film | [K: Vizontele Tuuba](https://www.wikidata.org/wiki/Q2529218) | Vizontele Tuuba | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-034 | Film | [K: G.O.R.A.](https://www.wikidata.org/wiki/Q934718) | G.O.R.A. | Ö | Zor | Yüksek | Saptanmadı | G1 |
| charades-035 | Film | [K: A.R.O.G](https://www.wikidata.org/wiki/Q278190) | A.R.O.G. | Ö | Zor | Yüksek | Saptanmadı | G1 |
| charades-036 | Film | [K: Yahsi Bati - The Ottoman Cowboys](https://www.wikidata.org/wiki/Q8046967) | Yahşi Batı | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-037 | Film | [K: The Magician](https://www.wikidata.org/wiki/Q639228) | Hokkabaz | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-038 | Film | [K: Magic Carpet Ride](https://www.wikidata.org/wiki/Q639070) | Organize İşler | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-039 | Film | [K: Money Trap](https://www.wikidata.org/wiki/Q56877293) | Organize İşler Sazan Sarmalı | TR | Orta | Orta | Saptanmadı | G1 |
| charades-040 | Film | [K: Düğün Dernek](https://www.wikidata.org/wiki/Q17450797) | Düğün Dernek | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-041 | Film | [K: Düğün Dernek 2: Sünnet](https://www.wikidata.org/wiki/Q21525046) | Düğün Dernek 2: Sünnet | TR | Orta | Orta | Saptanmadı | G1 |
| charades-042 | Film | [K: Among Family](https://www.wikidata.org/wiki/Q38081888) | Aile Arasında | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-043 | Film | [K: Recep İvedik](https://www.wikidata.org/wiki/Q1518391) | Recep İvedik | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-044 | Film | [K: Recep İvedik 2](https://www.wikidata.org/wiki/Q934763) | Recep İvedik 2 | Ö | Orta | Orta | Saptanmadı | G4 |
| charades-045 | Film | [K: Recep İvedik 3](https://www.wikidata.org/wiki/Q1573810) | Recep İvedik 3 | Ö | Orta | Orta | Saptanmadı | G4 |
| charades-046 | Film | [K: Recep İvedik 4](https://www.wikidata.org/wiki/Q17378488) | Recep İvedik 4 | Ö | Orta | Orta | Saptanmadı | G4 |
| charades-047 | Film | [K: Deliha](https://www.wikidata.org/wiki/Q19473364) | Deliha | Ö | Orta | Orta | Saptanmadı | G1 |
| charades-048 | Film | [K: The Butterfly's Dream](https://www.wikidata.org/wiki/Q12208610) | Kelebeğin Rüyası | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-049 | Film | [K: My Grandfather's People](https://www.wikidata.org/wiki/Q6070309) | Dedemin İnsanları | TR | Orta | Orta | Saptanmadı | G1 |
| charades-050 | Film | [K: The White Angel](https://www.wikidata.org/wiki/Q3137286) | Beyaz Melek | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-051 | Film | [K: The Miracle](https://www.wikidata.org/wiki/Q18729081) | Mucize | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-052 | Film | [K: Miracle in Cell No. 7](https://www.wikidata.org/wiki/Q73804850) | 7. Koğuştaki Mucize | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-053 | Film | [K: Ayla: The Daughter of War](https://www.wikidata.org/wiki/Q31193403) | Ayla | Ö | Zor | Yüksek | Saptanmadı | G1 |
| charades-054 | Film | [K: Müslüm](https://www.wikidata.org/wiki/Q57523772) | Müslüm | Ö | Zor | Yüksek | Saptanmadı | G1 |
| charades-055 | Film | [K: Bergen](https://www.wikidata.org/wiki/Q111190224) | Bergen | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-056 | Film | [K: Conquest 1453](https://www.wikidata.org/wiki/Q171731) | Fetih 1453 | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-057 | Film | [K: Breath](https://www.wikidata.org/wiki/Q1162297) | Nefes: Vatan Sağolsun | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-058 | Film | [K: The Mountain](https://www.wikidata.org/wiki/Q7752476) | Dağ | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-059 | Film | [K: The Mountain II](https://www.wikidata.org/wiki/Q25476945) | Dağ II | TR | Orta | Orta | Saptanmadı | G1 |
| charades-060 | Film | [K: Winter Sleep](https://www.wikidata.org/wiki/Q15921329) | Kış Uykusu | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-061 | Film | [K: Once Upon a Time in Anatolia](https://www.wikidata.org/wiki/Q1707497) | Bir Zamanlar Anadolu'da | TR | Zor | Orta | Saptanmadı | G1 |
| charades-062 | Film | [K: The Wild Pear Tree](https://www.wikidata.org/wiki/Q31193168) | Ahlat Ağacı | TR | Zor | Orta | Saptanmadı | G1 |
| charades-063 | Film | [K: Uzak](https://www.wikidata.org/wiki/Q1361018) | Uzak | TR | Orta | Orta | Saptanmadı | G1 |
| charades-064 | Film | [K: Innocence](https://www.wikidata.org/wiki/Q6785706) | Masumiyet | TR | Zor | Orta | Saptanmadı | G1 |
| charades-065 | Film | [K: Yol](https://www.wikidata.org/wiki/Q683020) | Yol | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-066 | Film | [K: Don't Let Them Shoot the Kite](https://www.wikidata.org/wiki/Q2505085) | Uçurtmayı Vurmasınlar | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-067 | Film | [K: Istanbul Beneath My Wings](https://www.wikidata.org/wiki/Q12812998) | İstanbul Kanatlarımın Altında | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-068 | Film | [K: Killing the Shadows](https://www.wikidata.org/wiki/Q6082425) | Hacivat Karagöz Neden Öldürüldü? | TR | Zor | Orta | Saptanmadı | G1 |
| charades-069 | Film | [K: Yol Arkadaşım](https://www.wikidata.org/wiki/Q61077240) | Yol Arkadaşım | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-070 | Film | [K: Husband Factor](https://www.wikidata.org/wiki/Q20473165) | Kocan Kadar Konuş | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-071 | Film | [K: The Shawshank Redemption](https://www.wikidata.org/wiki/Q172241) | Esaretin Bedeli | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-072 | Film | [K: The Godfather](https://www.wikidata.org/wiki/Q47703) | Baba | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-073 | Film | [K: The Godfather Part II](https://www.wikidata.org/wiki/Q184768) | Baba II | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-074 | Film | [K: The Godfather Part III](https://www.wikidata.org/wiki/Q202326) | Baba III | TR | Orta | Orta | Saptanmadı | G1 |
| charades-075 | Film | [K: Forrest Gump](https://www.wikidata.org/wiki/Q134773) | Forrest Gump | Ö | Zor | Yüksek | Saptanmadı | G1 |
| charades-076 | Film | [K: The Green Mile](https://www.wikidata.org/wiki/Q208263) | Yeşil Yol | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-077 | Film | [K: Titanic](https://www.wikidata.org/wiki/Q44578) | Titanik | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-078 | Film | [K: Inception](https://www.wikidata.org/wiki/Q25188) | Başlangıç | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-079 | Film | [K: Interstellar](https://www.wikidata.org/wiki/Q13417189) | Yıldızlararası | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-080 | Film | [K: The Dark Knight](https://www.wikidata.org/wiki/Q163872) | Kara Şövalye | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-081 | Film | [K: Batman Begins](https://www.wikidata.org/wiki/Q166262) | Batman Başlıyor | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-082 | Film | [K: The Dark Knight Rises](https://www.wikidata.org/wiki/Q189330) | Kara Şövalye Yükseliyor | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-083 | Film | [K: Joker](https://www.wikidata.org/wiki/Q42759035) | Joker | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-084 | Film | [K: Fight Club](https://www.wikidata.org/wiki/Q190050) | Dövüş Kulübü | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-085 | Film | [K: Pulp Fiction](https://www.wikidata.org/wiki/Q104123) | Ucuz Roman | TR | Zor | Yüksek | Saptanmadı | G1 |
| charades-086 | Film | [K: Seven](https://www.wikidata.org/wiki/Q190908) | Yedi | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-087 | Film | [K: Shutter Island](https://www.wikidata.org/wiki/Q210364) | Zindan Adası | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-088 | Film | [K: A Beautiful Mind](https://www.wikidata.org/wiki/Q164103) | Akıl Oyunları | TR | Orta | Orta | Saptanmadı | G1 |
| charades-089 | Film | [K: Good Will Hunting](https://www.wikidata.org/wiki/Q193835) | Can Dostum | İncele | Orta | Orta | Saptanmadı | G3 |
| charades-090 | Film | [K: Rain Man](https://www.wikidata.org/wiki/Q188845) | Yağmur Adam | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-091 | Film | [K: Gladiator](https://www.wikidata.org/wiki/Q128518) | Gladyatör | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-092 | Film | [K: Braveheart](https://www.wikidata.org/wiki/Q162729) | Cesur Yürek | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-093 | Film | [K: Troy](https://www.wikidata.org/wiki/Q186587) | Truva | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-094 | Film | [K: 300](https://www.wikidata.org/wiki/Q131390) | 300 Spartalı | TR | Orta | Orta | Saptanmadı | G1 |
| charades-095 | Film | [K: The Last Samurai](https://www.wikidata.org/wiki/Q207130) | Son Samuray | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-096 | Film | [K: Saving Private Ryan](https://www.wikidata.org/wiki/Q165817) | Er Ryan'ı Kurtarmak | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-097 | Film | [K: The Pianist](https://www.wikidata.org/wiki/Q150804) | Piyanist | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-098 | Film | [K: Schindler's List](https://www.wikidata.org/wiki/Q483941) | Schindler'in Listesi | TR | Zor | Orta | Saptanmadı | G1 |
| charades-099 | Film | [K: Life Is Beautiful](https://www.wikidata.org/wiki/Q19355) | Hayat Güzeldir | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-100 | Film | [K: My Dear Brother](https://www.wikidata.org/wiki/Q6081026) | Canım Kardeşim | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-101 | Film | [K: Green Book](https://www.wikidata.org/wiki/Q48673898) | Yeşil Rehber | TR | Orta | Orta | Saptanmadı | G1 |
| charades-102 | Film | [K: Parasite](https://www.wikidata.org/wiki/Q61448040) | Parazit | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-103 | Film | [K: The Intouchables](https://www.wikidata.org/wiki/Q595) | Can Dostum (2011) | İncele | Orta | Orta | Saptanmadı | G3 |
| charades-104 | Film | [K: Amélie](https://www.wikidata.org/wiki/Q484048) | Amélie | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-105 | Film | [K: Léon: The Professional](https://www.wikidata.org/wiki/Q484675) | Leon: Sevginin Gücü | Karma | Zor | Yüksek | Saptanmadı | G1 |
| charades-106 | Film | [K: The Truman Show](https://www.wikidata.org/wiki/Q214801) | Truman Show | Ö | Zor | Yüksek | Saptanmadı | G1 |
| charades-107 | Film | [K: Dead Poets Society](https://www.wikidata.org/wiki/Q106316) | Ölü Ozanlar Derneği | TR | Orta | Orta | Saptanmadı | G1 |
| charades-108 | Film | [K: One Flew Over the Cuckoo's Nest](https://www.wikidata.org/wiki/Q171669) | Guguk Kuşu | TR | Orta | Orta | Saptanmadı | G1 |
| charades-109 | Film | [K: A Clockwork Orange](https://www.wikidata.org/wiki/Q181086) | Otomatik Portakal | TR | Orta | Orta | Saptanmadı | G1 |
| charades-110 | Film | [K: Back to the Future](https://www.wikidata.org/wiki/Q91540) | Geleceğe Dönüş | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-111 | Film | [K: Back to the Future Part II](https://www.wikidata.org/wiki/Q109331) | Geleceğe Dönüş II | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-112 | Film | [K: Back to the Future Part III](https://www.wikidata.org/wiki/Q230552) | Geleceğe Dönüş III | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-113 | Film | [K: Jurassic Park](https://www.wikidata.org/wiki/Q167726) | Jurassic Park | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-114 | Film | [K: Jurassic World](https://www.wikidata.org/wiki/Q3512046) | Jurassic World | Ö | Orta | Orta | Saptanmadı | G1 |
| charades-115 | Film | [K: King Kong](https://www.wikidata.org/wiki/Q160215) | King Kong | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-116 | Film | [K: Godzilla](https://www.wikidata.org/wiki/Q7731172) | Godzilla | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-117 | Film | [K: Jaws](https://www.wikidata.org/wiki/Q189505) | Jaws | İncele | Kolay | Yüksek | Saptanmadı | G3 |
| charades-118 | Film | [K: E.T. the Extra-Terrestrial](https://www.wikidata.org/wiki/Q11621) | E.T. | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-119 | Film | [K: Avatar](https://www.wikidata.org/wiki/Q24871) | Avatar | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-120 | Film | [K: Avatar: The Way of Water](https://www.wikidata.org/wiki/Q3604746) | Avatar: Suyun Yolu | Karma | Kolay | Yüksek | Saptanmadı | G1 |
| charades-121 | Film | [K: The Matrix](https://www.wikidata.org/wiki/Q83495) | Matrix | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-122 | Film | [K: The Matrix Reloaded](https://www.wikidata.org/wiki/Q189600) | Matrix Reloaded | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-123 | Film | [K: The Matrix Revolutions](https://www.wikidata.org/wiki/Q207536) | Matrix Revolutions | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-124 | Film | [K: The Terminator](https://www.wikidata.org/wiki/Q162255) | Terminatör | Karma | Kolay | Yüksek | Saptanmadı | G1 |
| charades-125 | Film | [K: Terminator 2: Judgment Day](https://www.wikidata.org/wiki/Q170564) | Terminatör 2: Mahşer Günü | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-126 | Film | [K: Alien](https://www.wikidata.org/wiki/Q103569) | Yaratık | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-127 | Film | [K: Aliens](https://www.wikidata.org/wiki/Q104814) | Yaratık 2 | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-128 | Film | [K: Predator](https://www.wikidata.org/wiki/Q200804) | Av | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-129 | Film | [K: Blade Runner](https://www.wikidata.org/wiki/Q184843) | Bıçak Sırtı | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-130 | Film | [K: Blade Runner 2049](https://www.wikidata.org/wiki/Q21500755) | Bıçak Sırtı 2049 | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-131 | Film | [K: Dune](https://www.wikidata.org/wiki/Q60834962) | Dune: Çöl Gezegeni | Karma | Orta | Yüksek | Saptanmadı | G1 |
| charades-132 | Film | [K: Dune: Part Two](https://www.wikidata.org/wiki/Q109228991) | Dune: Çöl Gezegeni Bölüm İki | Karma | Orta | Yüksek | Saptanmadı | G1 |
| charades-133 | Film | [K: Star Wars: Episode IV – A New Hope](https://www.wikidata.org/wiki/Q17738) | Yıldız Savaşları: Yeni Bir Umut | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-134 | Film | [K: Star Wars: Episode V – The Empire Strikes Back](https://www.wikidata.org/wiki/Q181795) | Yıldız Savaşları: İmparator | İncele | Zor | Orta | Saptanmadı | G3 |
| charades-135 | Film | [K: Star Wars: Episode VI – Return of the Jedi](https://www.wikidata.org/wiki/Q181803) | Yıldız Savaşları: Jedi'ın Dönüşü | TR | Orta | Orta | Saptanmadı | G1 |
| charades-136 | Film | [K: Star Wars: Episode I – The Phantom Menace](https://www.wikidata.org/wiki/Q165713) | Yıldız Savaşları: Gizli Tehlike | TR | Orta | Orta | Saptanmadı | G1 |
| charades-137 | Film | [K: Star Wars: Episode II – Attack of the Clones](https://www.wikidata.org/wiki/Q181069) | Yıldız Savaşları: Klonların Saldırısı | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-138 | Film | [K: Star Wars: Episode III – Revenge of the Sith](https://www.wikidata.org/wiki/Q42051) | Yıldız Savaşları: Sith'in İntikamı | TR | Orta | Orta | Saptanmadı | G1 |
| charades-139 | Film | [K: The Lord of the Rings: The Fellowship of the Ring](https://www.wikidata.org/wiki/Q127367) | Yüzüklerin Efendisi: Yüzük Kardeşliği | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-140 | Film | [K: The Lord of the Rings: The Two Towers](https://www.wikidata.org/wiki/Q164963) | Yüzüklerin Efendisi: İki Kule | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-141 | Film | [K: The Lord of the Rings: The Return of the King](https://www.wikidata.org/wiki/Q131074) | Yüzüklerin Efendisi: Kralın Dönüşü | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-142 | Film | [K: The Hobbit: An Unexpected Journey](https://www.wikidata.org/wiki/Q80379) | Hobbit: Beklenmedik Yolculuk | TR | Orta | Orta | Saptanmadı | G1 |
| charades-143 | Film | [K: The Hobbit: The Desolation of Smaug](https://www.wikidata.org/wiki/Q719915) | Hobbit: Smaug'un Çorak Toprakları | TR | Zor | Orta | Saptanmadı | G1 |
| charades-144 | Film | [K: The Hobbit: The Battle of the Five Armies](https://www.wikidata.org/wiki/Q919649) | Hobbit: Beş Ordunun Savaşı | TR | Orta | Orta | Saptanmadı | G1 |
| charades-145 | Film | [K: Harry Potter and the Philosopher's Stone](https://www.wikidata.org/wiki/Q102438) | Harry Potter ve Felsefe Taşı | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-146 | Film | [K: Harry Potter and the Chamber of Secrets](https://www.wikidata.org/wiki/Q102244) | Harry Potter ve Sırlar Odası | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-147 | Film | [K: Harry Potter and the Prisoner of Azkaban](https://www.wikidata.org/wiki/Q102448) | Harry Potter ve Azkaban Tutsağı | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-148 | Film | [K: Harry Potter and the Goblet of Fire](https://www.wikidata.org/wiki/Q102225) | Harry Potter ve Ateş Kadehi | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-149 | Film | [K: Harry Potter and the Order of the Phoenix](https://www.wikidata.org/wiki/Q102235) | Harry Potter ve Zümrüdüanka Yoldaşlığı | TR | Zor | Orta | Saptanmadı | G1 |
| charades-150 | Film | [K: Harry Potter and the Half-Blood Prince](https://www.wikidata.org/wiki/Q161687) | Harry Potter ve Melez Prens | TR | Orta | Orta | Saptanmadı | G1 |
| charades-151 | Film | [K: Harry Potter and the Deathly Hallows – Part 1](https://www.wikidata.org/wiki/Q161678) | Harry Potter ve Ölüm Yadigârları: Bölüm 1 | TR | Zor | Orta | Saptanmadı | G1 |
| charades-152 | Film | [K: Harry Potter and the Deathly Hallows – Part 2](https://www.wikidata.org/wiki/Q232009) | Harry Potter ve Ölüm Yadigârları: Bölüm 2 | TR | Zor | Orta | Saptanmadı | G1 |
| charades-153 | Film | [K: Fantastic Beasts and Where to Find Them](https://www.wikidata.org/wiki/Q18199330) | Fantastik Canavarlar Nelerdir, Nerede Bulunurlar? | TR | Zor | Orta | Saptanmadı | G1 |
| charades-154 | Film | [K: Pirates of the Caribbean: The Curse of the Black Pearl](https://www.wikidata.org/wiki/Q46717) | Karayip Korsanları: Siyah İnci'nin Laneti | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-155 | Film | [K: Pirates of the Caribbean: Dead Man's Chest](https://www.wikidata.org/wiki/Q161087) | Karayip Korsanları: Ölü Adamın Sandığı | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-156 | Film | [K: Pirates of the Caribbean: At World's End](https://www.wikidata.org/wiki/Q54274) | Karayip Korsanları: Dünyanın Sonu | TR | Orta | Orta | Saptanmadı | G1 |
| charades-157 | Film | [K: Pirates of the Caribbean: On Stranger Tides](https://www.wikidata.org/wiki/Q183555) | Karayip Korsanları: Gizemli Denizlerde | TR | Orta | Orta | Saptanmadı | G1 |
| charades-158 | Film | [K: Raiders of the Lost Ark](https://www.wikidata.org/wiki/Q174284) | Indiana Jones: Kutsal Hazine Avcıları | Karma | Kolay | Orta | Saptanmadı | G1 |
| charades-159 | Film | [K: Indiana Jones and the Temple of Doom](https://www.wikidata.org/wiki/Q179215) | Indiana Jones: Kamçılı Adam | Karma | Zor | Orta | Saptanmadı | G1 |
| charades-160 | Film | [K: Indiana Jones and the Last Crusade](https://www.wikidata.org/wiki/Q185658) | Indiana Jones: Son Macera | Karma | Orta | Orta | Saptanmadı | G1 |
| charades-161 | Film | [K: The Mummy](https://www.wikidata.org/wiki/Q202508) | Mumya | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-162 | Film | [K: The Mummy Returns](https://www.wikidata.org/wiki/Q320461) | Mumya Geri Dönüyor | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-163 | Film | [K: Jumanji](https://www.wikidata.org/wiki/Q222939) | Jumanji | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-164 | Film | [K: Jumanji: Welcome to the Jungle](https://www.wikidata.org/wiki/Q20762680) | Jumanji: Vahşi Orman | Karma | Kolay | Yüksek | Saptanmadı | G1 |
| charades-165 | Film | [K: Home Alone](https://www.wikidata.org/wiki/Q105031) | Evde Tek Başına | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-166 | Film | [K: Home Alone 2: Lost in New York](https://www.wikidata.org/wiki/Q221202) | Evde Tek Başına 2 | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-167 | Film | [K: The Mask](https://www.wikidata.org/wiki/Q219421) | Maske | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-168 | Film | [K: Bruce Almighty](https://www.wikidata.org/wiki/Q207816) | Aman Tanrım! | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-169 | Film | [K: Yes Man](https://www.wikidata.org/wiki/Q269887) | Bay Evet | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-170 | Film | [K: Dumb and Dumber](https://www.wikidata.org/wiki/Q462418) | Salak ile Avanak | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-171 | Film | [K: Ace Ventura: Pet Detective](https://www.wikidata.org/wiki/Q340138) | Budala Dedektif | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-172 | Film | [K: Liar Liar](https://www.wikidata.org/wiki/Q48980) | Yalancı Yalancı | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-173 | Film | [K: Jingle All the Way](https://www.wikidata.org/wiki/Q1064530) | Babam Bir Kahraman | İncele | Kolay | Orta | Saptanmadı | G3 |
| charades-174 | Film | [K: Night at the Museum](https://www.wikidata.org/wiki/Q387601) | Müzede Bir Gece | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-175 | Film | [K: Night at the Museum: Battle of the Smithsonian](https://www.wikidata.org/wiki/Q476726) | Müzede Bir Gece 2 | TR | Orta | Orta | Saptanmadı | G1 |
| charades-176 | Film | [K: Mr. & Mrs. Smith](https://www.wikidata.org/wiki/Q191040) | Bay ve Bayan Smith | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-177 | Film | [K: Meet the Parents](https://www.wikidata.org/wiki/Q623724) | Zor Baba | TR | Orta | Orta | Saptanmadı | G1 |
| charades-178 | Film | [K: The Devil Wears Prada](https://www.wikidata.org/wiki/Q223316) | Şeytan Marka Giyer | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-179 | Film | [K: Freaky Friday](https://www.wikidata.org/wiki/Q118713) | Çılgın Cuma | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-180 | Film | [K: The Princess Diaries](https://www.wikidata.org/wiki/Q1046295) | Prenses Günlükleri | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-181 | Film | [K: Notting Hill](https://www.wikidata.org/wiki/Q200672) | Aşk Engel Tanımaz | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-182 | Film | [K: Love Actually](https://www.wikidata.org/wiki/Q190588) | Aşk Her Yerde | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-183 | Film | [K: Eternal Sunshine of the Spotless Mind](https://www.wikidata.org/wiki/Q208269) | Sil Baştan | TR | Orta | Orta | Saptanmadı | G1 |
| charades-184 | Film | [K: The Notebook](https://www.wikidata.org/wiki/Q223374) | Not Defteri | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-185 | Film | [K: The Fault in Our Stars](https://www.wikidata.org/wiki/Q14704171) | Aynı Yıldızın Altında | TR | Orta | Orta | Saptanmadı | G1 |
| charades-186 | Film | [K: Twilight](https://www.wikidata.org/wiki/Q160071) | Alacakaranlık | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-187 | Film | [K: The Hunger Games](https://www.wikidata.org/wiki/Q212965) | Açlık Oyunları | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-188 | Film | [K: The Hunger Games: Catching Fire](https://www.wikidata.org/wiki/Q574583) | Açlık Oyunları: Ateşi Yakalamak | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-189 | Film | [K: The Maze Runner](https://www.wikidata.org/wiki/Q13099455) | Labirent: Ölümcül Kaçış | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-190 | Film | [K: Divergent](https://www.wikidata.org/wiki/Q8561227) | Uyumsuz | TR | Orta | Orta | Saptanmadı | G1 |
| charades-191 | Film | [K: Spider-Man](https://www.wikidata.org/wiki/Q484442) | Örümcek Adam | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-192 | Film | [K: Spider-Man 2](https://www.wikidata.org/wiki/Q190145) | Örümcek Adam 2 | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-193 | Film | [K: Spider-Man 3](https://www.wikidata.org/wiki/Q182212) | Örümcek Adam 3 | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-194 | Film | [K: The Amazing Spider-Man](https://www.wikidata.org/wiki/Q229808) | İnanılmaz Örümcek Adam | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-195 | Film | [K: Spider-Man: Homecoming](https://www.wikidata.org/wiki/Q23010088) | Örümcek Adam: Eve Dönüş | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-196 | Film | [K: Spider-Man: Far From Home](https://www.wikidata.org/wiki/Q27985819) | Örümcek Adam: Evden Uzakta | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-197 | Film | [K: Spider-Man: No Way Home](https://www.wikidata.org/wiki/Q68934496) | Örümcek Adam: Eve Dönüş Yok | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-198 | Film | [K: Iron Man](https://www.wikidata.org/wiki/Q192724) | Demir Adam | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-199 | Film | [K: Iron Man 2](https://www.wikidata.org/wiki/Q205028) | Demir Adam 2 | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-200 | Film | [K: Iron Man 3](https://www.wikidata.org/wiki/Q209538) | Demir Adam 3 | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-201 | Film | [K: Thor](https://www.wikidata.org/wiki/Q217020) | Thor | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-202 | Film | [K: Thor: The Dark World](https://www.wikidata.org/wiki/Q1201853) | Thor: Karanlık Dünya | Karma | Kolay | Orta | Saptanmadı | G1 |
| charades-203 | Film | [K: Thor: Ragnarok](https://www.wikidata.org/wiki/Q22665878) | Thor: Ragnarok | Karma | Zor | Orta | Saptanmadı | G1 |
| charades-204 | Film | [K: Captain America: The First Avenger](https://www.wikidata.org/wiki/Q275120) | Kaptan Amerika: İlk Yenilmez | TR | Orta | Orta | Saptanmadı | G1 |
| charades-205 | Film | [K: Captain America: The Winter Soldier](https://www.wikidata.org/wiki/Q1765358) | Kaptan Amerika: Kış Askeri | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-206 | Film | [K: Captain America: Civil War](https://www.wikidata.org/wiki/Q18407657) | Kaptan Amerika: Kahramanların Savaşı | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-207 | Film | [K: The Avengers](https://www.wikidata.org/wiki/Q182218) | Yenilmezler | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-208 | Film | [K: Avengers: Age of Ultron](https://www.wikidata.org/wiki/Q14171368) | Yenilmezler: Ultron Çağı | TR | Zor | Orta | Saptanmadı | G1 |
| charades-209 | Film | [K: Avengers: Infinity War](https://www.wikidata.org/wiki/Q23780914) | Yenilmezler: Sonsuzluk Savaşı | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-210 | Film | [K: Avengers: Endgame](https://www.wikidata.org/wiki/Q23781155) | Yenilmezler: Son Oyun | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-211 | Film | [K: Black Panther](https://www.wikidata.org/wiki/Q23780734) | Kara Panter | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-212 | Film | [K: Doctor Strange](https://www.wikidata.org/wiki/Q18406872) | Doktor Strange | Karma | Zor | Orta | Saptanmadı | G1 |
| charades-213 | Film | [K: Ant-Man](https://www.wikidata.org/wiki/Q5901134) | Karınca Adam | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-214 | Film | [K: Guardians of the Galaxy](https://www.wikidata.org/wiki/Q5887360) | Galaksinin Koruyucuları | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-215 | Film | [K: Deadpool](https://www.wikidata.org/wiki/Q19347291) | Deadpool | Ö | Zor | Yüksek | Saptanmadı | G1 |
| charades-216 | Film | [K: Deadpool 2](https://www.wikidata.org/wiki/Q25431158) | Deadpool 2 | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-217 | Film | [K: The Wolverine](https://www.wikidata.org/wiki/Q197491) | Wolverine | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-218 | Film | [K: Logan](https://www.wikidata.org/wiki/Q24053263) | Logan | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-219 | Film | [K: Superman Returns](https://www.wikidata.org/wiki/Q328695) | Süpermen Dönüyor | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-220 | Film | [K: Man of Steel](https://www.wikidata.org/wiki/Q622769) | Çelik Adam | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-221 | Film | [K: Batman v Superman: Dawn of Justice](https://www.wikidata.org/wiki/Q14772351) | Batman ve Superman: Adaletin Şafağı | İncele | Orta | Orta | Saptanmadı | G3 |
| charades-222 | Film | [K: Wonder Woman](https://www.wikidata.org/wiki/Q20502242) | Wonder Woman | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-223 | Film | [K: Aquaman](https://www.wikidata.org/wiki/Q22998395) | Aquaman | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-224 | Film | [K: Shazam! (film)](https://www.wikidata.org/wiki/Q23685878) | Shazam! | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-225 | Film | [K: The Fast and the Furious](https://www.wikidata.org/wiki/Q155476) | Hızlı ve Öfkeli | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-226 | Film | [K: 2 Fast 2 Furious](https://www.wikidata.org/wiki/Q222867) | Daha Hızlı Daha Öfkeli | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-227 | Film | [K: The Fast and the Furious: Tokyo Drift](https://www.wikidata.org/wiki/Q213208) | Hızlı ve Öfkeli: Tokyo Yarışı | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-228 | Film | [K: Fast Five](https://www.wikidata.org/wiki/Q401976) | Hızlı ve Öfkeli 5 | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-229 | Film | [K: Mission: Impossible](https://www.wikidata.org/wiki/Q1741232) | Görevimiz Tehlike | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-230 | Film | [K: Mission: Impossible 2](https://www.wikidata.org/wiki/Q505790) | Görevimiz Tehlike 2 | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-231 | Film | [K: Mission: Impossible III](https://www.wikidata.org/wiki/Q288173) | Görevimiz Tehlike 3 | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-232 | Film | [K: John Wick](https://www.wikidata.org/wiki/Q15732802) | John Wick | Ö | Zor | Yüksek | Saptanmadı | G1 |
| charades-233 | Film | [K: John Wick: Chapter 2](https://www.wikidata.org/wiki/Q21451640) | John Wick 2 | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-234 | Film | [K: John Wick: Chapter 3 – Parabellum](https://www.wikidata.org/wiki/Q52951815) | John Wick 3: Parabellum | Karma | Zor | Orta | Saptanmadı | G4 |
| charades-235 | Film | [K: The Transporter](https://www.wikidata.org/wiki/Q819972) | Taşıyıcı | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-236 | Film | [K: Shooter](https://www.wikidata.org/wiki/Q309014) | Tetikçi | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-237 | Film | [K: Catch Me If You Can](https://www.wikidata.org/wiki/Q208108) | Sıkıysa Yakala | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-238 | Film | [K: Die Hard](https://www.wikidata.org/wiki/Q105598) | Zor Ölüm | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-239 | Film | [K: Top Gun](https://www.wikidata.org/wiki/Q110138) | Top Gun | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-240 | Film | [K: Top Gun: Maverick](https://www.wikidata.org/wiki/Q31202708) | Top Gun: Maverick | Karma | Zor | Orta | Saptanmadı | G1 |
| charades-241 | Film | [K: Erin Brockovich](https://www.wikidata.org/wiki/Q220955) | Erin Brockovich | Ö | Zor | Düşük | Saptanmadı | G4 |
| charades-242 | Film | [K: The Martian](https://www.wikidata.org/wiki/Q18547944) | Marslı | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-243 | Film | [K: Gravity](https://www.wikidata.org/wiki/Q2579784) | Yerçekimi | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-244 | Film | [K: Cast Away](https://www.wikidata.org/wiki/Q213411) | Yeni Hayat | TR | Kolay | Orta | Saptanmadı | G2 |
| charades-245 | Film | [K: Life of Pi](https://www.wikidata.org/wiki/Q152780) | Pi'nin Yaşamı | Karma | Kolay | Orta | Saptanmadı | G1 |
| charades-246 | Film | [K: 127 Hours](https://www.wikidata.org/wiki/Q174371) | 127 Saat | TR | Orta | Orta | Saptanmadı | G1 |
| charades-247 | Film | [K: Gone Girl](https://www.wikidata.org/wiki/Q14920425) | Kayıp Kız | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-248 | Film | [K: The Silence of the Lambs](https://www.wikidata.org/wiki/Q133654) | Kuzuların Sessizliği | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-249 | Film | [K: The Sixth Sense](https://www.wikidata.org/wiki/Q183063) | Altıncı His | TR | Orta | Orta | Saptanmadı | G1 |
| charades-250 | Film | [K: The Others](https://www.wikidata.org/wiki/Q332515) | Diğerleri | TR | Orta | Orta | Saptanmadı | G1 |
| charades-251 | Film | [K: The Shining](https://www.wikidata.org/wiki/Q186341) | Cinnet | TR | Orta | Orta | Saptanmadı | G1 |
| charades-252 | Film | [K: The Exorcist](https://www.wikidata.org/wiki/Q274167) | Şeytan | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-253 | Film | [K: The Ring](https://www.wikidata.org/wiki/Q212804) | Halka | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-254 | Film | [K: Saw](https://www.wikidata.org/wiki/Q486239) | Testere | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-255 | Film | [K: The Conjuring](https://www.wikidata.org/wiki/Q5540479) | Korku Seansı | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-256 | Film | [K: Annabelle](https://www.wikidata.org/wiki/Q15733440) | Annabelle | TR | Orta | Orta | Saptanmadı | G1 |
| charades-257 | Film | [K: It](https://www.wikidata.org/wiki/Q25136484) | O | TR | Orta | Orta | Saptanmadı | G1 |
| charades-258 | Film | [K: Insidious](https://www.wikidata.org/wiki/Q122713) | Ruhlar Bölgesi | TR | Orta | Orta | Saptanmadı | G1 |
| charades-259 | Film | [K: Scream](https://www.wikidata.org/wiki/Q27411) | Çığlık | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-260 | Film | [K: A Quiet Place](https://www.wikidata.org/wiki/Q39070473) | Sessiz Bir Yer | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-261 | Film | [K: Bird Box](https://www.wikidata.org/wiki/Q43370937) | Kuş Kafesi | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-262 | Film | [K: Us](https://www.wikidata.org/wiki/Q56000996) | Biz | TR | Orta | Orta | Saptanmadı | G1 |
| charades-263 | Film | [K: Get Out](https://www.wikidata.org/wiki/Q25136235) | Kapan | TR | Orta | Orta | Saptanmadı | G1 |
| charades-264 | Film | [K: The Lion King](https://www.wikidata.org/wiki/Q36479) | Aslan Kral | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-265 | Film | [K: Toy Story](https://www.wikidata.org/wiki/Q171048) | Oyuncak Hikâyesi | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-266 | Film | [K: Toy Story 2](https://www.wikidata.org/wiki/Q187266) | Oyuncak Hikâyesi 2 | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-267 | Film | [K: Toy Story 3](https://www.wikidata.org/wiki/Q187278) | Oyuncak Hikâyesi 3 | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-268 | Film | [K: Toy Story 4](https://www.wikidata.org/wiki/Q18517638) | Oyuncak Hikâyesi 4 | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-269 | Film | [K: Finding Nemo](https://www.wikidata.org/wiki/Q132863) | Kayıp Balık Nemo | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-270 | Film | [K: Finding Dory](https://www.wikidata.org/wiki/Q9321426) | Kayıp Balık Dori | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-271 | Film | [K: Monsters, Inc.](https://www.wikidata.org/wiki/Q187726) | Sevimli Canavarlar | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-272 | Film | [K: Monsters University](https://www.wikidata.org/wiki/Q641362) | Sevimli Canavarlar Üniversitesi | TR | Orta | Orta | Saptanmadı | G1 |
| charades-273 | Film | [K: The Incredibles](https://www.wikidata.org/wiki/Q213326) | İnanılmaz Aile | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-274 | Film | [K: Incredibles 2](https://www.wikidata.org/wiki/Q24832112) | İnanılmaz Aile 2 | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-275 | Film | [K: Cars](https://www.wikidata.org/wiki/Q182153) | Arabalar | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-276 | Film | [K: Cars 2](https://www.wikidata.org/wiki/Q192212) | Arabalar 2 | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-277 | Film | [K: Cars 3](https://www.wikidata.org/wiki/Q21079862) | Arabalar 3 | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-278 | Film | [K: Ratatouille](https://www.wikidata.org/wiki/Q170035) | Ratatuy | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-279 | Film | [K: Up](https://www.wikidata.org/wiki/Q174811) | Yukarı Bak | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-280 | Film | [K: WALL-E](https://www.wikidata.org/wiki/Q104905) | WALL-E | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-281 | Film | [K: Inside Out](https://www.wikidata.org/wiki/Q6144664) | Ters Yüz | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-282 | Film | [K: Inside Out 2](https://www.wikidata.org/wiki/Q113877606) | Ters Yüz 2 | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-283 | Film | [K: Coco](https://www.wikidata.org/wiki/Q5815826) | Coco | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-284 | Film | [K: Soul](https://www.wikidata.org/wiki/Q64744044) | Ruh | TR | Orta | Orta | Saptanmadı | G1 |
| charades-285 | Film | [K: Luca](https://www.wikidata.org/wiki/Q97925311) | Luka | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-286 | Film | [K: Turning Red](https://www.wikidata.org/wiki/Q104845027) | Kırmızı | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-287 | Film | [K: Elemental](https://www.wikidata.org/wiki/Q112801489) | Elemental: Doğanın Güçleri | Karma | Orta | Orta | Saptanmadı | G1 |
| charades-288 | Film | [K: Frozen](https://www.wikidata.org/wiki/Q246283) | Karlar Ülkesi | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-289 | Film | [K: Frozen 2](https://www.wikidata.org/wiki/Q24733929) | Karlar Ülkesi II | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-290 | Film | [K: Moana](https://www.wikidata.org/wiki/Q18647981) | Moana | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-291 | Film | [K: Shrek](https://www.wikidata.org/wiki/Q483815) | Şrek | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-292 | Film | [K: Shrek 2](https://www.wikidata.org/wiki/Q485983) | Şrek 2 | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-293 | Film | [K: Shrek the Third](https://www.wikidata.org/wiki/Q486588) | Şrek 3 | İncele | Zor | Orta | Saptanmadı | G3 |
| charades-294 | Film | [K: Shrek Forever After](https://www.wikidata.org/wiki/Q208131) | Şrek: Sonsuza Dek Mutlu | Karma | Zor | Orta | Saptanmadı | G1 |
| charades-295 | Film | [K: Kung Fu Panda](https://www.wikidata.org/wiki/Q129193) | Kung Fu Panda | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-296 | Film | [K: Kung Fu Panda 2](https://www.wikidata.org/wiki/Q487447) | Kung Fu Panda 2 | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-297 | Film | [K: Kung Fu Panda 3](https://www.wikidata.org/wiki/Q15055043) | Kung Fu Panda 3 | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-298 | Film | [K: Ice Age](https://www.wikidata.org/wiki/Q305250) | Buz Devri | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-299 | Film | [K: Ice Age: The Meltdown](https://www.wikidata.org/wiki/Q190910) | Buz Devri 2: Erime Başlıyor | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-300 | Film | [K: Madagascar](https://www.wikidata.org/wiki/Q174555) | Madagaskar | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-301 | Dizi | [K: Avrupa Yakası](https://www.tvmaze.com/shows/35824/avrupa-yakasi) | Avrupa Yakası | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-302 | Dizi | [K: Yalan Dünya](https://www.tvmaze.com/shows/19126/yalan-dunya) | Yalan Dünya | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-303 | Dizi | [K: Leyla ile Mecnun](https://www.tvmaze.com/shows/17963/leyla-ile-mecnun) | Leyla ile Mecnun | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-304 | Dizi | [K: İşler Güçler](https://www.tvmaze.com/shows/18022/isler-gucler) | İşler Güçler | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-305 | Dizi | [K: Kardeş Payı](https://www.tvmaze.com/shows/18020/kardes-payi) | Kardeş Payı | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-306 | Dizi | [K: Gibi](https://www.tvmaze.com/shows/52761/gibi) | Gibi | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-307 | Dizi | [K: Prens](https://www.tvmaze.com/shows/69540/prens) | Prens | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-308 | Dizi | [K: Ayak İşleri](https://www.tvmaze.com/shows/55623/ayak-isleri) | Ayak İşleri | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-309 | Dizi | [K: İkinci Bahar](https://www.tvmaze.com/shows/63947/ikinci-bahar) | İkinci Bahar | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-310 | Dizi | [K: Süper Baba](https://www.tvmaze.com/shows/94132/super-baba) | Süper Baba | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-311 | Dizi | [K: Bizimkiler](https://www.tvmaze.com/shows/94050/bizimkiler) | Bizimkiler | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-312 | Dizi | [K: Çocuklar Duymasın](https://www.tvmaze.com/shows/36989/cocuklar-duymasin) | Çocuklar Duymasın | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-313 | Dizi | [K: En Son Babalar Duyar](https://www.wikidata.org/wiki/Q6099338) | En Son Babalar Duyar | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-314 | Dizi | [K: Tatlı Hayat](https://www.tvmaze.com/shows/35827/tatli-hayat) | Tatlı Hayat | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-315 | Dizi | [K: Dadi](https://www.tvmaze.com/shows/94100/dadi) | Dadı | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-316 | Dizi | [K: Ekmek Teknesi](https://www.tvmaze.com/shows/94032/ekmek-teknesi) | Ekmek Teknesi | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-317 | Dizi | [K: Yedi Numara](https://www.tvmaze.com/shows/78422/yedi-numara) | Yedi Numara | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-318 | Dizi | [K: Akasya Durağı](https://www.tvmaze.com/shows/35834/akasya-duragi) | Akasya Durağı | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-319 | Dizi | [K: Geniş Aile](https://www.tvmaze.com/shows/46792/genis-aile) | Geniş Aile | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-320 | Dizi | [K: Seksenler](https://www.tvmaze.com/shows/18028/seksenler) | Seksenler | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-321 | Dizi | [K: Doksanlar](https://www.wikidata.org/wiki/Q19611012) | Doksanlar | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-322 | Dizi | [K: Sihirli Annem](https://www.tvmaze.com/shows/84986/sihirli-annem) | Sihirli Annem | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-323 | Dizi | [K: Bez Bebek](https://www.tvmaze.com/shows/65410/bez-bebek) | Bez Bebek | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-324 | Dizi | [K: Acemi Cadı](https://www.tvmaze.com/shows/35821/acemi-cadi) | Acemi Cadı | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-325 | Dizi | [K: Selena](https://www.tvmaze.com/shows/65406/selena) | Selena | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-326 | Dizi | [K: Hayat Bilgisi](https://www.tvmaze.com/shows/85194/hayat-bilgisi) | Hayat Bilgisi | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-327 | Dizi | [K: Arka Sıradakiler](https://www.tvmaze.com/shows/35832/arka-siradakiler) | Arka Sıradakiler | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-328 | Dizi | [K: Pis Yedili](https://www.tvmaze.com/shows/56522/pis-yedili) | Pis Yedili | TR | Zor | Orta | Saptanmadı | G1 |
| charades-329 | Dizi | [K: Kavak Yelleri](https://www.wikidata.org/wiki/Q1162150) | Kavak Yelleri | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-330 | Dizi | [K: Medcezir](https://www.tvmaze.com/shows/18758/medcezir) | Medcezir | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-331 | Dizi | [K: Güneşi Beklerken](https://www.tvmaze.com/shows/6144/gunesi-beklerken) | Güneşi Beklerken | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-332 | Dizi | [K: Adını Feriha Koydum](https://www.tvmaze.com/shows/18954/adini-feriha-koydum) | Adını Feriha Koydum | TR | Zor | Orta | Saptanmadı | G1 |
| charades-333 | Dizi | [K: Aşk-ı Memnu](https://www.tvmaze.com/shows/18892/ask-i-memnu) | Aşk-ı Memnu | Ö | Zor | Yüksek | Saptanmadı | G1 |
| charades-334 | Dizi | [K: Yaprak Dökümü](https://www.tvmaze.com/shows/14167/yaprak-dokumu) | Yaprak Dökümü | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-335 | Dizi | [K: Fatmagül'ün Suçu Ne?](https://www.tvmaze.com/shows/18880/fatmagulun-sucu-ne) | Fatmagül'ün Suçu Ne? | TR | Zor | Yüksek | Saptanmadı | G1 |
| charades-336 | Dizi | [K: Binbir Gece](https://www.tvmaze.com/shows/18952/binbir-gece) | Binbir Gece | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-337 | Dizi | [K: Gümüş](https://www.tvmaze.com/shows/14173/gumus) | Gümüş | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-338 | Dizi | [K: Asi](https://www.tvmaze.com/shows/18908/asi) | Asi | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-339 | Dizi | [K: Sıla](https://www.tvmaze.com/shows/18951/sila) | Sıla | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-340 | Dizi | [K: Ezel](https://www.tvmaze.com/shows/8448/ezel) | Ezel | Ö | Zor | Yüksek | Saptanmadı | G1 |
| charades-341 | Dizi | [K: Kurtlar Vadisi](https://www.tvmaze.com/shows/18332/kurtlar-vadisi) | Kurtlar Vadisi | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-342 | Dizi | [K: Kurtlar Vadisi Pusu](https://www.tvmaze.com/shows/7749/kurtlar-vadisi-pusu) | Kurtlar Vadisi Pusu | TR | Orta | Orta | Saptanmadı | G1 |
| charades-343 | Dizi | [K: Suskunlar](https://www.tvmaze.com/shows/18817/suskunlar) | Suskunlar | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-344 | Dizi | [K: Içerde](https://www.tvmaze.com/shows/20568/icerde) | İçerde | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-345 | Dizi | [K: Çukur](https://www.tvmaze.com/shows/32417/cukur) | Çukur | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-346 | Dizi | [K: Söz](https://www.tvmaze.com/shows/29702/soz) | Söz | TR | Zor | Orta | Saptanmadı | G1 |
| charades-347 | Dizi | [K: İsimsizler](https://www.tvmaze.com/shows/26882/isimsizler) | İsimsizler | TR | Zor | Orta | Saptanmadı | G1 |
| charades-348 | Dizi | [K: Börü](https://www.tvmaze.com/shows/34973/boru) | Börü | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-349 | Dizi | [K: Teşkilat](https://www.tvmaze.com/shows/53847/teskilat) | Teşkilat | TR | Orta | Orta | Saptanmadı | G1 |
| charades-350 | Dizi | [K: Arka Sokaklar](https://www.tvmaze.com/shows/31773/arka-sokaklar) | Arka Sokaklar | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-351 | Dizi | [K: Behzat Ç. Bir Ankara Polisiyesi](https://www.tvmaze.com/shows/17856/behzat-c-bir-ankara-polisiyesi) | Behzat Ç. | Ö | Zor | Yüksek | Saptanmadı | G1 |
| charades-352 | Dizi | [K: Şahsiyet](https://www.tvmaze.com/shows/35418/sahsiyet) | Şahsiyet | TR | Zor | Yüksek | Saptanmadı | G1 |
| charades-353 | Dizi | [K: Masum](https://www.tvmaze.com/shows/32307/masum) | Masum | TR | Zor | Orta | Saptanmadı | G1 |
| charades-354 | Dizi | [K: Bir Başkadır](https://www.tvmaze.com/shows/51887/bir-baskadir) | Bir Başkadır | TR | Zor | Orta | Saptanmadı | G1 |
| charades-355 | Dizi | [K: Fi](https://www.tvmaze.com/shows/26106/fi) | Fi | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-356 | Dizi | [K: Ufak Tefek Cinayetler](https://www.tvmaze.com/shows/32557/ufak-tefek-cinayetler) | Ufak Tefek Cinayetler | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-357 | Dizi | [K: Sadakatsiz](https://www.tvmaze.com/shows/50631/sadakatsiz) | Sadakatsiz | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-358 | Dizi | [K: Kadın](https://www.tvmaze.com/shows/32660/kadin) | Kadın | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-359 | Dizi | [K: Anne](https://www.tvmaze.com/shows/22276/anne) | Anne | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-360 | Dizi | [K: Kızım](https://www.tvmaze.com/shows/38488/kizim) | Kızım | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-361 | Dizi | [K: Öyle Bir Geçer Zaman Ki](https://www.tvmaze.com/shows/19172/oyle-bir-gecer-zaman-ki) | Öyle Bir Geçer Zaman ki | TR | Zor | Yüksek | Saptanmadı | G1 |
| charades-362 | Dizi | [K: Muhteşem Yüzyıl](https://www.tvmaze.com/shows/5858/muhtesem-yuzyil) | Muhteşem Yüzyıl | TR | Orta | Yüksek | Saptanmadı | G1 |
| charades-363 | Dizi | [K: Muhtesem Yüzyil: Kösem](https://www.tvmaze.com/shows/7093/muhtesem-yuzyil-kosem) | Muhteşem Yüzyıl: Kösem | Karma | Zor | Orta | Saptanmadı | G1 |
| charades-364 | Dizi | [K: Diriliş Ertuğrul](https://www.tvmaze.com/shows/11834/dirilis-ertugrul) | Diriliş: Ertuğrul | Karma | Zor | Yüksek | Saptanmadı | G1 |
| charades-365 | Dizi | [K: Kuruluş: Osman](https://www.tvmaze.com/shows/44935/kurulus-osman) | Kuruluş: Osman | Karma | Zor | Yüksek | Saptanmadı | G1 |
| charades-366 | Dizi | [K: Payitaht Abdülhamid](https://www.tvmaze.com/shows/29922/payitaht-abdulhamid) | Payitaht Abdülhamid | Karma | Zor | Orta | Saptanmadı | G1 |
| charades-367 | Dizi | [K: Vatanım Sensin](https://www.tvmaze.com/shows/22403/vatanim-sensin) | Vatanım Sensin | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-368 | Dizi | [K: Çalıkuşu](https://www.tvmaze.com/shows/18756/calikusu) | Çalıkuşu | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-369 | Dizi | [K: Hatırla Sevgili](https://www.tvmaze.com/shows/19029/hatirla-sevgili) | Hatırla Sevgili | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-370 | Dizi | [K: Çemberimde Gül Oya](https://www.tvmaze.com/shows/94113/cemberimde-gul-oya) | Çemberimde Gül Oya | TR | Zor | Orta | Saptanmadı | G1 |
| charades-371 | Dizi | [K: Goodbye Rumelia](https://www.wikidata.org/wiki/Q6100407) | Elveda Rumeli | TR | Zor | Orta | Saptanmadı | G1 |
| charades-372 | Dizi | [K: Kınalı Kar](https://www.wikidata.org/wiki/Q4119866) | Kınalı Kar | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-373 | Dizi | [K: Yabancı Damat](https://www.tvmaze.com/shows/14176/yabanci-damat) | Yabancı Damat | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-374 | Dizi | [K: Asmalı Konak](https://www.tvmaze.com/shows/35825/asmali-konak) | Asmalı Konak | TR | Zor | Orta | Saptanmadı | G1 |
| charades-375 | Dizi | [K: Deli Yürek](https://www.tvmaze.com/shows/18333/deli-yurek) | Deli Yürek | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-376 | Dizi | [K: Kuzey Güney](https://www.tvmaze.com/shows/17720/kuzey-guney) | Kuzey Güney | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-377 | Dizi | [K: Karadayı](https://www.tvmaze.com/shows/17719/karadayi) | Karadayı | TR | Zor | Orta | Saptanmadı | G1 |
| charades-378 | Dizi | [K: Kara Sevda](https://www.tvmaze.com/shows/7580/kara-sevda) | Kara Sevda | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-379 | Dizi | [K: Kiralık Aşk](https://www.tvmaze.com/shows/7664/kiralik-ask) | Kiralık Aşk | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-380 | Dizi | [K: Erkenci Kuş](https://www.tvmaze.com/shows/37065/erkenci-kus) | Erkenci Kuş | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-381 | Dizi | [K: Sen Çal Kapımı](https://www.tvmaze.com/shows/48595/sen-cal-kapimi) | Sen Çal Kapımı | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-382 | Dizi | [K: Dolunay](https://www.tvmaze.com/shows/30122/dolunay) | Dolunay | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-383 | Dizi | [K: İstanbullu Gelin](https://www.tvmaze.com/shows/25674/istanbullu-gelin) | İstanbullu Gelin | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-384 | Dizi | [K: Kalp Atışı](https://www.tvmaze.com/shows/29913/kalp-atisi) | Kalp Atışı | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-385 | Dizi | [K: Mucize Doktor](https://www.tvmaze.com/shows/43557/mucize-doktor) | Mucize Doktor | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-386 | Dizi | [K: Hekimoğlu](https://www.tvmaze.com/shows/45329/hekimoglu) | Hekimoğlu | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-387 | Dizi | [K: Yargı](https://www.tvmaze.com/shows/57473/yargi) | Yargı | TR | Zor | Yüksek | Saptanmadı | G1 |
| charades-388 | Dizi | [K: Camdaki Kız](https://www.tvmaze.com/shows/54296/camdaki-kiz) | Camdaki Kız | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-389 | Dizi | [K: Masumlar Apartmanı](https://www.tvmaze.com/shows/50108/masumlar-apartmani) | Masumlar Apartmanı | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-390 | Dizi | [K: Kırmızı Oda](https://www.tvmaze.com/shows/50015/kirmizi-oda) | Kırmızı Oda | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-391 | Dizi | [K: Kızılcık Şerbeti](https://www.tvmaze.com/shows/64593/kizilcik-serbeti) | Kızılcık Şerbeti | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-392 | Dizi | [K: Kızıl Goncalar](https://www.tvmaze.com/shows/73042/kizil-goncalar) | Kızıl Goncalar | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-393 | Dizi | [K: Yalı Çapkını](https://www.tvmaze.com/shows/64071/yali-capkini) | Yalı Çapkını | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-394 | Dizi | [K: Bahar](https://www.tvmaze.com/shows/74223/bahar) | Bahar | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-395 | Dizi | [K: İnci Taneleri](https://www.tvmaze.com/shows/74036/inci-taneleri) | İnci Taneleri | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-396 | Dizi | [K: Aile](https://www.tvmaze.com/shows/66631/aile) | Aile | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-397 | Dizi | [K: Uzak Şehir](https://www.tvmaze.com/shows/80669/uzak-sehir) | Uzak Şehir | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-398 | Dizi | [K: Adım Farah](https://www.tvmaze.com/shows/67182/adim-farah) | Adım Farah | Karma | Zor | Orta | Saptanmadı | G1 |
| charades-399 | Dizi | [K: Şahmaran](https://www.tvmaze.com/shows/65338/sahmaran) | Şahmaran | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-400 | Dizi | [K: The Protector](https://www.tvmaze.com/shows/36807/the-protector) | Hakan: Muhafız | Karma | Zor | Orta | Saptanmadı | G1 |
| charades-401 | Dizi | [K: Friends](https://www.tvmaze.com/shows/431/friends) | Friends | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-402 | Dizi | [K: How I Met Your Mother](https://www.tvmaze.com/shows/171/how-i-met-your-mother) | How I Met Your Mother | Ö | Orta | Yüksek | Saptanmadı | G1 |
| charades-403 | Dizi | [K: The Big Bang Theory](https://www.tvmaze.com/shows/66/the-big-bang-theory) | The Big Bang Theory | Ö | Orta | Yüksek | Saptanmadı | G1 |
| charades-404 | Dizi | [K: Modern Family](https://www.tvmaze.com/shows/80/modern-family) | Modern Family | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-405 | Dizi | [K: The Office](https://www.tvmaze.com/shows/526/the-office) | The Office | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-406 | Dizi | [K: Brooklyn Nine-Nine](https://www.tvmaze.com/shows/49/brooklyn-nine-nine) | Brooklyn Nine-Nine | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-407 | Dizi | [K: Seinfeld](https://www.tvmaze.com/shows/530/seinfeld) | Seinfeld | Ö | Zor | Düşük | Saptanmadı | G4 |
| charades-408 | Dizi | [K: Frasier](https://www.tvmaze.com/shows/540/frasier) | Frasier | Ö | Zor | Düşük | Saptanmadı | G4 |
| charades-409 | Dizi | [K: Two and a Half Men](https://www.tvmaze.com/shows/130/two-and-a-half-men) | Two and a Half Men | İncele | Kolay | Orta | Saptanmadı | G3 |
| charades-410 | Dizi | [K: Scrubs](https://www.tvmaze.com/shows/532/scrubs) | Scrubs | Ö | Zor | Düşük | Saptanmadı | G4 |
| charades-411 | Dizi | [K: The Good Place](https://www.tvmaze.com/shows/2790/the-good-place) | The Good Place | İncele | Zor | Orta | Saptanmadı | G3 |
| charades-412 | Dizi | [K: Community](https://www.tvmaze.com/shows/318/community) | Community | Ö | Zor | Düşük | Saptanmadı | G4 |
| charades-413 | Dizi | [K: New Girl](https://www.tvmaze.com/shows/58/new-girl) | New Girl | Ö | Orta | Orta | Saptanmadı | G1 |
| charades-414 | Dizi | [K: Sabrina the Teenage Witch](https://www.tvmaze.com/shows/976/sabrina-the-teenage-witch) | Sabrina | İncele | Zor | Orta | Saptanmadı | G3 |
| charades-415 | Dizi | [K: ALF](https://www.tvmaze.com/shows/848/alf) | Alf | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-416 | Dizi | [K: Married... with Children](https://www.tvmaze.com/shows/499/married-with-children) | Evli ve Çocuklu | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-417 | Dizi | [K: The Simpsons](https://www.tvmaze.com/shows/83/the-simpsons) | Simpsonlar | TR | Kolay | Yüksek | Saptanmadı | G1 |
| charades-418 | Dizi | [K: Family Guy](https://www.tvmaze.com/shows/84/family-guy) | Family Guy | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-419 | Dizi | [K: South Park](https://www.tvmaze.com/shows/112/south-park) | South Park | Ö | Orta | Orta | Saptanmadı | G1 |
| charades-420 | Dizi | [K: Rick and Morty](https://www.tvmaze.com/shows/216/rick-and-morty) | Rick and Morty | Ö | Orta | Orta | Saptanmadı | G1 |
| charades-421 | Dizi | [K: Futurama](https://www.tvmaze.com/shows/538/futurama) | Futurama | Ö | Zor | Düşük | Saptanmadı | G4 |
| charades-422 | Dizi | [K: BoJack Horseman](https://www.tvmaze.com/shows/184/bojack-horseman) | BoJack Horseman | Ö | Zor | Düşük | Saptanmadı | G4 |
| charades-423 | Dizi | [K: Avatar: The Last Airbender](https://www.tvmaze.com/shows/555/avatar-the-last-airbender) | Avatar: Son Hava Bükücü | İncele | Kolay | Orta | Saptanmadı | G3 |
| charades-424 | Dizi | [K: SpongeBob SquarePants](https://www.tvmaze.com/shows/713/spongebob-squarepants) | SüngerBob KareŞort | TR | Kolay | Orta | Saptanmadı | G1 |
| charades-425 | Dizi | [K: Pokémon](https://www.tvmaze.com/shows/590/pokemon) | Pokémon | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-426 | Dizi | [K: Dragon Ball](https://www.tvmaze.com/shows/2102/dragon-ball) | Dragon Ball | İncele | Zor | Orta | Saptanmadı | G3 |
| charades-427 | Dizi | [K: Naruto](https://www.tvmaze.com/shows/495/naruto) | Naruto | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-428 | Dizi | [K: One Piece](https://www.tvmaze.com/shows/1505/one-piece) | One Piece | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-429 | Dizi | [K: Death Note](https://www.tvmaze.com/shows/40/death-note) | Death Note | İncele | Zor | Orta | Saptanmadı | G3 |
| charades-430 | Dizi | [K: Attack on Titan](https://www.tvmaze.com/shows/919/attack-on-titan) | Attack on Titan | İncele | Zor | Orta | Saptanmadı | G3 |
| charades-431 | Dizi | [K: Breaking Bad](https://www.tvmaze.com/shows/169/breaking-bad) | Breaking Bad | Ö | Orta | Yüksek | Saptanmadı | G1 |
| charades-432 | Dizi | [K: Better Call Saul](https://www.tvmaze.com/shows/618/better-call-saul) | Better Call Saul | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-433 | Dizi | [K: Prison Break](https://www.tvmaze.com/shows/541/prison-break) | Prison Break | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-434 | Dizi | [K: Lost](https://www.tvmaze.com/shows/123/lost) | Lost | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-435 | Dizi | [K: Game of Thrones](https://www.tvmaze.com/shows/82/game-of-thrones) | Game of Thrones | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-436 | Dizi | [K: House of the Dragon](https://www.tvmaze.com/shows/44778/house-of-the-dragon) | House of the Dragon | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-437 | Dizi | [K: The Walking Dead](https://www.tvmaze.com/shows/73/the-walking-dead) | The Walking Dead | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-438 | Dizi | [K: Stranger Things](https://www.tvmaze.com/shows/2993/stranger-things) | Stranger Things | Ö | Zor | Yüksek | Saptanmadı | G1 |
| charades-439 | Dizi | [K: Black Mirror](https://www.tvmaze.com/shows/305/black-mirror) | Black Mirror | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-440 | Dizi | [K: Sherlock](https://www.tvmaze.com/shows/335/sherlock) | Sherlock | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-441 | Dizi | [K: House](https://www.tvmaze.com/shows/118/house) | House | İncele | Kolay | Orta | Saptanmadı | G3 |
| charades-442 | Dizi | [K: Grey's Anatomy](https://www.tvmaze.com/shows/67/greys-anatomy) | Grey's Anatomy | Ö | Orta | Orta | Saptanmadı | G1 |
| charades-443 | Dizi | [K: The Good Doctor](https://www.tvmaze.com/shows/21845/the-good-doctor) | The Good Doctor | İncele | Kolay | Orta | Saptanmadı | G3 |
| charades-444 | Dizi | [K: Doctor Who](https://www.tvmaze.com/shows/210/doctor-who) | Doctor Who | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-445 | Dizi | [K: Supernatural](https://www.tvmaze.com/shows/19/supernatural) | Supernatural | Ö | Orta | Orta | Saptanmadı | G1 |
| charades-446 | Dizi | [K: The Vampire Diaries](https://www.tvmaze.com/shows/63/the-vampire-diaries) | The Vampire Diaries | İncele | Kolay | Orta | Saptanmadı | G3 |
| charades-447 | Dizi | [K: The Originals](https://www.tvmaze.com/shows/62/the-originals) | The Originals | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-448 | Dizi | [K: Teen Wolf](https://www.tvmaze.com/shows/176/teen-wolf) | Teen Wolf | İncele | Kolay | Orta | Saptanmadı | G3 |
| charades-449 | Dizi | [K: Buffy the Vampire Slayer](https://www.tvmaze.com/shows/427/buffy-the-vampire-slayer) | Buffy: Vampir Avcısı | Karma | Kolay | Orta | Saptanmadı | G1 |
| charades-450 | Dizi | [K: The X-Files](https://www.tvmaze.com/shows/430/the-x-files) | Gizli Dosyalar | TR | Kolay | Orta | Saptanmadı | G2 |
| charades-451 | Dizi | [K: Fringe](https://www.tvmaze.com/shows/158/fringe) | Fringe | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-452 | Dizi | [K: Dexter](https://www.tvmaze.com/shows/161/dexter) | Dexter | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-453 | Dizi | [K: Hannibal](https://www.tvmaze.com/shows/194/hannibal) | Hannibal | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-454 | Dizi | [K: The Mentalist](https://www.tvmaze.com/shows/116/the-mentalist) | The Mentalist | Ö | Orta | Orta | Saptanmadı | G1 |
| charades-455 | Dizi | [K: Castle](https://www.tvmaze.com/shows/68/castle) | Castle | Ö | Orta | Orta | Saptanmadı | G1 |
| charades-456 | Dizi | [K: Lucifer](https://www.tvmaze.com/shows/1859/lucifer) | Lucifer | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-457 | Dizi | [K: Suits](https://www.tvmaze.com/shows/172/suits) | Suits | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-458 | Dizi | [K: Peaky Blinders](https://www.tvmaze.com/shows/269/peaky-blinders) | Peaky Blinders | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-459 | Dizi | [K: Vikings](https://www.tvmaze.com/shows/29/vikings) | Vikings | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-460 | Dizi | [K: The Last Kingdom](https://www.tvmaze.com/shows/2759/the-last-kingdom) | The Last Kingdom | Ö | Orta | Orta | Saptanmadı | G1 |
| charades-461 | Dizi | [K: Spartacus](https://www.tvmaze.com/shows/716/spartacus) | Spartacus | İncele | Kolay | Orta | Saptanmadı | G3 |
| charades-462 | Dizi | [K: Rome](https://www.tvmaze.com/shows/677/rome) | Rome | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-463 | Dizi | [K: The Tudors](https://www.tvmaze.com/shows/712/the-tudors) | The Tudors | Ö | Zor | Düşük | Saptanmadı | G4 |
| charades-464 | Dizi | [K: The Crown](https://www.tvmaze.com/shows/3594/the-crown) | The Crown | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-465 | Dizi | [K: Downton Abbey](https://www.tvmaze.com/shows/251/downton-abbey) | Downton Abbey | Ö | Zor | Düşük | Saptanmadı | G4 |
| charades-466 | Dizi | [K: La Casa de Papel](https://www.tvmaze.com/shows/27436/la-casa-de-papel) | La Casa de Papel | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-467 | Dizi | [K: Squid Game](https://www.tvmaze.com/shows/43687/squid-game) | Squid Game | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-468 | Dizi | [K: Wednesday](https://www.tvmaze.com/shows/53647/wednesday) | Wednesday | Ö | Kolay | Yüksek | Saptanmadı | G1 |
| charades-469 | Dizi | [K: The Witcher](https://www.tvmaze.com/shows/28276/the-witcher) | The Witcher | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-470 | Dizi | [K: The Last of Us](https://www.tvmaze.com/shows/46562/the-last-of-us) | The Last of Us | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-471 | Dizi | [K: Chernobyl](https://www.tvmaze.com/shows/30770/chernobyl) | Chernobyl | İncele | Zor | Orta | Saptanmadı | G3 |
| charades-472 | Dizi | [K: Band of Brothers](https://www.tvmaze.com/shows/465/band-of-brothers) | Kardeşler Takımı | TR | Kolay | Orta | Saptanmadı | G2 |
| charades-473 | Dizi | [K: The Queen's Gambit](https://www.tvmaze.com/shows/41428/the-queens-gambit) | The Queen's Gambit | İncele | Zor | Orta | Saptanmadı | G3 |
| charades-474 | Dizi | [K: Dark](https://www.tvmaze.com/shows/17861/dark) | Dark | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-475 | Dizi | [K: 1899](https://www.tvmaze.com/shows/39749/1899) | 1899 | Ö | Zor | Düşük | Saptanmadı | G4 |
| charades-476 | Dizi | [K: Lupin](https://www.tvmaze.com/shows/50701/lupin) | Lupin | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-477 | Dizi | [K: Élite](https://www.tvmaze.com/shows/37854/elite) | Elite | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-478 | Dizi | [K: Sex Education](https://www.tvmaze.com/shows/36795/sex-education) | Sex Education | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-479 | Dizi | [K: You](https://www.tvmaze.com/shows/26856/you) | You | Ö | Orta | Orta | Saptanmadı | G1 |
| charades-480 | Dizi | [K: Emily in Paris](https://www.tvmaze.com/shows/41632/emily-in-paris) | Emily in Paris | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-481 | Dizi | [K: Gossip Girl](https://www.tvmaze.com/shows/567/gossip-girl) | Gossip Girl | İncele | Kolay | Orta | Saptanmadı | G3 |
| charades-482 | Dizi | [K: Glee](https://www.tvmaze.com/shows/8/glee) | Glee | Ö | Zor | Orta | Saptanmadı | G4 |
| charades-483 | Dizi | [K: Desperate Housewives](https://www.tvmaze.com/shows/550/desperate-housewives) | Desperate Housewives | İncele | Kolay | Orta | Saptanmadı | G3 |
| charades-484 | Dizi | [K: Gilmore Girls](https://www.tvmaze.com/shows/525/gilmore-girls) | Gilmore Girls | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-485 | Dizi | [K: Pretty Little Liars](https://www.tvmaze.com/shows/177/pretty-little-liars) | Pretty Little Liars | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-486 | Dizi | [K: Gotham](https://www.tvmaze.com/shows/11/gotham) | Gotham | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-487 | Dizi | [K: Arrow](https://www.tvmaze.com/shows/4/arrow) | Arrow | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-488 | Dizi | [K: The Flash](https://www.tvmaze.com/shows/13/the-flash) | The Flash | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-489 | Dizi | [K: Smallville](https://www.tvmaze.com/shows/435/smallville) | Smallville | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-490 | Dizi | [K: Superman & Lois](https://www.wikidata.org/wiki/Q93281114) | Superman ve Lois | İncele | Kolay | Orta | Saptanmadı | G3 |
| charades-491 | Dizi | [K: Marvel's Daredevil](https://www.tvmaze.com/shows/1369/marvels-daredevil) | Daredevil | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-492 | Dizi | [K: Marvel's Jessica Jones](https://www.tvmaze.com/shows/1370/marvels-jessica-jones) | Jessica Jones | Ö | Zor | Düşük | Saptanmadı | G4 |
| charades-493 | Dizi | [K: Loki](https://www.tvmaze.com/shows/41007/loki) | Loki | Ö | Kolay | Orta | Saptanmadı | G1 |
| charades-494 | Dizi | [K: WandaVision](https://www.tvmaze.com/shows/41748/wandavision) | WandaVision | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-495 | Dizi | [K: The Mandalorian](https://www.tvmaze.com/shows/38963/the-mandalorian) | The Mandalorian | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-496 | Dizi | [K: Andor](https://www.tvmaze.com/shows/52341/andor) | Andor | Ö | Zor | Düşük | Saptanmadı | G4 |
| charades-497 | Dizi | [K: The Boys](https://www.tvmaze.com/shows/15299/the-boys) | The Boys | Ö | Orta | Orta | Saptanmadı | G1 |
| charades-498 | Dizi | [K: Invincible](https://www.tvmaze.com/shows/37196/invincible) | Invincible | İncele | Orta | Orta | Saptanmadı | G3 |
| charades-499 | Dizi | [K: Severance](https://www.tvmaze.com/shows/44933/severance) | Severance | Ö | Zor | Orta | Saptanmadı | G1 |
| charades-500 | Dizi | [K: Big Little Lies](https://www.wikidata.org/wiki/Q19873404) | Büyük Küçük Yalanlar | İncele | Orta | Orta | Saptanmadı | G3 |

## Kapsam ve dosya bütünlüğü

Bu çalışmada sadece docs/charades_phase41_review.md raporu oluşturuldu. JSON havuzu, kaynak kayıt dosyası, oyun kodu, testler, tema, Tabu ve navigasyon değiştirilmedi. Mevcut Faz 4 değişiklikleri çalışma ağacında önceden bulunuyordu ve korundu. Oynanış değişmediği için Flutter test/analyze/build bu salt belge incelemesinde yeniden çalıştırılmadı. Rapor için kayıt sayısı, şema, grup toplamları, her ID’nin tam bir kez değerlendirilmesi ve alternatif ad çakışmaları betikle denetlendi.

İncelenen kart dosyasının SHA-256 değeri: `8331023ac7906c1ce30f3edd74f6b2957050834f3183076692e765d7044c35a6`. Değerlendirme öncesi/sonrası aynı olmalıdır. Commit/push yapılmadı.

## Seçili ek doğrulama kaynakları

- [Yeni Hayat — Sinema TV](https://sinematv.com.tr/CAST-AWAY): İngilizce ve Türkçe başlığı aynı kayıt üzerinde veriyor.
- [Yeni Hayat — Box Office Türkiye](https://boxofficeturkiye.com/film/yeni-hayat--2001029): dağıtım/yıl eşleştirmesi.
- [Şrek — Netflix Türkiye](https://www.netflix.com/tr/title/60020686): mevcut Türkçe yazım destekleniyor.
- [The Good Place — Netflix Türkiye](https://www.netflix.com/tr/title/80113701): başlık İngilizce; açıklamadaki İyi Yer farklı işlevde.
- [The Queen’s Gambit — Netflix Türkiye](https://www.netflix.com/tr/title/80234304): dizi başlığı; [Netflix kitap değerlendirmesi](https://about.netflix.com/tr/news/an-exciting-new-chapter-for-books-with-netflix-adaptations) ise Vezir Gambiti kitap adını kullanıyor.
- [Av — Apple TV Türkiye](https://tv.apple.com/tr/movie/av/umc.cmc.4axzo5v4q64albtyks88pbp01?l=tr): Predator için mevcut Av tercihini destekliyor; Avcı gibi yeni bir çeviri önerilmedi.
- [Nefes: Vatan Sağolsun — Box Office Türkiye](https://boxofficeturkiye.com/film/nefes-vatan-sagolsun--2010279): başlıkta mevcut Sağolsun yazımı var; genel yazım kuralıyla eser adı sessizce değiştirilmedi.
- [Invincible — Prime Video Türkçe](https://www.primevideo.com/-/tr/detail/0KRK7IABRYDORGPDYP1XO3OT0Q): özgün marka başlığı.

Kaynak erişim tarihi 28 Ekim 2026. Arama sonucunda başka film, kitap veya yeni uyarlama çıkması mevcut kartla aynı kimliği doğrulamaz; yıl/kadro/kanonik kimlik gerekir. Katalog sayfalarındaki yayın erişimi ve fiyatlar araştırma konusu değildir; bunlardan bulunurluk veya popülerlik sonucu çıkarılmadı. Kaynak metinleri, açıklamalar ve başka uygulamaların kart listeleri kopyalanmadı.

Son belge kontrolü: Ek A’da 500 ID’nin her biri tam bir kez bulunuyor; grup toplamları 500 ediyor. İnceleme başında kaydedilen 55 mevcut lib/test/assets/docs dosyasının SHA-256 değerleri inceleme sonunda aynı kaldı. Bu fazın yeni kalıcı dosyası yalnızca bu rapordur.
