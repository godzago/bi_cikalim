import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_services.dart';
import '../../shared/models/api_models.dart';

// ---------------------------------------------------------------------------
// Service Providers
// ---------------------------------------------------------------------------

final taxonomyApiServiceProvider = Provider<TaxonomyApiService>((ref) {
  return TaxonomyApiService();
});

final venueApiServiceProvider = Provider<VenueApiService>((ref) {
  return VenueApiService();
});

final eventApiServiceProvider = Provider<EventApiService>((ref) {
  return EventApiService();
});

final interactionApiServiceProvider = Provider<InteractionApiService>((ref) {
  return InteractionApiService();
});

// ---------------------------------------------------------------------------
// Eskişehir Tepebaşı Mock Venues List
// ---------------------------------------------------------------------------

final List<ApiVenue> _tepebasiMockVenues = [
  ApiVenue(
    id: 'mock_tepebasi_1',
    name: 'Cassaba Modern (moc data)',
    slug: 'cassaba-modern-mock',
    shortDescription: 'Tepebaşı\'nın en popüler açık hava sosyal ve cafe alanı.',
    description: 'Cassaba Modern, Eskişehir Tepebaşı\'nda yer alan, geniş açık alanları, kaliteli kafeleri ve eğlenceli sosyal ortamıyla gençlerin ve ailelerin en çok tercih ettiği modern yaşam merkezidir.',
    venueType: 'mall',
    city: const ApiLocationSummary(id: 'esk', name: 'Eskişehir', slug: 'eskisehir'),
    district: const ApiLocationSummary(id: 'tep', name: 'Tepebaşı', slug: 'tepebasi'),
    coverUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600',
    isVerified: true,
    isFavorite: false,
    activitySummary: const [
      ApiVenueActivitySummary(id: 'm1_1', activityId: 'cafe', activityName: 'Kahve & Sohbet', activitySlug: 'kahve-sohbet', status: 'available', priceType: 'free', requiresReservation: false, isFeatured: true),
    ],
    latitude: 39.7836,
    longitude: 30.5101,
    ratingAverage: 4.7,
    ratingCount: 184,
    tags: const [ApiTagSummary(id: 't1', name: 'Açık Hava', slug: 'acik-hava'), ApiTagSummary(id: 't1_2', name: 'Sosyal', slug: 'sosyal')],
  ),
  ApiVenue(
    id: 'mock_tepebasi_2',
    name: 'Hall Eskişehir (moc data)',
    slug: 'hall-eskisehir-mock',
    shortDescription: 'Kültür, sanat, konser alanı ve oyun kafesi.',
    description: 'Hall Eskişehir, alternatif sahnesi, masa oyunları alanı, retro tasarımı ve harika atıştırmalıklarıyla Tepebaşı bölgesinin en sevilen gençlik buluşma noktalarından biridir.',
    venueType: 'hall',
    city: const ApiLocationSummary(id: 'esk', name: 'Eskişehir', slug: 'eskisehir'),
    district: const ApiLocationSummary(id: 'tep', name: 'Tepebaşı', slug: 'tepebasi'),
    coverUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600',
    isVerified: true,
    isFavorite: false,
    activitySummary: const [
      ApiVenueActivitySummary(id: 'm2_1', activityId: 'board_games', activityName: 'Kutu Oyunları', activitySlug: 'kutu-oyunlari', status: 'available', priceType: 'paid', requiresReservation: false, isFeatured: true),
    ],
    latitude: 39.7818,
    longitude: 30.5115,
    ratingAverage: 4.5,
    ratingCount: 92,
    tags: const [ApiTagSummary(id: 't2_1', name: 'Oyun', slug: 'oyun'), ApiTagSummary(id: 't2_2', name: 'Masaüstü Oyunları', slug: 'masaustu-oyunlari')],
  ),
  ApiVenue(
    id: 'mock_tepebasi_3',
    name: 'Hey Joe Coffee Co. (moc data)',
    slug: 'hey-joe-coffee-mock',
    shortDescription: 'Yeni nesil nitelikli kahve barı ve çalışma alanı.',
    description: 'Üçüncü nesil kahve demleme teknikleri ve huzurlu çalışma ortamıyla bilinen Hey Joe, ders çalışmak veya kitap okumak isteyenlerin Tepebaşı\'ndaki bir numaralı tercihidir.',
    venueType: 'cafe',
    city: const ApiLocationSummary(id: 'esk', name: 'Eskişehir', slug: 'eskisehir'),
    district: const ApiLocationSummary(id: 'tep', name: 'Tepebaşı', slug: 'tepebasi'),
    coverUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600',
    isVerified: true,
    isFavorite: false,
    activitySummary: const [
      ApiVenueActivitySummary(id: 'm3_1', activityId: 'coffee_tasting', activityName: 'Nitelikli Kahve', activitySlug: 'nitelikli-kahve', status: 'available', priceType: 'paid', requiresReservation: false, isFeatured: true),
    ],
    latitude: 39.7852,
    longitude: 30.5095,
    ratingAverage: 4.6,
    ratingCount: 78,
    tags: const [ApiTagSummary(id: 't3_1', name: 'Kahve', slug: 'kahve'), ApiTagSummary(id: 't3_2', name: 'Sessiz Alan', slug: 'sessiz-alan')],
  ),
  ApiVenue(
    id: 'mock_tepebasi_4',
    name: 'Gaga Eskişehir (moc data)',
    slug: 'gaga-eskisehir-mock',
    shortDescription: 'Geniş yeşil bahçesiyle popüler pub ve restoran.',
    description: 'Gaga Eskişehir, Tepebaşı\'nda ağaçlar altındaki devasa bahçesi, dünya mutfağından lezzetleri ve canlı müzik etkinlikleriyle akşam saatlerinin vazgeçilmez adresidir.',
    venueType: 'pub',
    city: const ApiLocationSummary(id: 'esk', name: 'Eskişehir', slug: 'eskisehir'),
    district: const ApiLocationSummary(id: 'tep', name: 'Tepebaşı', slug: 'tepebasi'),
    coverUrl: 'https://images.unsplash.com/photo-1543007630-9710e4a00a20?w=600',
    isVerified: true,
    isFavorite: false,
    activitySummary: const [
      ApiVenueActivitySummary(id: 'm4_1', activityId: 'live_music', activityName: 'Canlı Müzik Performansı', activitySlug: 'canli-muzik', status: 'available', priceType: 'free', requiresReservation: true, isFeatured: true),
    ],
    latitude: 39.7796,
    longitude: 30.5135,
    ratingAverage: 4.4,
    ratingCount: 312,
    tags: const [ApiTagSummary(id: 't4_1', name: 'Canlı Müzik', slug: 'canli-muzik'), ApiTagSummary(id: 't4_2', name: 'Bahçe', slug: 'bahce')],
  ),
  ApiVenue(
    id: 'mock_tepebasi_5',
    name: 'Kutup Oyun & Cafe (moc data)',
    slug: 'kutup-oyun-cafe-mock',
    shortDescription: 'D&D, kutu oyunları ve PlayStation turnuvaları.',
    description: 'Kutup Oyun & Cafe, masaüstü rol yapma oyunlarından (FRP), Catan ve Carcassonne gibi popüler kutu oyunlarına kadar geniş bir kütüphane sunan tam donanımlı bir eğlence merkezidir.',
    venueType: 'cafe',
    city: const ApiLocationSummary(id: 'esk', name: 'Eskişehir', slug: 'eskisehir'),
    district: const ApiLocationSummary(id: 'tep', name: 'Tepebaşı', slug: 'tepebasi'),
    coverUrl: 'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?w=600',
    isVerified: true,
    isFavorite: false,
    activitySummary: const [
      ApiVenueActivitySummary(id: 'm5_1', activityId: 'frp_games', activityName: 'D&D FRP Seansı', activitySlug: 'dnd-frp', status: 'available', priceType: 'paid', requiresReservation: true, isFeatured: true),
    ],
    latitude: 39.7810,
    longitude: 30.5102,
    ratingAverage: 4.8,
    ratingCount: 64,
    tags: const [ApiTagSummary(id: 't5_1', name: 'FRP', slug: 'frp'), ApiTagSummary(id: 't5_2', name: 'PlayStation', slug: 'playstation')],
  ),
  ApiVenue(
    id: 'mock_tepebasi_6',
    name: 'Varuna Gezgin Cafe (moc data)',
    slug: 'varuna-gezgin-mock',
    shortDescription: 'Dünya kültürleriyle bezeli, ünlü gezgin kafesi.',
    description: 'Gezginlerin anıları ve haritalarıyla dekore edilmiş Varuna Gezgin Cafe, hem leziz dünya biraları hem de haftalık eğlenceli Quiz Night (Bilgi Yarışması) geceleriyle ünlüdür.',
    venueType: 'cafe',
    city: const ApiLocationSummary(id: 'esk', name: 'Eskişehir', slug: 'eskisehir'),
    district: const ApiLocationSummary(id: 'tep', name: 'Tepebaşı', slug: 'tepebasi'),
    coverUrl: 'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=600',
    isVerified: true,
    isFavorite: false,
    activitySummary: const [
      ApiVenueActivitySummary(id: 'm6_1', activityId: 'quiz_night', activityName: 'Haftalık Quiz Gecesi', activitySlug: 'quiz-gecesi', status: 'available', priceType: 'free', requiresReservation: false, isFeatured: true),
    ],
    latitude: 39.7791,
    longitude: 30.5140,
    ratingAverage: 4.6,
    ratingCount: 420,
    tags: const [ApiTagSummary(id: 't6_1', name: 'Quiz Night', slug: 'quiz-night'), ApiTagSummary(id: 't6_2', name: 'Tematik', slug: 'tematik')],
  ),
  ApiVenue(
    id: 'mock_tepebasi_7',
    name: 'Walker\'s Coffee House (moc data)',
    slug: 'walkers-coffee-mock',
    shortDescription: 'Anadolu Üniversitesi yakınında ders ve kahve noktası.',
    description: 'Özellikle üniversite öğrencilerinin sınav haftalarında favorisi olan Walker\'s Coffee, rahat çalışma masaları ve lezzetli tatlılarıyla Tepebaşı\'nda hizmet vermektedir.',
    venueType: 'cafe',
    city: const ApiLocationSummary(id: 'esk', name: 'Eskişehir', slug: 'eskisehir'),
    district: const ApiLocationSummary(id: 'tep', name: 'Tepebaşı', slug: 'tepebasi'),
    coverUrl: 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=600',
    isVerified: true,
    isFavorite: false,
    activitySummary: const [
      ApiVenueActivitySummary(id: 'm7_1', activityId: 'study', activityName: 'Sessiz Çalışma Alanı', activitySlug: 'sessiz-calisma', status: 'available', priceType: 'free', requiresReservation: false, isFeatured: false),
    ],
    latitude: 39.7882,
    longitude: 30.5036,
    ratingAverage: 4.3,
    ratingCount: 110,
    tags: const [ApiTagSummary(id: 't7_1', name: 'Ders Çalışma', slug: 'ders-calisma'), ApiTagSummary(id: 't7_2', name: 'Hızlı Wifi', slug: 'hizli-wifi')],
  ),
  ApiVenue(
    id: 'mock_tepebasi_8',
    name: 'Külliye Kahve (moc data)',
    slug: 'kulliye-kahve-mock',
    shortDescription: 'Geleneksel Türk kahvesi ve nargile bahçesi.',
    description: 'Anadolu Üniversitesi eczacılık kapısı yakınında bulunan Külliye Kahve, otantik tasarımı, Türk kahvesi çeşitleri ve akşamları arkadaş gruplarıyla okey/tavla oynanabilecek geniş bahçesiyle bilinir.',
    venueType: 'cafe',
    city: const ApiLocationSummary(id: 'esk', name: 'Eskişehir', slug: 'eskisehir'),
    district: const ApiLocationSummary(id: 'tep', name: 'Tepebaşı', slug: 'tepebasi'),
    coverUrl: 'https://images.unsplash.com/photo-1507133750040-4a8f57021571?w=600',
    isVerified: false,
    isFavorite: false,
    activitySummary: const [
      ApiVenueActivitySummary(id: 'm8_1', activityId: 'board_games', activityName: 'Tavla & Okey', activitySlug: 'tavla-okey', status: 'available', priceType: 'free', requiresReservation: false, isFeatured: false),
    ],
    latitude: 39.7901,
    longitude: 30.5020,
    ratingAverage: 4.2,
    ratingCount: 154,
    tags: const [ApiTagSummary(id: 't8_1', name: 'Geleneksel', slug: 'geleneksel'), ApiTagSummary(id: 't8_2', name: 'Okey Tavla', slug: 'okey-tavla')],
  ),
  ApiVenue(
    id: 'mock_tepebasi_9',
    name: 'Social Pub Cassaba (moc data)',
    slug: 'social-pub-cassaba-mock',
    shortDescription: 'Cassaba Modern içinde pub, dart ve kokteyl barı.',
    description: 'Özel kokteylleri, dart tahtaları ve dinamik müzikleriyle Social Pub, Cassaba Modern içerisinde Tepebaşı gençliğine enerjik bir gece hayatı sunmaktadır.',
    venueType: 'pub',
    city: const ApiLocationSummary(id: 'esk', name: 'Eskişehir', slug: 'eskisehir'),
    district: const ApiLocationSummary(id: 'tep', name: 'Tepebaşı', slug: 'tepebasi'),
    coverUrl: 'https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=600',
    isVerified: true,
    isFavorite: false,
    activitySummary: const [
      ApiVenueActivitySummary(id: 'm9_1', activityId: 'dart', activityName: 'Elektronik Dart', activitySlug: 'dart', status: 'available', priceType: 'free', requiresReservation: false, isFeatured: false),
    ],
    latitude: 39.7838,
    longitude: 30.5105,
    ratingAverage: 4.5,
    ratingCount: 142,
    tags: const [ApiTagSummary(id: 't9_1', name: 'Dart', slug: 'dart'), ApiTagSummary(id: 't9_2', name: 'Kokteyl', slug: 'kokteyl')],
  ),
  ApiVenue(
    id: 'mock_tepebasi_10',
    name: 'Anadolu Öğrenci Merkezi (moc data)',
    slug: 'anadolu-ogrenci-merkezi-mock',
    shortDescription: 'Drama, satranç ve öğrenci kulüpleri merkezi.',
    description: 'Anadolu Üniversitesi Yunus Emre Kampüsü merkezinde yer alan Öğrenci Merkezi; tiyatro gösterileri, satranç turnuvaları ve öğrenci kulüplerinin masa oyunları etkinliklerine ev sahipliği yapmaktadır.',
    venueType: 'hall',
    city: const ApiLocationSummary(id: 'esk', name: 'Eskişehir', slug: 'eskisehir'),
    district: const ApiLocationSummary(id: 'tep', name: 'Tepebaşı', slug: 'tepebasi'),
    coverUrl: 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=600',
    isVerified: true,
    isFavorite: false,
    activitySummary: const [
      ApiVenueActivitySummary(id: 'm10_1', activityId: 'chess', activityName: 'Satranç Buluşmaları', activitySlug: 'satranc', status: 'available', priceType: 'free', requiresReservation: false, isFeatured: false),
    ],
    latitude: 39.7915,
    longitude: 30.4990,
    ratingAverage: 4.6,
    ratingCount: 220,
    tags: const [ApiTagSummary(id: 't10_1', name: 'Satranç', slug: 'satranc'), ApiTagSummary(id: 't10_2', name: 'Öğrenci Kulübü', slug: 'ogrenci-kulubu')],
  ),
];

