# Ayarlar, gizlilik ve hakkında — App Store hazırlığı

Tarih: 11 Kasım 2026

## Tamamlananlar

- Ayarlar'a **Gizlilik ve Yasal** bölümü eklendi. Gizlilik Politikası her derlemede görünür ve Türkçe GitHub Pages sayfasını sistemin dış tarayıcısında açar. Metin uygulamaya kopyalanmadı.
- Türkçe/İngilizce URL'ler, destek e-postası ve konu `AppLinks` içinde merkezileştirildi. İngilizce bağlantı ilerideki dil desteği için saklanır; bu fazda dil seçimi eklenmedi.
- Destek ve İletişim, `mailto:support.berilapps@gmail.com` ve `Oynika - Destek Talebi` konusu ile sistemin e-posta uygulamasını açar. Gönderim otomatik yapılmaz.
- URL açma false dönerse veya platform hatası oluşursa SnackBar gösterilir. E-posta hata mesajı destek adresini de içerir. Ekran/navigasyon çalışmaya devam eder.
- Hakkında sloganı **Eğlence Bir Araya Getirir!** olarak değiştirildi. İstenen açıklama kullanılır; oyun adları `PartyGame.values` üzerinden üretilir ve yeni katalog oyunları eklendiğinde metin kendiliğinden güncellenir.
- Sürüm/build, `PackageInfo.fromPlatform()` ile kurulu paketten alınır. Ayarlar ve açık kaynak lisansları aynı değeri kullanır. Mevcut pubspec `0.1.0+2` için beklenen gösterim **Sürüm 0.1.0 (2)**. Kodda sürüm sabiti yoktur. Yükleme/hata durumları ayrı metinlerle karşılanır.
- QA ekranı ve `OYNIKA_ADS_QA` görünürlük koşulu korunur. Gizlilik politikası QA'dan bağımsızdır. UMP tarafından gerekli görülen reklam gizlilik seçenekleri aynı işlevle Gizlilik ve Yasal bölümünde bulunur.

## Bağımlılıklar ve platform davranışı

- `url_launcher: 6.3.2`: dış tarayıcı/e-posta uygulaması. `LaunchMode.externalApplication` kullanılır. `canLaunchUrl` ön sorgusu kullanılmaz; doğrudan açma denenip başarısızlık ele alınır. Bu nedenle sorgu görünürlüğü için Info.plist/AndroidManifest'e yeni scheme izinleri eklenmedi.
- `package_info_plus: 9.0.1`: platform paket sürümü/build bilgisi. Gereksiz bağımlılık yükseltmesi yapılmadı; mevcut kilit sürümleri korundu, yalnızca bu iki paket ve transitif gereksinimleri eklendi.
- Mevcut Flutter 3.38.10, iOS 15 hedefi ve Android Gradle/Kotlin sürümleri paket gereksinimleriyle statik olarak karşılaştırıldı. Native iOS/Android derlemesi bu görevde çalıştırılmadı.
- Resmî kaynaklar: [url_launcher](https://pub.dev/packages/url_launcher/versions/6.3.2), [package_info_plus](https://pub.dev/packages/package_info_plus/versions/9.0.1).

## Değişen dosyalar — bu görev

- `lib/core/constants/app_links.dart` — yeni; merkezi bağlantı/iletişim bilgileri.
- `lib/core/utils/external_links.dart` — yeni; test edilebilir dış URL açma provider'ı.
- `lib/core/utils/app_package_info.dart` — yeni; asenkron paket bilgisi ve sürüm etiketi.
- `lib/features/settings/presentation/settings_screen.dart` — yasal/destek seçenekleri, dinamik sürüm ve hata geri bildirimi.
- `lib/features/games/domain/party_game.dart` — yalnızca slogan ve katalogdan üretilen hakkında açıklaması; oyun kuralları/verileri değişmedi.
- `pubspec.yaml`, `pubspec.lock` — iki gerekli doğrudan bağımlılık ve çözümlenen transitif paketler.
- `test/settings_release_test.dart` — yeni; 16 test.
- `docs/settings_release.md` — bu rapor.

Önceki commit edilmemiş splash, iki satırlı hero sloganı, beyaz ok navigasyonu, reklam sıklığı, QA dokümantasyonu ve testleri korunur. Bu görev bunların dosyalarını değiştirmedi. Uygulama sürümü 0.1.0+2 olarak kaldı.

## Test ve kontroller

- Gizlilik ve destek aksiyonlarının gerçek URL açma adaptörüne ilettiği platform kanalı çağrıları yakalanarak doğru URL/e-posta/konu ve dış tarayıcı modu doğrulandı. Testler gerçek e-posta göndermez veya cihazda tarayıcı açmaz.
- URL açmanın false dönmesi ve exception üretmesi hem gizlilik hem destek için sınandı.
- Platform paket verisi testte **9.8.7 (123)** verilerek sabit sürüm kullanılmadığı, lisans sayfasının da aynı değeri aldığı doğrulandı.
- Paket bilgisi bekleme/hata durumu uygulamayı bozmadı.
- QA kapalı/açık iken politika erişimi, QA görünürlüğü ve UMP required durumunda tercihleri yeniden açma doğrulandı.
- 320/375/430 px genişliklerde açık/koyu tema, 2,5× sistem yazısı ve alt sekme navigasyonu overflow üretmedi.
- Türkçe ve İngilizce politika adresleri HTTP HEAD kontrolünde **200** döndürdü.
- `fvm flutter analyze`: **No issues found**.
- `fvm flutter test`: **442 test başarılı** (önceki 426 test + 16 yeni Ayarlar testi).
- `git diff --check`: başarılı; whitespace hatası yok.

## Kalan cihaz doğrulamaları

Bu aşamada fiziksel iPhone/Android cihaz, native derleme ve TestFlight testi yapılmadı. Yeni native plugin'ler için tam uygulama derlemesi gerekir; yalnızca hot reload yeterli değildir. Gerçek cihazda sistem tarayıcısı, e-posta uygulaması bulunan/bulunmayan durum ve kurulu paketin sürüm etiketi ayrıca kontrol edilmelidir. Windows'ta Mac/Xcode/iOS işlemleri yapılmış gibi raporlanmaz.

## Git

Commit/push yapılmadı. Önceden mevcut `.vs/` yerel klasörü korunur. Önceki geliştirmeler geri alınmadı; çalışma ağacı önceki faz ve bu görev değişikliklerini birlikte içerir. Reklam kimlikleri, UMP servis mantığı ve iOS yapılandırması bu görevde değiştirilmedi.
