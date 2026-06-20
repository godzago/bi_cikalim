# BiÇıkalım — AI Agent Project Guide

> Bu dosya, BiÇıkalım mobil uygulamasını geliştirecek AI agent / coding agent için ana proje bağlamıdır.  
> Agent bu dokümanı ürün, tasarım, teknik mimari, kapsam ve kalite kuralları için temel referans olarak kullanmalıdır.

---

## 1. Ürün Özeti

**Ürün adı:** BiÇıkalım  
**Ürün tipi:** Mobil aktivite ve mekan keşif platformu  
**Pilot şehir:** Eskişehir  
**Platform önceliği:** Android öncelikli mobil uygulama, ardından iOS  
**Ana teknoloji yönü:** Flutter + Firebase + Google Maps  
**Tasarım yönü:** Light theme, sıcak turuncu primary renk, sade rounded card yapısı, mobil-first deneyim

### 1.1 Tek Cümlelik Ürün Amacı

BiÇıkalım, kullanıcıların kendi şehirlerinde hangi mekanda hangi aktivite ve etkinlik olduğunu keşfedebildiği, mekanları puanlayıp yorumlayabildiği ve mekan sahiplerinin mekanlarını oluşturup yönetebildiği mobil odaklı bir platformdur.

### 1.2 Ana Kullanıcı Soruları

Uygulama şu sorulara cevap vermelidir:

- Bu akşam ne yapalım?
- Yarın ne yapsak?
- Nerede hangi aktivite yapılır?
- X aktivite veya oyun nerede oynanır?
- Bu akşam hangi mekanda ne var?
- 2 / 4 / 8 / +10 kişi toplandık, bize uygun ne var?
- Bir mekan aktivite açısından gerçekten iyi mi?
- Kullanıcılar o mekan ve aktivite deneyimini nasıl yorumlamış?

---

## 2. Ürün Pozisyonlaması

BiÇıkalım klasik bir mekan rehberi, blog sitesi veya yalnızca etkinlik listeleme uygulaması değildir.

Ana pozisyon:

> Aktiviteye göre mekan keşfi ve güncel etkinlik görünürlüğü sağlayan mobil platform.

### Kullanıcı için

Şehrinde nerede ne yapılır, BiÇıkalım’da keşfet.

### Mekan için

Sunduğun aktiviteleri ve etkinlikleri görünür yap, kullanıcılar seni BiÇıkalım’da bulsun.

### Platform için

Güvenilir mekan / aktivite datası oluşturan, güncel ve mobil-first keşif ağı.

---

## 3. MVP Kapsamı

MVP’nin odağı:

- Kullanıcıların şehirde aktiviteye göre mekan keşfetmesi
- Güncel etkinlikleri görmesi
- Mekan profillerindeki aktivite envanterini incelemesi
- Mekanları puanlayıp yorumlaması
- Mekan sahiplerinin mekan oluşturabilmesi
- Editör tarafından eklenen mekanların gerçek sahibi tarafından sahiplenilebilmesi
- Admin / editör onay ve moderasyon akışlarının çalışması

### 3.1 MVP’de Olacak Özellikler

#### Son kullanıcı tarafı

- Şehir seçimi
- Keşfet ana ekranı
- Aktivite kategorileri
- Alt aktivite / oyun bazlı arama
- Etkinlik listesi
- Etkinlik detayları
- Mekan profili
- Mekan aktivite envanteri
- Mekan puanlama
- Mekan yorum sistemi
- Favoriler / kaydedilenler
- Harita ekranı
- Kullanıcı profili

#### Mekan sahibi tarafı

- Mekan sahibi hesabı / işletme modu
- Yeni mekan oluşturma başvurusu
- Editör tarafından eklenen mekanı sahiplenme talebi
- Mekan bilgisi düzenleme
- Aktivite envanteri ekleme / düzenleme / silme
- Etkinlik oluşturma / düzenleme / iptal etme
- Yorumları görüntüleme
- Uygunsuz yorumu bildirme

#### Admin / editör tarafı

- Mekan oluşturma ve düzenleme
- Aktivite kategorisi yönetimi
- Aktivite yönetimi
- Etkinlik yönetimi
- Yeni mekan başvurusu onay / red
- Mekan sahiplenme talebi onay / red
- Yorum moderasyonu
- Kullanıcı ve rol yönetimi
- Raporlanan içerikleri inceleme
- Mekan değişiklik geçmişi

### 3.2 MVP Dışında Kalacak Özellikler

Aşağıdaki özellikler MVP’ye dahil edilmemelidir:

- Rezervasyon
- Ödeme
- Kupon / indirim sistemi
- Grup planı oluşturma
- Arkadaş daveti
- Oylama
- Chat / mesajlaşma
- Mekan abonelik ve premium ödeme sistemi
- Gelişmiş rozet / gamification
- AI öneri motoru
- Sadakat sistemi

