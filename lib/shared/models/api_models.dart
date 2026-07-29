import 'package:flutter/material.dart';

// Helper to safely parse doubles from dynamic values
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

// Helper to safely parse dates
DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

class ApiCategory {
  final String id;
  final String name;
  final String slug;
  final String? iconName;
  final String? description;
  final bool isActive;
  final int sortOrder;

  const ApiCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.iconName,
    this.description,
    required this.isActive,
    required this.sortOrder,
  });

  factory ApiCategory.fromJson(Map<String, dynamic> json) {
    return ApiCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      iconName: (json['icon'] ?? json['icon_name']) as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  // Helper to map font icon
  IconData get iconData {
    switch (iconName?.toLowerCase()) {
      case 'masaustu_oyunlar':
      case 'casino':
      case 'dice':
        return Icons.casino;
      case 'dijital_oyunlar':
      case 'sports_esports':
      case 'game':
        return Icons.sports_esports;
      case 'salon_eglenceleri':
      case 'celebration':
      case 'party':
        return Icons.celebration;
      case 'saha_sporlari':
      case 'sports_soccer':
      case 'soccer':
        return Icons.sports_soccer;
      case 'bireysel_sporlar':
      case 'fitness_center':
      case 'gym':
        return Icons.fitness_center;
      case 'macera_deneyim':
      case 'explore':
      case 'adventure':
        return Icons.explore;
      default:
        return Icons.category;
    }
  }

  IconData get icon => iconData;
}

class ApiSubcategory {
  final String id;
  final String categoryId;
  final String name;
  final String slug;

