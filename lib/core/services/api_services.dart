import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../shared/models/api_models.dart';
import '../../shared/models/user_model.dart';
import '../errors/app_exception.dart';
import '../network/api_client.dart';

abstract class _ApiService {
  final Dio dio = ApiClient.instance.dio;

  Map<String, dynamic> mapData(Response<dynamic> response) {
    return response.data as Map<String, dynamic>? ?? const {};
  }

  Map<String, dynamic> wrappedData(Response<dynamic> response) {
    return mapData(response)['data'] as Map<String, dynamic>? ?? const {};
  }

  Never fail(Object error) => throw apiServiceException(error);
}

Future<List<T>> _collectAllPages<T>(
  Future<ApiPaginatedResponse<T>> Function(int page) loadPage,
) async {
  final result = <T>[];
  var page = 1;
  while (true) {
    final response = await loadPage(page);
    result.addAll(response.items);
    if (page >= response.pages) return result;
    page++;
  }
}

class TaxonomyApiService extends _ApiService {
  Future<ApiPaginatedResponse<ApiCategory>> fetchCategoriesPage({
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final response = await dio.get(
        '/activity-categories',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return ApiPaginatedResponse.fromJson(
        mapData(response),
        ApiCategory.fromJson,
      );
    } catch (error) {
      fail(error);
    }
  }

  Future<List<ApiCategory>> fetchCategories() async {
    return _collectAllPages(
      (page) => fetchCategoriesPage(page: page, pageSize: 100),
    );
  }

  Future<ApiCategory> fetchCategory(String slug) async {
    try {
      final response = await dio.get('/activity-categories/$slug');
      return ApiCategory.fromJson(wrappedData(response));
    } catch (error) {
      fail(error);
    }
  }

  Future<ApiPaginatedResponse<ApiSubcategory>> fetchSubcategoriesPage({
    int page = 1,
    int pageSize = 100,
    String? categorySlug,
  }) async {
    try {
      final response = await dio.get(
        '/activity-sub-categories',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          'category_slug': ?categorySlug,
        },
      );
      return ApiPaginatedResponse.fromJson(
        mapData(response),
        ApiSubcategory.fromJson,
      );
    } catch (error) {
      fail(error);
    }
  }

  Future<List<ApiSubcategory>> fetchSubcategories({
    String? categorySlug,
  }) async {
    return _collectAllPages(
      (page) => fetchSubcategoriesPage(
        page: page,
        pageSize: 100,
        categorySlug: categorySlug,
      ),
    );
  }

  Future<ApiSubcategory> fetchSubcategory(String slug) async {
    try {
      final response = await dio.get('/activity-sub-categories/$slug');
      return ApiSubcategory.fromJson(wrappedData(response));
    } catch (error) {
      fail(error);
    }
  }

  Future<ApiPaginatedResponse<ApiActivity>> fetchActivitiesPage({
    int page = 1,
    int pageSize = 100,
    String? categorySlug,
    String? subCategorySlug,
    String? q,
  }) async {
    try {
      final response = await dio.get(
        '/activities',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          'category_slug': ?categorySlug,
          'sub_category_slug': ?subCategorySlug,
          'q': ?q,
        },
      );
      return ApiPaginatedResponse.fromJson(
        mapData(response),
        ApiActivity.fromJson,
      );
    } catch (error) {
      fail(error);
    }
  }

  Future<List<ApiActivity>> fetchActivities({
    String? categorySlug,
    String? subCategorySlug,
    String? q,
  }) async {
    return _collectAllPages(
      (page) => fetchActivitiesPage(
        page: page,
        pageSize: 100,
        categorySlug: categorySlug,
        subCategorySlug: subCategorySlug,
        q: q,
      ),
    );
  }

  Future<ApiActivity> fetchActivity(String slug) async {
    try {
      final response = await dio.get('/activities/$slug');
      return ApiActivity.fromJson(wrappedData(response));
    } catch (error) {
      fail(error);
    }
  }
}