> Kritik karar: Rezervasyon ve ödeme MVP dışındadır. İlk hedef güvenilir mekan-aktivite datası, mobil keşif deneyimi, yorum/puanlama ve mekan sahiplenme altyapısını çalışır hale getirmektir.

---

## 4. Aktivite ve Etkinlik Ayrımı

### Aktivite

Bir mekanda genel olarak bulunan, sürekli veya sık erişilebilir imkan/hizmettir.

Örnekler:

- Monopoly
- Tabu
- Catan
- Satranç
- Bilardo
- Bowling
- PS5
- Dart
- Karaoke
- Masa Tenisi
- VR
- Escape Room

### Etkinlik

Belirli günü ve saati olan organizasyon veya tekil programdır.

Örnekler:

- Quiz Night
- Catan Turnuvası
- Karaoke Gecesi
- Board Game Night
- Workshop
- FIFA Turnuvası
- Açık Mikrofon

---

## 5. Kullanıcı Rolleri ve Yetkiler

### 5.1 Normal Kullanıcı

Yetkiler:

- Uygulamayı giriş yapmadan gezebilir
- Mekan, aktivite ve etkinlik keşfedebilir
- Giriş yaptıktan sonra favorilere ekleyebilir
- Giriş yaptıktan sonra yorum ve puan verebilir
- Kendi yorumlarını görüntüleyebilir
- Mekan ekleme / sahiplenme başvurusu gönderebilir

### 5.2 Mekan Sahibi

Yetkiler:

- Yeni mekan başvurusu oluşturabilir
- Editör tarafından eklenen mekanı sahiplenebilir
- Onaylı mekanını düzenleyebilir
- Aktivite envanteri yönetebilir
- Etkinlik oluşturabilir / düzenleyebilir / iptal edebilir
- Yorumları görüntüleyebilir
- Uygunsuz yorum bildirebilir

### 5.3 Editör

Yetkiler:

- Mekan datası ekleyebilir
- Mekan ve aktivite bilgilerini güncelleyebilir
- Etkinlik datası ekleyebilir
- Veri kalitesini kontrol edebilir

### 5.4 Admin

Yetkiler:

- Tüm verilere erişebilir
- Başvuru ve sahiplenme taleplerini onaylayabilir / reddedebilir
- Kullanıcı rolleri yönetebilir
- Yorumları gizleyebilir / silebilir
- Mekanları askıya alabilir
- Admin loglarını görebilir

---

## 6. Veri Kaynağı, Güven ve Onay

BiÇıkalım’ın temel değeri güvenilir ve güncel mekan/aktivite datasıdır.

### 6.1 Veri Kaynağı Etiketleri

#### Editör Eklemesi

BiÇıkalım ekibi tarafından araştırılıp eklenen veridir.

Kullanıcıya mesajı:

> Bilgi platform tarafından girildi; mekan sahibi henüz doğrulamamış olabilir.

#### Onaylı Mekan

Mekan sahibi veya yetkilisi tarafından sahiplenilmiş ve doğrulanmış profildir.

Kullanıcıya mesajı:

> Bilgi mekan tarafından yönetiliyor ve daha güvenilir kabul edilir.

### 6.2 Yayın ve Onay Mantığı

- Yeni mekan ekleme: Mekan sahibi başvuru yapar, admin onayından sonra yayınlanır.
- Mekan sahiplenme: Var olan editör mekanında “Bu mekanın sahibi misiniz?” akışı başlar, admin onayı gerekir.
- Mekan düzenleme: Onaylı mekan sahibi temel bilgileri düzenleyebilir. Kritik alanlar admin onayına düşebilir.
- Etkinlik ekleme: MVP’de güvenlik için ilk aşamada admin onayına düşebilir.
- Yorumlar: Direkt yayınlanabilir; raporlama ve admin gizleme/moderasyon sistemi olmalıdır.

### 6.3 Doğrulama Yöntemleri

- Manuel ekip kontrolü
- Mekan telefonundan doğrulama
- Resmi Instagram hesabından DM doğrulama kodu gönderme
- Belge yükleme: vergi levhası, ruhsat veya işletme kanıtı
- Gerekirse yerinde doğrulama veya telefon görüşmesi

---

## 7. Uygulama Bilgi Mimarisi

### 7.1 Bottom Navigation

Ana sekmeler:

1. Keşfet
2. Etkinlikler
3. Harita
4. Kaydedilenler
5. Profil

### 7.2 Ana Navigasyon Akışları

- Keşfet → Kategori → Aktiviteye göre mekan listesi → Mekan profili
- Keşfet → Bu akşam ne var → Etkinlik detay → Mekan profili
- Arama → Mekanlar / Aktiviteler / Etkinlikler
- Harita → Mini mekan kartı → Mekan profili
- Profil → Mekan ekle / sahiplenme başvurusu / başvuru durumu
- Mekan Profili → Genel / Aktiviteler / Etkinlikler / Yorumlar

---

