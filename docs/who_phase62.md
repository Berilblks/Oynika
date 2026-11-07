# Ben Kimim? — Faz 6.2: çevrimdışı kart havuzu

## İçerik

Tam 300 kart, yalnızca `id`, `name`, `category`, `difficulty` alanları. Sabit başlangıç ID'leri `who-001`–`who-300`; sıralama değişse bile ID'ler yeniden üretilmemeli. ID–isim fixture'ı istemsiz değişiklikleri yakalar. JSON, Türkçe Unicode metinlerle UTF-8 olarak saklanır. NFC kontrolü geçti; boş, normalleştirilmiş mükerrer isim veya ID bulunmadı.

| Kategori | Toplam | Kolay | Orta | Zor |
| --- | ---: | ---: | ---: | ---: |
| Ünlüler ve tanınmış kişiler | 70 | 31 | 37 | 2 |
| Film ve çizgi film karakterleri | 60 | 38 | 17 | 5 |
| Hayvanlar | 50 | 38 | 12 | 0 |
| Meslekler | 40 | 27 | 13 | 0 |
| Nesneler | 50 | 47 | 3 | 0 |
| Eğlenceli karakterler ve kavramlar | 30 | 20 | 7 | 3 |
| **Toplam** | **300** | **201** | **89** | **10** |

Zorluk dağılımı %67 Kolay, yaklaşık %29,7 Orta, %3,3 Zor. Zorluk, tanınırlık ve sözlü ipuçlarıyla ayırt edilebilirliğe göre editoryal atanmıştır; yaş gruplarıyla ölçülmüş bir sonuç değildir.

Adlar Türkiye'de yaygın kullanılan biçimlerden seçildi. Aynı kimliğin yaygın alternatif adları için ayrıca test vardır: Atatürk, Âşık Veysel, Muhammed Ali, Charlie Chaplin, Mickey Mouse, Örümcek Adam, Demir Adam, Kaptan Amerika, Kara Panter, Çizmeli Kedi, Şimşek McQueen ve Pinokyo.

