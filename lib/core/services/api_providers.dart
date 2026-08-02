import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../shared/models/api_models.dart';
import '../network/api_client.dart';
import 'api_services.dart';

final taxonomyApiServiceProvider = Provider<TaxonomyApiService>(
  (ref) => TaxonomyApiService(),
);
final userApiServiceProvider = Provider<UserApiService>(
  (ref) => UserApiService(),
);
final venueApiServiceProvider = Provider<VenueApiService>(
  (ref) => VenueApiService(),
);
final eventApiServiceProvider = Provider<EventApiService>(
  (ref) => EventApiService(),
);
final interactionApiServiceProvider = Provider<InteractionApiService>(
  (ref) => InteractionApiService(),
);
final searchApiServiceProvider = Provider<SearchApiService>(
  (ref) => SearchApiService(),
);
final submissionApiServiceProvider = Provider<SubmissionApiService>(
  (ref) => SubmissionApiService(),
);
final mediaApiServiceProvider = Provider<MediaApiService>(
  (ref) => MediaApiService(),
);
final analyticsApiServiceProvider = Provider<AnalyticsApiService>(
  (ref) => AnalyticsApiService(),
);

final citiesProvider = FutureProvider<List<ApiCity>>((ref) async {
  return ref.read(userApiServiceProvider).fetchAllCities();
});

final cityDetailProvider = FutureProvider.family<ApiCity, String>(
  (ref, slug) => ref.read(userApiServiceProvider).fetchCity(slug),
);

class SelectedCityNotifier extends AsyncNotifier<ApiCity?> {
  static const _storage = FlutterSecureStorage();
  static const _citySlugKey = 'selected_city_slug';
  static const _cityCacheKey = 'selected_city_cache';

  @override
  Future<ApiCity?> build() async {
    final slug = await _storage.read(key: _citySlugKey);
    final cached = await _readCachedCity();
    if (slug == null || slug.isEmpty) return cached;
    try {
      final city = await ref.read(userApiServiceProvider).fetchCity(slug);
      await _persist(city);
      return city;
    } catch (_) {
      // Geçici ağ hatasında kullanıcının şehir tercihini silme.
      return cached;
    }
  }

  Future<void> select(ApiCity city) async {
    final previous = state;
    state = AsyncData(city);
    try {
      await _storage.write(key: _citySlugKey, value: city.slug);
      await _storage.write(
        key: _cityCacheKey,
        value: jsonEncode(_cityToJson(city)),
      );
      if (await ApiClient.instance.getToken() != null) {
        await ref.read(userApiServiceProvider).updateSelectedCity(city.id);
      }
    } catch (error, stackTrace) {
      state = previous;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _citySlugKey);
    await _storage.delete(key: _cityCacheKey);
    state = const AsyncData(null);
  }

  /// Başka cihazda/backend'de seçilmiş şehri yerel state'e taşır.
  Future<ApiCity?> restoreFromUserCityId(String? cityId) async {
    if (cityId == null || cityId.isEmpty) return state.value;
    final current = state.value;
    if (current?.id == cityId) return current;

    var page = 1;
    while (true) {
      final response = await ref
          .read(userApiServiceProvider)
          .fetchCities(page: page, pageSize: 100);
      for (final city in response.items) {
        if (city.id == cityId) {
          state = AsyncData(city);
          await _persist(city);
          return city;
        }
      }
      if (page >= response.pages) break;
      page++;
    }
    return null;
  }

  Future<void> _persist(ApiCity city) async {
    await _storage.write(key: _citySlugKey, value: city.slug);
    await _storage.write(
      key: _cityCacheKey,
      value: jsonEncode(_cityToJson(city)),
    );
  }