class UserApiService extends _ApiService {
  Future<ApiPaginatedResponse<ApiCity>> fetchCities({
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final response = await dio.get(
        '/cities',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return ApiPaginatedResponse.fromJson(mapData(response), ApiCity.fromJson);
    } catch (error) {
      fail(error);
    }
  }

  Future<ApiCity> fetchCity(String slug) async {
    try {
      final response = await dio.get('/cities/$slug');
      return ApiCity.fromJson(wrappedData(response));
    } catch (error) {
      fail(error);
    }
  }

  Future<List<ApiCity>> fetchAllCities() {
    return _collectAllPages((page) => fetchCities(page: page, pageSize: 100));
  }

  Future<AppUser> updateProfile({String? fullName, String? username}) async {
    try {
      final response = await dio.patch(
        '/users/me',
        data: {'full_name': ?fullName, 'username': ?username},
      );
      return appUserFromApi(wrappedData(response));
    } catch (error) {
      fail(error);
    }
  }

  Future<AppUser> updateSelectedCity(String cityId) async {
    try {
      final response = await dio.put(
        '/users/me/selected-city',
        data: {'city_id': cityId},
      );
      return appUserFromApi(wrappedData(response));
    } catch (error) {
      fail(error);
    }
  }
}

class VenueApiService extends _ApiService {
  Future<ApiPaginatedResponse<ApiVenue>> fetchVenuesPage({
    int page = 1,
    int pageSize = 20,
    String? citySlug,
    String? districtSlug,
    String? neighborhoodSlug,
    String? activityCategorySlug,
    String? activitySubCategorySlug,
    String? activitySlug,
    String? tagSlug,
    String? q,
    bool? hasCoordinates,
    bool? isVerified,
  }) async {
    try {
      final response = await dio.get(
        '/venues',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          'city_slug': ?citySlug,
          'district_slug': ?districtSlug,
          'neighborhood_slug': ?neighborhoodSlug,
          'activity_category_slug': ?activityCategorySlug,
          'activity_sub_category_slug': ?activitySubCategorySlug,
          'activity_slug': ?activitySlug,
          'tag_slug': ?tagSlug,
          'q': ?q,
          'has_coordinates': ?hasCoordinates,
          'is_verified': ?isVerified,
        },
      );
      return ApiPaginatedResponse.fromJson(
        mapData(response),
        ApiVenue.fromJson,
      );
    } catch (error) {
      fail(error);
    }
  }

  Future<List<ApiVenue>> fetchVenues({
    int page = 1,
    int pageSize = 20,
    String? citySlug,
    String? districtSlug,
    String? neighborhoodSlug,
    String? activityCategorySlug,
    String? activitySubCategorySlug,
    String? activitySlug,
    String? tagSlug,
    String? q,
    bool? hasCoordinates,
    bool? isVerified,
  }) async {
    return _collectAllPages(
      (currentPage) => fetchVenuesPage(
        page: currentPage,
        pageSize: 100,
        citySlug: citySlug,
        districtSlug: districtSlug,
        neighborhoodSlug: neighborhoodSlug,
        activityCategorySlug: activityCategorySlug,
        activitySubCategorySlug: activitySubCategorySlug,
        activitySlug: activitySlug,
        tagSlug: tagSlug,
        q: q,
        hasCoordinates: hasCoordinates,
        isVerified: isVerified,
      ),
    );
  }

  Future<ApiVenue> fetchVenueDetail(String slug) async {
    try {
      final response = await dio.get('/venues/$slug');
      return ApiVenue.fromJson(wrappedData(response));
    } catch (error) {
      fail(error);
    }
  }

