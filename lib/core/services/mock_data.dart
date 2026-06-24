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
      name: 'Masaustu Oyunlar',
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
      name: 'Salon Eglenceleri',
      icon: Icons.celebration,
      order: 3,
    ),
    const ActivityCategory(
      id: 'saha_sporlari',
      name: 'Saha Sporlari',
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
      name: 'Macera ve Deneyim',
      icon: Icons.explore,
      order: 6,
    ),
  ];

  static final List<ActivitySubcategory> subcategories = [
    const ActivitySubcategory(
      id: 'kutu_oyunlari',
      categoryId: 'masaustu_oyunlar',
      name: 'Kutu Oyunlari',
    ),
    const ActivitySubcategory(
      id: 'kart_oyunlari',
      categoryId: 'masaustu_oyunlar',
      name: 'Kart ve Tas Oyunlari',
    ),
    const ActivitySubcategory(
      id: 'frp',
      categoryId: 'masaustu_oyunlar',
      name: 'FRP ve TTRPG',
    ),
    const ActivitySubcategory(
      id: 'konsol',
      categoryId: 'dijital_oyunlar',
      name: 'Konsol',
    ),
    const ActivitySubcategory(
      id: 'vr',
      categoryId: 'dijital_oyunlar',
      name: 'VR ve Simulator',
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
      id: 'sosyal_gece',
      categoryId: 'salon_eglenceleri',
      name: 'Sosyal Gece',
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
      id: 'raket',
      categoryId: 'saha_sporlari',
      name: 'Raket Sporlari',
    ),
    const ActivitySubcategory(
      id: 'fitness',
      categoryId: 'bireysel_sporlar',
      name: 'Fitness',
    ),
    const ActivitySubcategory(
      id: 'wellness',
      categoryId: 'bireysel_sporlar',
      name: 'Wellness Studio',
    ),
    const ActivitySubcategory(
      id: 'tirmanis',
      categoryId: 'macera_deneyim',
      name: 'Tirmanis',
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
      description: 'Kaynak yonetimi ve ticaret odakli strateji oyunu.',
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
      id: 'azul',
      name: 'Azul',
      categoryId: 'masaustu_oyunlar',
      subcategoryId: 'kutu_oyunlari',
      description: 'Kisa sureli ama karar agirligi yuksek kutu oyunu.',
      icon: Icons.grid_on,
      minPeople: 2,
      maxPeople: 4,
    ),
    const Activity(
      id: 'tabu',
      name: 'Tabu',
      categoryId: 'masaustu_oyunlar',
      subcategoryId: 'kart_oyunlari',
      description: 'Kelime anlatma ve takim iletisim oyunu.',
      icon: Icons.forum,
      minPeople: 4,
      maxPeople: 10,
    ),
    const Activity(
      id: 'okey',
      name: 'Okey',
      categoryId: 'masaustu_oyunlar',
      subcategoryId: 'kart_oyunlari',
      description: 'Uzun oturumlara uygun klasik tas oyunu.',
      icon: Icons.grid_view,
      minPeople: 4,
      maxPeople: 4,
    ),
    const Activity(
      id: 'magic_commander',
      name: 'Magic Commander',
      categoryId: 'masaustu_oyunlar',
      subcategoryId: 'kart_oyunlari',
      description: 'Koleksiyon kart oyunu icin sosyal format masalari.',
      icon: Icons.style,
      minPeople: 2,
      maxPeople: 4,
    ),
    const Activity(
      id: 'dnd_5e',
      name: 'D&D 5e',
      categoryId: 'masaustu_oyunlar',
      subcategoryId: 'frp',
      description: 'Game master esli masaustu rol yapma deneyimi.',
      icon: Icons.auto_awesome,
      minPeople: 3,
      maxPeople: 6,
      aliases: ['Dungeons and Dragons'],
    ),
    const Activity(
      id: 'call_of_cthulhu',
      name: 'Call of Cthulhu',
      categoryId: 'masaustu_oyunlar',
      subcategoryId: 'frp',
      description: 'Dedektiflik ve gerilim odakli rol yapma oturumlari.',
      icon: Icons.nightlight,
      minPeople: 3,
      maxPeople: 6,
    ),
    const Activity(
      id: 'ps5_fc',
      name: 'PS5 and FC 25',
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
      description: 'Kalabalik gruplar icin yariş ve party oyunlari.',
      icon: Icons.videogame_asset,
      minPeople: 2,
      maxPeople: 8,
    ),
    const Activity(
      id: 'retro_arcade',
      name: 'Retro Arcade',
      categoryId: 'dijital_oyunlar',
      subcategoryId: 'konsol',
      description: 'Retro cihazlar ve atari klasiklerini oynama alani.',
      icon: Icons.gamepad,
      minPeople: 1,
      maxPeople: 4,
    ),
    const Activity(
      id: 'vr_shooter',
      name: 'VR Shooter',
      categoryId: 'dijital_oyunlar',
      subcategoryId: 'vr',
      description: 'Sanal gerceklikte aksiyon ve takim oyunu deneyimi.',
      icon: Icons.vrpano,
      minPeople: 1,
      maxPeople: 4,
    ),
    const Activity(
      id: 'racing_sim',
      name: 'Racing Simulator',
      categoryId: 'dijital_oyunlar',
      subcategoryId: 'vr',
      description: 'Direksiyon setli araba yarisi simulatoru.',
      icon: Icons.sports_motorsports,
      minPeople: 1,
      maxPeople: 2,
    ),
    const Activity(
      id: 'amerikan_bilardo',
      name: 'Amerikan Bilardo',
      categoryId: 'salon_eglenceleri',
      subcategoryId: 'bilardo',
      description: '8 top ve 9 top icin uygun klasik masa.',
      icon: Icons.sports,
      minPeople: 2,
      maxPeople: 4,
    ),
    const Activity(
      id: 'snooker',
      name: 'Snooker',
      categoryId: 'salon_eglenceleri',
      subcategoryId: 'bilardo',
      description: 'Uzun oturumlara uygun tam boy masa kurulumu.',
      icon: Icons.sports_bar,
      minPeople: 2,
      maxPeople: 4,
    ),
    const Activity(
      id: 'karaoke_odasi',
      name: 'Ozel Karaoke Odasi',
      categoryId: 'salon_eglenceleri',
      subcategoryId: 'karaoke',
      description: 'Grup kullanimi icin ayrilmis ozel karaoke deneyimi.',
      icon: Icons.music_note,
      minPeople: 4,
      maxPeople: 15,
    ),
    const Activity(
      id: 'open_mic_karaoke',
      name: 'Open Mic Karaoke',
      categoryId: 'salon_eglenceleri',
      subcategoryId: 'sosyal_gece',
      description: 'Acik sahnede sarkili sosyal karaoke duzeni.',
      icon: Icons.mic_external_on,
      minPeople: 1,
      maxPeople: 40,
    ),
    const Activity(
      id: 'dart_hedefi',
      name: 'Elektronik Dart',
      categoryId: 'salon_eglenceleri',
      subcategoryId: 'dart',
      description: 'Skor takibi yapan elektronik dart duzenegi.',
      icon: Icons.gps_fixed,
      minPeople: 2,
      maxPeople: 6,
    ),
    const Activity(
      id: 'hali_saha',
      name: 'Kapali Hali Saha',
      categoryId: 'saha_sporlari',
      subcategoryId: 'futbol',
      description: 'Takim maci ve organizasyon icin uygun hali saha.',
      icon: Icons.sports_soccer,
      minPeople: 10,
      maxPeople: 14,
    ),
    const Activity(
      id: 'acik_saha',
      name: 'Acik Hali Saha',
      categoryId: 'saha_sporlari',
      subcategoryId: 'futbol',
      description: 'Yaz aksamlarina uygun acik saha rezervasyonu.',
      icon: Icons.sports_soccer_outlined,
      minPeople: 10,
      maxPeople: 14,
    ),
    const Activity(
      id: 'toprak_kort',
      name: 'Toprak Tenis Kortu',
      categoryId: 'saha_sporlari',
      subcategoryId: 'raket',
      description: 'Tekler ve ciftler icin toprak zemin kort.',
      icon: Icons.sports_tennis,
      minPeople: 2,
      maxPeople: 4,
    ),
    const Activity(
      id: 'padel_court',
      name: 'Padel Court',
      categoryId: 'saha_sporlari',
      subcategoryId: 'raket',
      description: 'Ciftler odakli padel oyun alani.',
      icon: Icons.sports_tennis,
      minPeople: 2,
      maxPeople: 4,
    ),
    const Activity(
      id: 'fitness_salonu',
      name: 'Fitness Salonu',
      categoryId: 'bireysel_sporlar',
      subcategoryId: 'fitness',
      description: 'Serbest agirlik ve kondisyon ekipmanlari bulunan salon.',
      icon: Icons.fitness_center,
      minPeople: 1,
      maxPeople: 30,
    ),
    const Activity(
      id: 'spinning',
      name: 'Spinning Studio',
      categoryId: 'bireysel_sporlar',
      subcategoryId: 'fitness',
      description: 'Muzikli grup kondisyon dersleri icin studio setupi.',
      icon: Icons.directions_bike,
      minPeople: 6,
      maxPeople: 18,
    ),
    const Activity(
      id: 'reformer',
      name: 'Reformer Pilates',
      categoryId: 'bireysel_sporlar',
      subcategoryId: 'wellness',
      description: 'Kucuk grup veya birebir reformer calisma alani.',
      icon: Icons.self_improvement,
      minPeople: 1,
      maxPeople: 6,
    ),
    const Activity(
      id: 'boulder',
      name: 'Boulder Duvasi',
      categoryId: 'macera_deneyim',
      subcategoryId: 'tirmanis',
      description: 'Farkli zorluk derecelerinde indoor tirmanis rotalari.',
      icon: Icons.terrain,
      minPeople: 1,
      maxPeople: 12,
    ),
    const Activity(
      id: 'lead_climbing',
      name: 'Top Rope Tirmanis',
      categoryId: 'macera_deneyim',
      subcategoryId: 'tirmanis',
      description: 'Eslikli uzun rota tirmanis deneyimi.',
      icon: Icons.hiking,
      minPeople: 1,
      maxPeople: 10,
    ),
    const Activity(
      id: 'escape_room',
      name: 'Escape Room',
      categoryId: 'macera_deneyim',
      subcategoryId: 'escape_room',
      description: 'Takim halinde bulmaca cozmeye dayali kacis deneyimi.',
      icon: Icons.meeting_room,
      minPeople: 2,
      maxPeople: 6,
    ),
    const Activity(
      id: 'detective_room',
      name: 'Dedektif Oda Senaryosu',
      categoryId: 'macera_deneyim',
      subcategoryId: 'escape_room',
      description: 'Kaniti takip eden hikaye odakli escape room deneyimi.',
      icon: Icons.search,
      minPeople: 2,
      maxPeople: 6,
    ),
  ];

  static final List<Venue> venues = [
    const Venue(
      id: 'venue_1',
      name: 'Roll and Play Cafe',
      slug: 'roll-play-cafe',
      description:
          'Eskisehirde genis masaustu oyun secimi, bilardo alani ve ozel karaoke odalariyla guclu bir sosyal bulusma noktasi.',
      city: 'Eskisehir',
      district: 'Odunpazari',
      address: 'Akarbasi Mah. Ataturk Cad. No:42 Odunpazari',
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
      activityTags: ['Masaustu Oyunlar', 'Bilardo', 'Karaoke'],
    ),
    const Venue(
      id: 'venue_2',
      name: 'Social Lounge Pub and Game',
      slug: 'social-lounge',
      description:
          'Konsol kabinleri, dart alani ve etkinlik aksamlariyla genc kitleye hitap eden hibrit oyun eglence mekani.',
      city: 'Eskisehir',
      district: 'Tepebasi',
      address: 'Hosnudiye Mah. Vural Sok. No:12 Tepebasi',
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
          'Yogun kutu oyunu envanteri ve duzenli masa oyunu bulusmalariyla sehirdeki masaustu odakli mekanlardan biri.',
      city: 'Eskisehir',
      district: 'Odunpazari',
      address: 'Istiklal Mah. Adalar Sok. No:31A Odunpazari',
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
      activityTags: ['Masaustu Oyunlar', 'FRP'],
    ),
    const Venue(
      id: 'venue_4',
      name: 'Bento Spor Kompleksi',
      slug: 'bento-spor-kompleksi',
      description:
          'Kapali ve acik hali saha, tenis kortlari ve sosyal alanlariyla spor odakli kompleks.',
      city: 'Eskisehir',
      district: 'Odunpazari',
      address: 'OSB Yasam Park Odunpazari',
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
      activityTags: ['Saha Sporlari', 'Tenis'],
    ),
    const Venue(
      id: 'venue_5',
      name: 'XP VR Station',
      slug: 'xp-vr-station',
      description:
          'Sanal gerceklik oyunlari ve dijital deneyim odakli ozel oyun salonu.',
      city: 'Eskisehir',
      district: 'Tepebasi',
      address: 'Hosnudiye Mah. Tepebasi',
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
      name: 'Boulder Eskisehir',
      slug: 'boulder-eskisehir',
      description:
          'Indoor boulder ve tirmanis deneyimi sunan topluluk odakli spor alani.',
      city: 'Eskisehir',
      district: 'Tepebasi',
      address: 'Fabrikalar Bolgesi Tepebasi',
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
      activityTags: ['Macera ve Deneyim', 'Bireysel Sporlar'],
    ),
    const Venue(
      id: 'venue_7',
      name: 'Kilitli Oda',
      slug: 'kilitli-oda',
      description:
          'Kucuk gruplar icin bulmaca cozme ve takim deneyimi odakli escape room mekani.',
      city: 'Eskisehir',
      district: 'Tepebasi',
      address: 'Ismet Inonu 1 Cad. No:60 Tepebasi',
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
      activityTags: ['Macera ve Deneyim', 'Escape Room'],
    ),
    const Venue(
      id: 'venue_8',
      name: 'Analog House',
      slug: 'analog-house',
      description:
          'Kutu oyunlari, kart oyunlari ve sakin calisma koseleriyle uzun oturumlara uygun kafe.',
      city: 'Eskisehir',
      district: 'Adalar',
      address: 'Porsuk Bulvari No:18 Adalar',
      latitude: 39.776,
      longitude: 30.525,
      phone: '+90 222 219 19 19',
      instagramUrl: 'https://instagram.com/analoghouseesk',
      coverImageUrl:
          'https://images.unsplash.com/photo-1511988617509-a57c8a288659?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      verificationStatus: 'unverified',
      ownershipStatus: 'unclaimed',
      averageRating: 4.6,
      reviewCount: 102,
      activityTags: ['Masaustu Oyunlar', 'Kart Oyunlari'],
    ),
    const Venue(
      id: 'venue_9',
      name: 'Dungeon Tabletop Hub',
      slug: 'dungeon-tabletop-hub',
      description:
          'FRP oturumlari, miniatur masa duzeni ve uzun kampanyalara uygun rezervasyonlu alanlar sunar.',
      city: 'Eskisehir',
      district: 'Doktorlar',
      address: 'Sivrihisar 1 Cad. No:72 Doktorlar',
      latitude: 39.779,
      longitude: 30.519,
      phone: '+90 552 101 20 20',
      instagramUrl: 'https://instagram.com/dungeonesk',
      coverImageUrl:
          'https://images.unsplash.com/photo-1560179406-1c6c60e0dc76?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'venue_owner',
      verificationStatus: 'verified',
      ownershipStatus: 'claimed',
      averageRating: 4.9,
      reviewCount: 87,
      activityTags: ['FRP', 'Masaustu Oyunlar'],
    ),
    const Venue(
      id: 'venue_10',
      name: 'Retro Pixel Cafe',
      slug: 'retro-pixel-cafe',
      description:
          'Retro konsollar, arcade setup ve nostaljik oyun geceleriyle dijital oyun odakli bulusma mekani.',
      city: 'Eskisehir',
      district: 'Hosnudiye',
      address: 'Basin Sehitleri Cad. No:9 Hosnudiye',
      latitude: 39.784,
      longitude: 30.516,
      phone: '+90 553 212 47 47',
      instagramUrl: 'https://instagram.com/retropixelesk',
      coverImageUrl:
          'https://images.unsplash.com/photo-1511882150382-421056c89033?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      verificationStatus: 'unverified',
      ownershipStatus: 'unclaimed',
      averageRating: 4.5,
      reviewCount: 73,
      activityTags: ['Dijital Oyunlar', 'Retro Arcade'],
    ),
    const Venue(
      id: 'venue_11',
      name: 'Loop Karaoke Rooms',
      slug: 'loop-karaoke-rooms',
      description:
          'Saatlik kiralanabilen ozel odalar ve open mic geceleriyle karaoke odakli deneyim sunar.',
      city: 'Eskisehir',
      district: 'Baglar',
      address: 'Baglar Cad. No:27 Baglar',
      latitude: 39.773,
      longitude: 30.509,
      phone: '+90 530 450 45 45',
      instagramUrl: 'https://instagram.com/loopkaraoke',
      coverImageUrl:
          'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      verificationStatus: 'unverified',
      ownershipStatus: 'unclaimed',
      averageRating: 4.1,
      reviewCount: 56,
      activityTags: ['Karaoke', 'Salon Eglenceleri'],
    ),
    const Venue(
      id: 'venue_12',
      name: 'Midas Snooker Hall',
      slug: 'midas-snooker-hall',
      description:
          'Snooker ve amerikan bilardo masalariyla seri oyunculara hitap eden klasik salon.',
      city: 'Eskisehir',
      district: 'Yenibaglar',
      address: 'Yenibaglar Mah. No:14 Yenibaglar',
      latitude: 39.771,
      longitude: 30.505,
      phone: '+90 543 330 88 88',
      instagramUrl: 'https://instagram.com/midassnooker',
      coverImageUrl:
          'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      verificationStatus: 'unverified',
      ownershipStatus: 'unclaimed',
      averageRating: 4.4,
      reviewCount: 68,
      activityTags: ['Bilardo', 'Snooker'],
    ),
    const Venue(
      id: 'venue_13',
      name: 'Adalar Racket Club',
      slug: 'adalar-racket-club',
      description:
          'Padel ve tenis odakli, ders ve saatlik rezervasyon modeliyle isleyen kulup.',
      city: 'Eskisehir',
      district: 'Adalar',
      address: 'Adalar Park yani',
      latitude: 39.778,
      longitude: 30.527,
      phone: '+90 531 700 00 11',
      instagramUrl: 'https://instagram.com/adalarracket',
      coverImageUrl:
          'https://images.unsplash.com/photo-1542144582-1ba00456b5e3?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      verificationStatus: 'unverified',
      ownershipStatus: 'unclaimed',
      averageRating: 4.6,
      reviewCount: 44,
      activityTags: ['Saha Sporlari', 'Padel'],
    ),
    const Venue(
      id: 'venue_14',
      name: 'Well Studio Eskisehir',
      slug: 'well-studio-eskisehir',
      description:
          'Reformer, spinning ve kucuk grup dersleriyle daha butik bir spor deneyimi sunar.',
      city: 'Eskisehir',
      district: 'Hosnudiye',
      address: 'Hosnudiye Mah. Isiklar Sok. No:6',
      latitude: 39.786,
      longitude: 30.514,
      phone: '+90 537 112 00 98',
      instagramUrl: 'https://instagram.com/wellstudioesk',
      coverImageUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      verificationStatus: 'unverified',
      ownershipStatus: 'unclaimed',
      averageRating: 4.7,
      reviewCount: 59,
      activityTags: ['Bireysel Sporlar', 'Wellness'],
    ),
    const Venue(
      id: 'venue_15',
      name: 'GoalPark Indoor',
      slug: 'goalpark-indoor',
      description:
          'Mac organizasyonu, takim bulma ve gece seanslariyla odaklanan yogun bir hali saha tesisi.',
      city: 'Eskisehir',
      district: 'Batikent',
      address: 'Batikent Spor Alani',
      latitude: 39.759,
      longitude: 30.489,
      phone: '+90 541 700 70 70',
      instagramUrl: 'https://instagram.com/goalparkindoor',
      coverImageUrl:
          'https://images.unsplash.com/photo-1522778119026-d647f0596c20?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      verificationStatus: 'unverified',
      ownershipStatus: 'unclaimed',
      averageRating: 4.3,
      reviewCount: 91,
      activityTags: ['Saha Sporlari', 'Futbol'],
    ),
  ];

  static final List<VenueActivity> venueActivities = [
    const VenueActivity(
      id: 'va_1',
      venueId: 'venue_1',
      activityId: 'monopoly',
      note: 'Klasik ve buyuk kutu versiyonlari mevcut.',
      isFree: true,
      priceInfo: 'Ucretsiz',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_2',
      venueId: 'venue_1',
      activityId: 'catan',
      note: 'Genisleme paketleriyle oynanabilir.',
      isFree: false,
      priceInfo: 'Masa kullanimina dahil',
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
      note: 'Ozel oda rezervasyonu onerilir.',
      isFree: false,
      priceInfo: 'Saatlik 250 TL',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_5',
      venueId: 'venue_2',
      activityId: 'ps5_fc',
      note: 'VIP kabinlerde coklu ekran setuplari var.',
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
      priceInfo: 'Ucretsiz',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_7',
      venueId: 'venue_2',
      activityId: 'switch_party',
      note: 'Couch alanda 8 kisilik party setup var.',
      isFree: false,
      priceInfo: 'Saatlik paket',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_8',
      venueId: 'venue_3',
      activityId: 'catan',
      note: 'Ogretici masa destegi veriliyor.',
      isFree: true,
      priceInfo: 'Ucretsiz',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_9',
      venueId: 'venue_3',
      activityId: 'tabu',
      note: 'Kalabalik grup icin hizli baslangic oyunu.',
      isFree: true,
      priceInfo: 'Ucretsiz',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_10',
      venueId: 'venue_3',
      activityId: 'dnd_5e',
      note: 'Belirli gunlerde GM esli masa kuruluyor.',
      isFree: false,
      priceInfo: 'Etkinlige gore degisir',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_11',
      venueId: 'venue_4',
      activityId: 'hali_saha',
      note: 'Kapali ve acik saha secenekleri var.',
      isFree: false,
      priceInfo: 'Rezervasyonlu kullanim',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_12',
      venueId: 'venue_4',
      activityId: 'toprak_kort',
      note: 'Aydinlatmali kort secenekleri bulunuyor.',
      isFree: false,
      priceInfo: 'Saatlik kiralama',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_13',
      venueId: 'venue_5',
      activityId: 'vr_shooter',
      note: 'Tekli ve coklu senaryolar var.',
      isFree: false,
      priceInfo: 'Seans bazli',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_14',
      venueId: 'venue_5',
      activityId: 'racing_sim',
      note: 'Direksiyon setli simulator podlari mevcut.',
      isFree: false,
      priceInfo: '20 dk paket',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_15',
      venueId: 'venue_6',
      activityId: 'boulder',
      note: 'Baslangic ve orta seviye rotalar mevcut.',
      isFree: false,
      priceInfo: 'Gunluk giris',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_16',
      venueId: 'venue_6',
      activityId: 'lead_climbing',
      note: 'Partnerli tirmanis slotlari aciliyor.',
      isFree: false,
      priceInfo: 'Seans bazli',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_17',
      venueId: 'venue_7',
      activityId: 'escape_room',
      note: '2-6 kisilik ekiplerle oynanabilir.',
      isFree: false,
      priceInfo: 'Oda basi rezervasyon',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_18',
      venueId: 'venue_7',
      activityId: 'detective_room',
      note: 'Hikaye odakli yeni sezon senaryosu eklendi.',
      isFree: false,
      priceInfo: 'Premium senaryo',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_19',
      venueId: 'venue_8',
      activityId: 'azul',
      note: 'Kisa sureli oyunlar icin raf bolumu ayrilmistir.',
      isFree: true,
      priceInfo: 'Ucretsiz',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_20',
      venueId: 'venue_8',
      activityId: 'magic_commander',
      note: 'Kart karsilasma aksamlarinda masa ayrilir.',
      isFree: false,
      priceInfo: 'Etkinlik gunu masa payi',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_21',
      venueId: 'venue_8',
      activityId: 'okey',
      note: 'Sessiz arka bolumde uzun oturum duzeni var.',
      isFree: true,
      priceInfo: 'Ucretsiz',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_22',
      venueId: 'venue_9',
      activityId: 'dnd_5e',
      note: 'Kampanya masalari haftalik ayni grupla ilerler.',
      isFree: false,
      priceInfo: 'Masa basi 300 TL',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_23',
      venueId: 'venue_9',
      activityId: 'call_of_cthulhu',
      note: 'Tek gecelik senaryolar da aciliyor.',
      isFree: false,
      priceInfo: 'Oturum basi',
      sourceType: 'venue_owner',
    ),
    const VenueActivity(
      id: 'va_24',
      venueId: 'venue_10',
      activityId: 'retro_arcade',
      note: 'Jeton sistemi yerine surelik kullanim var.',
      isFree: false,
      priceInfo: 'Saatlik 100 TL',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_25',
      venueId: 'venue_10',
      activityId: 'switch_party',
      note: 'Mario Kart ve Smash grup paketleri var.',
      isFree: false,
      priceInfo: 'Saatlik 85 TL',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_26',
      venueId: 'venue_11',
      activityId: 'karaoke_odasi',
      note: '3 farkli tema oda secenegi bulunuyor.',
      isFree: false,
      priceInfo: 'Saatlik 280 TL',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_27',
      venueId: 'venue_11',
      activityId: 'open_mic_karaoke',
      note: 'Hafta ici acik sahne gecesi yapiliyor.',
      isFree: true,
      priceInfo: 'Icecek min. harcama',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_28',
      venueId: 'venue_12',
      activityId: 'amerikan_bilardo',
      note: 'Turnuva gunlerinde erken rezervasyon gerekir.',
      isFree: false,
      priceInfo: 'Saatlik 140 TL',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_29',
      venueId: 'venue_12',
      activityId: 'snooker',
      note: '2 tam boy snooker masasi mevcut.',
      isFree: false,
      priceInfo: 'Saatlik 160 TL',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_30',
      venueId: 'venue_13',
      activityId: 'padel_court',
      note: 'Online rezervasyon ve ekipman kiralama mevcut.',
      isFree: false,
      priceInfo: 'Saatlik 400 TL',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_31',
      venueId: 'venue_13',
      activityId: 'toprak_kort',
      note: 'Kulup uyeleri icin indirimli paketler var.',
      isFree: false,
      priceInfo: 'Saatlik 320 TL',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_32',
      venueId: 'venue_14',
      activityId: 'reformer',
      note: '4 kisilik butik studio formatinda ders yapilir.',
      isFree: false,
      priceInfo: 'Ders basi',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_33',
      venueId: 'venue_14',
      activityId: 'spinning',
      note: 'Aksam saatlerinde grup dersleri doluyor.',
      isFree: false,
      priceInfo: 'Paket uyelik',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_34',
      venueId: 'venue_15',
      activityId: 'hali_saha',
      note: '7v7 ve 8v8 mac organizasyonu icin populer.',
      isFree: false,
      priceInfo: 'Saatlik 1800 TL',
      sourceType: 'editor',
    ),
    const VenueActivity(
      id: 'va_35',
      venueId: 'venue_15',
      activityId: 'acik_saha',
      note: 'Gece seanslari ve haftalik lig duzeni bulunuyor.',
      isFree: false,
      priceInfo: 'Saatlik 1500 TL',
      sourceType: 'editor',
    ),
  ];

  static final List<Event> events = [
    Event(
      id: 'event_1',
      venueId: 'venue_1',
      title: 'Quiz Night Genel Kultur ve Sinema',
      description:
          '4 kisilik takimini kur, odullu quiz gecesine katil ve surpriz oduller kazan.',
      category: 'Quiz Night',
      startDate: DateTime.now().add(const Duration(hours: 4)),
      priceInfo: 'Ucretsiz Giris',
      imageUrl:
          'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'venue_owner',
      status: 'published',
    ),
    Event(
      id: 'event_2',
      venueId: 'venue_3',
      title: 'Catan Turnuvasi',
      description:
          'Strateji ve masaustu oyun meraklilarini bir araya getiren dostluk turnuvasi.',
      category: 'Masaustu',
      startDate: DateTime.now().add(const Duration(days: 1, hours: 2)),
      priceInfo: 'Katilim 50 TL',
      imageUrl:
          'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'venue_owner',
      status: 'published',
    ),
    Event(
      id: 'event_3',
      venueId: 'venue_2',
      title: 'Karaoke Gecesi and Party',
      description:
          'Acik alanda sahneli karaoke ve grup oyunlariyla sosyal bir aksam.',
      category: 'Karaoke',
      startDate: DateTime.now().add(const Duration(hours: 26)),
      priceInfo: 'Giris Ucretsiz',
      imageUrl:
          'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      status: 'published',
    ),
    Event(
      id: 'event_4',
      venueId: 'venue_6',
      title: 'Baslangic Boulder Workshop',
      description:
          'Ilk kez tirmanacaklar icin kisa teknik giris ve esli rota denemeleri.',
      category: 'Tirmanis',
      startDate: DateTime.now().add(const Duration(days: 2, hours: 5)),
      priceInfo: 'Katilim 180 TL',
      imageUrl:
          'https://images.unsplash.com/photo-1522163182402-834f871fd851?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      status: 'published',
    ),
    Event(
      id: 'event_5',
      venueId: 'venue_9',
      title: 'One Shot FRP Aksami',
      description:
          'Yeni oyunculara acik, tek oturumluk masaustu rol yapma senaryosu.',
      category: 'FRP',
      startDate: DateTime.now().add(const Duration(days: 1, hours: 8)),
      priceInfo: 'Katilim 220 TL',
      imageUrl:
          'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'venue_owner',
      status: 'published',
    ),
    Event(
      id: 'event_6',
      venueId: 'venue_13',
      title: 'Padel Starter Social',
      description:
          'Yeni baslayanlar icin mini ders ve eslesmeli deneme maclari.',
      category: 'Padel',
      startDate: DateTime.now().add(const Duration(days: 3)),
      priceInfo: 'Katilim 300 TL',
      imageUrl:
          'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      status: 'published',
    ),
    Event(
      id: 'event_7',
      venueId: 'venue_10',
      title: 'Retro Arcade Battle Night',
      description:
          'Metal Slug, Street Fighter ve retro arcade skor yarislariyla nostaljik bir gece.',
      category: 'Retro Arcade',
      startDate: DateTime.now().add(const Duration(hours: 10)),
      priceInfo: 'Katilim 120 TL',
      imageUrl:
          'https://images.unsplash.com/photo-1511882150382-421056c89033?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      status: 'published',
    ),
    Event(
      id: 'event_8',
      venueId: 'venue_11',
      title: 'Open Mic Karaoke Session',
      description:
          'Listeden sarkini sec, sahneye cik ve grup performanslariyla geceyi devral.',
      category: 'Karaoke',
      startDate: DateTime.now().add(const Duration(days: 1, hours: 4)),
      priceInfo: 'Icecek min. harcama',
      imageUrl:
          'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      status: 'published',
    ),
    Event(
      id: 'event_9',
      venueId: 'venue_4',
      title: 'Gece Maci Organizasyonu',
      description:
          'Takim eslestirmeli, hakemli ve skor takibi yapilan gece hali saha seansi.',
      category: 'Futbol',
      startDate: DateTime.now().add(const Duration(days: 1, hours: 7)),
      priceInfo: 'Kisi basi 240 TL',
      imageUrl:
          'https://images.unsplash.com/photo-1522778119026-d647f0596c20?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      status: 'published',
    ),
    Event(
      id: 'event_10',
      venueId: 'venue_14',
      title: 'Reformer Intro Class',
      description:
          'Ilk kez reformer deneyecekler icin kucuk grup tanitim ve temel hareket akisi.',
      category: 'Wellness',
      startDate: DateTime.now().add(const Duration(days: 2, hours: 1)),
      priceInfo: 'Katilim 350 TL',
      imageUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      status: 'published',
    ),
    Event(
      id: 'event_11',
      venueId: 'venue_12',
      title: 'Snooker Ladder Match',
      description:
          'Seviye bazli snooker eslesmeleri ve haftalik siralama puani toplanan seri.',
      category: 'Bilardo',
      startDate: DateTime.now().add(const Duration(days: 2, hours: 6)),
      priceInfo: 'Katilim 180 TL',
      imageUrl:
          'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      status: 'published',
    ),
    Event(
      id: 'event_12',
      venueId: 'venue_8',
      title: 'Commander League Table',
      description:
          'Dort kisilik pod formatinda social commander aksami ve mini odul havuzu.',
      category: 'Kart Oyunlari',
      startDate: DateTime.now().add(const Duration(days: 3, hours: 3)),
      priceInfo: 'Masa payi 90 TL',
      imageUrl:
          'https://images.unsplash.com/photo-1511988617509-a57c8a288659?auto=format&fit=crop&q=80&w=1000',
      sourceType: 'editor',
      status: 'published',
    ),
  ];

  static final List<Review> reviews = [
    Review(
      id: 'r_1',
      venueId: 'venue_1',
      userDisplayName: 'Ulas Demirkol',
      rating: 5,
      comment:
          'Bilardo masalari cok kaliteli ve karaoke odasi arkadas grubuyla gitmek icin gercekten ideal.',
      visitedActivityName: 'Amerikan Bilardo',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Review(
      id: 'r_2',
      venueId: 'venue_1',
      userDisplayName: 'Merve Altin',
      rating: 4,
      comment:
          'Masaustu oyun secimi iyi, ozellikle Catan ve Monopoly icin geldik. Servis biraz daha hizli olabilir.',
      visitedActivityName: 'Catan',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Review(
      id: 'r_3',
      venueId: 'venue_3',
      userDisplayName: 'Can Kaynak',
      rating: 5,
      comment:
          'Duzenli oyun geceleri ve ogretici masa kulturu sayesinde yeni oyun ogrenmek kolay.',
      visitedActivityName: 'D&D 5e',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Review(
      id: 'r_4',
      venueId: 'venue_5',
      userDisplayName: 'Selin Yilmaz',
      rating: 4,
      comment:
          'VR deneyimi bekledigimden daha keyifliydi, ozellikle grup halinde gidince cok eglenceli oluyor.',
      visitedActivityName: 'VR Shooter',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Review(
      id: 'r_5',
      venueId: 'venue_9',
      userDisplayName: 'Ekin Sener',
      rating: 5,
      comment:
          'FRP masalari icin ciddi emek verilmis, DM destegi ve oda duzeni cok iyi.',
      visitedActivityName: 'Call of Cthulhu',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static ActivityCategory getCategoryById(String id) {
    return categories.firstWhere((category) => category.id == id);
  }

  static ActivitySubcategory? getSubcategoryById(String? id) {
    if (id == null) return null;
    return subcategories.firstWhere((subcategory) => subcategory.id == id);
  }

  static Activity getActivityById(String id) {
    return activities.firstWhere((activity) => activity.id == id);
  }

  static Venue getVenueById(String id) {
    return venues.firstWhere((venue) => venue.id == id);
  }

  static List<VenueActivity> getVenueActivities(String venueId) {
    return venueActivities
        .where((venueActivity) => venueActivity.venueId == venueId)
        .toList();
  }

  static List<Activity> getActivitiesForVenue(String venueId) {
    final activityIds = getVenueActivities(
      venueId,
    ).map((venueActivity) => venueActivity.activityId).toSet();
    return activities
        .where((activity) => activityIds.contains(activity.id))
        .toList();
  }

  static List<ActivitySubcategory> getSubcategoriesForCategory(
    String categoryId,
  ) {
    return subcategories
        .where((subcategory) => subcategory.categoryId == categoryId)
        .toList();
  }

  static List<Activity> getActivitiesForCategory(String categoryId) {
    return activities
        .where((activity) => activity.categoryId == categoryId)
        .toList();
  }

  static List<Activity> getActivitiesForSubcategory(String subcategoryId) {
    return activities
        .where((activity) => activity.subcategoryId == subcategoryId)
        .toList();
  }

  static List<Venue> getVenuesForCategory(String categoryId) {
    final categoryActivityIds = getActivitiesForCategory(
      categoryId,
    ).map((activity) => activity.id).toSet();
    final venueIds = venueActivities
        .where(
          (venueActivity) =>
              categoryActivityIds.contains(venueActivity.activityId),
        )
        .map((venueActivity) => venueActivity.venueId)
        .toSet();
    return venues.where((venue) => venueIds.contains(venue.id)).toList();
  }

  static List<Venue> getVenuesForActivity(String activityId) {
    final venueIds = venueActivities
        .where((venueActivity) => venueActivity.activityId == activityId)
        .map((venueActivity) => venueActivity.venueId)
        .toSet();
    return venues.where((venue) => venueIds.contains(venue.id)).toList();
  }

  static List<Venue> getVenuesForSubcategory(String subcategoryId) {
    final activityIds = getActivitiesForSubcategory(
      subcategoryId,
    ).map((activity) => activity.id).toSet();
    final venueIds = venueActivities
        .where(
          (venueActivity) => activityIds.contains(venueActivity.activityId),
        )
        .map((venueActivity) => venueActivity.venueId)
        .toSet();
    return venues.where((venue) => venueIds.contains(venue.id)).toList();
  }

  static List<Event> getEventsForVenue(String venueId) {
    return events.where((event) => event.venueId == venueId).toList();
  }

  static List<Event> getEventsForCategory(String categoryId) {
    final activityIds = getActivitiesForCategory(
      categoryId,
    ).map((activity) => activity.id).toSet();
    final venueIds = venueActivities
        .where(
          (venueActivity) => activityIds.contains(venueActivity.activityId),
        )
        .map((venueActivity) => venueActivity.venueId)
        .toSet();
    return events.where((event) => venueIds.contains(event.venueId)).toList();
  }

  static List<Event> getEventsForSubcategory(String subcategoryId) {
    final activityIds = getActivitiesForSubcategory(
      subcategoryId,
    ).map((activity) => activity.id).toSet();
    final venueIds = venueActivities
        .where(
          (venueActivity) => activityIds.contains(venueActivity.activityId),
        )
        .map((venueActivity) => venueActivity.venueId)
        .toSet();
    return events.where((event) => venueIds.contains(event.venueId)).toList();
  }

  static List<ActivityCategory> searchCategories(String query) {
    final normalizedQuery = query.toLowerCase();
    return categories
        .where(
          (category) => category.name.toLowerCase().contains(normalizedQuery),
        )
        .toList();
  }

  static List<Activity> searchActivities(String query) {
    final normalizedQuery = query.toLowerCase();
    return activities.where((activity) {
      return activity.name.toLowerCase().contains(normalizedQuery) ||
          activity.description.toLowerCase().contains(normalizedQuery) ||
          activity.aliases.any(
            (alias) => alias.toLowerCase().contains(normalizedQuery),
          );
    }).toList();
  }

  static List<Venue> searchVenues(String query) {
    final normalizedQuery = query.toLowerCase();
    return venues.where((venue) {
      final activityMatches = getActivitiesForVenue(venue.id).any((activity) {
        return activity.name.toLowerCase().contains(normalizedQuery) ||
            activity.aliases.any(
              (alias) => alias.toLowerCase().contains(normalizedQuery),
            );
      });

      return venue.name.toLowerCase().contains(normalizedQuery) ||
          venue.description.toLowerCase().contains(normalizedQuery) ||
          venue.district.toLowerCase().contains(normalizedQuery) ||
          venue.activityTags.any(
            (tag) => tag.toLowerCase().contains(normalizedQuery),
          ) ||
          activityMatches;
    }).toList();
  }
}
