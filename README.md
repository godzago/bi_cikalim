# Bi Çıkalım

> Şehrinde ne yapacağını keşfet, etkinlikleri yakala, yeni mekânlarla tanış.

Bi Çıkalım; kullanıcıların şehirlerindeki etkinlikleri, aktiviteleri ve mekânları tek bir mobil deneyim üzerinden keşfetmesini sağlayan Flutter tabanlı bir uygulamadır. Projenin ilk odağı Eskişehir'dir ve Android öncelikli olarak geliştirilmektedir.

Uygulama klasik bir mekân rehberinden farklı olarak “Nereye gidelim?” sorusunun yanında “Bugün ne yapabiliriz?” sorusuna da cevap vermeyi amaçlar. Kullanıcılar aktivite türüne göre arama yapabilir, yaklaşan etkinlikleri inceleyebilir ve ilgilendikleri içerikleri daha sonra erişmek üzere kaydedebilir.

## Neler Yapılabilir?

- Şehir, kategori ve aktivite bazında mekân keşfetme
- Bugün, yarın veya bu hafta gerçekleşecek etkinlikleri inceleme
- Mekân ve etkinlik detaylarına ulaşma
- OpenStreetMap tabanlı harita üzerinden yakındaki yerleri görüntüleme
- Arama sonuçlarını farklı filtrelerle daraltma
- Mekânları ve etkinlikleri favorilere ekleme
- Misafir olarak uygulamayı keşfetme
- Kullanıcı hesabı oluşturma ve oturum yönetme
- Mekân sahibi olarak başvuru ve sahiplenme süreçlerini başlatma

## Uygulama Yapısı

Ana deneyim beş temel bölümden oluşur:

1. **Keşfet:** Kategoriler, popüler mekânlar ve öne çıkan aktiviteler
2. **Etkinlikler:** Tarih ve kategoriye göre etkinlik listeleri
3. **Harita:** Mekân ve etkinliklerin konum tabanlı görünümü
4. **Favoriler:** Kaydedilen mekân ve etkinlikler
5. **Profil:** Hesap, şehir seçimi ve mekân sahibi işlemleri

## Teknik Yapı

Proje feature-based bir klasör yapısı kullanır. Ekranlar ve işlevler özelliklerine göre ayrılırken ağ, yönlendirme ve tema gibi uygulama genelindeki parçalar ortak bir çekirdekte tutulur.

```text
lib/
├── core/       # API, yönlendirme, tema ve ortak servisler
├── features/   # Auth, keşfet, etkinlik, harita, mekân ve profil
├── shared/     # Modeller, yardımcılar ve tekrar kullanılabilir widget'lar
└── main.dart   # Uygulama başlangıç noktası
```

### Kullanılan Teknolojiler

- **Flutter & Dart:** Çapraz platform mobil geliştirme
- **Riverpod:** Uygulama durumu ve bağımlılık yönetimi
- **GoRouter:** Deklaratif yönlendirme
- **Dio:** REST API iletişimi ve interceptor yönetimi
- **Flutter Map & OpenStreetMap:** Harita deneyimi
- **Flutter Secure Storage:** Güvenli oturum saklama
- **Cached Network Image:** Görsel önbellekleme

## Başlangıç

### Gereksinimler

- Flutter 3.44 veya üzeri
- Dart 3.12 veya üzeri
- Android Studio ya da uygun bir Flutter geliştirme ortamı
- Çalışan bir Bi Çıkalım API servisi

Bağımlılıkları yükleyin:

```bash
flutter pub get
```

Uygulamayı yerel API ile çalıştırın:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

Android emülatöründen bilgisayarınızdaki API'ye bağlanırken `localhost` yerine `10.0.2.2` kullanın:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

## Kalite Kontrolleri

Projede ekran davranışları, responsive görünüm, provider'lar, API modelleri ve temel kullanıcı akışları için testler bulunur.

```bash
flutter analyze
flutter test
```

## Güvenlik

API anahtarları, canlı servis adresleri, imzalama dosyaları, sertifikalar ve yerel ortam değişkenleri repoya eklenmemelidir. Hassas yapılandırmalar çalışma zamanında `--dart-define` veya güvenli CI/CD değişkenleri üzerinden sağlanmalıdır.

## Proje Durumu

Bi Çıkalım aktif olarak geliştirilmektedir. Mobil keşif deneyimi, etkinlik akışları, harita, favoriler ve kullanıcı oturumu uygulamada yer almaktadır; ürün kapsamı ve servis entegrasyonları geliştirme süreci boyunca ilerlemeye devam etmektedir.

## Kullanım Hakları

Bu proje ShiftWave Holding'e aittir. Kaynak kodunun herkese açık olması; kopyalama, dağıtma, ticari kullanım veya yeniden lisanslama izni verildiği anlamına gelmez.
