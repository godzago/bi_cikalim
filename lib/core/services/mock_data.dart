import 'package:flutter/material.dart';

// Models
class ActivityCategory {
  final String id;
  final String name;
  final IconData icon;
  final int order;

  const ActivityCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.order,
  });
}

class Activity {
  final String id;
  final String name;
  final String categoryId;
  final String description;
  final IconData icon;
  final int minPeople;
  final int maxPeople;

  const Activity({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.icon,
    required this.minPeople,
    required this.maxPeople,
  });
}

class VenueActivity {
  final String id;
  final String venueId;
  final String activityId;
  final String note;
  final bool isFree;
  final String priceInfo;
  final String sourceType; // 'venue_owner' | 'editor'

  const VenueActivity({
    required this.id,
    required this.venueId,
    required this.activityId,
    required this.note,
    required this.isFree,
    required this.priceInfo,
    required this.sourceType,
  });
}

class Venue {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String city;
  final String district;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String instagramUrl;
  final String coverImageUrl;
  final String sourceType; // 'editor' | 'venue_owner'
  final String verificationStatus; // 'verified' | 'unverified'
  final String ownershipStatus; // 'claimed' | 'unclaimed'
  final double averageRating;
  final int reviewCount;
  final List<String> activityTags;

  const Venue({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.city,
    required this.district,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.instagramUrl,
    required this.coverImageUrl,
    required this.sourceType,
    required this.verificationStatus,
    required this.ownershipStatus,
    required this.averageRating,
    required this.reviewCount,
    required this.activityTags,
  });
}

class Event {
  final String id;
  final String venueId;
  final String title;
  final String description;
  final String category;
  final DateTime startDate;
  final String priceInfo;
  final String imageUrl;
  final String sourceType; // 'venue_owner' | 'editor'
  final String status; // 'published' | 'cancelled'

  const Event({
    required this.id,
    required this.venueId,
    required this.title,
    required this.description,
    required this.category,
    required this.startDate,
    required this.priceInfo,
    required this.imageUrl,
    required this.sourceType,
    required this.status,
  });
}

class Review {
  final String id;
  final String venueId;
  final String userDisplayName;
  final int rating;
  final String comment;
  final String visitedActivityName;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.venueId,
    required this.userDisplayName,
    required this.rating,
    required this.comment,
    required this.visitedActivityName,
    required this.createdAt,
  });
}

// Mock Database
class MockDatabase {
  static final List<ActivityCategory> categories = [
    const ActivityCategory(id: 'masa_oyunlari', name: 'Masa Oyunları', icon: Icons.casino, order: 1),
    const ActivityCategory(id: 'bilardo', name: 'Bilardo', icon: Icons.sports, order: 2),
    const ActivityCategory(id: 'ps_konsol', name: 'PS / Konsol', icon: Icons.sports_esports, order: 3),
    const ActivityCategory(id: 'karaoke', name: 'Karaoke', icon: Icons.mic, order: 4),
    const ActivityCategory(id: 'dart', name: 'Dart', icon: Icons.adjust, order: 5),
    const ActivityCategory(id: 'bowling', name: 'Bowling', icon: Icons.lens, order: 6),
  ];

  static final List<Activity> activities = [
    const Activity(id: 'monopoly', name: 'Monopoly', categoryId: 'masa_oyunlari', description: 'Emlak ticareti masa oyunu.', icon: Icons.monetization_on, minPeople: 2, maxPeople: 6),
    const Activity(id: 'catan', name: 'Catan', categoryId: 'masa_oyunlari', description: 'Kaynak yönetimi ve ticaret oyunu.', icon: Icons.landscape, minPeople: 3, maxPeople: 4),
    const Activity(id: 'tabu', name: 'Tabu', categoryId: 'masa_oyunlari', description: 'Yasaklı kelimeleri kullanmadan anlatma oyunu.', icon: Icons.forum, minPeople: 4, maxPeople: 10),
    const Activity(id: 'amerikan_bilardo', name: 'Amerikan Bilardo', categoryId: 'bilardo', description: '8 Top bilardo oyunu.', icon: Icons.sports, minPeople: 2, maxPeople: 4),
    const Activity(id: 'ps5_fifa', name: 'PS5 & FIFA 24', categoryId: 'ps_konsol', description: 'PlayStation 5\'te futbol keyfi.', icon: Icons.sports_soccer, minPeople: 2, maxPeople: 4),
    const Activity(id: 'karaoke_odasi', name: 'Özel Karaoke Odası', categoryId: 'karaoke', description: 'Arkadaşlarınızla şarkı söyleyin.', icon: Icons.music_note, minPeople: 4, maxPeople: 15),
    const Activity(id: 'dart_hedefi', name: 'Dart Hedefi', categoryId: 'dart', description: 'Klasik dart hedef tahtası oyunu.', icon: Icons.gps_fixed, minPeople: 2, maxPeople: 6),
  ];