## 8. Ekran Kapsamı

### 8.1 MVP Ekranları

- Splash
- Onboarding
- Şehir seçimi
- Keşfet ana ekranı
- Arama sonuçları
- Aktivite kategori ekranı
- Aktiviteye göre mekan listesi
- Etkinlikler ekranı
- Etkinlik detay ekranı
- Harita ekranı
- Mekan profili
- Mekan profili / Genel sekmesi
- Mekan profili / Aktiviteler sekmesi
- Mekan profili / Etkinlikler sekmesi
- Mekan profili / Yorumlar sekmesi
- Yorum yaz ekranı
- Kaydedilenler
- Kullanıcı profili
- Ayarlar
- Mekan ekle başvuru ekranı
- Mekan sahiplenme ekranı
- Başvuru durumu ekranı
- Admin panel ekranları

---

## 9. Tasarım Dili

### 9.1 Genel Karakter

BiÇıkalım tasarım dili:

- Sade
- Modern
- Mobil-first
- Keşif odaklı
- Samimi
- Enerjik
- Güvenilir
- Blog gibi değil, gerçek mobil uygulama gibi

### 9.2 Design Direction

- Light theme
- Sıcak turuncu / canlı mercan primary renk
- Temiz beyaz / kırık beyaz zemin
- Rounded card yapısı
- Sade ikonografi
- Kısa metinler
- Görsel ağırlıklı keşif kartları
- Yumuşak gölgeler
- Net bilgi hiyerarşisi

### 9.3 Renk Kullanımı

| Rol | Kullanım |
|---|---|
| Primary | Sıcak turuncu / canlı mercan |
| Background | Beyaz, kırık beyaz, çok açık gri |
| Text Primary | Siyaha yakın koyu gri |
| Text Secondary | Orta gri |
| Success | Açık mekan durumu, onaylı veri |
| Warning / Highlight | Ödüllü, dikkat çeken event |
| Passive Icons | Açık gri / nötr gri |

### 9.4 Component Dili

Temel component’ler:

- Search bar
- Filter chip
- Category card
- Event card
- Venue card
- Activity card
- Review card
- Rating badge
- Status badge
- Source badge
- Bottom navigation
- Save / bookmark icon
- Section header + Tümünü gör linki
- Segmented control / tab bar
- Bottom sheet
- Map pin
- Empty state
- Loading state
- Error state

### 9.5 Kaçınılacak Tasarım Kararları

- Aşırı koyu ve ağır ekranlar
- Fazla gradient kullanımı
- Gereksiz renk kalabalığı
- Blog benzeri uzun metin blokları
- Küçük tıklama alanları
- Sert border kullanımı
- Karmaşık ikonografi
- Çok fazla bilgi sıkıştırılmış kartlar

---

## 10. Ekran Tasarım Detayları

### 10.1 Keşfet Ana Ekranı

Amaç:

Kullanıcının uygulamaya girdiğinde şehir bazlı genel keşif yapabildiği, kategori, etkinlik ve popüler mekanları tek akışta gördüğü ana ekran.

Bileşenler:

- BiÇıkalım logo alanı
- Şehir seçici: Eskişehir
- Arama barı: “Mekan, oyun veya aktivite ara”
- Hızlı filtreler:
  - Bugün açık
  - Bu akşam
  - 4 kişi
  - Yakınımda
- Kategoriler:
  - Masa Oyunları
  - Bilardo
  - Bowling
  - PS / Konsol
  - Karaoke
  - Dart
- Bu akşam ne var?
- Popüler Mekanlar
- Yakındaki aktiviteler
- Bottom navigation

Kullanıcı aksiyonları:

- Arama yapmak
- Şehir değiştirmek
- Kategori seçmek
- Etkinlik detayı açmak
- Mekan profiline gitmek
- Kaydetmek

---

### 10.2 Etkinlikler Ekranı

Amaç:

Şehirdeki etkinlikleri gün, tarih aralığı ve kategori bazlı filtreleyerek listelemek.

Bileşenler:

- Header: BiÇıkalım + şehir seçici
- Sayfa başlığı: Etkinlikler
- Tarih segmentleri:
  - Bugün
  - Yarın
  - Bu Hafta
- Filtre chipleri:
  - Masa Oyunu
  - Karaoke
  - Bilardo
  - Ücretsiz
- Öne çıkan büyük etkinlik kartı
- Dikey etkinlik listesi
- Kaydet butonları
- Bottom navigation

---

### 10.3 Harita Ekranı

Amaç:

Kullanıcının bulunduğu yere veya seçili şehre göre mekanları harita üzerinde keşfetmesini sağlamak.

Bileşenler:

- Sayfa başlığı: Harita
- Şehir seçici
- Arama barı
- Hızlı filtreler:
  - Bu akşam
  - 4 kişi
  - Yakınımda
- Aktivite ikonlu map pinleri
- Konuma dön butonu
- Alt bottom sheet mekan kartları
- Bottom navigation

