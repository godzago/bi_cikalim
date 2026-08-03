---
status: resolved
trigger: "bottom overflow hataları var onları düzelt"
created: 2026-08-03
updated: 2026-08-03
---

# Symptoms

- expected: 320–599 px genişlikte ve 1.0/1.3/1.5 yazı ölçeğinde hiçbir alt taşma olmaması.
- actual: Responsive compact refactor sonrasında bazı bileşenlerde bottom overflow oluşuyor.
- errors: Keşfet header satırında 17 px yatay taşma; sabit Explore kart yüksekliklerinde alt taşma riski; harita mekan kartı metadata satırında 62 px yatay taşma.
- timeline: Responsive compact UI refactor sonrasında bildirildi.
- reproduction: Sabit yükseklikli kartları ve dikey Column içeriklerini dar ekran + büyütülmüş yazıyla render et.

# Current Focus

- hypothesis: Sabit carousel/kart yükseklikleri, erişilebilirlik text scale ile büyüyen içerikten daha kısa kalıyor.
- test: Tüm sabit yükseklikli reusable kartları 320 px ve 1.5 text scale ile production constraints altında render et.
- expecting: En az bir RenderFlex overflow yakalanması.
- next_action: resolved
- reasoning_checkpoint: Gerçek ekran provider akışlarıyla 320 px / 1.5 text scale altında iki ayrı taşma üretildi ve düzeltmelerden sonra aynı akışlar kaydırılarak doğrulandı.
- tdd_checkpoint: regression tests passing

# Evidence

- `DiscoverScreen` üretim akışı uzun Türkçe mekan/aktivite/etkinlik adlarıyla 320x568 ve 1.5 text scale altında header `Row` için 17 px taşma üretti.
- Explore kartlarının dış yüksekliği 126–188 px'e küçültülmüşken cover alanları 76–126 px ve gövde içi `Spacer`/`Expanded` yapısı korunmuştu; büyüyen metin için dikey alan kalmıyordu.
- `MapScreen` seçili mekan kartı aynı koşullarda puan/yorum + konum metadata satırında 62 px yatay taşma üretti.
- Harita aksiyon butonlarının varsayılan yatay padding'i dar iki kolonlu satır için gereğinden büyüktü.

# Eliminated

- Global text scaling veya bütün sayfayı ölçekleme kullanılmadı.
- Sorun API/provider verisi ya da navigasyon akışından kaynaklanmıyordu.

# Resolution

- root_cause: Dar ekranlarda küçülen sabit kart/sheet ölçüleri ile erişilebilirlikte büyüyen metin aynı anda hesaba katılmamış; bazı yatay metadata ve header öğeleri de esnek alan paylaşmıyordu.
- fix: Explore grid kartları content-driven yapıldı; cover, padding ve font tokenları küçültüldü; compact header'da ikincil bildirim aksiyonu kaldırıldı; carousel ve map sheet'e text-scale-aware yükseklik payı eklendi; harita metadata satırı ve aksiyon butonları esnek/kompakt hale getirildi.
- verification: `flutter analyze` temiz; tüm 23 test geçti. Üretim `DiscoverScreen` ve `MapScreen` akışları 320x568, text scale 1.5 ve uzun Türkçe içerikle ayrı regresyon testlerinden geçti. Ortak kart matrisi 320/360/390/430/480 px ve 1.0/1.3/1.5 ölçeklerini kapsıyor.
- files_changed: `lib/features/discover/presentation/screens/discover_screen.dart`, `lib/features/map/presentation/screens/map_screen.dart`, `test/responsive_widgets_test.dart`
