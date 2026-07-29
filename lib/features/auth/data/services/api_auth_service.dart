import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_services.dart';
import '../../../../shared/models/user_model.dart';

class ApiAuthService {
  final Dio _dio = ApiClient.instance.dio;

  Future<AppUser> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'username': username,
          'full_name': fullName,
          'role': role,
        },
      );
      final body = response.data as Map<String, dynamic>? ?? const {};
      return appUserFromApi(body['data'] as Map<String, dynamic>? ?? const {});
    } catch (error) {
      throw apiServiceException(error);
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>? ?? const {};
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      if (accessToken == null || refreshToken == null) {
        throw const FormatException('Token response eksik.');
      }
      await ApiClient.instance.saveSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (error) {
      throw apiServiceException(error);
    }
  }

  Future<AppUser> fetchCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      final body = response.data as Map<String, dynamic>? ?? const {};
      return appUserFromApi(body['data'] as Map<String, dynamic>? ?? const {});
    } catch (error) {
      throw apiServiceException(error);
    }
  }

  Future<void> logout() async {
    final refreshToken = await ApiClient.instance.getRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _dio.post('/auth/logout', data: {'refresh_token': refreshToken});
      }
    } on DioException {
      // Sunucu kapalı olsa da cihazdaki oturum mutlaka sonlandırılır.
    } finally {
      await ApiClient.instance.clearSession();
    }
  }
}
