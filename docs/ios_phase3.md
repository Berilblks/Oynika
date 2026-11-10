# Oynika | iOS Faz 3

10 Kasım 2026 · Windows statik denetimi ve Flutter testleri

## iOS ve AdMob yapılandırması

| Kontrol | Sonuç |
| --- | --- |
| Flutter ve iOS hedefi | FVM 3.38.10. Podfile, Runner proje ayarları ve Flutter framework plist dosyasında iOS 15.0. RunnerTests proje hedefini devralıyor. Podfile, alt hedefleri 15.0'a çıkaran mevcut post-install kuralını içeriyor. |
| Uygulama kimliği | Runner Info.plist içindeki iOS GADApplicationIdentifier değeri ca-app-pub-8170413007027196~9161134058. Paneldeki uygulama eşleşmesi ve yayın durumu cihaz testiyle doğrulanmalı. |
| SDK | Dart tarafında google_mobile_ads 9.2.0 sabit. Eklentinin iOS podspec dosyası Google-Mobile-Ads-SDK ~> 13.11 istiyor ve eklenti hedefi iOS 13.0. Kesin native Google Mobile Ads ve UMP sürümleri Mac'te pod install sonrasında Podfile.lock üzerinden doğrulanacak. |
| SKAdNetwork | Google'ın iOS gizlilik kılavuzundaki 50 benzersiz kimlik Info.plist'e eklendi. Python plistlib ile XML, kimlik biçimi, benzersizlik, mevcut App ID ve iOS hedefleri doğrulandı. Bu liste, SDK aracılık adaptörü kurulduğu anlamına gelmez. |
| Reklam birimi | iOS debug/profile ve release QA, Google test geçiş birimini kullanıyor. Normal iOS release mevcut üretim geçiş birimini kullanıyor. Android reklam kimlikleri ve istek parametreleri korundu. Banner yok. |