---

### 10.4 Aktiviteye Göre Mekan Listesi

Örnek ekran: Masa Oyunları

Amaç:

Belirli bir aktivite kategorisi veya alt filtreye göre mekan listelemek.

Bileşenler:

- Geri butonu
- Sayfa başlığı: Masa Oyunları
- Şehir seçici
- Filtre butonu
- Filter chipleri:
  - Monopoly
  - Catan
  - 2-4 kişi
  - Bugün açık
- Sonuç sayısı: “Eskişehir’de 18 mekan bulundu”
- Akıllı sıralama
- Mekan kartları:
  - Görsel
  - Mekan adı
  - Açık/kapalı
  - İlçe
  - Puan
  - Mesafe
  - Kısa açıklama
  - Aktivite tagleri
  - Kaydet ikonu

---

### 10.5 Mekan Profili — Genel

Amaç:

Mekan hakkında özet bilgiyi, öne çıkan aktiviteleri, bu akşamki etkinlikleri ve kısa yorum görünümünü bir araya getirmek.

Bileşenler:

- Geri butonu
- BiÇıkalım wordmark
- Paylaş butonu
- Hero mekan görseli
- Mekan adı
- İl/ilçe
- Onaylı Mekan rozeti
- Açık durumu
- Puan ve yorum sayısı
- Aksiyon butonları:
  - Kaydet
  - Yol Tarifi
  - Ara
  - Instagram
- Kısa açıklama
- Sekmeler:
  - Genel
  - Aktiviteler
  - Etkinlikler
  - Yorumlar
- Öne çıkan aktiviteler
- Bu akşam
- Meta bloklar:
  - Çalışma saatleri
  - Fiyat seviyesi
  - Uygun grup büyüklüğü
  - Atmosfer
- Kullanıcı yorumları önizleme

---

### 10.6 Mekan Profili — Aktiviteler

Amaç:

Mekanın sunduğu tüm aktiviteleri detaylarıyla listelemek.

Bileşenler:

- Mekan header alanı
- Sekmelerde Aktiviteler aktif
- Mekan Aktiviteleri başlığı
- Aktivite kartları:
  - Aktivite görseli / ikonu
  - Aktivite adı
  - Kategori
  - Kısa açıklama
  - Kişi sayısı
  - Ücretsiz / ücretli bilgisi
  - Kaynak: Onaylı Mekan / Editör Eklemesi
  - Son güncelleme

Örnek aktiviteler:

- Monopoly
- Catan
- Bilardo
- Karaoke
- Dart
- PS5
- Tabu

---

### 10.7 Mekan Profili — Etkinlikler

Amaç:

Mekana özel yaklaşan etkinlikleri listelemek.

Bileşenler:

- Mekan header alanı
- Sekmelerde Etkinlikler aktif
- Yaklaşan Etkinlikler başlığı
- Filtre chipleri:
  - Tümü
  - Bugün
  - Bu Hafta
  - Yakında
- Etkinlik kartları:
  - Görsel
  - Tarih bloğu
  - Saat
  - Etkinlik adı
  - Tarih-saat metni
  - Kısa açıklama
  - Katılım bilgisi
  - Ücretsiz / ödüllü etiketi
  - Kaydet ikonu

---

### 10.8 Mekan Profili — Yorumlar

Amaç:

Mekana ait puan dağılımını ve kullanıcı yorumlarını göstermek.

Bileşenler:

- Mekan header alanı
- Sekmelerde Yorumlar aktif
- Ortalama puan özeti
- 1-5 yıldız dağılım çubukları
- Toplam yorum sayısı
- Yorum Yaz butonu
- Yorum kartları:
  - Kullanıcı avatarı
  - Kullanıcı adı
  - Yıldız puanı
  - Tarih
  - Aktivite etiketi
  - Yorum metni
  - Üç nokta / raporlama menüsü

Yorumlar aktivite deneyimi odaklı olmalıdır.

Örnek:

> “Bilardo masaları çok kaliteli ve düzenli. Arkadaşlarla keyifli vakit geçirmek için birebir.”

---

### 10.9 Kaydedilenler Ekranı

Amaç:

Kullanıcının ilgilendiği mekan ve etkinlikleri tek yerde toplamak.

Bileşenler:

- BiÇıkalım header
- Şehir seçici
- Başlık: Kaydedilenler
- Açıklama: “Beğendiğin mekanları ve etkinlikleri burada bulabilirsin.”
- Segmented control:
  - Mekanlar
  - Etkinlikler
- Kaydedilen Mekanlar
- Kaydedilen Etkinlikler
- Kartlar:
  - Görsel
  - Başlık
  - Açık durumu
  - Puan
  - Mesafe
  - Aktivite tagleri
  - Kaydet ikonu
- Bottom navigation, Kaydedilenler aktif

---

## 11. Yorum ve Puanlama

### 11.1 Yorum Yazma Alanları

