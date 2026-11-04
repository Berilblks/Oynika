const wordPairData = '''
Kahve|Çay
Deniz|Havuz
Sinema|Tiyatro
Doktor|Hemşire
Pilot|Kaptan
Güneş|Ay
Otobüs|Tren
Pizza|Hamburger
Kedi|Köpek
Kitap|Dergi
Ayran|Kefir
Limonata|Gazoz
Salep|Sıcak çikolata
Boza|Şıra
Maden suyu|Tonik
Portakal suyu|Elma suyu
Su|Buzlu çay
Kola|Enerji içeceği
Süt|Badem sütü
Nane çayı|Ihlamur
Börek|Poğaça
Simit|Açma
Lahmacun|Pide
Mantı|İçli köfte
Köfte|Sucuk
Döner|Kokoreç
Pilav|Bulgur
Makarna|Erişte
Mercimek çorbası|Ezogelin çorbası
Menemen|Omlet
Kuru fasulye|Nohut
Patates kızartması|Soğan halkası
Sarma|Dolma
Karnıyarık|İmam bayıldı
Kısır|Patates salatası
Turşu|Zeytin
Peynir|Lor
Tereyağı|Margarin
Yoğurt|Kaymak
Bal|Reçel
Tahin|Pekmez
Kestane|Fındık
Badem|Ceviz
Leblebi|Çekirdek
Patlamış mısır|Cips
Baklava|Şöbiyet
Künefe|Kadayıf
Sütlaç|Kazandibi
Dondurma|Meyveli buz
Lokum|Pişmaniye
Kek|Kurabiye
Pasta|Turta
Puding|Muhallebi
Helva|Aşure
Gözleme|Krep
Elma|Armut
Portakal|Mandalina
Limon|Greyfurt
Karpuz|Kavun
Kiraz|Vişne
Şeftali|Kayısı
Erik|Nektarin
Çilek|Ahududu
Böğürtlen|Dut
İncir|Hurma
Üzüm|Nar
Muz|Ananas
Havuç|Turp
Domates|Salatalık
Patlıcan|Kabak
Ispanak|Pazı
Brokoli|Karnabahar
Maydanoz|Dereotu
Marul|Roka
Sarımsak|Soğan
Öğretmen|Profesör
Avukat|Hâkim
Polis|Jandarma
İtfaiyeci|Cankurtaran
Aşçı|Pastacı
Berber|Kuaför
Kasap|Balıkçı
Terzi|Modacı
Mimar|İnşaat mühendisi
Elektrikçi|Tesisatçı
Çiftçi|Bahçıvan
Veteriner|Biyolog
Diş hekimi|Diş teknisyeni
Fotoğrafçı|Kameraman
Gazeteci|Muhabir
Yazar|Şair
Oyuncu|Yönetmen
Şarkıcı|Besteci
Ressam|Heykeltıraş
Çevirmen|Dil öğretmeni
Postacı|Kurye
Bankacı|Muhasebeci
Eczacı|Kimyager
Antrenör|Hakem
Marangoz|Mobilyacı
İstanbul|İzmir
Ankara|Eskişehir
Antalya|Muğla
Trabzon|Rize
Gaziantep|Şanlıurfa
Bursa|Bolu
Çanakkale|Edirne
Konya|Kayseri
Van|Bitlis
Mardin|Diyarbakır
Paris|Roma
Londra|Dublin
Atina|Selanik
Tokyo|Seul
Berlin|Viyana
Köy|Kasaba
Sahil|İskele
Meydan|Çarşı
Müze|Sergi salonu
Kütüphane|Kitapçı
Fırın|Pastane
Bakkal|Market
Otel|Pansiyon
Kamp alanı|Karavan parkı
Okul|Kurs merkezi
Metro|Tramvay
Dolmuş|Taksi
Bisiklet|Kaykay
Motosiklet|Motorlu bisiklet
Vapur|Feribot
Kano|Kürek teknesi
Yelkenli|Yat
Uçak|Helikopter
Balon|Zeplin
Teleferik|Füniküler
Kamyon|Tır
Minibüs|Servis aracı
Ambulans|İtfaiye aracı
Garaj|Otopark
Bilet|Abonman
Valiz|Sırt çantası
Köprü|Viyadük
Tünel|Alt geçit
Kavşak|Dönel kavşak
Trafik lambası|Dur levhası
Dağ|Tepe
Ova|Plato
Vadi|Kanyon
Göl|Gölet
Nehir|Dere
Şelale|Su değirmeni
Orman|Koruluk
Çöl|Bozkır
Kum|Çakıl
Yağmur|Dolu
Kar|Kırağı
Sis|Bulut
Rüzgâr|Fırtına
Gökkuşağı|Kutup ışıkları
Yıldız|Gezegen
Deprem|Heyelan
Volkan|Gayzer
Mağara|Kaya oyuğu
Çam|Köknar
Meşe|Çınar
Gül|Karanfil
Lale|Sümbül
Papatya|Ayçiçeği
Kaktüs|Aloe vera
Yosun|Eğrelti otu
Aslan|Kaplan
Leopar|Çita
Fil|Gergedan
Zebra|Zürafa
At|Eşek
Koyun|Keçi
İnek|Manda
Tavşan|Sincap
Kurt|Tilki
Ayı|Panda
Kirpi|Köstebek
Tavuk|Hindi
Ördek|Kaz
Kartal|Şahin
Martı|Pelikan
Papağan|Muhabbet kuşu
Karga|Saksağan
Baykuş|Yarasa
Yunus|Balina
Fok|Deniz aslanı
Ahtapot|Kalamar
Yengeç|Istakoz
Kurbağa|Semender
Kaplumbağa|Kertenkele
Arı|Yaban arısı
Telefon|Tablet
Dizüstü bilgisayar|Masaüstü bilgisayar
Klavye|Fare
Monitör|Projektör
Yazıcı|Tarayıcı
Hoparlör|Kulaklık
Mikrofon|Ses kayıt cihazı
Kumanda|Oyun kolu
Pil|Şarj aleti
USB bellek|Hafıza kartı
Radyo|Televizyon
Çalar saat|Zamanlayıcı
Robot süpürge|Elektrikli süpürge
Buzdolabı|Derin dondurucu
Fırın tepsisi|Tava
Tencere|Düdüklü tencere
Su ısıtıcısı|Çaydanlık
Kaşık|Çatal
Bardak|Kupa
Tabak|Kâse
Koltuk|Sedir
Yatak|Hamak
Yastık|Minder
Battaniye|Yorgan
Perde|Stor
Halı|Kilim
Ayna|Pencere
Dolap|Şifonyer
Masa|Sehpa
Sandalye|Tabure
Sabun|Duş jeli
Şampuan|Saç kremi
Havlu|Bornoz
Diş fırçası|Diş ipi
Tarak|Toka
Gömlek|Tişört
Ceket|Hırka
Mont|Palto
Etek|Elbise
Pantolon|Şort
Şapka|Bere
Atkı|Fular
Eldiven|Bileklik
Bot|Çizme
Terlik|Sandalet
Bilardo|Bowling
Yapboz|Lego
Gitar|Ukulele
Piyano|Org
Davul|Darbuka
Keman|Viyola
Flüt|Klarnet
Konser|Festival
Lunapark|Su parkı
Doğum günü|Mezuniyet
''';
