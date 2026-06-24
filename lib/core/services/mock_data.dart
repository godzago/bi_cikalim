import 'package:flutter/material.dart';

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

class ActivitySubcategory {
  final String id;
  final String categoryId;
  final String name;

  const ActivitySubcategory({
    required this.id,
    required this.categoryId,
    required this.name,
  });
}

class Activity {
  final String id;
  final String name;
  final String categoryId;
  final String? subcategoryId;
  final String description;
  final IconData icon;
  final int minPeople;
  final int maxPeople;
  final List<String> aliases;

  const Activity({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.icon,
    required this.minPeople,
    required this.maxPeople,
    this.subcategoryId,
    this.aliases = const [],
  });
}

class VenueActivity {
  final String id;
  final String venueId;
  final String activityId;
  final String note;
  final bool isFree;
  final String priceInfo;
  final String sourceType;

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
  final String sourceType;
  final String verificationStatus;
  final String ownershipStatus;
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
  final String sourceType;
  final String status;

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

class MockDatabase {
  static final List<ActivityCategory> categories = [
    const ActivityCategory(
      id: 'masaustu_oyunlar',
      name: 'Masaüstü Oyunlar',
      icon: Icons.casino,
      order: 1,
    ),
    const ActivityCategory(
      id: 'dijital_oyunlar',
      name: 'Dijital Oyunlar',
      icon: Icons.sports_esports,
      order: 2,
    ),
    const ActivityCategory(
      id: 'salon_eglenceleri',
      name: 'Salon Eğlenceleri',
      icon: Icons.celebration,
      order: 3,
    ),
    const ActivityCategory(
      id: 'saha_sporlari',
      name: 'Saha Sporları',
      icon: Icons.sports_soccer,
      order: 4,
    ),
    const ActivityCategory(
      id: 'bireysel_sporlar',
      name: 'Bireysel Sporlar',
      icon: Icons.fitness_center,
      order: 5,
    ),
    const ActivityCategory(
      id: 'macera_deneyim',
      name: 'Macera & Deneyim',
      icon: Icons.explore,
      order: 6,
    ),
  ];

  static final List<ActivitySubcategory> subcategories = [
    const ActivitySubcategory(
      id: 'kutu_oyunlari',
      categoryId: 'masaustu_oyunlar',
      name: 'Kutu Oyunları',
    ),
    const ActivitySubcategory(
      id: 'kart_oyunlari',
      categoryId: 'masaustu_oyunlar',
      name: 'Kart Oyunları',
    ),
    const ActivitySubcategory(
      id: 'frp',
      categoryId: 'masaustu_oyunlar',
      name: 'FRP / TTRPG',
    ),
    const ActivitySubcategory(
      id: 'konsol',
      categoryId: 'dijital_oyunlar',
      name: 'Konsol',
    ),
    const ActivitySubcategory(
      id: 'vr',
      categoryId: 'dijital_oyunlar',
      name: 'VR & Simülasyon',
    ),
    const ActivitySubcategory(
      id: 'bilardo',
      categoryId: 'salon_eglenceleri',
      name: 'Bilardo',
    ),
    const ActivitySubcategory(
      id: 'karaoke',
      categoryId: 'salon_eglenceleri',
      name: 'Karaoke',
    ),
    const ActivitySubcategory(
      id: 'dart',
      categoryId: 'salon_eglenceleri',
      name: 'Dart',
    ),
    const ActivitySubcategory(
      id: 'futbol',
      categoryId: 'saha_sporlari',
      name: 'Futbol',
    ),
    const ActivitySubcategory(
      id: 'tenis',
      categoryId: 'saha_sporlari',
      name: 'Tenis',
    ),
    const ActivitySubcategory(
      id: 'fitness',
      categoryId: 'bireysel_sporlar',
      name: 'Fitness',
    ),
    const ActivitySubcategory(
      id: 'tirmanis',
      categoryId: 'macera_deneyim',
      name: 'Tırmanış',
    ),
    const ActivitySubcategory(
      id: 'escape_room',
      categoryId: 'macera_deneyim',
      name: 'Escape Room',
    ),
  ];

