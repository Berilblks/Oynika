# Oynika — App Store üretim yapılandırması denetimi

Tarih: 13 Kasım 2026 · Windows üzerinde kaynak/config denetimi

## Sonuç ve kapsam

Varsayılan **release** reklam seçimi üretim birimini kullanıyor. QA ekranı normal yapılandırmada erişilemez; gerekli UMP kontrolleri korunuyor. `pubspec.yaml` **0.1.0+4 → 0.1.0+5** olarak güncellendi. Oyun kodu, tasarım, reklam sıklığı, SDK sürümleri, reklam kimlikleri veya izinler değiştirilmedi.

Bu rapor kod seçimini doğrular; Codemagic üretim argümanları, AdMob paneli ve oluşturulacak üretim IPA'sı incelenmedi. Bu nedenle yayın için koşulsuz onay değildir. Kullanıcının Build 4 iPhone testi kabul edildi; bu görevde yeni bir fiziksel iPhone testi/derlemesi yapılmış gibi raporlanmaz.

## 1. iOS reklam kimlikleri

| Alan | Mevcut değer | Denetim |
|---|---|---|
| Bundle ID | `com.oynika.app` | Runner Debug/Profile/Release aynı |
| AdMob iOS App ID | `ca-app-pub-8170413007027196~9161134058` | Info.plist; üretim biçimi, Google örnek App ID'si değil |
| iOS üretim interstitial | `ca-app-pub-8170413007027196/3293392996` | Normal release seçimi |
| iOS resmî test interstitial | `ca-app-pub-3940256099942544/4411468910` | Debug/profile veya açık test seçeneği |
| Google Mobile Ads Flutter | `google_mobile_ads 9.2.0` | Sürüm değiştirilmedi |
| Native GMA bağımlılık aralığı | `Google-Mobile-Ads-SDK ~> 13.11` | Kurulu Flutter eklentisinin podspec'inden okundu |

App ID ile reklam birimi aynı yayıncı önekini kullanıyor. Ancak kimliklerin panelde doğru iOS uygulamasına ait olduğu, uygulama onayı/reklam sunum durumu ve arabuluculuk/teklif veren ayarları yalnızca kaynak koddan doğrulanamaz. Panelde bu iki değerin `com.oynika.app` iOS kaydıyla eşleşmesi yayın öncesinde kontrol edilmelidir. Birim türü App ID ile karıştırılmamış.

## 2. Release, QA ve test seçimi

`ad_units.dart` içindeki üretim koşulu `release && !testMode && !qa`. `google_ads_backend.dart` bunu `kReleaseMode` ve derleme sabitleriyle çağırıyor.

| Yapılandırma | iOS birimi | QA erişimi |
|---|---|---|
| Release; iki reklam flag'i yok/false; test cihazı listesi boş | Üretim | Kapalı |
| Debug/profile, flag yok | Google test | QA flag'i yoksa kapalı |
| Release; `OYNIKA_ADS_QA=true` | Google test | Açık |
| Release; `OYNIKA_ADS_TEST_MODE=true` | Google test | QA flag'ine bağlı |
| Release; `OYNIKA_ADMOB_TEST_DEVICE_IDS` boş değil | Google test | QA flag'ine bağlı |

**Önemli:** Sadece `OYNIKA_ADS_QA` ve `OYNIKA_ADS_TEST_MODE` seçeneklerini kaldırmak, üçüncü test cihazı değişkeni doluysa yeterli değildir. `OYNIKA_ADMOB_TEST_DEVICE_IDS` de üretim Dart argümanlarında bulunmamalı/boş olmalı. `OYNIKA_UMP_DEBUG_EEA` kodda yalnızca debug modunda etkilidir; üretim iş akışından kaldırılması temiz yapılandırma sağlar.

QA menü girdisi flag kapalıyken çizilmez; `/qa/ads` rotası `/settings` adresine yönlenir ve QA widget'ı kendi içinde de flag kontrolü yapar. QA tanı nesnesi yalnızca QA flag'i açıkken oluşturulur. Normal release'te gerçek birim seçimi ve kapalı QA yolu mevcut otomatik testlerle kontrol edilir. Test kimliklerinin kaynakta bulunması debug/QA için gereklidir; üretimde seçildikleri anlamına gelmez. Derlenmiş IPA'nın içinde hiç test-ID metni bulunmadığı iddia edilmez.

Codemagic Workflow Editor ayarları veya uzak environment/dart-define değerleri repoda bulunmadığı için denetlenemedi. Üretim workflow'u QA/test argümanlarından arındırılmalı; build **release** olmalı. Mac/Codemagic için temel komut:

```sh
fvm flutter build ipa --release --build-name=0.1.0 --build-number=5
```

Bu komut burada çalıştırılmadı. Workflow ayrıca eski `--build-number=4` geçirmemeli.

## 3. UMP ve reklam akışı

