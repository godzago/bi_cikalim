import 'package:dio/dio.dart';
import '../../shared/models/api_models.dart';
import '../network/api_client.dart';

class TaxonomyApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<ApiCategory>> fetchCategories() async {
    try {
      final response = await _dio.get('/activity-categories');
      final data = response.data as Map<String, dynamic>;
      final list = data['items'] as List? ?? [];
      return list.map((item) => ApiCategory.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ApiSubcategory>> fetchSubcategories({String? categorySlug}) async {
    try {
      final response = await _dio.get(
        '/activity-sub-categories',
        queryParameters: {
          if (categorySlug != null) 'category_slug': categorySlug,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['items'] as List? ?? [];
      return list.map((item) => ApiSubcategory.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ApiActivity>> fetchActivities({
    String? categorySlug,
    String? subCategorySlug,
    String? q,
  }) async {
    try {
      final response = await _dio.get(
        '/activities',
        queryParameters: {
          if (categorySlug != null) 'category_slug': categorySlug,
          if (subCategorySlug != null) 'sub_category_slug': subCategorySlug,
          if (q != null) 'q': q,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['items'] as List? ?? [];
      return list.map((item) => ApiActivity.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
}

class VenueApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<ApiVenue>> fetchVenues({
    int page = 1,
    int pageSize = 20,
    String? citySlug,
    String? districtSlug,
    String? activityCategorySlug,
    String? activitySlug,
    String? q,
  }) async {
    try {
      final response = await _dio.get(
        '/venues',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (citySlug != null) 'city_slug': citySlug,
          if (districtSlug != null) 'district_slug': districtSlug,
          if (activityCategorySlug != null) 'activity_category_slug': activityCategorySlug,
          if (activitySlug != null) 'activity_slug': activitySlug,
          if (q != null) 'q': q,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['items'] as List? ?? [];
      return list.map((item) => ApiVenue.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiVenue> fetchVenueDetail(String slug) async {
    try {
      final response = await _dio.get('/venues/$slug');
      final data = response.data as Map<String, dynamic>;
      return ApiVenue.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ApiVenueActivitySummary>> fetchVenueActivities(String slug) async {
    try {
      final response = await _dio.get('/venues/$slug/activities');
      final data = response.data as Map<String, dynamic>;
      final list = data['items'] as List? ?? [];
      return list.map((item) => ApiVenueActivitySummary.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ApiVenue>> fetchFavoriteVenues() async {
    try {
      final response = await _dio.get('/users/me/favorite-venues');
      final data = response.data as Map<String, dynamic>;
      final list = data['items'] as List? ?? [];
      return list.map((item) => ApiVenue.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> addFavoriteVenue(String venueId) async {
    try {
      final response = await _dio.post('/users/me/favorite-venues/$venueId');
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      return data['is_favorite'] as bool? ?? true;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> removeFavoriteVenue(String venueId) async {
    try {
      final response = await _dio.delete('/users/me/favorite-venues/$venueId');
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      return data['is_favorite'] as bool? ?? false;
    } catch (e) {
      throw _handleError(e);
    }
  }
}

class EventApiService {
  final Dio _dio = ApiClient.instance.dio;

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
    try {
      final response = await _dio.get(
        '/events',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          if (citySlug != null) 'city_slug': citySlug,
          if (venueSlug != null) 'venue_slug': venueSlug,
          if (activitySlug != null) 'activity_slug': activitySlug,
          if (dateFrom != null) 'date_from': dateFrom.toIso8601String(),
          if (dateTo != null) 'date_to': dateTo.toIso8601String(),
          if (priceType != null) 'price_type': priceType,
          if (q != null) 'q': q,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['items'] as List? ?? [];
      return list.map((item) => ApiEvent.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiEvent> fetchEventDetail(String slug) async {
    try {
      final response = await _dio.get('/events/$slug');
      final data = response.data as Map<String, dynamic>;
      return ApiEvent.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiEventAttendance> setAttendance(String eventId, String status) async {
    try {
      final response = await _dio.post(
        '/events/$eventId/attendance',
        data: {'status': status},
      );
      final data = response.data as Map<String, dynamic>;
      return ApiEventAttendance.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteAttendance(String eventId) async {
    try {
      await _dio.delete('/events/$eventId/attendance');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ApiEvent>> fetchFavoriteEvents() async {
    try {
      final response = await _dio.get('/users/me/favorite-events');
      final data = response.data as Map<String, dynamic>;
      final list = data['items'] as List? ?? [];
      return list.map((item) => ApiEvent.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> addFavoriteEvent(String eventId) async {
    try {
      final response = await _dio.post('/users/me/favorite-events/$eventId');
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      return data['is_favorite'] as bool? ?? true;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> removeFavoriteEvent(String eventId) async {
    try {
      final response = await _dio.delete('/users/me/favorite-events/$eventId');
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      return data['is_favorite'] as bool? ?? false;
    } catch (e) {
      throw _handleError(e);
    }
  }
}

class InteractionApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<ApiReview>> fetchVenueReviews(String venueId, {int page = 1, int pageSize = 20}) async {
    try {
      final response = await _dio.get(
        '/venues/$venueId/reviews',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['items'] as List? ?? [];
      return list.map((item) => ApiReview.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiReview> createReview(String venueId, int rating, String? comment) async {
    try {
      final response = await _dio.post(
        '/venues/$venueId/reviews',
        data: {
          'rating': rating,
          if (comment != null) 'comment': comment,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return ApiReview.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiReview> updateMyReview(String venueId, int? rating, String? comment) async {
    try {
      final response = await _dio.patch(
        '/venues/$venueId/reviews/me',
        data: {
          if (rating != null) 'rating': rating,
          if (comment != null) 'comment': comment,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return ApiReview.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiContentReport> createContentReport({
    required String targetType,
    required String targetId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/reports',
        data: {
          'target_type': targetType,
          'target_id': targetId,
          'reason': reason,
          if (description != null) 'description': description,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return ApiContentReport.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }
}

Exception _handleError(dynamic e) {
  if (e is DioException) {
    if (e.response != null && e.response!.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      final detail = data['detail'];
      if (detail is String) {
        return Exception(detail);
      }
    }
    return Exception(e.message ?? 'Ağ hatası oluştu.');
  }
  return Exception(e.toString());
}