  Future<List<ApiVenueActivitySummary>> fetchVenueActivities(
    String slug,
  ) async {
    try {
      final response = await dio.get('/venues/$slug/activities');
      return (mapData(response)['items'] as List? ?? const [])
          .map(
            (item) =>
                ApiVenueActivitySummary.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (error) {
      fail(error);
    }
  }

  Future<ApiPaginatedResponse<ApiVenue>> fetchVenuesForDiscovery({
    required String scope,
    required String slug,
    required String citySlug,
    int page = 1,
    int pageSize = 20,
    String? districtSlug,
    String? neighborhoodSlug,
    String? tagSlug,
    String? q,
  }) async {
    final prefix = switch (scope) {
      'category' => 'activity-categories',
      'subcategory' => 'activity-sub-categories',
      _ => 'activities',
    };
    try {
      final response = await dio.get(
        '/$prefix/$slug/venues',
        queryParameters: {
          'city_slug': citySlug,
          'page': page,
          'page_size': pageSize,
          'district_slug': ?districtSlug,
          'neighborhood_slug': ?neighborhoodSlug,
          'tag_slug': ?tagSlug,
          'q': ?q,
        },
      );
      return ApiPaginatedResponse.fromJson(
        mapData(response),
        ApiVenue.fromJson,
      );
    } catch (error) {
      fail(error);
    }
  }

  Future<List<ApiVenue>> fetchAllVenuesForDiscovery({
    required String scope,
    required String slug,
    required String citySlug,
    String? districtSlug,
    String? neighborhoodSlug,
    String? tagSlug,
    String? q,
  }) {
    return _collectAllPages(
      (page) => fetchVenuesForDiscovery(
        scope: scope,
        slug: slug,
        citySlug: citySlug,
        page: page,
        pageSize: 100,
        districtSlug: districtSlug,
        neighborhoodSlug: neighborhoodSlug,
        tagSlug: tagSlug,
        q: q,
      ),
    );
  }

  Future<List<ApiVenue>> fetchFavoriteVenues({
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      return _collectAllPages((currentPage) async {
        final response = await dio.get(
          '/users/me/favorite-venues',
          queryParameters: {'page': currentPage, 'page_size': 100},
        );
        return ApiPaginatedResponse.fromJson(
          mapData(response),
          ApiVenue.fromJson,
        );
      });
    } catch (error) {
      fail(error);
    }
  }

  Future<bool> addFavoriteVenue(String venueId) =>
      _setFavorite('/users/me/favorite-venues/$venueId', true);

  Future<bool> removeFavoriteVenue(String venueId) =>
      _setFavorite('/users/me/favorite-venues/$venueId', false);

  Future<bool> _setFavorite(String path, bool value) async {
    try {
      final response = value ? await dio.post(path) : await dio.delete(path);
      return wrappedData(response)['is_favorite'] as bool? ?? value;
    } catch (error) {
      fail(error);
    }
  }
}

class EventApiService extends _ApiService {
  Future<ApiPaginatedResponse<ApiEvent>> fetchEventsPage({
    int page = 1,
    int pageSize = 20,
    String? citySlug,
    String? venueSlug,
    String? activitySlug,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? priceType,
    String? q,
  }) async {
    try {
      final response = await dio.get(
        '/events',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          'city_slug': ?citySlug,
          'venue_slug': ?venueSlug,
          'activity_slug': ?activitySlug,
          if (dateFrom != null) 'date_from': dateFrom.toIso8601String(),
          if (dateTo != null) 'date_to': dateTo.toIso8601String(),
          'price_type': ?priceType,
          'q': ?q,
        },
      );
      return ApiPaginatedResponse.fromJson(
        mapData(response),
        ApiEvent.fromJson,
      );
    } catch (error) {
      fail(error);
    }
  }

  Future<List<ApiEvent>> fetchEvents({
    int page = 1,
    int pageSize = 20,
    String? citySlug,
    String? venueSlug,
    String? activitySlug,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? priceType,
    String? q,
  }) async {
    return _collectAllPages(
      (currentPage) => fetchEventsPage(
        page: currentPage,
        pageSize: 100,
        citySlug: citySlug,
        venueSlug: venueSlug,
        activitySlug: activitySlug,
        dateFrom: dateFrom,
        dateTo: dateTo,
        priceType: priceType,
        q: q,
      ),
    );
  }

  Future<ApiEvent> fetchEventDetail(String slug) async {
    try {
      final response = await dio.get('/events/$slug');
      return ApiEvent.fromJson(wrappedData(response));
    } catch (error) {
      fail(error);
    }
  }

  Future<ApiEventAttendance> setAttendance(
    String eventId,
    String status,
  ) async {
    if (!const {'interested', 'going', 'not_going'}.contains(status)) {
      throw const ServiceException(
        message: 'Geçersiz katılım durumu.',
        code: 'client_validation_error',
        statusCode: 422,
      );
    }
    try {
      final response = await dio.post(
        '/events/$eventId/attendance',
        data: {'status': status},
      );
      return ApiEventAttendance.fromJson(wrappedData(response));
    } catch (error) {
      fail(error);
    }
  }

  Future<void> deleteAttendance(String eventId) async {
    try {
      await dio.delete('/events/$eventId/attendance');
    } catch (error) {
      fail(error);
    }
  }

  Future<List<ApiEvent>> fetchFavoriteEvents({
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      return _collectAllPages((currentPage) async {
        final response = await dio.get(
          '/users/me/favorite-events',
          queryParameters: {'page': currentPage, 'page_size': 100},
        );
        return ApiPaginatedResponse.fromJson(
          mapData(response),
          ApiEvent.fromJson,
        );
      });
    } catch (error) {
      fail(error);
    }
  }

  Future<bool> addFavoriteEvent(String eventId) =>
      _setFavorite('/users/me/favorite-events/$eventId', true);

  Future<bool> removeFavoriteEvent(String eventId) =>
      _setFavorite('/users/me/favorite-events/$eventId', false);

  Future<bool> _setFavorite(String path, bool value) async {
    try {
      final response = value ? await dio.post(path) : await dio.delete(path);
      return wrappedData(response)['is_favorite'] as bool? ?? value;
    } catch (error) {
      fail(error);
    }
  }
}

class InteractionApiService extends _ApiService {
  Future<ApiPaginatedResponse<ApiReview>> fetchVenueReviewsPage(
    String venueId, {
    String? activityId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        '/venues/$venueId/reviews',
        queryParameters: {
          'activity_id': ?activityId,
          'page': page,
          'page_size': pageSize,
        },
      );
      return ApiPaginatedResponse.fromJson(
        mapData(response),
        ApiReview.fromJson,
      );
    } catch (error) {
      fail(error);
    }
  }