  const ApiSubcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
  });

  factory ApiSubcategory.fromJson(Map<String, dynamic> json) {
    return ApiSubcategory(
      id: json['id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class ApiActivity {
  final String id;
  final String name;
  final String slug;
  final String categoryId;
  final String? subcategoryId;
  final String? description;
  final String kind;
  final int? minPeople;
  final int? maxPeople;

  const ApiActivity({
    required this.id,
    required this.name,
    required this.slug,
    required this.categoryId,
    this.subcategoryId,
    this.description,
    required this.kind,
    required this.minPeople,
    required this.maxPeople,
  });

  factory ApiActivity.fromJson(Map<String, dynamic> json) {
    return ApiActivity(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      subcategoryId: json['sub_category_id']?.toString(),
      description: json['description'] as String?,
      kind: (json['activity_kind'] ?? json['kind']) as String? ?? 'other',
      minPeople: (json['min_participants'] ?? json['min_people']) as int?,
      maxPeople: (json['max_participants'] ?? json['max_people']) as int?,
    );
  }

  IconData get iconData {
    switch (kind.toLowerCase()) {
      case 'game':
        return Icons.sports_esports;
      case 'sport':
        return Icons.sports_soccer;
      case 'workshop':
        return Icons.build;
      case 'entertainment':
        return Icons.celebration;
      case 'culture':
        return Icons.museum;
      case 'outdoor':
        return Icons.nature_people;
      default:
        return Icons.star;
    }
  }
}

class ApiLocationSummary {
  final String id;
  final String name;
  final String slug;

  const ApiLocationSummary({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ApiLocationSummary.fromJson(Map<String, dynamic> json) {
    return ApiLocationSummary(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class ApiTagSummary {
  final String id;
  final String name;
  final String slug;

  const ApiTagSummary({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ApiTagSummary.fromJson(Map<String, dynamic> json) {
    return ApiTagSummary(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class ApiVenueActivitySummary {
  final String id;
  final String activityId;
  final String activityName;
  final String activitySlug;
  final String availability;
  final bool isPaid;
  final double? price;
  final String? priceUnit;
  final String? shortDescription;
  final DateTime? lastVerifiedAt;

  const ApiVenueActivitySummary({
    required this.id,
    required this.activityId,
    required this.activityName,
    required this.activitySlug,
    required this.availability,
    required this.isPaid,
    this.price,
    this.priceUnit,
    this.shortDescription,
    this.lastVerifiedAt,
  });

  factory ApiVenueActivitySummary.fromJson(Map<String, dynamic> json) {
    return ApiVenueActivitySummary(
      id: json['id']?.toString() ?? '',
      activityId: json['activity_id']?.toString() ?? '',
      activityName: json['activity_name'] as String? ?? '',
      activitySlug: json['activity_slug'] as String? ?? '',
      availability:
          (json['availability'] ?? json['status']) as String? ?? 'available',
      isPaid:
          json['is_paid'] as bool? ?? (json['price_type'] as String?) == 'paid',
      price: _toDouble(json['price']),
      priceUnit: json['price_unit'] as String?,
      shortDescription: json['short_description'] as String?,
      lastVerifiedAt: _toDateTime(json['last_verified_at']),
    );
  }

  bool get isFree => !isPaid;
  String get status => availability;
  String get priceType => isPaid ? 'paid' : 'free';
  bool get requiresReservation => false;
  bool get isFeatured => false;
}

class ApiVenueOpeningHour {
  final int dayOfWeek;
  final String? opensAt;
  final String? closesAt;
  final bool isClosed;
  final String? note;

  const ApiVenueOpeningHour({
    required this.dayOfWeek,
    this.opensAt,
    this.closesAt,
    required this.isClosed,
    this.note,
  });

  factory ApiVenueOpeningHour.fromJson(Map<String, dynamic> json) {
    return ApiVenueOpeningHour(
      dayOfWeek: json['day_of_week'] as int? ?? 1,
      opensAt: json['opens_at'] as String?,
      closesAt: json['closes_at'] as String?,
      isClosed: json['is_closed'] as bool? ?? false,
      note: json['note'] as String?,
    );
  }
}

class ApiVenueMedia {
  final String mediaId;
  final String usageType;
  final String? publicUrl;
  final int sortOrder;

  const ApiVenueMedia({
    required this.mediaId,
    required this.usageType,
    this.publicUrl,
    required this.sortOrder,
  });

  factory ApiVenueMedia.fromJson(Map<String, dynamic> json) {
    return ApiVenueMedia(
      mediaId: json['media_id']?.toString() ?? '',
      usageType: json['usage_type'] as String? ?? 'gallery',
      publicUrl: json['public_url'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}

class ApiVenue {
  final String id;
  final String name;
  final String slug;
  final String? shortDescription;
  final String venueType;
  final ApiLocationSummary city;
  final ApiLocationSummary? district;
  final String? coverUrl;
  final bool isVerified;
  final bool isFavorite;
  final List<ApiVenueActivitySummary> activitySummary;

  // Detail-only fields
  final String? description;
  final String? address;
  final String? googleMapsUrl;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;
  final String? instagramUrl;
  final String? websiteUrl;
  final ApiLocationSummary? neighborhood;
  final List<ApiVenueOpeningHour> openingHours;
  final List<ApiTagSummary> tags;
  final List<ApiVenueMedia> media;
  final double? ratingAverage;
  final int ratingCount;

  const ApiVenue({
    required this.id,
    required this.name,
    required this.slug,
    this.shortDescription,
    required this.venueType,
    required this.city,
    this.district,
    this.coverUrl,
    required this.isVerified,
    required this.isFavorite,
    required this.activitySummary,

    // Detail-only
    this.description,
    this.address,
    this.googleMapsUrl,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.instagramUrl,
    this.websiteUrl,
    this.neighborhood,
    this.openingHours = const [],
    this.tags = const [],
    this.media = const [],
    this.ratingAverage,
    this.ratingCount = 0,
  });

  factory ApiVenue.fromJson(Map<String, dynamic> json) {
    return ApiVenue(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      shortDescription: json['short_description'] as String?,
      venueType: json['venue_type'] as String? ?? 'other',
      city: ApiLocationSummary.fromJson(
        json['city'] as Map<String, dynamic>? ?? {},
      ),
      district: json['district'] != null
          ? ApiLocationSummary.fromJson(
              json['district'] as Map<String, dynamic>,
            )
          : null,
      coverUrl: json['cover_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isFavorite: json['is_favorite'] as bool? ?? false,
      activitySummary:
          (json['activity_summary'] as List? ??
                  json['activities_summary'] as List? ??
                  [])
              .map(
                (item) => ApiVenueActivitySummary.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),

      // Detail-only
      description: json['description'] as String?,
      address: json['address'] as String?,
      googleMapsUrl: json['google_maps_url'] as String?,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      instagramUrl: json['instagram_url'] as String?,
      websiteUrl: json['website_url'] as String?,
      neighborhood: json['neighborhood'] != null
          ? ApiLocationSummary.fromJson(
              json['neighborhood'] as Map<String, dynamic>,
            )
          : null,
      openingHours: (json['opening_hours'] as List? ?? [])
          .map(
            (item) =>
                ApiVenueOpeningHour.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      tags: (json['tags'] as List? ?? [])
          .map((item) => ApiTagSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
      media: (json['media'] as List? ?? [])
          .map((item) => ApiVenueMedia.fromJson(item as Map<String, dynamic>))
          .toList(),
      ratingAverage: _toDouble(json['rating_average']),
      ratingCount: json['rating_count'] as int? ?? 0,
    );
  }

  String get coverImageUrl => coverUrl ?? '';
  String get verificationStatus => isVerified ? 'verified' : 'unverified';
  double get averageRating => ratingAverage ?? 0.0;
  int get reviewCount => ratingCount;
  List<String> get activityTags => tags.map((t) => t.name).toList();
  String get cityName => city.name;
  String get districtName => district?.name ?? '';
}

class ApiEventVenueSummary {
  final String id;
  final String name;
  final String slug;

  const ApiEventVenueSummary({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ApiEventVenueSummary.fromJson(Map<String, dynamic> json) {
    return ApiEventVenueSummary(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class ApiEventActivitySummary {
  final String id;
  final String name;
  final String slug;

  const ApiEventActivitySummary({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ApiEventActivitySummary.fromJson(Map<String, dynamic> json) {
    return ApiEventActivitySummary(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class ApiEventMedia {
  final String mediaId;
  final String usageType;
  final String? publicUrl;
  final int sortOrder;

  const ApiEventMedia({
    required this.mediaId,
    required this.usageType,
    this.publicUrl,
    required this.sortOrder,
  });

  factory ApiEventMedia.fromJson(Map<String, dynamic> json) {
    return ApiEventMedia(
      mediaId: json['media_id']?.toString() ?? '',
      usageType: json['usage_type'] as String? ?? 'gallery',
      publicUrl: json['public_url'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}

class ApiEvent {
  final String id;
  final String title;
  final String slug;
  final String? shortDescription;
  final DateTime startAt;
  final DateTime? endAt;
  final String timezone;
  final String status;
  final String priceType;
  final double? minPrice;
  final double? maxPrice;
  final String currency;
  final ApiLocationSummary city;
  final ApiEventVenueSummary? venue;
  final String? coverUrl;
  final List<ApiEventActivitySummary> activities;
  final bool isFavorite;
  final String? attendanceStatus;

  // Detail-only fields
  final String? description;
  final DateTime? doorsOpenAt;
  final String? ticketUrl;
  final String? reservationUrl;
  final int? ageLimit;
  final List<ApiEventMedia> media;

  const ApiEvent({
    required this.id,
    required this.title,
    required this.slug,
    this.shortDescription,
    required this.startAt,
    this.endAt,
    required this.timezone,
    required this.status,
    required this.priceType,
    this.minPrice,
    this.maxPrice,
    required this.currency,
    required this.city,
    this.venue,
    this.coverUrl,
    required this.activities,
    required this.isFavorite,
    this.attendanceStatus,

    // Detail-only
    this.description,
    this.doorsOpenAt,
    this.ticketUrl,
    this.reservationUrl,
    this.ageLimit,
    this.media = const [],
  });

  factory ApiEvent.fromJson(Map<String, dynamic> json) {
    return ApiEvent(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      shortDescription: json['short_description'] as String?,
      startAt: _toDateTime(json['start_at']) ?? DateTime.now(),
      endAt: _toDateTime(json['end_at']),
      timezone: json['timezone'] as String? ?? 'UTC',
      status: json['status'] as String? ?? 'draft',
      priceType: json['price_type'] as String? ?? 'unknown',
      minPrice: _toDouble(json['min_price']),
      maxPrice: _toDouble(json['max_price']),
      currency: json['currency'] as String? ?? 'TRY',
      city: ApiLocationSummary.fromJson(
        json['city'] as Map<String, dynamic>? ?? {},
      ),
      venue: json['venue'] != null
          ? ApiEventVenueSummary.fromJson(json['venue'] as Map<String, dynamic>)
          : null,
      coverUrl: json['cover_url'] as String?,
      activities: (json['activities'] as List? ?? [])
          .map(
            (item) =>
                ApiEventActivitySummary.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      isFavorite: json['is_favorite'] as bool? ?? false,
      attendanceStatus: json['attendance_status'] as String?,

      // Detail-only
      description: json['description'] as String?,
      doorsOpenAt: _toDateTime(json['doors_open_at']),
      ticketUrl: json['ticket_url'] as String?,
      reservationUrl: json['reservation_url'] as String?,
      ageLimit: json['age_limit'] as int?,
      media: (json['media'] as List? ?? [])
          .map((item) => ApiEventMedia.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  String get priceInfo {
    final normalized = priceType.toLowerCase();
    if (normalized == 'free') return 'Ücretsiz';
    if (normalized == 'reservation_required') {
      return 'Rezervasyon gerekli';
    }
    if (normalized == 'included_with_entry') return 'Girişe dahil';
    if (minPrice != null && maxPrice != null) {
      return '$minPrice - $maxPrice $currency';
    }
    if (minPrice != null) {
      return '$minPrice $currency\'den başlayan';
    }
    if (normalized == 'paid') return 'Ücretli';
    return 'Fiyat bilgisi yok';
  }

  String get imageUrl => coverUrl ?? '';
  String get category =>
      activities.isNotEmpty ? activities.first.name : 'Etkinlik';
  DateTime get startDate => startAt.toLocal();
  String get venueId => venue?.id ?? '';
}

class ApiEventAttendance {
  final String id;
  final String userId;
  final String eventId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ApiEventAttendance({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiEventAttendance.fromJson(Map<String, dynamic> json) {
    return ApiEventAttendance(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      status: json['status'] as String? ?? 'interested',
      createdAt: _toDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _toDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }
}

class ApiReview {
  final String id;
  final String venueId;
  final String userId;
  final String? activityId;
  final int rating;
  final String? comment;
  final String status;
  final String? moderationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ApiReview({
    required this.id,
    required this.venueId,
    required this.userId,
    this.activityId,
    required this.rating,
    this.comment,
    required this.status,
    this.moderationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiReview.fromJson(Map<String, dynamic> json) {
    return ApiReview(
      id: json['id']?.toString() ?? '',
      venueId: json['venue_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      activityId: json['activity_id']?.toString(),
      rating: json['rating'] as int? ?? 5,
      comment: json['comment'] as String?,
      status: json['status'] as String? ?? 'published',
      moderationReason: json['moderation_reason'] as String?,
      createdAt: _toDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _toDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }

  String get userDisplayName {
    final shortId = userId.length <= 4 ? userId : userId.substring(0, 4);
    return 'Kullanıcı ($shortId)';
  }
}

class ApiContentReport {
  final String id;
  final String reporterUserId;
  final String targetType;
  final String targetId;
  final String reason;
  final String? description;
  final String status;
  final String? reviewedByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ApiContentReport({
    required this.id,
    required this.reporterUserId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    required this.status,
    this.reviewedByUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiContentReport.fromJson(Map<String, dynamic> json) {
    return ApiContentReport(
      id: json['id']?.toString() ?? '',
      reporterUserId: json['reporter_user_id']?.toString() ?? '',
      targetType: json['target_type'] as String? ?? 'venue',
      targetId: json['target_id']?.toString() ?? '',
      reason: json['reason'] as String? ?? 'other',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      reviewedByUserId: json['reviewed_by_user_id']?.toString(),
      createdAt: _toDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _toDateTime(json['updated_at']) ?? DateTime.now(),
    );
  }
}

class ApiDataResponse<T> {
  final T data;

  const ApiDataResponse(this.data);

  factory ApiDataResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) decoder,
  ) {
    return ApiDataResponse(
      decoder(json['data'] as Map<String, dynamic>? ?? const {}),
    );
  }
}

class ApiPaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final int pages;

  const ApiPaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.pages,
  });

  factory ApiPaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) decoder,
  ) {
    return ApiPaginatedResponse(
      items: (json['items'] as List? ?? const [])
          .map((item) => decoder(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      pages: json['pages'] as int? ?? 0,
    );
  }
}

class ApiCity {
  final String id;
  final String name;
  final String slug;
  final String? plateCode;
  final String countryCode;
  final bool hasContent;
  final String launchStatus;
  final String? emptyStateTitle;
  final String? emptyStateDescription;

  const ApiCity({
    required this.id,
    required this.name,
    required this.slug,
    this.plateCode,
    required this.countryCode,
    required this.hasContent,
    required this.launchStatus,
    this.emptyStateTitle,
    this.emptyStateDescription,
  });

  factory ApiCity.fromJson(Map<String, dynamic> json) {
    return ApiCity(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      plateCode: json['plate_code']?.toString(),
      countryCode: json['country_code'] as String? ?? 'TR',
      hasContent: json['has_content'] as bool? ?? false,
      launchStatus: json['launch_status'] as String? ?? 'planned',
      emptyStateTitle: json['empty_state_title'] as String?,
      emptyStateDescription: json['empty_state_description'] as String?,
    );
  }
}

class ApiSearchTaxonomyItem {
  final String id;
  final String type;
  final String name;
  final String slug;

  const ApiSearchTaxonomyItem({
    required this.id,
    required this.type,
    required this.name,
    required this.slug,
  });

  factory ApiSearchTaxonomyItem.fromJson(Map<String, dynamic> json) {
    return ApiSearchTaxonomyItem(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}

class ApiSearchVenueItem {
  final String id;
  final String name;
  final String slug;
  final ApiLocationSummary city;
  final String? shortDescription;

  const ApiSearchVenueItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.city,
    this.shortDescription,
  });

  factory ApiSearchVenueItem.fromJson(Map<String, dynamic> json) {
    return ApiSearchVenueItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      city: ApiLocationSummary.fromJson(
        json['city'] as Map<String, dynamic>? ?? const {},
      ),
      shortDescription: json['short_description'] as String?,
    );
  }
}

class ApiSearchEventItem {
  final String id;
  final String title;
  final String slug;
  final ApiLocationSummary city;

  const ApiSearchEventItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.city,
  });

  factory ApiSearchEventItem.fromJson(Map<String, dynamic> json) {
    return ApiSearchEventItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      city: ApiLocationSummary.fromJson(
        json['city'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class ApiSearchResult {
  final String query;
  final List<ApiSearchTaxonomyItem> taxonomy;
  final List<ApiSearchVenueItem> venues;
  final List<ApiSearchEventItem> events;
  final int total;

  const ApiSearchResult({
    required this.query,
    required this.taxonomy,
    required this.venues,
    required this.events,
    required this.total,
  });

  factory ApiSearchResult.fromJson(Map<String, dynamic> json) {
    return ApiSearchResult(
      query: json['query'] as String? ?? '',
      taxonomy: (json['taxonomy'] as List? ?? const [])
          .map(
            (item) =>
                ApiSearchTaxonomyItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      venues: (json['venues'] as List? ?? const [])
          .map(
            (item) => ApiSearchVenueItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      events: (json['events'] as List? ?? const [])
          .map(
            (item) => ApiSearchEventItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }
}

class ApiSubmissionReceipt {
  final String id;
  final String status;
  final DateTime? createdAt;

  const ApiSubmissionReceipt({
    required this.id,
    required this.status,
    this.createdAt,
  });

  factory ApiSubmissionReceipt.fromJson(Map<String, dynamic> json) {
    return ApiSubmissionReceipt(
      id: json['id']?.toString() ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: _toDateTime(json['created_at']),
    );
  }
}

class ApiMedia {
  final String id;
  final String? publicUrl;
  final String mimeType;
  final int fileSize;
  final String mediaType;
  final String visibility;
  final String status;

  const ApiMedia({
    required this.id,
    this.publicUrl,
    required this.mimeType,
    required this.fileSize,
    required this.mediaType,
    required this.visibility,
    required this.status,
  });

  factory ApiMedia.fromJson(Map<String, dynamic> json) {
    return ApiMedia(
      id: json['id']?.toString() ?? '',
      publicUrl: json['public_url'] as String?,
      mimeType: json['mime_type'] as String? ?? '',
      fileSize: json['file_size'] as int? ?? 0,
      mediaType: json['media_type'] as String? ?? 'image',
      visibility: json['visibility'] as String? ?? 'public',
      status: json['status'] as String? ?? 'uploaded',
    );
  }
}

abstract final class AnalyticsEventName {
  static const search = 'search';
  static const activityFilter = 'activity_filter';
  static const venueView = 'venue_view';
  static const favorite = 'favorite';
  static const eventView = 'event_view';
  static const qrPageView = 'qr_page_view';

  static const values = {
    search,
    activityFilter,
    venueView,
    favorite,
    eventView,
    qrPageView,
  };
}
