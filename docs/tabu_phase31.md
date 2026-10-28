# Faz 3.1 — 500 kartlık Tabu havuzu

20 Ekim 2026: Mevcut 250 kartın bütün alanları ve sırası korundu. `tabu-251`–`tabu-500` aralığında 250 yeni kart eklendi. Toplam 500 kart ve 500 farklı hedef bulunur. JSON şeması değişmedi; uygulama/repository/controller/arayüz ve bağımlılıklar değiştirilmedi.

Her kategoride 25 yeni kart (15 Kolay, 8 Orta, 2 Zor) eklendi. Günlük yaşam, Yemek ve içecek, Spor, Meslekler, Teknoloji, Doğa, Eğlence, Kültür, Seyahat ve Nesneler kategorilerinin her birinde 50 kart (30 Kolay, 16 Orta, 4 Zor) vardır. Genel toplam: 300 Kolay, 160 Orta, 40 Zor.

## İçerik yaklaşımı ve kalite incelemesi

Kolay kartlar bilinen somut nesne, gündelik eylem ve görünür özelliklerden; orta kartlar daha özel süreç, rol veya kurallardan; zor kartlar temel çağrışımları engellendiğinde dolaylı anlatım gerektiren kavramlardan seçildi. Örnek: Kedi/Buzul/Fotosentez ve Televizyon/Sosyal medya/Şifreleme farklı anlatım güçlükleri sunar. Seviyeler sayısal kotaya rastgele atanmadı; her kategori için bu güçlük sırası içerik yazımında planlandı. Zorluk editoryal değerlendirmedir, gerçek oyuncu ölçümü değildir.

Yeni hedefler eski/yeni havuzla karşılaştırıldı. Örneğin mevcut Volkan için Yanardağ, Valiz için Bavul, Patlamış mısır için Popcorn gibi eş anlamlı/yabancı alternatifler eklenmedi. Saat/Çalar saat, Bilgisayar/Tablet gibi bağımsız kavramlar için aynı yazım kontrolünün ötesinde anlam incelemesi yapıldı. (Çalar saat, genel Saat hedefinden farklı olarak alarm/uyandırma işlevine odaklanır.) Türkçe doğal ifadeler kullanıldı; gereksiz İngilizce karşılıklar yerine Taşınabilir şarj cihazı ve Çevrim içi toplantı gibi adlar seçildi.

Beş yasaklı, yalnızca aynı kategoriden değil hedefin doğrudan çağrışımlarından oluşturuldu. İncelemede Çiçek kartındaki tek başına Taç ifadesi Taç yaprak olarak netleştirildi; Hokkabazlık kartı El çabukluğu, Numara, Gösteri, Şaşırtmak, Beceri ile yeniden düzenlendi. Eski kartlara müdahale edilmedi. Otomatik benzersizlik anlamsal eşdeğerliği kanıtlamaz; hedefler ayrıca anlam ve kullanım açısından gözden geçirildi. Oyuncu geri bildirimiyle zorluk dengesi daha sonra iyileştirilebilir.

## İnternet araştırması