[Google iOS SDK kurulumu](https://developers.google.com/admob/ios/quick-start) · [SKAdNetwork listesi](https://developers.google.com/admob/ios/privacy/strategies)

## ATT ve IDFA kararı

Bu fazda ATT istemeyen, kişiselleştirilmemiş iOS reklam yapılandırması seçildi. iOS geçiş isteklerinde eklentinin nonPersonalizedAds seçeneği etkin. Eklentinin yerel iOS kodu bu seçeneği Google reklam isteğine npa=1 olarak aktarıyor. Oynika kodu ATT çağrısı yapmıyor, IDFA okumuyor ve Info.plist'e NSUserTrackingUsageDescription eklenmedi. SKAdNetwork, IDFA olmadan kurulum ilişkilendirmesi için kullanılabiliyor.

Apple, IDFA erişimi veya Apple tanımına giren uygulamalar arası takip için ATT yetkilendirmesi istiyor. Kişiselleştirilmemiş reklam isteği tek başına SDK ve reklam ortaklarının takip yapmadığının kanıtı değildir. AdMob panelinde iOS için IDFA açıklama mesajının kapalı olduğunu, aracılık ve isteğe bağlı veri işleme ayarlarını kontrol et. Takip yapan bir SDK veya ortak doğrulanırsa yayından önce o davranışı kaldır ya da takip başlamadan önce ayrı bir ATT akışı tasarla. ATT yetkisi olmadığında iOS erişilebilir bir IDFA sağlamaz. Yayın adayında bunun cihaz ve SDK sinyalleriyle doğrulanması bekliyor.

UMP, bölgesel reklam rızasını yönetir. UMP seçimi ATT yetkisi vermez. Kişiselleştirilmemiş istek de UMP kontrolünü atlamaz. Apple'ın ATT reddi, ileride ATT eklenirse, oyuna erişimi kısıtlamamalı. [Apple kullanıcı gizliliği ve veri kullanımı](https://developer.apple.com/app-store/user-privacy-and-data-use/) · [Google IDFA mesajı](https://developers.google.com/admob/flutter/privacy/idfa) · [Google reklam sunum modları](https://developers.google.com/admob/ios/privacy/ad-serving-modes)

## UMP denetimi

- Ortak servis ilk kareden sonra UMP durumunu günceller. Başarılı güncelleme sonrası SDK'nın gerekli gördüğü formu açar. Bölge ve önceki seçimle birlikte ilgili AdMob mesajının doğru iOS App ID için yayımlanmış olması belirleyicidir.
- Ayarlar'daki Reklam gizlilik seçenekleri, UMP gerekli olduğunu bildirdiğinde görünür. Form açılırken eldeki geçiş reklamı atılır. Form dönüşünde SDK uygunluğu tekrar değerlendirilir.
- Reklam başlatma ve yükleme öncesinde canRequestAds() kontrol edilir. UMP ret seçiminden sonra dönen true, kişiselleştirme rızası olarak kullanılmaz. Google, rıza sinyallerine göre reklamı sınırlayabilir veya sunmayabilir.
- Çevrimdışı güncelleme ya da başlangıç formu hatasında uygulama çalışır. Yalnızca SDK önceki duruma göre izin verirse reklam isteği yapılabilir. Geçerli önceki durum yoksa reklam isteği gönderilmez. Hazır reklam yoksa sonuç ekranından geçiş beklemez.
- Bu fazda iOS davranışı kod ve ortak servis testlerinden incelendi. Yerel UMP formu, iOS ret/onay seçenekleri ve gizlilik formunun cihazda yeniden açılması Mac aşamasında doğrulanacak.

[Google Flutter UMP kılavuzu](https://developers.google.com/admob/flutter/privacy)

## App Store Connect gizlilik taslağı

Bu tablo doğrulama listesidir. Google'ın genel SDK beyanı 13.12.0 içindir. Son arşivdeki SDK sürümünü ve etkin özellikleri esas al.

| Aday veri | Kod veya SDK kanıtı | App Store Connect'te doğrulanacak |
| --- | --- | --- |
| Oyuncu ve takım adları, skorlar, oyun durumu ve tema | Oyunda yerel kullanım. Hesap, geliştiriciye veri gönderme, ayrı analitik veya crash reporting SDK'sı bulunmadı. | App Store'un toplama tanımına göre cihaz dışına çıkmadığını yayın adayıyla doğrula. |
| Ham hareket verisi | Ben Kimim? hareketi cihazda işler. Oyun kodunda sensör verisini kaydetme veya gönderme yolu görülmedi. | Sensör iznini reklam ve hareket verisi beyanından ayrı değerlendir. |
| Tanımlayıcılar | Oyun kodu IDFA okumuyor. Google SDK başka uygulama veya geliştirici kapsamlı tanımlayıcılar işleyebilir. Google'ın varsayılan publisher first-party ID ayarı ayrıca incelenmeli. | Device ID kullanım amacını, ilişkilendirme durumunu ve takip kullanımını arşiv ve SDK sinyalleriyle doğrula. |
| Kullanım verileri | Google, reklam gösterimleri ve reklam ya da ürün etkileşimleri işleyebildiğini belgeliyor. | Advertising Data, Product Interaction ve ilgili kullanım amaçlarını doğrula. Ayrı Firebase Analytics bulunmaması SDK ölçümünü ortadan kaldırmaz. |
| Tanılama | Google, çökme günlükleri ve performans verileri işleyebilir. | Crash Data ve Performance Data alanlarını ayrı değerlendir. Google, performans verisinin kullanıcıyla ilişkilendirilebildiğini belirtiyor. |
| IP ve yaklaşık konum | Google, IP'den yaklaşık konum çıkarabileceğini belgeliyor. Oynika'da konum izni isteme akışı görülmedi. | Coarse Location, ilgili amaçlar ve SDK ayarlarını doğrula. |
| Üçüncü taraflar, takip ve ilişkilendirme | Google Mobile Ads ve UMP üçüncü taraf hizmetleridir. Kaynakta ayrı aracılık adaptörü görülmedi. Paneldeki alıcılar ve veri işleme ayarları bu ortamdan doğrulanmadı. | Her veri türü için toplama, kullanım amacı, kullanıcıyla ilişkilendirme ve takip alanlarını ayrı doldur. Hesap veya ATT penceresi olmaması, ilişkilendirme veya takip alanlarını kendiliğinden belirlemez. |

Türkçe ve İngilizce yayımlanmış politika metinleri korunuyor. Yayın öncesinde UMP hatasında önceki SDK durumunun kullanılabildiğini ve iOS isteklerinin kişiselleştirilmemiş olduğunu her iki dildeki metne yansıt. Son SDK ve panel davranışıyla politika ve App Store Connect yanıtlarını eşleştir. [Google SDK veri beyanı](https://developers.google.com/admob/ios/privacy/data-disclosure) · [Apple App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/) · [Apple üçüncü taraf SDK gereksinimleri](https://developer.apple.com/support/third-party-SDK-requirements/)

## Mac ve Xcode yayın kontrolü

1. FVM sürümünü kullanarak fvm flutter pub get çalıştır. ios altında pod install çalıştır ve Runner.xcworkspace dosyasını aç. Podfile.lock ile GoogleMobileAds, UMP ve varsa reklam adaptörlerinin gerçek sürümlerini kaydet.
2. Xcode ile simülatör derlemesi, RunnerTests ve imzalı iPhone derlemesi yap. Uygulama hedefi, pod hedefleri ve arşivdeki Info.plist içinde iOS 15.0, App ID ve SKAdNetwork öğelerini doğrula.
3. Google test birimiyle iPhone'da AEA formunu, izin ve ret seçeneklerini, tercihleri yeniden açmayı, form gerekmeyen açılışı ve reklam sonrası navigasyonu dene. Temiz çevrimdışı açılışı ve önceki SDK durumu olan çevrimdışı açılışı ayrı dene. ATT penceresi çıkmadığını ve test isteklerinde IDFA kullanılmadığını doğrula.
4. App Store arşivinde SDK imzalarını, PrivacyInfo.xcprivacy dosyalarını, required-reason API beyanlarını ve Xcode Organizer gizlilik raporunu incele. Yerel sensör ve WebView paket kaynaklarında manifest mevcut. Google Ads ve UMP manifestlerinin arşive dahil edildiği Windows'ta doğrulanamadı.
5. AdMob paneli ve arşiv bulgularını karşılaştırarak veri beyanlarını ve iki dilli gizlilik politikasını tamamla. O zamana kadar App Store Connect'te kesin takip veya veri ilişkilendirme cevabı işaretleme. [Apple gönderim gereksinimleri](https://developer.apple.com/news/upcoming-requirements/)

## Doğrulama

- Windows'ta plist ve iOS hedeflerinin statik doğrulaması geçti.
- FVM üzerinden flutter analyze temiz. flutter test --concurrency=1 ile 393 test geçti.
- Native iOS derlemesi, XCTest, Xcode arşivi ve iPhone testi bekliyor.