  static final List<Activity> activities = [
    const Activity(
      id: 'catan',
      name: 'Catan',
      categoryId: 'masaustu_oyunlar',
      subcategoryId: 'kutu_oyunlari',
      description: 'Kaynak yönetimi ve ticaret odaklı strateji oyunu.',
      icon: Icons.landscape,
      minPeople: 3,
      maxPeople: 4,
      aliases: ['The Settlers of Catan'],
    ),
    const Activity(
      id: 'monopoly',
      name: 'Monopoly',
      categoryId: 'masaustu_oyunlar',
      subcategoryId: 'kutu_oyunlari',
      description: 'Klasik emlak ticareti ve rekabet oyunu.',
      icon: Icons.monetization_on,
      minPeople: 2,
      maxPeople: 6,
    ),
    const Activity(
      id: 'tabu',
      name: 'Tabu',
      categoryId: 'masaustu_oyunlar',
      subcategoryId: 'kart_oyunlari',
      description: 'Kelime anlatma ve takım iletişimi oyunu.',
      icon: Icons.forum,
      minPeople: 4,
      maxPeople: 10,
    ),
    const Activity(
      id: 'okey',
      name: 'Okey',
      categoryId: 'masaustu_oyunlar',
      subcategoryId: 'kart_oyunlari',
      description: 'Uzun oturumlara uygun klasik taş oyunu.',
      icon: Icons.grid_view,
      minPeople: 4,
      maxPeople: 4,
    ),
    const Activity(
      id: 'dnd_5e',
      name: 'D&D 5e',
      categoryId: 'masaustu_oyunlar',
      subcategoryId: 'frp',
      description: 'Game master eşli oynanan masaüstü rol yapma deneyimi.',
      icon: Icons.auto_awesome,
      minPeople: 3,
      maxPeople: 6,
      aliases: ['Dungeons & Dragons'],
    ),
    const Activity(
      id: 'amerikan_bilardo',
      name: 'Amerikan Bilardo',
      categoryId: 'salon_eglenceleri',
      subcategoryId: 'bilardo',
      description: '8 top ve 9 top için uygun klasik bilardo masası.',
      icon: Icons.sports,
      minPeople: 2,
      maxPeople: 4,
    ),
    const Activity(
      id: 'karaoke_odasi',
      name: 'Özel Karaoke Odası',
      categoryId: 'salon_eglenceleri',
      subcategoryId: 'karaoke',
      description: 'Grup kullanımı için ayrılmış özel karaoke deneyimi.',
      icon: Icons.music_note,
      minPeople: 4,
      maxPeople: 15,
    ),
    const Activity(
      id: 'dart_hedefi',
      name: 'Elektronik Dart',
      categoryId: 'salon_eglenceleri',
      subcategoryId: 'dart',
      description: 'Skor takibi yapan elektronik dart düzeneği.',
      icon: Icons.gps_fixed,
      minPeople: 2,
      maxPeople: 6,
    ),
    const Activity(
      id: 'ps5_fc',
      name: 'PS5 & FC 25',
      categoryId: 'dijital_oyunlar',
      subcategoryId: 'konsol',
      description: 'Yeni nesil konsolda futbol ve rekabet deneyimi.',
      icon: Icons.sports_esports,
      minPeople: 2,
      maxPeople: 4,
      aliases: ['PS5', 'FIFA', 'FC 25'],
    ),
    const Activity(
      id: 'switch_party',
      name: 'Nintendo Switch Party',
      categoryId: 'dijital_oyunlar',
      subcategoryId: 'konsol',
      description: 'Kalabalık gruplar için yarış ve parti oyunları setupı.',
      icon: Icons.videogame_asset,
      minPeople: 2,
      maxPeople: 8,
    ),
    const Activity(
      id: 'vr_shooter',
      name: 'VR Shooter',
      categoryId: 'dijital_oyunlar',
      subcategoryId: 'vr',
      description: 'Sanal gerçeklikte aksiyon ve takım oyunu deneyimi.',
      icon: Icons.vrpano,
      minPeople: 1,
      maxPeople: 4,
    ),
    const Activity(
      id: 'hali_saha',
      name: 'Kapalı Halı Saha',
      categoryId: 'saha_sporlari',
      subcategoryId: 'futbol',
      description: 'Takım maçı ve organizasyon için uygun halı saha.',
      icon: Icons.sports_soccer,
      minPeople: 10,
      maxPeople: 14,
    ),
    const Activity(
      id: 'toprak_kort',
      name: 'Toprak Tenis Kortu',
      categoryId: 'saha_sporlari',
      subcategoryId: 'tenis',
      description: 'Tekler ve çiftler için toprak zemin kort.',
      icon: Icons.sports_tennis,
      minPeople: 2,
      maxPeople: 4,
    ),
    const Activity(
      id: 'fitness_salonu',
      name: 'Fitness Salonu',
      categoryId: 'bireysel_sporlar',
      subcategoryId: 'fitness',
      description: 'Serbest ağırlık ve kondisyon ekipmanları bulunan salon.',
      icon: Icons.fitness_center,
      minPeople: 1,
      maxPeople: 30,
    ),
    const Activity(
      id: 'boulder',
      name: 'Boulder Duvarı',
      categoryId: 'macera_deneyim',
      subcategoryId: 'tirmanis',
      description: 'Farklı zorluk derecelerinde indoor tırmanış rotaları.',
      icon: Icons.terrain,
      minPeople: 1,
      maxPeople: 12,
    ),
    const Activity(
      id: 'escape_room',
      name: 'Escape Room',
      categoryId: 'macera_deneyim',
      subcategoryId: 'escape_room',
      description: 'Takım halinde bulmaca çözmeye dayalı oda kaçış deneyimi.',
      icon: Icons.meeting_room,
      minPeople: 2,
      maxPeople: 6,
    ),
  ];

