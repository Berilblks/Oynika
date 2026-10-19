# Dış beyaz çerçeve düzeltmesi

Kullanıcı ana ekran logosunun ve uygulama ikonunun dış beyaz çerçevesinin kaldırılmasını istedi. Orijinal assets/branding/oynika_logo.png korunur. Arayüz ve renkli ikonlar assets/branding/oynika_logo_borderless.png dosyasını kullanır.

İç krem zemin ve renkli desenler korunur. Android adaptive katmanında görünür alan daha fazla doldurulur; arka plan beyaz yerine logo ile uyumlu kremdir. iOS ikonları krem zeminle RGB olarak düzleştirilir; alpha kanalı eklenmez. Splash görsellerinin üretim kaynağı değiştirilmedi.

Araç: yerleşik image_gen. İlk çıkarımın dış kenarındaki beyaz parçalar için ikinci bir temizleme düzenlemesi yapıldı.

## İlk düzenleme prompt'u

Use case: background-extraction. Edit target: attached approved Oynika logo. Remove ONLY the exterior white canvas/frame surrounding the rounded-square logo tile, make that exterior truly transparent, and tightly frame the existing tile with essentially no padding. Keep the entire cream interior, all coral/yellow/lilac corner fields, exact dark purple Oynika lettering, smile, confetti, colors, proportions, gradients, and positions unchanged. This is surgical background extraction, not a redesign. Do not remove the cream inside the logo. No white outer stroke, white matte, border or halo. Output square transparent PNG.

## Kenar temizleme prompt'u

Use case: background-extraction. Edit this Oynika logo cutout ONLY to clean its outside boundary. The first cutout has unwanted stray white fragments above, below, and beside the rounded-square tile. REMOVE ALL OF THOSE WHITE FRAGMENTS and all outside pixels. Every pixel outside the single smooth rounded-square tile silhouette must have alpha zero. Crop tightly to the tile's bounds; tile should fill the square canvas edge to edge with only transparent rounded corners. Preserve the tile interior exactly: cream background, all colorful corner fields, Oynika lettering, smile and confetti, same colors, shapes and positions. NO redesign, no new text, no edge stroke, no white border, no halo, no extra exterior pixels. Genuine transparent PNG.

Arka plan çıkarımından kalan dış mat parçalarının dağıtılan assetlere taşınmaması için üretim betiği, kesiti temiz yuvarlatılmış bir çizim sınırından geçirir. Ara kesit design_reference/oynika_logo_cutout.png içinde, uygulamanın kullandığı sonuç assets/branding/oynika_logo_borderless.png içindedir. Orijinal onaylı kaynak değiştirilmez.
