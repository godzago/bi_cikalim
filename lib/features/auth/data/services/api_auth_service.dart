import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/user_model.dart';

/// FastAPI Backend ile kimlik doğrulama işlemlerini gerçekleştiren servis.
class ApiAuthService {
  final Dio _dio = ApiClient.instance.dio;

  /// Yeni kullanıcı kaydı oluşturur.
  /// Endpoint: POST /api/v1/auth/register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'username': username,
          'full_name': fullName,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Kullanıcı girişi yapar ve access token alır.
  /// Endpoint: POST /api/v1/auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      final responseData = response.data as Map<String, dynamic>;
      
      // Token'ı ApiClient ve lokal depolamada sakla
      final token = responseData['access_token'] as String?;
      if (token != null) {
        await ApiClient.instance.saveToken(token);
      }
      return responseData;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Giriş yapmış kullanıcının profil bilgilerini çeker.
  /// Endpoint: GET /api/v1/auth/me
  Future<AppUser> fetchCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      final responseData = response.data as Map<String, dynamic>;
      final userData = responseData['data'] as Map<String, dynamic>;
      
      final role = userData['role'] as String? ?? 'user';
      
      return AppUser(
        id: userData['id'] as String? ?? '',
        displayName: userData['full_name'] as String? ?? userData['username'] as String? ?? '',
        email: userData['email'] as String? ?? '',
        roles: [role],
        createdAt: userData['created_at'] != null 
            ? DateTime.tryParse(userData['created_at'] as String) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: userData['updated_at'] != null 
            ? DateTime.tryParse(userData['updated_at'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Aktif oturumu kapatır ve token'ı siler.
  Future<void> logout() async {
    await ApiClient.instance.clearToken();
  }

  /// JWT Token çözerek kullanıcı bilgilerini elde eder.
  /// Eğer JWT çözülemezse mock/fallback bir kullanıcı nesnesi oluşturur.
  AppUser parseUserFromToken(String token, {String? fallbackEmail, String? fallbackName}) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw const FormatException('Geçersiz token formatı');
      }
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decodedJson = utf8.decode(base64Url.decode(normalized));
      final payloadData = json.decode(decodedJson) as Map<String, dynamic>;

      final email = payloadData['sub'] as String? ?? payloadData['email'] as String? ?? fallbackEmail ?? 'user@bicikalim.com';
      final username = payloadData['username'] as String? ?? fallbackName ?? email.split('@')[0];
      final roles = payloadData['roles'] != null 
          ? List<String>.from(payloadData['roles'] as List) 
          : (payloadData['role'] != null ? [payloadData['role'] as String] : ['user']);

      return AppUser(
        id: payloadData['id']?.toString() ?? payloadData['user_id']?.toString() ?? email,
        displayName: payloadData['full_name'] as String? ?? username,
        email: email,
        roles: roles,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      // Çözme başarısız olursa güvenli fallback
      return AppUser(
        id: fallbackEmail ?? 'guest_user',
        displayName: fallbackName ?? fallbackEmail?.split('@')[0] ?? 'Kullanıcı',
        email: fallbackEmail ?? 'user@bicikalim.com',
        roles: ['user'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        // Özel hata formatımızı kontrol et
        final error = data['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'] as String?;
          final details = error['details'];
          if (details is List && details.isNotEmpty) {
            try {
              final msg = details.map((err) {
                if (err is Map<String, dynamic>) {
                  final msgVal = err['msg'] ?? err['message'];
                  if (msgVal != null) return msgVal;
                }
                return err.toString();
              }).join(', ');
              return Exception(msg);
            } catch (_) {}
          }
          if (message != null) {
            return Exception(message);
          }
        }

        // Klasik FastAPI detail formatı
        final detail = data['detail'];
        if (detail is String) {
          return Exception(detail);
        } else if (detail is List) {
          try {
            final msg = detail.map((err) => err['msg']).join(', ');
            return Exception(msg);
          } catch (_) {}
        }
      }
      return Exception('Sunucu hatası: ${e.response!.statusCode}');
    }
    
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return Exception('Bağlantı zaman aşımına uğradı. Lütfen Docker API\'nin çalıştığından emin olun.');
    }
    
    return Exception('Sunucuya bağlanılamadı: ${e.message}');
  }
}