  static final List<Venue> venues = [
    const Venue(
      id: 'venue_1',
      name: 'Roll & Play Cafe',
      slug: 'roll-play-cafe',
      description:
          'Eskişehir’de geniş masaüstü oyun seçkisi, bilardo alanı ve özel karaoke odalarıyla arkadaş grupları için güçlü bir sosyal buluşma noktası.',
      city: 'Eskişehir',
      district: 'Odunpazarı',
      address: 'Akarbaşı Mh., Atatürk Cd. No: 42, Odunpazarı/Eskişehir',
      latitude: 39.768,
      longitude: 30.522,
      phone: '+90 222 333 44 55',
      instagramUrl: 'https://instagram.com/rollplaycafe',
      coverImageUrl:
          'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'venue_owner',
      verificationStatus: 'verified',
      ownershipStatus: 'claimed',
      averageRating: 4.8,
      reviewCount: 312,
      activityTags: ['Masaüstü Oyunlar', 'Bilardo', 'Karaoke'],
    ),
    const Venue(
      id: 'venue_2',
      name: 'Social Lounge Pub & Game',
      slug: 'social-lounge',
      description:
          'Konsol kabinleri, dart alanı ve etkinlik akşamlarıyla genç kitleye hitap eden hibrit oyun-eğlence mekanı.',
      city: 'Eskişehir',
      district: 'Tepebaşı',
      address: 'Hoşnudiye Mh., Vural Sk. No: 12, Tepebaşı/Eskişehir',
      latitude: 39.782,
      longitude: 30.518,
      phone: '+90 222 444 55 66',
      instagramUrl: 'https://instagram.com/socialloungeesk',
      coverImageUrl:
          'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      verificationStatus: 'unverified',
      ownershipStatus: 'unclaimed',
      averageRating: 4.3,
      reviewCount: 145,
      activityTags: ['Dijital Oyunlar', 'Dart'],
    ),
    const Venue(
      id: 'venue_3',
      name: 'Meeple Board Game Cafe',
      slug: 'meeple-board-game-cafe',
      description:
          'Yoğun kutu oyunu envanteri ve düzenli masa oyunu buluşmalarıyla şehirdeki masaüstü oyun odaklı mekanlardan biri.',
      city: 'Eskişehir',
      district: 'Odunpazarı',
      address: 'İstiklal Mah., Adalar Sok. No: 31A, Odunpazarı/Eskişehir',
      latitude: 39.772,
      longitude: 30.518,
      phone: '+90 555 706 71 64',
      instagramUrl: 'https://instagram.com/meepleboardgamecafe',
      coverImageUrl:
          'https://images.unsplash.com/photo-1606167668584-78701c57f13d?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'venue_owner',
      verificationStatus: 'verified',
      ownershipStatus: 'claimed',
      averageRating: 4.9,
      reviewCount: 228,
      activityTags: ['Masaüstü Oyunlar', 'FRP'],
    ),
    const Venue(
      id: 'venue_4',
      name: 'Bento Spor Kompleksi',
      slug: 'bento-spor-kompleksi',
      description:
          'Kapalı ve açık halı saha, toprak tenis kortları ve sosyal alanlarıyla spor odaklı kompleks.',
      city: 'Eskişehir',
      district: 'Odunpazarı',
      address: 'OSB Yaşam Park, Odunpazarı/Eskişehir',
      latitude: 39.742,
      longitude: 30.495,
      phone: '+90 536 726 26 86',
      instagramUrl: 'https://instagram.com/bento.spor',
      coverImageUrl:
          'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      verificationStatus: 'unverified',
      ownershipStatus: 'unclaimed',
      averageRating: 4.5,
      reviewCount: 89,
      activityTags: ['Saha Sporları', 'Tenis'],
    ),
    const Venue(
      id: 'venue_5',
      name: 'XP VR Station',
      slug: 'xp-vr-station',
      description:
          'Sanal gerçeklik oyunları ve dijital deneyim odaklı özel oyun salonu.',
      city: 'Eskişehir',
      district: 'Tepebaşı',
      address: 'Hoşnudiye Mah., Tepebaşı/Eskişehir',
      latitude: 39.783,
      longitude: 30.512,
      phone: '+90 222 000 00 00',
      instagramUrl: 'https://instagram.com/xpvrstation',
      coverImageUrl:
          'https://images.unsplash.com/photo-1593508512255-86ab42a8e620?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      verificationStatus: 'unverified',
      ownershipStatus: 'unclaimed',
      averageRating: 4.4,
      reviewCount: 64,
      activityTags: ['Dijital Oyunlar', 'VR'],
    ),
    const Venue(
      id: 'venue_6',
      name: 'Boulder Eskişehir',
      slug: 'boulder-eskisehir',
      description:
          'Indoor boulder ve tırmanış deneyimi sunan topluluk odaklı spor alanı.',
      city: 'Eskişehir',
      district: 'Tepebaşı',
      address: 'Tepebaşı/Eskişehir',
      latitude: 39.789,
      longitude: 30.501,
      phone: '+90 555 026 26 49',
      instagramUrl: 'https://instagram.com/boulderes',
      coverImageUrl:
          'https://images.unsplash.com/photo-1522163182402-834f871fd851?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      verificationStatus: 'unverified',
      ownershipStatus: 'unclaimed',
      averageRating: 4.7,
      reviewCount: 41,
      activityTags: ['Macera & Deneyim', 'Bireysel Sporlar'],
    ),
    const Venue(
      id: 'venue_7',
      name: 'Kilitli Oda',
      slug: 'kilitli-oda',
      description:
          'Küçük gruplar için bulmaca çözme ve takım deneyimi odaklı escape room mekanı.',
      city: 'Eskişehir',
      district: 'Tepebaşı',
      address: 'İsmet İnönü-1 Cd. No: 60, Tepebaşı/Eskişehir',
      latitude: 39.781,
      longitude: 30.514,
      phone: '+90 544 441 56 32',
      instagramUrl: 'https://instagram.com/kilitlioda',
      coverImageUrl:
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      verificationStatus: 'unverified',
      ownershipStatus: 'unclaimed',
      averageRating: 4.2,
      reviewCount: 38,
      activityTags: ['Macera & Deneyim', 'Escape Room'],
    ),
  ];