  Future<List<ApiReview>> fetchVenueReviews(
    String venueId, {
    String? activityId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return _collectAllPages(
      (currentPage) => fetchVenueReviewsPage(
        venueId,
        activityId: activityId,
        page: currentPage,
        pageSize: 100,
      ),
    );
  }

  Future<ApiReview> createReview(
    String venueId,
    int rating,
    String? comment, {
    String? activityId,
  }) async {
    _validateRating(rating);
    try {
      final response = await dio.post(
        '/venues/$venueId/reviews',
        data: {
          'rating': rating,
          'comment': ?comment,
          'activity_id': ?activityId,
        },
      );
      return ApiReview.fromJson(wrappedData(response));
    } catch (error) {
      fail(error);
    }
  }

  Future<ApiReview> updateMyReview(
    String venueId,
    int? rating,
    String? comment, {
    String? activityId,
  }) async {
    if (rating != null) _validateRating(rating);
    try {
      final response = await dio.patch(
        '/venues/$venueId/reviews/me',
        queryParameters: {'activity_id': ?activityId},
        data: {'rating': ?rating, 'comment': ?comment},
      );
      return ApiReview.fromJson(wrappedData(response));
    } catch (error) {
      fail(error);
    }
  }

  Future<ApiContentReport> createContentReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await dio.post(
        '/reports',
        data: {
          'target_type': targetType,
          'target_id': targetId,
          'reason': reason,
          'description': ?description,
        },
      );
      return ApiContentReport.fromJson(wrappedData(response));
    } catch (error) {
      fail(error);
    }
  }

  void _validateRating(int rating) {
    if (rating < 1 || rating > 5) {
      throw const ServiceException(
        message: 'Puan 1 ile 5 arasında olmalıdır.',
        code: 'client_validation_error',
        statusCode: 422,
      );
    }
  }
}

