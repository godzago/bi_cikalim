import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config_loader.dart';

/// API isteklerini yöneten merkezi Dio HTTP istemcisi.
class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfigLoader.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Otomatik Authorization header ekleyen Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Hata detaylarını konsola yazdır
          debugPrint('API Hata [${e.response?.statusCode}]: ${e.requestOptions.path}');
          debugPrint('Hata Detayı: ${e.response?.data}');
          return handler.next(e);
        },
      ),
    );
  }

  static final ApiClient _instance = ApiClient._();
  late final Dio _dio;
  
  final _storage = const FlutterSecureStorage();

  /// Singleton ApiClient örneği.
  static ApiClient get instance => _instance;

  /// Dio istemcisi.
  Dio get dio => _dio;

  /// Token'ı kaydeder.
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Token'ı siler.
  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  /// Kayıtlı token'ı getirir.
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Beni Hatırla giriş bilgilerini kaydeder.
  Future<void> saveRememberedCredentials(String email, String password) async {
    await _storage.write(key: 'remember_email', value: email);
    await _storage.write(key: 'remember_password', value: password);
  }

  /// Beni Hatırla giriş bilgilerini temizler.
  Future<void> clearRememberedCredentials() async {
    await _storage.delete(key: 'remember_email');
    await _storage.delete(key: 'remember_password');
  }

  /// Kayıtlı Beni Hatırla giriş bilgilerini getirir.
  Future<Map<String, String?>> getRememberedCredentials() async {
    final email = await _storage.read(key: 'remember_email');
    final password = await _storage.read(key: 'remember_password');
    return {
      'email': email,
      'password': password,
    };
  }
}