  static final List<VenueActivity> venueActivities = [
    const VenueActivity(
      id: 'va_1',
      venueId: 'venue_1',
      activityId: 'monopoly',
      note: 'Klasik ve büyük kutu versiyonları mevcut.',
      isFree: true,
      priceInfo: 'Ücretsiz',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_2',
      venueId: 'venue_1',
      activityId: 'catan',
      note: 'Genişleme paketleriyle oynanabilir.',
      isFree: false,
      priceInfo: 'Masa kullanımına dahil',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_3',
      venueId: 'venue_1',
      activityId: 'amerikan_bilardo',
      note: '4 adet profesyonel masa mevcut.',
      isFree: false,
      priceInfo: 'Saatlik 120 TL',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_4',
      venueId: 'venue_1',
      activityId: 'karaoke_odasi',
      note: 'Özel oda rezervasyonu önerilir.',
      isFree: false,
      priceInfo: 'Saatlik 250 TL',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_5',
      venueId: 'venue_2',
      activityId: 'ps5_fc',
      note: 'VIP kabinlerde çoklu ekran setupı var.',
      isFree: false,
      priceInfo: 'Saatlik 90 TL',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_6',
      venueId: 'venue_2',
      activityId: 'dart_hedefi',
      note: 'Elektronik skor takibi mevcut.',
      isFree: true,
      priceInfo: 'Ücretsiz',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_7',
      venueId: 'venue_2',
      activityId: 'switch_party',
      note: 'Parti oyunları için ayrılmış couch alanı bulunuyor.',
      isFree: false,
      priceInfo: 'Saatlik paket',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_8',
      venueId: 'venue_3',
      activityId: 'catan',
      note: 'Öğretici masa desteği veriliyor.',
      isFree: true,
      priceInfo: 'Ücretsiz',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_9',
      venueId: 'venue_3',
      activityId: 'tabu',
      note: 'Kalabalık grup için hızlı başlangıç oyunu olarak öneriliyor.',
      isFree: true,
      priceInfo: 'Ücretsiz',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_10',
      venueId: 'venue_3',
      activityId: 'dnd_5e',
      note: 'Belirli günlerde GM eşli masa kuruluyor.',
      isFree: false,
      priceInfo: 'Etkinliğe göre değişir',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_11',
      venueId: 'venue_3',
      activityId: 'okey',
      note: 'Uzun oturum için sessiz arka masa alanı var.',
      isFree: true,
      priceInfo: 'Ücretsiz',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_12',
      venueId: 'venue_4',
      activityId: 'hali_saha',
      note: 'Kapalı ve açık saha seçenekleri var.',
      isFree: false,
      priceInfo: 'Rezervasyonlu kullanım',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_13',
      venueId: 'venue_4',
      activityId: 'toprak_kort',
      note: 'Açık ve kapalı kort seçenekleri sunuluyor.',
      isFree: false,
      priceInfo: 'Saatlik kiralama',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_14',
      venueId: 'venue_5',
      activityId: 'vr_shooter',
      note: 'Tekli ve çoklu senaryolar var.',
      isFree: false,
      priceInfo: 'Seans bazlı ücretlendirme',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_15',
      venueId: 'venue_6',
      activityId: 'boulder',
      note: 'Başlangıç ve orta seviye rotalar mevcut.',
      isFree: false,
      priceInfo: 'Günlük giriş',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_16',
      venueId: 'venue_6',
      activityId: 'fitness_salonu',
      note: 'Isınma ve kondisyon için destek alanı bulunuyor.',
      isFree: false,
      priceInfo: 'Girişe dahil',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_17',
      venueId: 'venue_7',
      activityId: 'escape_room',
      note: '2-6 kişilik ekiplerle oynanabilir.',
      isFree: false,
      priceInfo: 'Oda başı rezervasyon',
      sourceType: 'editor',
    ),
  ];