  Future<ApiCity?> _readCachedCity() async {
    final raw = await _storage.read(key: _cityCacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return ApiCity.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  Map<String, dynamic> _cityToJson(ApiCity city) => {
    'id': city.id,
    'name': city.name,
    'slug': city.slug,
    'plate_code': city.plateCode,
    'country_code': city.countryCode,
    'has_content': city.hasContent,
    'launch_status': city.launchStatus,
    'empty_state_title': city.emptyStateTitle,
    'empty_state_description': city.emptyStateDescription,
  };
}

final selectedCityProvider =
    AsyncNotifierProvider<SelectedCityNotifier, ApiCity?>(
      SelectedCityNotifier.new,
    );

final categoriesProvider = FutureProvider<List<ApiCategory>>((ref) {
  return ref.read(taxonomyApiServiceProvider).fetchCategories();
});

final subcategoriesProvider =
    FutureProvider.family<List<ApiSubcategory>, String?>((ref, categorySlug) {
      return ref
          .read(taxonomyApiServiceProvider)
          .fetchSubcategories(categorySlug: categorySlug);
    });

final activitiesProvider = FutureProvider<List<ApiActivity>>((ref) {
  return ref.read(taxonomyApiServiceProvider).fetchActivities();
});

class ActivityPageFilters {
  final int page;
  final int pageSize;
  final String? categorySlug;
  final String? subcategorySlug;
  final String? query;

  const ActivityPageFilters({
    this.page = 1,
    this.pageSize = 20,
    this.categorySlug,
    this.subcategorySlug,
    this.query,
  });

  @override
  bool operator ==(Object other) =>
      other is ActivityPageFilters &&
      other.page == page &&
      other.pageSize == pageSize &&
      other.categorySlug == categorySlug &&
      other.subcategorySlug == subcategorySlug &&
      other.query == query;

  @override
  int get hashCode =>
      Object.hash(page, pageSize, categorySlug, subcategorySlug, query);
}

final activitiesPageProvider =
    FutureProvider.family<
      ApiPaginatedResponse<ApiActivity>,
      ActivityPageFilters
    >((ref, filters) {
      return ref
          .read(taxonomyApiServiceProvider)
          .fetchActivitiesPage(
            page: filters.page,
            pageSize: filters.pageSize,
            categorySlug: filters.categorySlug,
            subCategorySlug: filters.subcategorySlug,
            q: filters.query,
          );
    });

class ActivityFilters {
  final String? categorySlug;
  final String? subcategorySlug;
  final String? query;

  const ActivityFilters({this.categorySlug, this.subcategorySlug, this.query});

  @override
  bool operator ==(Object other) =>
      other is ActivityFilters &&
      other.categorySlug == categorySlug &&
      other.subcategorySlug == subcategorySlug &&
      other.query == query;

  @override
  int get hashCode => Object.hash(categorySlug, subcategorySlug, query);
}

final filteredActivitiesProvider =
    FutureProvider.family<List<ApiActivity>, ActivityFilters>((ref, filters) {
      return ref
          .read(taxonomyApiServiceProvider)
          .fetchActivities(
            categorySlug: filters.categorySlug,
            subCategorySlug: filters.subcategorySlug,
            q: filters.query,
          );
    });

class VenueFilters {
  final String? citySlug;
  final String? districtSlug;
  final String? neighborhoodSlug;
  final String? activityCategorySlug;
  final String? activitySubCategorySlug;
  final String? activitySlug;
  final String? tagSlug;
  final String? q;
  final bool? hasCoordinates;
  final bool? isVerified;

  const VenueFilters({
    this.citySlug,
    this.districtSlug,
    this.neighborhoodSlug,
    this.activityCategorySlug,
    this.activitySubCategorySlug,
    this.activitySlug,
    this.tagSlug,
    this.q,
    this.hasCoordinates,
    this.isVerified,
  });

  @override
  bool operator ==(Object other) =>
      other is VenueFilters &&
      other.citySlug == citySlug &&
      other.districtSlug == districtSlug &&
      other.neighborhoodSlug == neighborhoodSlug &&
      other.activityCategorySlug == activityCategorySlug &&
      other.activitySubCategorySlug == activitySubCategorySlug &&
      other.activitySlug == activitySlug &&
      other.tagSlug == tagSlug &&
      other.q == q &&
      other.hasCoordinates == hasCoordinates &&
      other.isVerified == isVerified;

  @override
  int get hashCode => Object.hash(
    citySlug,
    districtSlug,
    neighborhoodSlug,
    activityCategorySlug,
    activitySubCategorySlug,
    activitySlug,
    tagSlug,
    q,
    hasCoordinates,
    isVerified,
  );
}

final venuesListProvider = FutureProvider.family<List<ApiVenue>, VenueFilters>((
  ref,
  filters,
) {
  return ref
      .read(venueApiServiceProvider)
      .fetchVenues(
        citySlug: filters.citySlug,
        districtSlug: filters.districtSlug,
        neighborhoodSlug: filters.neighborhoodSlug,
        activityCategorySlug: filters.activityCategorySlug,
        activitySubCategorySlug: filters.activitySubCategorySlug,
        activitySlug: filters.activitySlug,
        tagSlug: filters.tagSlug,
        q: filters.q,
        hasCoordinates: filters.hasCoordinates,
        isVerified: filters.isVerified,
      );
});

class MapVenueResult {
  final List<ApiVenue> venues;
  final int total;
  final int pages;
  final int loadedCount;
  final int invalidCoordinateCount;
  final int detailFailureCount;

  const MapVenueResult({
    required this.venues,
    required this.total,
    required this.pages,
    required this.loadedCount,
    required this.invalidCoordinateCount,
    required this.detailFailureCount,
  });
}

final mapVenuesProvider = FutureProvider.family<MapVenueResult, VenueFilters>((
  ref,
  filters,
) async {
  const pageSize = 100;
  final service = ref.read(venueApiServiceProvider);
  final byId = <String, ApiVenue>{};
  var page = 1;
  var pages = 1;
  var total = 0;

  while (true) {
    final response = await service.fetchVenuesPage(
      page: page,
      pageSize: pageSize,
      citySlug: filters.citySlug,
      districtSlug: filters.districtSlug,
      neighborhoodSlug: filters.neighborhoodSlug,
      activityCategorySlug: filters.activityCategorySlug,
      activitySubCategorySlug: filters.activitySubCategorySlug,
      activitySlug: filters.activitySlug,
      tagSlug: filters.tagSlug,
      q: filters.q,
      hasCoordinates: true,
      isVerified: filters.isVerified,
    );
    total = response.total;
    pages = response.pages;
    for (final venue in response.items) {
      final key = venue.id.isNotEmpty ? venue.id : venue.slug;
      if (key.isNotEmpty) byId[key] = venue;
    }
    if (page >= response.pages) break;
    page++;
  }

  final resolvedById = <String, ApiVenue>{};
  var invalidCoordinateCount = 0;
  var detailFailureCount = 0;
  final listedVenues = byId.values.toList(growable: false);

  const detailBatchSize = 8;
  for (var start = 0; start < listedVenues.length; start += detailBatchSize) {
    final end = start + detailBatchSize > listedVenues.length
        ? listedVenues.length
        : start + detailBatchSize;
    final batch = listedVenues.sublist(start, end);
    final resolved = await Future.wait(
      batch.map((venue) async {
        if (venue.hasValidCoordinates) return _MapVenueResolveResult(venue);
        if (venue.slug.isEmpty) return const _MapVenueResolveResult.failed();
        try {
          return _MapVenueResolveResult(
            await service.fetchVenueDetail(venue.slug),
          );
        } on Object {
          return const _MapVenueResolveResult.failed();
        }
      }),
    );

    for (final item in resolved) {
      final venue = item.venue;
      if (item.failed || venue == null) {
        detailFailureCount++;
        continue;
      }
      if (!venue.hasValidCoordinates) {
        invalidCoordinateCount++;
        continue;
      }
      final key = venue.id.isNotEmpty ? venue.id : venue.slug;
      if (key.isNotEmpty) resolvedById[key] = venue;
    }
  }

  return MapVenueResult(
    venues: resolvedById.values.toList(growable: false),
    total: total,
    pages: pages,
    loadedCount: byId.length,
    invalidCoordinateCount: invalidCoordinateCount,
    detailFailureCount: detailFailureCount,
  );
});

class _MapVenueResolveResult {
  final ApiVenue? venue;
  final bool failed;

  const _MapVenueResolveResult(this.venue) : failed = false;

  const _MapVenueResolveResult.failed() : venue = null, failed = true;
}

class VenuePageFilters {
  final int page;
  final int pageSize;
  final String? citySlug;
  final String? districtSlug;
  final String? neighborhoodSlug;
  final String? activityCategorySlug;
  final String? activitySubCategorySlug;
  final String? activitySlug;
  final String? tagSlug;
  final String? q;
  final bool? hasCoordinates;
  final bool? isVerified;

  const VenuePageFilters({
    this.page = 1,
    this.pageSize = 20,
    this.citySlug,
    this.districtSlug,
    this.neighborhoodSlug,
    this.activityCategorySlug,
    this.activitySubCategorySlug,
    this.activitySlug,
    this.tagSlug,
    this.q,
    this.hasCoordinates,
    this.isVerified,
  });

  @override
  bool operator ==(Object other) =>
      other is VenuePageFilters &&
      other.page == page &&
      other.pageSize == pageSize &&
      other.citySlug == citySlug &&
      other.districtSlug == districtSlug &&
      other.neighborhoodSlug == neighborhoodSlug &&
      other.activityCategorySlug == activityCategorySlug &&
      other.activitySubCategorySlug == activitySubCategorySlug &&
      other.activitySlug == activitySlug &&
      other.tagSlug == tagSlug &&
      other.q == q &&
      other.hasCoordinates == hasCoordinates &&
      other.isVerified == isVerified;

  @override
  int get hashCode => Object.hash(
    page,
    pageSize,
    citySlug,
    districtSlug,
    neighborhoodSlug,
    activityCategorySlug,
    activitySubCategorySlug,
    activitySlug,
    tagSlug,
    q,
    hasCoordinates,
    isVerified,
  );
}

final venuesPageProvider =
    FutureProvider.family<ApiPaginatedResponse<ApiVenue>, VenuePageFilters>((
      ref,
      filters,
    ) {
      return ref
          .read(venueApiServiceProvider)
          .fetchVenuesPage(
            page: filters.page,
            pageSize: filters.pageSize,
            citySlug: filters.citySlug,
            districtSlug: filters.districtSlug,
            neighborhoodSlug: filters.neighborhoodSlug,
            activityCategorySlug: filters.activityCategorySlug,
            activitySubCategorySlug: filters.activitySubCategorySlug,
            activitySlug: filters.activitySlug,
            tagSlug: filters.tagSlug,
            q: filters.q,
            hasCoordinates: filters.hasCoordinates,
            isVerified: filters.isVerified,
          );
    });

class DiscoveryVenueFilters {
  final String scope;
  final String slug;
  final String citySlug;
  final String? districtSlug;
  final String? neighborhoodSlug;
  final String? tagSlug;
  final String? query;

  const DiscoveryVenueFilters({
    required this.scope,
    required this.slug,
    required this.citySlug,
    this.districtSlug,
    this.neighborhoodSlug,
    this.tagSlug,
    this.query,
  });

  @override
  bool operator ==(Object other) =>
      other is DiscoveryVenueFilters &&
      other.scope == scope &&
      other.slug == slug &&
      other.citySlug == citySlug &&
      other.districtSlug == districtSlug &&
      other.neighborhoodSlug == neighborhoodSlug &&
      other.tagSlug == tagSlug &&
      other.query == query;

  @override
  int get hashCode => Object.hash(
    scope,
    slug,
    citySlug,
    districtSlug,
    neighborhoodSlug,
    tagSlug,
    query,
  );
}

final discoveryVenuesProvider =
    FutureProvider.family<List<ApiVenue>, DiscoveryVenueFilters>((
      ref,
      filters,
    ) async {
      final venues = await ref
          .read(venueApiServiceProvider)
          .fetchAllVenuesForDiscovery(
            scope: filters.scope,
            slug: filters.slug,
            citySlug: filters.citySlug,
            districtSlug: filters.districtSlug,
            neighborhoodSlug: filters.neighborhoodSlug,
            tagSlug: filters.tagSlug,
            q: filters.query,
          );
      ref
          .read(analyticsApiServiceProvider)
          .track(
            eventName: AnalyticsEventName.activityFilter,
            properties: {
              'scope': filters.scope,
              'slug': filters.slug,
              'result_count': venues.length,
              'city_slug': filters.citySlug,
            },
          );
      return venues;
    });

class ActivityVenuePreviewFilters {
  final String citySlug;
  final String activitySlug;
  final int pageSize;
  final bool? hasCoordinates;
  final bool? isVerified;

  const ActivityVenuePreviewFilters({
    required this.citySlug,
    required this.activitySlug,
    this.pageSize = 4,
    this.hasCoordinates,
    this.isVerified,
  });

  @override
  bool operator ==(Object other) =>
      other is ActivityVenuePreviewFilters &&
      other.citySlug == citySlug &&
      other.activitySlug == activitySlug &&
      other.pageSize == pageSize &&
      other.hasCoordinates == hasCoordinates &&
      other.isVerified == isVerified;

  @override
  int get hashCode =>
      Object.hash(citySlug, activitySlug, pageSize, hasCoordinates, isVerified);
}

final activityVenuePreviewProvider =
    FutureProvider.family<
      ApiPaginatedResponse<ApiVenue>,
      ActivityVenuePreviewFilters
    >((ref, filters) async {
      final response = await ref
          .read(venueApiServiceProvider)
          .fetchVenuesForDiscovery(
            scope: 'activity',
            slug: filters.activitySlug,
            citySlug: filters.citySlug,
            pageSize: filters.pageSize,
          );

      final items = response.items.where((venue) {
        if (filters.hasCoordinates == true &&
            (venue.latitude == null || venue.longitude == null)) {
          return false;
        }
        if (filters.isVerified == true && !venue.isVerified) return false;
        return true;
      }).toList();

      return ApiPaginatedResponse<ApiVenue>(
        items: items,
        total: response.total,
        page: response.page,
        pageSize: response.pageSize,
        pages: response.pages,
      );
    });

class TonightActivityRecommendation {
  final ApiActivity activity;
  final ApiPaginatedResponse<ApiVenue> venues;

  const TonightActivityRecommendation({
    required this.activity,
    required this.venues,
  });
}

class TonightRecommendationFilters {
  final String citySlug;
  final String? categorySlug;
  final String? subcategorySlug;
  final String? activitySlug;
  final bool? hasCoordinates;
  final bool? isVerified;
  final int limit;

  const TonightRecommendationFilters({
    required this.citySlug,
    this.categorySlug,
    this.subcategorySlug,
    this.activitySlug,
    this.hasCoordinates,
    this.isVerified,
    this.limit = 6,
  });

  @override
  bool operator ==(Object other) =>
      other is TonightRecommendationFilters &&
      other.citySlug == citySlug &&
      other.categorySlug == categorySlug &&
      other.subcategorySlug == subcategorySlug &&
      other.activitySlug == activitySlug &&
      other.hasCoordinates == hasCoordinates &&
      other.isVerified == isVerified &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(
    citySlug,
    categorySlug,
    subcategorySlug,
    activitySlug,
    hasCoordinates,
    isVerified,
    limit,
  );
}

final tonightActivityRecommendationsProvider =
    FutureProvider.family<
      List<TonightActivityRecommendation>,
      TonightRecommendationFilters
    >((ref, filters) async {
      final activitiesPage = await ref
          .read(taxonomyApiServiceProvider)
          .fetchActivitiesPage(
            page: 1,
            pageSize: 30,
            categorySlug: filters.categorySlug,
            subCategorySlug: filters.subcategorySlug,
          );
      final activities = activitiesPage.items;
      final candidates = _diversifyActivities(
        filters.activitySlug == null
            ? activities
            : activities
                  .where((activity) => activity.slug == filters.activitySlug)
                  .toList(),
      ).take(18);
      final recommendations = <TonightActivityRecommendation>[];

      for (final activity in candidates) {
        try {
          final venues = await ref.read(
            activityVenuePreviewProvider(
              ActivityVenuePreviewFilters(
                citySlug: filters.citySlug,
                activitySlug: activity.slug,
                pageSize: 4,
                hasCoordinates: filters.hasCoordinates,
                isVerified: filters.isVerified,
              ),
            ).future,
          );
          if (venues.items.isEmpty && venues.total == 0) continue;
          recommendations.add(
            TonightActivityRecommendation(activity: activity, venues: venues),
          );
          if (recommendations.length >= filters.limit) break;
        } on Object {
          // Tek aktiviteye ait mekan preview hatası tüm öneri modülünü bozmasın.
        }
      }

      ref
          .read(analyticsApiServiceProvider)
          .track(
            eventName: AnalyticsEventName.activityFilter,
            properties: {
              'source': 'tonight_recommendations',
              'city_slug': filters.citySlug,
              if (filters.categorySlug != null)
                'category_slug': filters.categorySlug,
              if (filters.subcategorySlug != null)
                'subcategory_slug': filters.subcategorySlug,
              if (filters.activitySlug != null)
                'activity_slug': filters.activitySlug,
              'result_count': recommendations.length,
            },
          );

      return recommendations;
    });

List<ApiActivity> _diversifyActivities(List<ApiActivity> activities) {
  final buckets = <String, List<ApiActivity>>{};
  for (final activity in activities) {
    buckets.putIfAbsent(activity.categoryId, () => []).add(activity);
  }

  final result = <ApiActivity>[];
  var added = true;
  while (added) {
    added = false;
    for (final bucket in buckets.values) {
      if (bucket.isEmpty) continue;
      result.add(bucket.removeAt(0));
      added = true;
    }
  }
  return result;
}

final venueDetailProvider = FutureProvider.family<ApiVenue, String>((
  ref,
  slug,
) async {
  final venue = await ref.read(venueApiServiceProvider).fetchVenueDetail(slug);
  ref
      .read(analyticsApiServiceProvider)
      .track(
        eventName: AnalyticsEventName.venueView,
        cityId: venue.city.id,
        venueId: venue.id,
      );
  return venue;
});

final venueActivitiesProvider =
    FutureProvider.family<List<ApiVenueActivitySummary>, String>((ref, slug) {
      return ref.read(venueApiServiceProvider).fetchVenueActivities(slug);
    });

final venueReviewsProvider = FutureProvider.family<List<ApiReview>, String>((
  ref,
  venueId,
) {
  return ref.read(interactionApiServiceProvider).fetchVenueReviews(venueId);
});

class EventFilters {
  final String? citySlug;
  final String? venueSlug;
  final String? activitySlug;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? priceType;
  final String? q;

  const EventFilters({
    this.citySlug,
    this.venueSlug,
    this.activitySlug,
    this.dateFrom,
    this.dateTo,
    this.priceType,
    this.q,
  });

  @override
  bool operator ==(Object other) =>
      other is EventFilters &&
      other.citySlug == citySlug &&
      other.venueSlug == venueSlug &&
      other.activitySlug == activitySlug &&
      other.dateFrom == dateFrom &&
      other.dateTo == dateTo &&
      other.priceType == priceType &&
      other.q == q;

  @override
  int get hashCode => Object.hash(
    citySlug,
    venueSlug,
    activitySlug,
    dateFrom,
    dateTo,
    priceType,
    q,
  );
}

final eventsListProvider = FutureProvider.family<List<ApiEvent>, EventFilters>((
  ref,
  filters,
) {
  return ref
      .read(eventApiServiceProvider)
      .fetchEvents(
        citySlug: filters.citySlug,
        venueSlug: filters.venueSlug,
        activitySlug: filters.activitySlug,
        dateFrom: filters.dateFrom,
        dateTo: filters.dateTo,
        priceType: filters.priceType,
        q: filters.q,
      );
});

class EventPageFilters {
  final int page;
  final int pageSize;
  final String? citySlug;
  final String? venueSlug;
  final String? activitySlug;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? priceType;
  final String? q;

  const EventPageFilters({
    this.page = 1,
    this.pageSize = 20,
    this.citySlug,
    this.venueSlug,
    this.activitySlug,
    this.dateFrom,
    this.dateTo,
    this.priceType,
    this.q,
  });

  @override
  bool operator ==(Object other) =>
      other is EventPageFilters &&
      other.page == page &&
      other.pageSize == pageSize &&
      other.citySlug == citySlug &&
      other.venueSlug == venueSlug &&
      other.activitySlug == activitySlug &&
      other.dateFrom == dateFrom &&
      other.dateTo == dateTo &&
      other.priceType == priceType &&
      other.q == q;

  @override
  int get hashCode => Object.hash(
    page,
    pageSize,
    citySlug,
    venueSlug,
    activitySlug,
    dateFrom,
    dateTo,
    priceType,
    q,
  );
}

final eventsPageProvider =
    FutureProvider.family<ApiPaginatedResponse<ApiEvent>, EventPageFilters>((
      ref,
      filters,
    ) {
      return ref
          .read(eventApiServiceProvider)
          .fetchEventsPage(
            page: filters.page,
            pageSize: filters.pageSize,
            citySlug: filters.citySlug,
            venueSlug: filters.venueSlug,
            activitySlug: filters.activitySlug,
            dateFrom: filters.dateFrom,
            dateTo: filters.dateTo,
            priceType: filters.priceType,
            q: filters.q,
          );
    });

final eventDetailProvider = FutureProvider.family<ApiEvent, String>((
  ref,
  slug,
) async {
  final event = await ref.read(eventApiServiceProvider).fetchEventDetail(slug);
  ref
      .read(analyticsApiServiceProvider)
      .track(
        eventName: AnalyticsEventName.eventView,
        cityId: event.city.id,
        eventRefId: event.id,
      );
  return event;
});

final favoriteVenuesProvider = FutureProvider<List<ApiVenue>>((ref) {
  return ref.read(venueApiServiceProvider).fetchFavoriteVenues();
});

final favoriteEventsProvider = FutureProvider<List<ApiEvent>>((ref) {
  return ref.read(eventApiServiceProvider).fetchFavoriteEvents();
});

class SearchFilters {
  final String query;
  final String? citySlug;
  final int limit;

  const SearchFilters({required this.query, this.citySlug, this.limit = 8});

  @override
  bool operator ==(Object other) =>
      other is SearchFilters &&
      other.query == query &&
      other.citySlug == citySlug &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(query, citySlug, limit);
}

final searchResultsProvider =
    FutureProvider.family<ApiSearchResult, SearchFilters>((ref, filters) async {
      final result = await ref
          .read(searchApiServiceProvider)
          .search(
            query: filters.query,
            citySlug: filters.citySlug,
            limit: filters.limit,
          );
      ref
          .read(analyticsApiServiceProvider)
          .track(
            eventName: AnalyticsEventName.search,
            properties: {
              'query': filters.query,
              'result_count': result.total,
              'zero_results': result.total == 0,
              if (filters.citySlug != null) 'city_slug': filters.citySlug,
            },
          );
      return result;
    });