Yorum yazarken kullanıcıdan alınacak bilgiler:

- Puan: 1-5 yıldız
- Hangi aktivite için gittin?
- Yorum metni
- Opsiyonel: tekrar gider misin?
- Opsiyonel: grup büyüklüğü

MVP’de fotoğraflı yorum zorunlu değildir.

### 11.2 Review Status

Yorum statüleri:

- pending
- active
- hidden
- deleted

MVP önerisi:

- Yorumlar ilk etapta direkt active olabilir.
- Raporlama sonrası admin gizleyebilir.
- Uygunsuz içerikler için moderasyon ekranı olmalıdır.

---

## 12. Mekan Sahibi Akışları

### 12.1 Yeni Mekan Oluşturma

Akış:

1. Kullanıcı profil ekranından “Mekan Ekle” aksiyonuna girer.
2. Mekan sahibi bilgilerini ve mekan temel bilgilerini doldurur.
3. Mekan konumu, iletişim bilgileri, aktivite kategorileri ve görseller eklenir.
4. Başvuru `pending_review` statüsüne düşer.
5. Admin başvuruyu kontrol eder.
6. Onaylanırsa mekan yayınlanır ve kullanıcı mekan sahibi olarak atanır.

### 12.2 Editör Mekanını Sahiplenme

Akış:

1. Mekan profilinde “Bu mekanın sahibi misiniz?” butonu gösterilir.
2. Kullanıcı sahiplenme formunu doldurur.
3. Ad soyad, telefon, e-posta, işletmedeki rol, Instagram ve kanıt bilgileri alınır.
4. Talep `pending` statüsüne düşer.
5. Admin telefon, Instagram DM, belge veya manuel kontrol ile doğrular.
6. Onaylanırsa mekan profili kullanıcı hesabına bağlanır.
7. Mekan etiketi `Onaylı Mekan` olur.

### 12.3 Mekan Sahibi Yetkileri

- Mekan açıklaması ve iletişim bilgilerini düzenleme
- Çalışma saatlerini güncelleme
- Fotoğraf ve kapak görseli ekleme
- Aktivite envanteri ekleme / düzenleme / silme
- Etkinlik oluşturma / düzenleme / iptal etme
- Yorumları görüntüleme
- Uygunsuz yorum bildirme

---

## 13. Admin / Editör Akışları

Admin panel MVP’de gereklidir.

### 13.1 Admin Panel Fonksiyonları

- Mekan oluşturma ve düzenleme
- Aktivite kategorisi yönetimi
- Aktivite yönetimi
- Etkinlik yönetimi
- Yeni mekan başvurusu onay / red
- Mekan sahiplenme talebi onay / red
- Yorum moderasyonu
- Kullanıcı ve rol yönetimi
- Raporlanan içerikleri inceleme
- Mekan değişiklik geçmişi

### 13.2 İçerik Statüleri

| Nesne | Statüler |
|---|---|
| Mekan | draft, pending_review, published, rejected, suspended, closed |
| Sahiplik | unclaimed, claim_pending, claimed, claim_rejected, ownership_removed |
| Etkinlik | draft, pending_review, published, cancelled, rejected |
| Yorum | pending, active, hidden, deleted |
| Başvuru | pending, approved, rejected, need_more_info |

---

## 14. Veri Modeli Taslağı

Firestore collection mantığı ile ilk domain modeli:

### 14.1 Collections

```text
users
venues
activity_categories
activities
venue_activities
events
reviews
favorites
venue_claim_requests
venue_submissions
venue_ownerships
admin_logs
reports
```

### 14.2 users

```json
{
  "id": "userId",
  "displayName": "Ulaş",
  "email": "user@example.com",
  "phone": "+90...",
  "city": "Eskişehir",
  "roles": ["user"],
  "avatarUrl": "",
  "createdAt": "...",
  "updatedAt": "..."
}
```

### 14.3 venues

```json
{
  "id": "venueId",
  "name": "Roll & Play Cafe",
  "slug": "roll-play-cafe",
  "description": "Masa oyunları, bilardo ve karaoke keyfini bir arada sunan mekan.",
  "city": "Eskişehir",
  "district": "Odunpazarı",
  "address": "Adres bilgisi",
  "latitude": 39.776,
  "longitude": 30.520,
  "phone": "+90...",
  "instagramUrl": "https://instagram.com/...",
  "coverImageUrl": "",
  "imageUrls": [],
  "sourceType": "editor",
  "verificationStatus": "unverified",
  "ownershipStatus": "unclaimed",
  "status": "published",
  "openingHours": {},
  "averageRating": 4.8,
  "reviewCount": 312,
  "activityTags": ["Masa Oyunları", "Bilardo", "Karaoke"],
  "createdAt": "...",
  "updatedAt": "..."
}
```

### 14.4 activity_categories

```json
{
  "id": "categoryId",
  "name": "Masa Oyunları",
  "icon": "dice",
  "order": 1,
  "isActive": true
}
```