// ---------------------------------------------------------------------------
// Data Providers (Direct API Communication with Tepebaşı Mock Fallback)
// ---------------------------------------------------------------------------

// Categories provider
final categoriesProvider = FutureProvider<List<ApiCategory>>((ref) async {
  return ref.read(taxonomyApiServiceProvider).fetchCategories();
});

// Activities provider
final activitiesProvider = FutureProvider<List<ApiActivity>>((ref) async {
  return ref.read(taxonomyApiServiceProvider).fetchActivities();
});

// Venues list provider
class VenueFilters {
  final String? citySlug;
  final String? districtSlug;
  final String? activityCategorySlug;
  final String? activitySlug;
  final String? q;

  const VenueFilters({
    this.citySlug,
    this.districtSlug,
    this.activityCategorySlug,
    this.activitySlug,
    this.q,
  });
}

final venuesListProvider = FutureProvider.family<List<ApiVenue>, VenueFilters>((ref, filters) async {
  List<ApiVenue> apiVenues = [];
  try {
    apiVenues = await ref.read(venueApiServiceProvider).fetchVenues(
      citySlug: filters.citySlug,
      districtSlug: filters.districtSlug,
      activityCategorySlug: filters.activityCategorySlug,
      activitySlug: filters.activitySlug,
      q: filters.q,
    );
  } catch (e) {
    // Fail silently, fall back to empty list from API
  }

  // Filter local Tepebaşı mock venues according to search query
  var filteredMock = List<ApiVenue>.from(_tepebasiMockVenues);
  if (filters.q != null && filters.q!.isNotEmpty) {
    filteredMock = filteredMock
        .where((v) => v.name.toLowerCase().contains(filters.q!.toLowerCase()))
        .toList();
  }
  if (filters.activityCategorySlug != null) {
    // Simple category mapping filtering for mock
    filteredMock = filteredMock.where((v) {
      if (filters.activityCategorySlug == 'kutu-oyunlari' || filters.activityCategorySlug == 'oyun') {
        return v.id == 'mock_tepebasi_2' || v.id == 'mock_tepebasi_5' || v.id == 'mock_tepebasi_8' || v.id == 'mock_tepebasi_10';
      }
      return true;
    }).toList();
  }

  return [...apiVenues, ...filteredMock];
});