- [TDK Yazım Kılavuzu](https://tdk.gov.tr/tdk/kurumsal/yazim-kilavuzu/): arama dizininde doğru yazım için Güncel Türkçe Sözlük yönlendirmesi incelendi. Doğrudan sayfa açılışı 502 hatası verdi.
- [TDK Güncel Türkçe Sözlük](https://sozluk.gov.tr/arama): başvuru kaynağı olarak araştırıldı; 250 kelimenin tamamına tek tek sözlük sorgusu yapıldığı iddia edilmez.
- [TDK Hıdırellez, Nevruz ve Mihrican yazısı](https://www.tdk.gov.tr/wp-content/uploads/2013/03/20130307.pdf): Hıdırellez yazımı ve bahar/dilek/kutlama çağrışımları araştırıldı.
- [TDK İstiklal Marşı sayfası](https://tdk.gov.tr/genel/istiklal-marsi/), [TDK/TBMM İstiklâl Marşı çalışması](https://cdn.tbmm.gov.tr/TbmmWeb/Yayinlar/Dosya/f3c1bc24-b9e6-4bd3-a0f6-0f8a8125a4a6.pdf): adın ve Türkçe kültür bağlamının yazımı karşılaştırıldı.
- [Hasbro Türkçe Tabu açıklaması](https://instructions.hasbro.com/tr-tr/instruction/tabu): hedefle güçlü ilişkili kelimeleri engelleme yaklaşımı incelendi. Kart listesi indirilmedi veya toplu kopyalanmadı.

Hedef/yasaklı kombinasyonları proje için özgün yazıldı. Araştırma, kaynak kartların içe aktarılması anlamına gelmez.

## Doğrulama ve eski verinin korunması

`test/fixtures/tabu_cards_phase3.json` ilk sürümün 250 kartlık değişmez test referansıdır. Yeni test ilk 250 kaydı tüm alanları ve sırasıyla bu referansa karşı karşılaştırır. Test referansı oyun asset'i değildir; uygulama yalnızca 500 kartlık asıl JSON'u yükler.

`test/tabu_card_data_test.dart` şu kontrolleri yapar: tam 500 kart; şema ve veri tipleri; sıralı/benzersiz ID'ler; Türkçe I/İ/ı/i normalleştirmeli hedef benzersizliği; beş dolu/farklı yasaklı; hedefin yasaklılarda olmaması; eski/yeni kategori ve zorluk dağılımları; kenar/çift boşluk, kontrol/görünmez karakter, bozuk kodlama ve Latin harfine benzeyen başka alfabe karakterlerinin bulunmaması. Controller testi 500 kartın tamamı görülmeden tekrar olmadığını, takım değişiminde destenin korunduğunu, bitince yeniden karıştığını ve sınırda son kartın hemen tekrarlanmadığını doğrular.

Mevcut `Random()`/`shuffle()` algoritmasına dokunulmadı. Süre, hedef puan, sınırsız tur, üç pas, puanlama, kart görünümü ve ekranlar korunur.

## Her kategoriden üç yeni örnek

| Kategori | Hedef | Zorluk | Beş yasaklı |
|---|---|---|---|
| Günlük yaşam | Diş fırçalamak | Kolay | Macun, Ağız, Temizlik, Lavabo, Sabah |
| Günlük yaşam | Plan yapmak | Orta | Program, Gelecek, Önceden, Hazırlık, Düzen |
| Günlük yaşam | Empati | Zor | Duygu, Anlamak, Yerine koymak, Karşıdaki, Bakış açısı |
| Yemek ve içecek | Lahmacun | Kolay | Hamur, Kıyma, İnce, Limon, Fırın |
| Yemek ve içecek | Humus | Orta | Nohut, Tahin, Limon, Meze, Ezilmiş |
| Yemek ve içecek | Mayalamak | Zor | Hamur, Kabarmak, Bekletmek, Yoğurt, Maya |
| Spor | Masa tenisi | Kolay | Raket, Top, File, Küçük, Masa |
| Spor | Ofsayt | Orta | Futbol, Çizgi, Hakem, Pas, Savunma |
| Spor | Averaj | Zor | Gol, Fark, Puan, Lig, Sıralama |
| Meslekler | Diş hekimi | Kolay | Ağız, Çürük, Dolgu, Koltuk, Muayene |
| Meslekler | Marangoz | Orta | Ahşap, Testere, Mobilya, Çivi, Ölçmek |
| Meslekler | Restoratör | Zor | Tarihî eser, Onarmak, Korumak, Eski, Sanat |
| Teknoloji | Televizyon | Kolay | Ekran, Kanal, Kumanda, Dizi, İzlemek |
| Teknoloji | Sosyal medya | Orta | Paylaşmak, Takipçi, Beğeni, Hesap, Gönderi |
| Teknoloji | Şifreleme | Zor | Gizlilik, Anahtar, Veri, Korumak, Çözmek |
| Doğa | Kedi | Kolay | Miyav, Pati, Bıyık, Tüy, Evcil |
| Doğa | Buzul | Orta | Buz, Kutup, Erimek, Soğuk, Kütle |
| Doğa | Fotosentez | Zor | Bitki, Işık, Oksijen, Karbondioksit, Üretmek |
| Eğlence | Dizi | Kolay | Bölüm, Televizyon, Sezon, Oyuncu, İzlemek |
| Eğlence | Doğaçlama | Orta | Hazırlıksız, Sahne, Anlık, Oyuncu, Metin |
| Eğlence | İllüzyon | Zor | Yanılsama, Göz, Aldatmak, Sihir, Gösteri |
| Kültür | Nazar boncuğu | Kolay | Mavi, Göz, Korumak, Kötülük, İnanç |
| Kültür | Kervansaray | Orta | Yolcu, Konaklamak, Ticaret, Deve, Tarihî |
| Kültür | Oya | Zor | İğne, İplik, Yazma, Kenar, İşlemek |
| Seyahat | Uçak | Kolay | Kanat, Pilot, Havaalanı, Uçmak, Yolcu |
| Seyahat | Aktarma | Orta | Değiştirmek, Sefer, Bağlantı, Durak, Yolcu |
| Seyahat | Saat farkı | Zor | Zaman, Ülke, Dilim, Uzak, Ayarlamak |
| Nesneler | Tabak | Kolay | Yemek, Porselen, Sofra, Yuvarlak, Servis |
| Nesneler | Mandal | Orta | Çamaşır, Asmak, İp, Sıkıştırmak, Yay |
| Nesneler | Tirbuşon | Zor | Mantar, Şişe, Açmak, Spiral, Çevirmek |

## Son doğrulama

- `flutter pub get`: başarılı; bağımlılık değişikliği yok.
- `flutter analyze`: sorun yok.
- `flutter test`: 72/72 başarılı (önceki 64 test ve 8 yeni veri/500 kart döngüsü testi).
- `flutter build apk --debug`: başarılı; `build/app/outputs/flutter-apk/app-debug.apk`.
- Oyun controller/model/repository/arayüz kaynakları ve pubspec dosyaları değişmedi. Derlemede kullanılan geçici Gradle bellek sınırı dosyaya kalıcı yazılmadı.
- Değişen dosyalar: asıl kart JSON'u, `test/tabu_controller_test.dart`, `test/tabu_card_data_test.dart`, `test/fixtures/tabu_cards_phase3.json`, `README.md`, `docs/tabu_phase3.md`, bu rapor.
- Commit veya push yapılmadı. APK'nın fiziksel cihazda yeniden çalıştırılması bu veri genişletme görevinin doğrulama adımları arasında istenmedi; önceki kurulu sürümler otomatik güncellenmedi.