Örnek kaynak kontrolleri: [TRT Çocuk — Rafadan Tayfa Hayri](https://ebeveynakademisi.trtcocuk.net.tr/etkinlik/rafadan-tayfa-hayri-boyama-12041234), [Disney — Woody ve Buzz Lightyear](https://toystory.disney.com/), [Disney Cars — Lightning McQueen](https://cars.disney.com/), [Nickelodeon Play İstanbul — Patrick Yıldız adı kullanımı](https://www.nickelodeonplayistanbul.com/). Bunlar örnek kontrollerdir; 300 kartın tamamının ayrı ayrı harici kaynakla doğrulandığı iddia edilmez. Başka bir oyunun kart listesi topluca kopyalanmadı.

## Mimari ve eklenen dosyalar

- `assets/data/who_am_i_cards.json`: Uygulamaya gömülü 300 kart.
- `lib/features/games/who_am_i/domain/who_card.dart`: Immutable kart, kategori/zorluk enumları, şema ve ad normalleştirme.
- `lib/features/games/who_am_i/domain/who_card_deck.dart`: Oyuncudan bağımsız, enjekte edilebilir Random kullanan deste.
- `lib/features/games/who_am_i/data/who_card_repository.dart`: `rootBundle` üzerinden JSON yükleme, geçersiz şema/enum/tekrar reddi ve `whoCardsProvider`.
- `lib/features/games/who_am_i/application/who_deck_provider.dart`: Oturum ayarlarıyla ilişkili deste ve Random provider'ları.
- `lib/features/games/who_am_i/presentation/who_card_labels.dart`: Türkçe kategori/zorluk etiketleri; domain enumlarında UI metni yoktur.
- `test/who_card_data_test.dart`, `test/who_card_deck_test.dart`: Veri, repository, deste ve provider testleri.
- `test/fixtures/who_phase62_card_identities.json`: 300 sabit ID–isim eşleşmesi.
- Bu rapor.

`pubspec.yaml` dosyasına yalnızca JSON asset kaydı eklendi. `README.md` güncellendi. Paket eklenmedi, lockfile içeriği değişmedi. Faz 6.1 ayarları, başlangıç ekranı, WhoController ve WhoGameSession değiştirilmedi. Diğer oyunların feature dosyaları değişmedi.

Kartlar APK içinde bulunur; repository yalnızca yerel asset okur ve ağ/API/backend kullanmaz. FutureProvider ilk okunduğunda asenkron yükler ve uygulama container'ında cache'ler. Uygulama açılışına ek bekleme ekranı eklenmedi.

## Deste yaşam döngüsü

1. Deste oluşturulunca tüm kategoriler birlikte karıştırılır. Kategori veya zorluk filtresi yoktur.
2. 300 kartın her biri bir döngüde bir kez çekilir.
3. Döngü tükenince yeniden karıştırılır. Yeni ilk kart önceki son kartla çakışırsa başka bir kartla yer değiştirilir.
4. Oyuncu değişimi aynı deste instance'ını kullanır. Provider yalnızca oturumdaki `settings` kimliği değişince yeni deste üretir; aynı ayar nesnesini koruyan oturum güncellemesinde deste ilerlemesi korunur.
5. Reset sonrası yeni oyun yeni ayar nesnesi ve yeni deste oluşturur. Deste gelecekteki oynanışta `whoDeckProvider` izlenerek oturum süresince canlı tutulmalıdır; autoDispose son tüketici ayrılınca desteyi bırakır.
6. Sabit seed ile testlerde aynı sıra üretilebilir. Gerçek uygulama normal Random kullanır.

Bu fazda deste servisi hazırlandı; geçici başlangıç ekranına kart çekimi bağlanmadı. Gerçek oyuncu/tur geçişleri hâlâ sonraki fazın kapsamındadır. Koruma davranışı servis ve aynı ayarları koruyan oturum güncellemesi testleriyle doğrulanır. Tek kartlık özel test havuzunda ardışık tekrarı önlemek matematiksel olarak mümkün değildir; 300 kartlık uygulama havuzunda sınır tekrarı engellenir.

## Doğrulama

- `flutter analyze`: temiz.
- `flutter test --concurrency=1`: **205 test başarılı**, 32 yeni veri/deste testi.
- `flutter build apk --debug`: başarılı.
- APK arşivindeki `assets/flutter_assets/assets/data/who_am_i_cards.json`: tam 300 kart.
- Beş tam deste döngüsü, zorlanmış sınır çakışması, deterministik seed, yeni oyun reset'i, oturum devamlılığı, geçersiz JSON/şema/enum/tekrar ve yerel asset yükleme test edildi.
- Onaylanan ekranlar ve oyunların mevcut testleri başarılı. Yeni görsel ekran veya sensör/tur/sayaç oluşturulmadı. `isPlayable` false kalır.

## Yayın öncesi inceleme ve sınırlar

- `who-001`–`who-070`: kişi adları; yayın/hak incelemesi sırasında kullanım ayrıca değerlendirilecek.
- `who-071`–`who-130`: karakter ve seriyle ilişkili adlar; marka/karakter kullanım incelemesi ayrıca yapılacak. Örnekler Mickey Mouse, SüngerBob, Kral Şakir, Harry Potter, Batman ve Marvel karakter adları.
- İçerik yalnızca kısa isimlerden oluşur. Kişiler hakkında iddia veya özel hayat bilgisi, karakter görseli, marka logosu, film repliği ya da kaynak açıklaması eklenmedi. Kısa ad kullanımı bir izin veya hak uygunluğu onayı olarak sunulmaz.
- Tanınırlık ve zorluk hedef yaş gruplarındaki gerçek oyunlarla ayrıca değerlendirilmeli. Oturum/deste diske yazılmaz; uygulama yeniden başlarsa karıştırma geçmişi korunmaz.
- Önceki V1 ve Faz 6.1 çalışma alanı değişiklikleri korunur. Commit veya push yapılmadı.