### 14.5 activities

```json
{
  "id": "activityId",
  "name": "Monopoly",
  "categoryId": "masa_oyunlari",
  "description": "Klasik masa oyunu",
  "icon": "monopoly",
  "minPeople": 2,
  "maxPeople": 6,
  "isActive": true
}
```

### 14.6 venue_activities

```json
{
  "id": "venueActivityId",
  "venueId": "venueId",
  "activityId": "activityId",
  "categoryId": "masa_oyunlari",
  "note": "Oyun rafında mevcut.",
  "isFree": true,
  "priceInfo": "Ücretsiz",
  "sourceType": "venue_owner",
  "lastVerifiedAt": "...",
  "createdAt": "...",
  "updatedAt": "..."
}
```

### 14.7 events

```json
{
  "id": "eventId",
  "venueId": "venueId",
  "title": "Quiz Night",
  "description": "Takımını kur, ödüllü quiz gecesine katıl.",
  "category": "quiz",
  "startDate": "...",
  "endDate": "...",
  "priceInfo": "Ücretsiz",
  "imageUrl": "",
  "sourceType": "venue_owner",
  "status": "published",
  "createdAt": "...",
  "updatedAt": "..."
}
```

### 14.8 reviews

```json
{
  "id": "reviewId",
  "venueId": "venueId",
  "userId": "userId",
  "userDisplayName": "Ulaş",
  "rating": 5,
  "comment": "Bilardo için gittik, masalar iyiydi.",
  "visitedActivityId": "bilardo",
  "status": "active",
  "createdAt": "...",
  "updatedAt": "..."
}
```

### 14.9 favorites

```json
{
  "id": "favoriteId",
  "userId": "userId",
  "targetType": "venue",
  "targetId": "venueId",
  "createdAt": "..."
}
```

### 14.10 venue_claim_requests

```json
{
  "id": "claimRequestId",
  "venueId": "venueId",
  "requesterUserId": "userId",
  "requesterName": "Ad Soyad",
  "requesterPhone": "+90...",
  "requesterEmail": "mail@example.com",
  "requesterRole": "owner",
  "instagramAccount": "@mekan",
  "proofFileUrl": "",
  "note": "Mekanın sahibiyim.",
  "status": "pending",
  "adminNote": "",
  "reviewedByAdminId": "",
  "reviewedAt": null,
  "createdAt": "..."
}
```

### 14.11 venue_submissions

```json
{
  "id": "submissionId",
  "submittedByUserId": "userId",
  "name": "Yeni Mekan",
  "city": "Eskişehir",
  "district": "Tepebaşı",
  "address": "Adres",
  "latitude": 39.77,
  "longitude": 30.52,
  "phone": "+90...",
  "instagramUrl": "",
  "description": "",
  "coverImageUrl": "",
  "status": "pending",
  "adminNote": "",
  "reviewedByAdminId": "",
  "reviewedAt": null,
  "createdAt": "..."
}
```

---

## 15. Teknoloji Stack

### 15.1 Mobil App

- Flutter
- Riverpod
- go_router
- freezed
- json_serializable
- cached_network_image
- google_maps_flutter
- geolocator
- geocoding

### 15.2 Firebase

- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Analytics
- Firebase Crashlytics
- Firebase Cloud Messaging
- Cloud Functions

### 15.3 Admin Panel

MVP için iki seçenek:

1. Flutter Web Admin Panel
2. Next.js Admin Panel

İlk pilot için Flutter Web yeterlidir. Uzun vadede Next.js düşünülebilir.

### 15.4 Harita

- Google Maps Platform

### 15.5 Proje Yönetimi

- GitHub veya GitLab
- GitHub Projects / Linear / Trello
- Figma
- Google Sheets veri toplama
- Notion veya Markdown dokümantasyon

---

## 16. Flutter Proje Yapısı

Önerilen klasör yapısı:

```text
lib/
  core/
    constants/
    theme/
    router/
    utils/
    errors/
    services/
  features/
    auth/
    discover/
    venues/
    activities/
    events/
    reviews/
    favorites/
    map/
    owner/
    profile/
  shared/
    widgets/
    models/
    extensions/
```

### 16.1 Feature Kuralları

Her feature mümkünse şu alt yapıya sahip olmalıdır:

```text
feature_name/
  data/
    models/
    repositories/
    datasources/
  domain/
    entities/
    usecases/
  presentation/
    screens/
    widgets/
    providers/
```

MVP hızı için domain katmanı gerektiğinde sadeleştirilebilir ancak repository pattern korunmalıdır.

---

## 17. Routing Planı

`go_router` kullanılmalıdır.

Örnek route isimleri:

```text
/splash
/onboarding
/city-select
/discover
/search
/categories/:categoryId
/venues
/venues/:venueId
/venues/:venueId/activities
/venues/:venueId/events
/venues/:venueId/reviews
/events
/events/:eventId
/map
/favorites
/profile
/profile/reviews
/owner/submit-venue
/owner/claim/:venueId
/owner/applications
/admin
```