  static final List<Event> events = [
    Event(
      id: 'event_1',
      venueId: 'venue_1',
      title: 'Quiz Night: Genel Kültür & Sinema',
      description:
          '4 kişilik takımını kur, ödüllü quiz gecesine katıl ve sürpriz ödüller kazan.',
      category: 'Quiz Night',
      startDate: DateTime.now().add(const Duration(hours: 4)),
      priceInfo: 'Ücretsiz Giriş',
      imageUrl:
          'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'venue_owner',
      status: 'published',
    ),
    Event(
      id: 'event_2',
      venueId: 'venue_3',
      title: 'Catan Turnuvası',
      description:
          'Strateji ve masaüstü oyun meraklılarını bir araya getiren dostluk turnuvası.',
      category: 'Masaüstü Oyunlar',
      startDate: DateTime.now().add(const Duration(days: 1, hours: 2)),
      priceInfo: 'Katılım 50 TL',
      imageUrl:
          'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'venue_owner',
      status: 'published',
    ),
    Event(
      id: 'event_3',
      venueId: 'venue_2',
      title: 'Karaoke Gecesi & Party',
      description:
          'Açık alanda sahneli karaoke ve grup oyunlarıyla sosyal bir akşam.',
      category: 'Karaoke',
      startDate: DateTime.now().add(const Duration(hours: 26)),
      priceInfo: 'Giriş Ücretsiz',
      imageUrl:
          'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      status: 'published',
    ),
    Event(
      id: 'event_4',
      venueId: 'venue_6',
      title: 'Başlangıç Boulder Workshop',
      description:
          'İlk kez tırmanacaklar için kısa teknik giriş ve eşli rota denemeleri.',
      category: 'Tırmanış',
      startDate: DateTime.now().add(const Duration(days: 2, hours: 5)),
      priceInfo: 'Katılım 180 TL',
      imageUrl:
          'https://images.unsplash.com/photo-1522163182402-834f871fd851?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      status: 'published',
    ),
  ];

