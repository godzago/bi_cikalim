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
