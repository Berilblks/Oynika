# V1 — dört oyunluk ürün yapısı

Merkezi katalog `lib/features/games/domain/party_game.dart` içindeki `PartyGame` enum'udur. Liste sırası, başlık, açıklama, asset, rota ve `isPlayable` bilgisi burada tutulur. Ana ekran ve Oyunlar sekmesi aynı `GameCollection` bileşenini kullanır. Slogan oyun sayısından türetilir.

| Sıra | Oyun | Durum |
| --- | --- | --- |
| 1 | Tabu | Oynanabilir, 500 kart |
| 2 | Sessiz Sinema | Oynanabilir, 300 film ve 200 dizi |
| 3 | Aramızdaki Casus | Oynanabilir, onaylanan mor karakter ve gizli oyun akışı |
| 4 | Ben Kimim? | Faz 6.3.1 ile 300 kart ve dokunmatik kontrollerle oynanabilir |

Ben Kimim? için `/games/who_am_i` ayar ekranına açılır. Faz 6.3.1 ile oyuncu hazırlığı, 3 saniyelik başlangıç sayacı, gerçek tur, Doğru/Pas, duraklatma ve tur sonucu uygulanmıştır. Dört oyun da katalogda oynanabilir durumdadır. Hareket sensörleri sonraki faza bırakılmıştır; mevcut oyun dokunmatik kontroller kullanır.

Ürün adı: **Oynika**

Ana slogan: **4 Oyun, Tek Uygulama!**

Destekleyici metin: **Arkadaşlarınla eğlence Oynika'da!**

Yayın hazırlığı için önerilen kısa metin: “Tabu, Sessiz Sinema, Aramızdaki Casus ve Ben Kimim? ile arkadaşlarınla eğlenceyi başlat!” Dört oyun da oynanabilir; mağaza yayını, hak incelemesi ve yayın cihaz doğrulaması bu görevlerin dışında kalır.

Mevcut App Store metadata/fastlane dosyası bulunmuyor. App Store Connect üzerinde işlem yapılmadı. Mağaza açıklaması ve yayın ekran görüntüleri ayrı yayın hazırlığı aşamasına bırakıldı.

Kaldırılan oyunun enum kaydı, beşinci kartı ve yalnızca ona ait PNG kaldırıldı. Ayrı controller, model veya veri dosyası bulunmuyordu. Genel `/games/:game` yönlendiricisi katalogda bulunmayan adresleri `/games` listesine gönderir. Git geçmişi korunur.

## Değişen dosyalar ve doğrulama

- `lib/features/games/domain/party_game.dart`: Dört kayıt, sıra, kısa açıklamalar, oynanabilirlik ve katalogdan türetilen metinler.
- `lib/shared/widgets/game_collection.dart`: İki sütunlu katalog tabanlı grid; beşinci yatay kart kaldırıldı.
- `lib/features/home/presentation/home_screen.dart`: Güncel oynanabilirlik metni.
- `lib/features/home/presentation/widgets/home_header.dart`: Destekleyici metin ve okunabilir satır genişliği.
- `lib/features/home/presentation/widgets/party_banner.dart`: Dinamik ana slogan ve illüstrasyonla çakışmayan metin genişliği.
- `lib/features/games/presentation/games_screen.dart`: Katalogdan gelen durum metni.
- `lib/features/settings/presentation/settings_screen.dart`: Dört oyunluk hakkında ve mevcut geliştirme durumu.
- `test/widget_test.dart`: Dört kartın sırası, açıklamalar, sloganlar, iki tema, kaldırılan adres ve mevcut akış kontrolleri.
- `README.md`, `assets/README.md`: Güncel ürün ve asset bilgileri.
- Bu dosya: V1 kapsamı ve Ben Kimim? durum raporu.
- Kaldırıldı: `assets/illustrations/never_have_i_ever.png`.

`flutter analyze` temiz, `flutter test --concurrency=1` ile 152 test başarılı, `flutter build apk --debug` başarılı. APK arşivinde kaldırılan asset'in bulunmadığı kontrol edildi. Pixel 3'te her iki temada native oyun listesinde doğru sırayla tam dört kart doğrulandı.

Yerel ekran görüntüleri `build/v1-four-games/` altında: `pixel-home-top-light.png`, `pixel-home-top-dark.png`, `pixel-home-light.png`, `pixel-home-dark.png`, `pixel-games-light.png`, `pixel-games-dark.png`. Bu klasör Git tarafından ignore edilir.