---

## 18. State Management Kuralları

- Riverpod kullanılmalıdır.
- Firestore stream gereken yerlerde StreamProvider kullanılabilir.
- Tekil detay ekranlarında FutureProvider veya AsyncNotifier kullanılabilir.
- UI içinde doğrudan Firestore çağrısı yapılmamalıdır.
- Data erişimi repository üzerinden yapılmalıdır.
- Loading / error / empty states her ekranda düşünülmelidir.

---

## 19. Firebase Security Kuralları İçin Mantık

Temel yetki mantığı:

- Herkes published mekanları ve etkinlikleri okuyabilir.
- Giriş yapan kullanıcı yorum yazabilir.
- Kullanıcı sadece kendi yorumunu düzenleyebilir veya silebilir.
- Kullanıcı sadece kendi favorilerini yönetebilir.
- Kullanıcı mekan başvurusu ve sahiplenme talebi gönderebilir.
- Mekan sahibi sadece sahip olduğu mekanı yönetebilir.
- Editör mekan ve aktivite datası yönetebilir.
- Admin tüm verilere erişebilir.

---

## 20. Cloud Functions Gereken Yerler

Cloud Functions önerilen görevler:

- Review oluşturulunca venue averageRating ve reviewCount güncelle
- Review silinince veya gizlenince venue rating yeniden hesapla
- Venue claim approved olunca venue_ownership oluştur
- Venue submission approved olunca venues collection’a mekan oluştur
- Event publish olunca gerekli bildirimleri tetikle
- Search keywords üret
- Admin log oluştur
- Kritik veri değişikliklerinde change log oluştur

---

## 21. Analytics Eventleri

Uygulama şu eventleri göndermelidir:

```text
app_open
city_selected
search_performed
category_opened
venue_viewed
event_viewed
map_opened
favorite_added
favorite_removed
review_submitted
claim_request_submitted
venue_submission_created
owner_panel_opened
call_clicked
instagram_clicked
directions_clicked
```

---

## 22. Pilot Deploy Planı

### 22.1 Ortamlar

- staging
- production

Firebase projeleri:

- bicikalim-staging
- bicikalim-prod

### 22.2 Yayın Sırası

1. Android local APK testi
2. Google Play Internal Testing
3. Google Play Closed Testing
4. Eskişehir Public Pilot — Google Play Production
5. iOS TestFlight
6. iOS App Store yayını

### 22.3 Geliştirme Aşamaları

| Aşama | Çıktı |
|---|---|
| 0. Hazırlık | Firebase, Flutter project, Maps API, Git repo, env yapısı |
| 1. UI Temel | Theme, componentler, splash, onboarding, şehir seçimi, Keşfet |
| 2. Core App | Kategori, mekan listesi, mekan profili, etkinlikler, harita, arama |
| 3. Auth + Yorum | Giriş, favoriler, puanlama, yorum yazma/listeleme |
| 4. Mekan Sahibi | Mekan ekle, sahiplenme formu, başvuru durumu |
| 5. Admin Panel | Mekan/aktivite/etkinlik yönetimi, onay/red, moderasyon |
| 6. Pilot Veri | Eskişehir mekan ve aktivite datası |
| 7. Internal Test | Hata, analytics, akış ve güvenlik testi |
| 8. Closed Beta | 100-300 kullanıcı, mekan sahibi testleri |

---

## 23. Pilot Veri Hedefi

İlk pilot için hedef:

- 50-100 mekan
- 300-500 aktivite / oyun girdisi
- 20-50 etkinlik girdisi
- Mekan başına minimum:
  - ad
  - ilçe
  - konum
  - görsel
  - aktivite listesi
  - açık saatler
  - Instagram / telefon
  - kaynak etiketi

---

## 24. Veri Toplama Sheet Kolonları

İlk veri Google Sheet üzerinden hazırlanabilir.

Kolonlar:

```text
Mekan Adı
Şehir
İlçe
Adres
Google Maps Link
Latitude
Longitude
Instagram
Telefon
Mekan Türü
Aktivite Kategorileri
Aktiviteler
Etkinlik Var mı?
Açık Saatler
Görsel Linkleri
Kaynak
Doğrulama Durumu
Not
```

---

## 25. Başarı Metrikleri

### 25.1 Kullanıcı Metrikleri

- Günlük aktif kullanıcı
- Haftalık aktif kullanıcı
- Arama sayısı
- Kategori tıklama sayısı
- Mekan profil görüntüleme
- Etkinlik görüntüleme
- Harita açma
- Kaydetme
- Yorum yazma
- Yol tarifi tıklama
- Telefon tıklama
- Instagram tıklama

### 25.2 Platform Metrikleri