class SearchApiService extends _ApiService {
  Future<ApiSearchResult> search({
    required String query,
    String? citySlug,
    int limit = 8,
  }) async {
    try {
      final response = await dio.get(
        '/search',
        queryParameters: {'q': query, 'city_slug': ?citySlug, 'limit': limit},
      );
      return ApiSearchResult.fromJson(mapData(response));
    } catch (error) {
      fail(error);
    }
  }
}

class SubmissionApiService extends _ApiService {
  Future<ApiSubmissionReceipt> createVenueSuggestion({
    required String cityId,
    required String name,
    String? address,
    String? googleMapsUrl,
    String? instagramUrl,
    String? note,
  }) async {
    try {
      final response = await dio.post(
        '/venue-suggestions',
        data: {
          'city_id': cityId,
          'name': name,
          'address': ?address,
          'google_maps_url': ?googleMapsUrl,
          'instagram_url': ?instagramUrl,
          'note': ?note,
        },
      );
      return ApiSubmissionReceipt.fromJson(mapData(response));
    } catch (error) {
      fail(error);
    }
  }

  Future<ApiSubmissionReceipt> createOwnershipApplication({
    String? venueId,
    String? requestedVenueName,
    String? businessName,
    required String contactName,
    required String contactPhone,
    required String contactEmail,
    String? proofMediaId,
    String? message,
  }) async {
    try {
      final response = await dio.post(
        '/venue-ownership-applications',
        data: {
          'venue_id': ?venueId,
          'requested_venue_name': ?requestedVenueName,
          'business_name': ?businessName,
          'contact_name': contactName,
          'contact_phone': contactPhone,
          'contact_email': contactEmail,
          'proof_media_id': ?proofMediaId,
          'message': ?message,
        },
      );
      return ApiSubmissionReceipt.fromJson(mapData(response));
    } catch (error) {
      fail(error);
    }
  }

  Future<ApiSubmissionReceipt> createTaxonomyRequest({
    required String requestType,
    required String name,
    String? description,
    String? categoryId,
  }) async {
    try {
      final response = await dio.post(
        '/taxonomy-requests',
        data: {
          'request_type': requestType,
          'name': name,
          'description': ?description,
          'category_id': ?categoryId,
        },
      );
      return ApiSubmissionReceipt.fromJson(mapData(response));
    } catch (error) {
      fail(error);
    }
  }
}

class MediaApiService extends _ApiService {
  Future<ApiMedia> fetchMedia(String mediaId) async {
    try {
      final response = await dio.get('/media/$mediaId/metadata');
      return ApiMedia.fromJson(wrappedData(response));
    } catch (error) {
      fail(error);
    }
  }

  Future<ApiMedia> uploadImage({
    required String filePath,
    required String usageType,
    String visibility = 'public',
  }) async {
    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'usage_type': usageType,
        'visibility': visibility,
      });
      final response = await dio.post(
        '/uploads/image',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      return ApiMedia.fromJson(wrappedData(response));
    } catch (error) {
      fail(error);
    }
  }
}

class AnalyticsApiService extends _ApiService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const _anonymousIdKey = 'analytics_anonymous_id';
  static final String _sessionId = _newId('session');

  void track({
    required String eventName,
    String? cityId,
    String? venueId,
    String? activityId,
    String? eventRefId,
    Map<String, dynamic> properties = const {},
  }) {
    unawaited(
      send(
        eventName: eventName,
        cityId: cityId,
        venueId: venueId,
        activityId: activityId,
        eventRefId: eventRefId,
        properties: properties,
      ),
    );
  }

  Future<bool> send({
    required String eventName,
    String? cityId,
    String? venueId,
    String? activityId,
    String? eventRefId,
    Map<String, dynamic> properties = const {},
  }) async {
    if (!AnalyticsEventName.values.contains(eventName)) {
      if (kDebugMode) {
        debugPrint('Analytics event reddedildi: $eventName');
      }
      return false;
    }

    try {
      final anonymousId = await _getAnonymousId();
      await dio.post(
        '/analytics/track',
        data: {
          'event_name': eventName,
          'anonymous_id': anonymousId,
          'session_id': _sessionId,
          'city_id': ?cityId,
          'venue_id': ?venueId,
          'activity_id': ?activityId,
          'event_ref_id': ?eventRefId,
          'platform': 'flutter',
          'app_version': '1.0.0',
          'properties': properties,
        },
      );
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          'Analytics gönderilemedi: ${apiServiceException(error).code}',
        );
      }
      return false;
    }
  }

  Future<String> _getAnonymousId() async {
    final existing = await _storage.read(key: _anonymousIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = _newId('install');
    await _storage.write(key: _anonymousIdKey, value: generated);
    return generated;
  }

  static String _newId(String prefix) {
    final random = Random.secure();
    final entropy = List.generate(
      4,
      (_) => random.nextInt(0x7fffffff).toRadixString(16),
    ).join();
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-$entropy';
  }
}

