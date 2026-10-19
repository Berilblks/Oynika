# Görsel kaynakları

## Referans
Kullanıcının onayladığı tasarım: ../design_reference/home_screen.png. Bu dosya yalnızca referanstır; uygulamanın asset manifestine eklenmedi.

## İllüstrasyonlar
assets/illustrations/ altındaki altı şeffaf PNG, 18 Ekim 2026 tarihinde yerleşik image_gen aracıyla bu proje için üretildi. Referans yalnızca stil ve kompozisyon rehberi olarak kullanıldı. Rastgele internet görseli indirilmedi.

Ortak üretim prompt'u:

> Use case: stylized-concept. Asset type: transparent PNG illustration for the Oynika Flutter party app. Input image is STYLE REFERENCE ONLY, not a target to edit. Match its polished soft 3D clay render, rounded friendly forms, studio lighting, pastel colors. Actual transparent background, isolated subject, no text, no UI, no panels, no phone, no watermark. Fill canvas with subject and a small transparent margin.

Her prompt'a eklenen Subject bölümü:

- friends.png: Three joyful young adult friends laughing together, two women and one man. Woman left in lilac sweater raising her hand, curly-haired man middle in cream tee, long dark-haired woman right wearing coral. Waist-up tightly grouped portrait, lively happy expressions, friendly inclusive party mood. Similar composition to friends in reference. Entire raised hand and faces visible. Single isolated group.
- taboo.png: One glossy pink-coral speech balloon with three small cream dots, slightly tilted, tiny coral celebratory strokes beside it. A sculptural toy-like icon, large and centered.
- charades.png: One purple and cream cinema clapperboard with open diagonal striped top, softly rounded, slight three-quarter perspective, tiny amber and lavender accent strokes beside it. A sculptural toy-like icon, large and centered.
- who_am_i.png: One ivory square card with softly rounded corners, tilted slightly, thick raised purple question mark, little amber decorative strokes beside it. A sculptural toy-like icon, large and centered.
- five_seconds.png: One mint turquoise stopwatch with ivory clock face, coral hand, tiny mint hour ticks, rounded turquoise button on top, tiny coral celebratory strokes beside it. A sculptural toy-like icon, large and centered.
- never_have_i_ever.png: Two cute laughing speech balloons with friendly closed smiling eyes, one pink left and one violet right, overlapping like two friends. Little coral accent strokes above. A sculptural toy-like icon, large and centered.

Uygulama bu dosyaları yerel olarak yükler; çalışma zamanında görüntü üretim servisine bağlanmaz.

## Yazı tipi
Nunito variable font, Google Fonts resmi deposundan alındı:

- https://github.com/google/fonts/tree/main/ofl/nunito
- Dosya: fonts/Nunito-Variable.ttf
- Lisans: fonts/OFL.txt (SIL Open Font License 1.1)

Nunito lisansı uygulamanın Açık kaynak lisansları ekranına da kaydedilir. Yazı tipi paket veya ağ bağlantısı gerektirmez.

## Diğer çizimler
Mor organik panel CustomPainter ile oluşturuldu. Faz 2.1 resmî logo ve native ikon ayrıntıları branding/README.md içindedir. Ayarlar, oklar ve alt navigasyon Flutter Material Icons kullanır.