- Toplam mekan sayısı
- Toplam aktivite sayısı
- Toplam etkinlik sayısı
- Onaylı mekan sayısı
- Sahiplenme başvurusu sayısı
- Yeni mekan başvurusu sayısı
- Yorum sayısı
- Bilgi doğruluk oranı
- Güncel olmayan veri oranı

---

## 26. AI Agent Çalışma Kuralları

AI agent aşağıdaki kurallara uymalıdır:

### 26.1 Genel Kurallar

- Ürün kapsamını büyütme.
- Rezervasyon, ödeme, kupon, grup planlama gibi MVP dışı özellikleri ekleme.
- Kod üretirken önce mevcut proje yapısını incele.
- Var olan mimariye ters düşen dosya/klasör üretme.
- UI kararlarında bu project.md içindeki tasarım dilini koru.
- Türkçe kullanıcı metinlerini koru.
- Gerekmedikçe İngilizce UI metni kullanma.
- Her yeni feature için loading, empty ve error state düşün.
- Firebase erişimini UI içine gömme; repository kullan.
- Firestore collection isimlerini bu dokümandaki isimlerle uyumlu tut.
- Büyük değişikliklerden önce kısa plan çıkar.
- İş bitince hangi dosyaların değiştiğini ve neden değiştiğini özetle.

### 26.2 Kod Kalitesi Kuralları

- Flutter null-safety uyumlu kod yaz.
- Widget’ları küçük ve yeniden kullanılabilir tut.
- Tek ekranda aşırı büyük widget dosyaları oluşturma.
- Ortak componentleri `shared/widgets` altına koy.
- Theme değerlerini hard-code etme; `core/theme` üzerinden yönet.
- Renk, spacing, border radius ve text style değerleri merkezi olmalı.
- Firestore field isimlerinde tutarlı camelCase kullan.
- Model sınıflarında `freezed` ve `json_serializable` tercih et.
- Hata yönetimi için kullanıcıya anlaşılır mesaj göster.

### 26.3 UI Kuralları

- Light theme ana tema olmalı.
- Primary renk sıcak turuncu olmalı.
- Kartlar rounded ve yumuşak gölgeli olmalı.
- Bottom navigation 5 sekmeli yapıda kalmalı.
- Ana aksiyonlar turuncu, durum bilgileri yeşil, pasif ikonlar gri olmalı.
- Mekan kartlarında minimum şu bilgiler olmalı:
  - görsel
  - ad
  - açık durumu
  - puan
  - mesafe
  - aktivite tagleri
  - kaydet ikonu
- Etkinlik kartlarında minimum şu bilgiler olmalı:
  - görsel
  - etkinlik adı
  - mekan adı
  - tarih/saat
  - katılım veya kişi bilgisi
  - kaydet ikonu

### 26.4 Test / Doğrulama Kuralları

Her feature sonrası kontrol et:

- Uygulama derleniyor mu?
- Ekran küçük cihazlarda taşma yapıyor mu?
- Loading state var mı?
- Empty state var mı?
- Error state var mı?
- Auth gerektiren aksiyonlarda kullanıcı yönlendiriliyor mu?
- Firestore security mantığı ihlal ediliyor mu?
- Analytics event gerekiyorsa eklendi mi?

---

## 27. Öncelikli Geliştirme Sırası

AI agent mümkünse şu sırayı takip etmelidir:

1. Project setup
2. Theme / design system
3. Shared widgets
4. Navigation shell
5. Splash / onboarding / city select
6. Keşfet ekranı
7. Aktivite kategori ve mekan liste ekranı
8. Mekan profili genel
9. Mekan profili aktiviteler
10. Mekan profili etkinlikler
11. Mekan profili yorumlar
12. Etkinlikler ekranı
13. Harita ekranı
14. Kaydedilenler ekranı
15. Auth
16. Favoriler
17. Yorum / puanlama
18. Mekan ekleme başvurusu
19. Mekan sahiplenme başvurusu
20. Admin panel MVP
21. Firebase rules / functions
22. Staging deploy
23. Closed beta hazırlığı

---

## 28. Son MVP Tanımı

BiÇıkalım MVP, kullanıcıların şehirlerinde aktiviteye göre mekan ve etkinlik keşfetmesini, mekanları puanlayıp yorumlamasını; mekan sahiplerinin ise mekanlarını oluşturmasını, editör tarafından eklenen mekanları sahiplenmesini ve aktivite/etkinlik bilgilerini yönetmesini sağlayan mobil odaklı platformdur.

İlk sürümün amacı büyük ve karmaşık bir sosyal platform kurmak değildir. İlk sürümün amacı şehirdeki aktivite datasını görünür yapmak, mekanların aktivite envanterini kullanıcıya sunmak, etkinlikleri mobil bir keşif deneyimiyle göstermek, kullanıcı yorumlarıyla güven oluşturmak ve BiÇıkalım markasını “Bu akşam ne yapalım?” sorusunun cevabı haline getirmektir.