Başlangıçta `requestConsentInfoUpdate`, ardından gerekli form için `loadAndShowConsentFormIfRequired` çağrılır. SDK izin verirse Mobile Ads başlatılır; ön yükleme ve gösterim öncesinde `canRequestAds` yeniden kontrol edilir. Güncelleme hatası otomatik rıza sayılmaz; SDK'nın önceki geçerli durumuyla verdiği sonuç kullanılır. İlk güncelleme yoksa izin varsayılmaz. [Google UMP akışı](https://developers.google.com/admob/flutter/privacy)

`PrivacyOptionsRequirementStatus.required` durumunda Ayarlar → Gizlilik ve Yasal altında **Reklam gizlilik seçenekleri** görünür. Yeniden açma çağrısı `showPrivacyOptionsForm` kullanır. Gerekmiyorsa seçenek gizlidir; Türkçe/İngilizce politika bağlantıları bundan bağımsızdır. Türkiye'de form görülmemesi tek başına hata değildir.

Gizlilik/SDK hataları oyun ekranını engellemez; mevcut zaman aşımı, kontrollü yeniden deneme ve reklam yokken beklemeden ilerleme korunur. `canRequestAds=true`, kişiselleştirilmiş reklama rıza verildiği şeklinde yorumlanmaz. ATT ayrı mekanizmadır.

Banner yok. Dört oyun ortak `AdsService` kullanır; tamamlanan tur geçişleri, kapanış sonrası 90 saniye aralığı, aynı tur/final için tek fırsat ve erken çıkışta reklam göstermeme mantığı bu görevde değiştirilmedi. QA manuel gösterimleri sayacı artırmaz. iOS istekleri `AdRequest(nonPersonalizedAds: true)`, Android istekleri mevcut varsayılan davranışla devam eder.

## 4. Info.plist, izinler ve privacy manifest