  static final List<Venue> venues = [
    const Venue(
      id: 'venue_1',
      name: 'Roll & Play Cafe',
      slug: 'roll-play-cafe',
      description: 'Eskişehir\'in en büyük masa oyunu arşivi, profesyonel bilardo masaları ve 3 adet özel akustik karaoke odasıyla eğlencenin tek adresi.',
      city: 'Eskişehir',
      district: 'Odunpazarı',
      address: 'Akarbaşı Mh., Atatürk Cd. No: 42, Odunpazarı/Eskişehir',
      latitude: 39.768,
      longitude: 30.522,
      phone: '+90 222 333 44 55',
      instagramUrl: 'https://instagram.com/rollplaycafe',
      coverImageUrl: 'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'venue_owner',
      verificationStatus: 'verified',
      ownershipStatus: 'claimed',
      averageRating: 4.8,
      reviewCount: 312,
      activityTags: ['Masa Oyunları', 'Bilardo', 'Karaoke'],
    ),
    const Venue(
      id: 'venue_2',
      name: 'Social Lounge Pub & Game',
      slug: 'social-lounge',
      description: 'Geniş konsol odaları, dev ekranlarda PS5 turnuvaları ve keyifli bahçesiyle arkadaş grupları için harika bir ortam.',
      city: 'Eskişehir',
      district: 'Tepebaşı',
      address: 'Hoşnudiye Mh., Vural Sk. No: 12, Tepebaşı/Eskişehir',
      latitude: 39.782,
      longitude: 30.518,
      phone: '+90 222 444 55 66',
      instagramUrl: 'https://instagram.com/socialloungeeskeshir',
      coverImageUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      verificationStatus: 'unverified',
      ownershipStatus: 'unclaimed',
      averageRating: 4.3,
      reviewCount: 145,
      activityTags: ['PS / Konsol', 'Dart'],
    ),
    const Venue(
      id: 'venue_3',
      name: 'Overlord Board Game Cafe',
      slug: 'overlord-cafe',
      description: '200\'den fazla güncel board game seçeneği, oyun koçları eşliğinde kuralları hızlıca öğrenip oynayabileceğiniz samimi bir mekan.',
      city: 'Eskişehir',
      district: 'Tepebaşı',
      address: 'Eskibağlar Mh., Üniversite Cd. No: 8, Tepebaşı/Eskişehir',
      latitude: 39.785,
      longitude: 30.505,
      phone: '+90 222 555 66 77',
      instagramUrl: 'https://instagram.com/overlordboardgame',
      coverImageUrl: 'https://images.unsplash.com/photo-1606167668584-78701c57f13d?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'venue_owner',
      verificationStatus: 'verified',
      ownershipStatus: 'claimed',
      averageRating: 4.9,
      reviewCount: 228,
      activityTags: ['Masa Oyunları'],
    ),
  ];