// Venue Detail provider
final venueDetailProvider = FutureProvider.family<ApiVenue, String>((ref, slugOrId) async {
  try {
    return await ref.read(venueApiServiceProvider).fetchVenueDetail(slugOrId);
  } catch (e) {
    // If not found in live API database, check if it matches our Tepebaşı mock venues
    final matched = _tepebasiMockVenues.firstWhere(
      (v) => v.slug == slugOrId || v.id == slugOrId,
    );
    return matched;
  }
});

// Venue Reviews provider
final venueReviewsProvider = FutureProvider.family<List<ApiReview>, String>((ref, venueId) async {
  try {
    return await ref.read(interactionApiServiceProvider).fetchVenueReviews(venueId);
  } catch (e) {
    return [];
  }
});

// Events list provider
class EventFilters {
  final String? citySlug;
  final String? venueSlug;
  final String? activitySlug;
  final String? q;

  const EventFilters({
    this.citySlug,
    this.venueSlug,
    this.activitySlug,
    this.q,
  });
}

final eventsListProvider = FutureProvider.family<List<ApiEvent>, EventFilters>((ref, filters) async {
  try {
    return await ref.read(eventApiServiceProvider).fetchEvents(
      citySlug: filters.citySlug,
      venueSlug: filters.venueSlug,
      activitySlug: filters.activitySlug,
      q: filters.q,
    );
  } catch (e) {
    return [];
  }
});

// Event Detail provider
final eventDetailProvider = FutureProvider.family<ApiEvent, String>((ref, slugOrId) async {
  return ref.read(eventApiServiceProvider).fetchEventDetail(slugOrId);
});

// Favorite Venues provider
final favoriteVenuesProvider = FutureProvider<List<ApiVenue>>((ref) async {
  try {
    return await ref.read(venueApiServiceProvider).fetchFavoriteVenues();
  } catch (e) {
    return [];
  }
});

// Favorite Events provider
final favoriteEventsProvider = FutureProvider<List<ApiEvent>>((ref) async {
  try {
    return await ref.read(eventApiServiceProvider).fetchFavoriteEvents();
  } catch (e) {
    return [];
  }
});