- `GADApplicationIdentifier` mevcut. **50 benzersiz SKAdNetwork kaydı**, 13 Kasım 2026 tarihinde Google'ın güncel listesinden çekilen 50 kayıtla bire bir eşleşti; eksik/fazla kayıt yok. [Google iOS gizlilik stratejileri](https://developers.google.com/admob/ios/privacy/strategies)
- iOS hedefi 15.0; Runner build numarası ve sürümü Flutter değişkenlerinden alınır. Gereksiz ATS istisnası veya WKAppBoundDomains kısıtı bulunmuyor.
- Tek NS kullanım açıklaması `NSMotionUsageDescription`; Ben Kimim? hareket kontrolünü açıklıyor. Kamera, mikrofon, konum, kişiler veya fotoğraf kitaplığı izni eklenmedi. IP'den konum çıkarımı için GPS izni varmış gibi raporlanmaz.
- Oynika kodunda `ATTrackingManager` istemi/IDFA okuması ve Info.plist'te `NSUserTrackingUsageDescription` yok. Mevcut kişiselleştirilmemiş iOS stratejisi için rastgele ATT açıklaması/penceresi eklenmedi.
- Bu durum, tüm üçüncü taraf zincirinin Apple tanımında takip yapmadığını tek başına kanıtlamaz. Apple'ın takip kapsamındaki işleme varsa ATT gereklidir. Nihai panel/SDK davranışı doğrulanmadan App Store Connect'te kesin “takip yok” kararı verilmemeli. [Apple takip kuralları](https://developer.apple.com/app-store/user-privacy-and-data-use/)
- Google'ın publisher first-party ID özelliği varsayılan açık; uygulamada kapatıldığına dair çağrı yok. Bu, IDFA ile aynı şey değildir. Mevcut NPA stratejisiyle SDK/panel etkileşimi yayın kararı kapsamında incelenmeli; denetim amacıyla sessizce kapatılmadı. [Google açıklaması](https://developers.google.com/admob/ios/privacy/strategies#publisher_first-party_id)
- Repoda `ios/Podfile.lock`, Pods/native GMA binary manifesti veya Runner'a ait `.xcprivacy` yok. Bu tek başına manifest hatası kanıtı değildir. Yerel pub cache'te sensors_plus, package_info_plus, url_launcher_ios ve webview_flutter_wkwebview manifestleri bulundu; bu wrapper manifestleri takip/veri toplamayı false/boş beyan ediyor. Bu beyanlar GMA native SDK'sının davranışı yerine kullanılamaz.
- GMA'nın güncel veri açıklaması 13.12.0 içindir ve SDK manifest desteğini açıklar. Tam native GMA/UMP sürümü ile manifest birleşimi, **gerçek arşiv/Podfile.lock ve Xcode Privacy Report** üzerinden kontrol edilmelidir; tahmini reason-code veya boş “uyumluluk” manifesti eklenmedi. [GMA veri açıklaması](https://developers.google.com/admob/ios/privacy/data-disclosure)

## 5. Politika ve destek

- Türkçe: https://berilblks.github.io/Oynika/privacy.html
- İngilizce: https://berilblks.github.io/Oynika/privacy-en.html
- İkisi de **HTTP 200**; indirilen içerik, yerel HTML'lerle satır sonları normalleştirildiğinde aynı.
- Geliştirici Beril Bölükbaşı ve destek `support.berilapps@gmail.com` doğru. Uygulamadaki merkezi AppLinks değerleri sayfalarla aynı; mailto konusu `Oynika - Destek Talebi`.
- Politika iOS NPA isteğini, Android farkını, Google üçüncü taraf işlemesini, UMP önceki durumunu ve koşullu tercih erişimini açıklıyor. Destek yazışmaları için çözüldükten sonra en fazla 6 ay hükmü Google reklam verilerine uygulanmıyor. Bu aşamada politika metni değiştirilmedi.

## 6. App Store Connect gizlilik beyanı çalışma tablosu

**Nihai form doldurulmadı.** Aşağıdaki SDK başlıkları mevcut kod ile Google'ın veri açıklamasından çıkarılan inceleme adaylarıdır; gerçek arşiv/panel üzerinden sonlandırılmalıdır. Google'ın rehberinde reklam/analiz işlevleri için şu gruplar yer alır: [SDK veri açıklaması](https://developers.google.com/admob/ios/privacy/data-disclosure).

| Veri başlığı | İncelenecek SDK davranışı |
|---|---|
| Identifiers / Device ID | IDFA uygunluğu; uygulama/geliştirici kapsamlı diğer tanımlayıcılar |
| Usage Data / Advertising Data | Reklam gösterimi ve etkileşim ölçümleri |
| Usage Data / Product Interaction | Uygulama açılışı, tıklama/video etkileşimi |
| Diagnostics / Crash Data | SDK hata/çökme bilgisi |
| Diagnostics / Performance Data | Açılış, takılma ve enerji ölçümleri |
| Location / Coarse Location | IP kaynaklı yaklaşık konum; GPS izni bulunmaması bu başlığı tek başına dışlamaz |

Amaç alanlarında Third-Party Advertising, Analytics ve ilgili güvenlik/tanılama için App Functionality değerlendirilir. “Kullanıcıya bağlı” ve “takip için kullanılır” alanları tek bir genel cevapla kapatılmadı. Hesap sistemi bulunmaması cihazla ilişkilendirmeyi dışlamaz. [Apple veri türleri ve amaçları](https://developer.apple.com/app-store/app-privacy-details/)

Oyun adları/puanlar ve ham hareket verileri kodda yalnızca cihazda işlenir; sunucuya gönderilmez. Yerel işleme Apple'ın veri toplama tanımından ayrıdır. Ayrı Firebase Analytics/Crashlytics bağımlılığı görülmedi; buna rağmen reklam SDK'sının kendi analiz/tanılama işlemleri dışlanamaz.

Destek e-postası gönüllü kullanıcı iletişimidir. Email Address/Customer Support ve App Functionality başlıkları değerlendirilmelidir; Apple'ın isteğe bağlı beyan istisnası ancak bütün koşulları sağlanıyorsa kullanılabilir. Nihai bağlılık/takip ve istisna kararları geliştirici tarafından doğrulanmalı. [Apple App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)

## 7. Yayın öncesinde kalan dış doğrulamalar

1. Üretim Codemagic workflow'unda QA/test/test-cihazı Dart argümanlarının temizliği ve build numarası 5.
2. AdMob panelinde App ID/reklam birimi eşleşmesi, iOS UMP mesajları (ATT istemeyen stratejiyle uyum), reklam sunum onayı ve varsa mediation/teklif veren davranışı.
3. Gerçek native SDK sürümleri ve birleşik privacy manifest/report. Windows kaynak denetimi Xcode archive doğrulaması yerine geçmez.
4. Bu bilgilerle App Store Connect veri türü/amaç/bağlılık/takip beyanlarının sonlandırılması. ATT gerektiren işleme tespit edilirse çözülmeden yayınlanmamalı; yalnızca plist'e izin metni eklemek yeterli değildir.

Bunlar doğrulanmadığından gerçek reklam biriminin sunum yapacağı veya final “takip yok” beyanının kesin doğru olduğu iddia edilmez. Gereksiz izin eklenmedi; oyun/reklam davranışı bu denetimde değiştirilmedi.

## 8. Doğrulama ve değişen dosyalar

- `pubspec.yaml`: 0.1.0+5.
- `docs/appstore_production_audit.md`: bu rapor.
- İlgili mevcut testler: üretim birimi seçimi, QA/test override'ları, QA rota/menu erişimi, UMP başarısızlığı ve önceki durum, gizlilik tercihleri, politika/destek bağlantıları, tur geçişleri ve 90 saniye aralığı.
- `fvm flutter analyze`: **No issues found**.
- `fvm flutter test`: **462 test başarılı**.
- `git diff --check`: başarılı.

Commit veya push yapılmadı. Önceden mevcut `.vs/` korunur; yeni build çıktısı veya sertifika oluşturulmadı. Yeni Mac/Xcode/iPhone/Codemagic testi veya App Store Connect yüklemesi yapılmadı.