  static final List<VenueActivity> venueActivities = [
    const VenueActivity(id: 'va_1', venueId: 'venue_1', activityId: 'monopoly', note: 'Dev Monopoly oyun tahtası mevcut.', isFree: true, priceInfo: 'Ücretsiz', sourceType: 'venue_owner'),
    const VenueActivity(id: 'va_2', venueId: 'venue_1', activityId: 'catan', note: 'Genişleme paketi dahil.', isFree: false, priceInfo: 'Saatlik 40 TL', sourceType: 'venue_owner'),
    const VenueActivity(id: 'va_3', venueId: 'venue_1', activityId: 'amerikan_bilardo', note: 'Zemin katta 4 adet profesyonel masa.', isFree: false, priceInfo: 'Saatlik 120 TL', sourceType: 'venue_owner'),
    const VenueActivity(id: 'va_4', venueId: 'venue_1', activityId: 'karaoke_odasi', note: 'Önceden rezervasyon yapılması önerilir.', isFree: false, priceInfo: 'Saatlik 250 TL', sourceType: 'venue_owner'),
    const VenueActivity(id: 'va_5', venueId: 'venue_2', activityId: 'ps5_fifa', note: '6 adet VIP kabin.', isFree: false, priceInfo: 'Saatlik 90 TL', sourceType: 'editor'),
    const VenueActivity(id: 'va_6', venueId: 'venue_2', activityId: 'dart_hedefi', note: 'Turnuva tipi elektronik hedef.', isFree: true, priceInfo: 'Ücretsiz', sourceType: 'editor'),
    const VenueActivity(id: 'va_7', venueId: 'venue_3', activityId: 'monopoly', note: 'Türkçe ve İngilizce kutular mevcut.', isFree: true, priceInfo: 'Ücretsiz', sourceType: 'venue_owner'),
    const VenueActivity(id: 'va_8', venueId: 'venue_3', activityId: 'catan', note: 'Oyun koçu anlatımıyla oynayabilirsiniz.', isFree: true, priceInfo: 'Ücretsiz', sourceType: 'venue_owner'),
    const VenueActivity(id: 'va_9', venueId: 'venue_3', activityId: 'tabu', note: '10 kişilik büyük grup versiyonu.', isFree: true, priceInfo: 'Ücretsiz', sourceType: 'venue_owner'),
  ];

  static final List<Event> events = [
    Event(
      id: 'event_1',
      venueId: 'venue_1',
      title: 'Quiz Night: Genel Kültür & Sinema',
      description: 'Eskişehir\'in en büyük Quiz gecesi! 4 kişilik takımını kur, ödüllü bilgi yarışmasına katıl. Birinci olan takıma 1.000 TL Roll & Play çek verilecektir.',
      category: 'Quiz Night',
      startDate: DateTime.now().add(const Duration(hours: 4)),
      priceInfo: 'Ücretsiz Giriş',
      imageUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'venue_owner',
      status: 'published',
    ),
    Event(
      id: 'event_2',
      venueId: 'venue_3',
      title: 'Catan Turnuvası',
      description: 'Büyük Catan gecesi başlıyor! Kaynakları doğru yönet, adayı fethet ve büyük turnuva kupasını kazan.',
      category: 'Masa Oyunu',
      startDate: DateTime.now().add(const Duration(days: 1, hours: 2)),
      priceInfo: 'Katılım 50 TL',
      imageUrl: 'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'venue_owner',
      status: 'published',
    ),
    Event(
      id: 'event_3',
      venueId: 'venue_2',
      title: 'Karaoke Gecesi & Party',
      description: 'Bahçede açık havada ortak karaoke şenliği! Şarkını seç, sahneye çık ve gecenin yıldızı ol.',
      category: 'Karaoke',
      startDate: DateTime.now().add(const Duration(hours: 26)),
      priceInfo: 'Giriş Ücretsiz',
      imageUrl: 'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      status: 'published',
    ),
  ];

  static final List<Review> reviews = [
    Review(id: 'r_1', venueId: 'venue_1', userDisplayName: 'Ulaş Demirkol', rating: 5, comment: 'Bilardo masaları son derece kaliteli ve düzgündü. Arkadaş grubumuzla çok keyifli bir akşam geçirdik.', visitedActivityName: 'Bilardo', createdAt: DateTime.now().subtract(const Duration(days: 2))),
    Review(id: 'r_2', venueId: 'venue_1', userDisplayName: 'Merve Altın', rating: 4, comment: 'Masa oyunları arşivi mükemmel. Monopoly oynamak için gittik. İçecekler güzel ancak servis biraz yavaş.', visitedActivityName: 'Masa Oyunları', createdAt: DateTime.now().subtract(const Duration(days: 5))),
    Review(id: 'r_3', venueId: 'venue_3', userDisplayName: 'Can Kaynak', rating: 5, comment: 'Catan oyununu kurallarıyla anlatan bir oyun koçunun olması harika. Kesinlikle tekrar geleceğiz.', visitedActivityName: 'Catan', createdAt: DateTime.now().subtract(const Duration(days: 1))),
    Review(id: 'r_4', venueId: 'venue_2', userDisplayName: 'Selin Yılmaz', rating: 4, comment: 'PS5 kabinleri rahat ve ekranlar büyük. Arkadaşlarla FIFA attık, memnun kaldık.', visitedActivityName: 'PS / Konsol', createdAt: DateTime.now().subtract(const Duration(days: 4))),
  ];
}