AppUser appUserFromApi(Map<String, dynamic> json) {
  final role = json['role'] as String? ?? 'user';
  return AppUser(
    id: json['id']?.toString() ?? '',
    username: json['username'] as String? ?? '',
    displayName:
        json['full_name'] as String? ?? json['username'] as String? ?? '',
    email: json['email'] as String? ?? '',
    selectedCityId: json['selected_city_id']?.toString(),
    roles: [role],
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updated_at'] as String? ?? '') ??
        DateTime.now(),
  );
}

ServiceException apiServiceException(Object error) {
  if (error is ServiceException) return error;
  if (error is DioException) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final fallbackMessage = _dioFallbackMessage(error, statusCode);

    try {
      final data = response?.data;
      final body = data is Map ? data : const <String, dynamic>{};
      final rawErrorBody = body['error'];
      final errorBody = rawErrorBody is Map
          ? rawErrorBody
          : const <String, dynamic>{};
      final detail = body['detail'];

      return ServiceException(
        message:
            _apiErrorText(errorBody['message']) ??
            _apiErrorText(detail) ??
            fallbackMessage,
        code: _apiPrimitiveText(errorBody['code']) ?? 'api_error',
        statusCode: statusCode,
        requestId: response?.headers.value('x-request-id'),
        details: errorBody['details'] ?? detail,
      );
    } on Object {
      // Hata gövdesi beklenmedik bir tipte olsa da Dio hatasını UI'a
      // dönüştürmek ikinci bir exception üretmemeli.
      return ServiceException(
        message: fallbackMessage,
        code: 'api_error',
        statusCode: statusCode,
        requestId: response?.headers.value('x-request-id'),
      );
    }
  }
  return ServiceException(message: error.toString(), code: 'unexpected_error');
}

String _dioFallbackMessage(DioException error, int? statusCode) {
  return switch (statusCode) {
    401 => 'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.',
    403 => 'Bu işlem için yetkiniz bulunmuyor.',
    404 => 'İstenen kayıt bulunamadı.',
    409 => 'Bu işlem mevcut kayıtla çakışıyor.',
    422 => 'Gönderilen bilgileri kontrol edin.',
    429 => 'Çok fazla istek gönderildi. Lütfen biraz bekleyin.',
    500 => 'Sunucuda bir hata oluştu. Lütfen daha sonra tekrar deneyin.',
    _ => switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => 'API bağlantısı zaman aşımına uğradı.',
      DioExceptionType.connectionError => 'İnternet bağlantınızı kontrol edin.',
      _ => 'API sunucusuna bağlanılamadı.',
    },
  };
}

String? _apiPrimitiveText(Object? value) {
  if (value is String) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
  if (value is num || value is bool) return value.toString();
  return null;
}

String? _apiErrorText(Object? value) {
  final primitive = _apiPrimitiveText(value);
  if (primitive != null) return primitive;

  if (value is Map) {
    return _apiErrorText(value['message']) ??
        _apiErrorText(value['msg']) ??
        _apiErrorText(value['detail']);
  }

  if (value is List) {
    final messages = value
        .map(_apiErrorText)
        .whereType<String>()
        .where((message) => message.isNotEmpty)
        .toList();
    return messages.isEmpty ? null : messages.join('\n');
  }

  return null;
}