  static final List<Review> reviews = [
    Review(
      id: 'r_1',
      venueId: 'venue_1',
      userDisplayName: 'Ulaş Demirkol',
      rating: 5,
      comment:
          'Bilardo masaları çok kaliteli ve karaoke odası arkadaş grubuyla gitmek için gerçekten ideal.',
      visitedActivityName: 'Amerikan Bilardo',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Review(
      id: 'r_2',
      venueId: 'venue_1',
      userDisplayName: 'Merve Altın',
      rating: 4,
      comment:
          'Masaüstü oyun seçkisi iyi, özellikle Catan ve Monopoly için geldik. Servis biraz daha hızlı olabilir.',
      visitedActivityName: 'Catan',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Review(
      id: 'r_3',
      venueId: 'venue_3',
      userDisplayName: 'Can Kaynak',
      rating: 5,
      comment:
          'Düzenli oyun geceleri ve öğretici masa kültürü sayesinde yeni oyun öğrenmek kolay.',
      visitedActivityName: 'D&D 5e',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Review(
      id: 'r_4',
      venueId: 'venue_5',
      userDisplayName: 'Selin Yılmaz',
      rating: 4,
      comment:
          'VR deneyimi beklediğimden daha keyifliydi, özellikle grup halinde gidince çok eğlenceli oluyor.',
      visitedActivityName: 'VR Shooter',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  static ActivityCategory getCategoryById(String id) {
    return categories.firstWhere((category) => category.id == id);
  }

  static ActivitySubcategory? getSubcategoryById(String? id) {
    if (id == null) return null;
    return subcategories.firstWhere((subcategory) => subcategory.id == id);
  }
}
