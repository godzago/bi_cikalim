# Bi Çıkalım

Bi Çıkalım, şehirdeki etkinlikleri, aktiviteleri ve mekânları keşfetmeyi kolaylaştıran Flutter tabanlı bir mobil uygulamadır. Kullanıcılar yakınlarındaki mekânları haritada görüntüleyebilir, etkinlikleri inceleyebilir ve favorilerini kaydedebilir.

## Özellikler

- Şehir, kategori ve aktivite bazlı keşif
- Etkinlik ve mekân detayları
- OpenStreetMap tabanlı harita görünümü
- Favori mekân ve etkinlikler
- Misafir, kullanıcı ve mekân sahibi akışları
- Responsive ve erişilebilir mobil arayüz

## Teknolojiler

- Flutter ve Dart
- Riverpod
- GoRouter
- Dio ve REST API
- Flutter Map / OpenStreetMap
- Secure Storage

## Kurulum

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

Android emülatöründen yerel API'ye bağlanırken `localhost` yerine `10.0.2.2` kullanın:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

## Kontroller

```bash
flutter analyze
flutter test
```

> API adresleri, anahtarlar, imzalama dosyaları ve diğer gizli yapılandırmalar repoya eklenmemelidir.

## Kullanım Hakları

Bu proje ShiftWave Holding'e aittir. Kaynak kodunun herkese açık olması, kullanım veya dağıtım izni verildiği anlamına gelmez.
