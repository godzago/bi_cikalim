import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config_loader.dart';
import '../../shared/models/user_model.dart';

/// Uygulamanın tek HTTP istemcisi.
///
/// Oturum varsa public istekler dahil bütün isteklere bearer token ekler.
/// 401 yanıtında aynı anda yalnızca bir refresh çalıştırır ve isteği bir kez
/// tekrarlar. Access ve refresh token tek JSON kaydıyla birlikte güncellenir.
class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfigLoader.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConfigLoader.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = await getSession();
          final accessToken = session?.accessToken;
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final requestId =
              error.response?.headers.value('x-request-id') ?? 'unknown';
          debugPrint(
            'API ${error.response?.statusCode ?? '-'} '
            '${error.requestOptions.method} ${error.requestOptions.path} '
            'requestId=$requestId',
          );

          if (_canRefresh(error)) {
            final accessToken = await _refreshAccessToken();
            if (accessToken != null) {
              final options = error.requestOptions;
              options.extra[_retriedKey] = true;
              options.headers['Authorization'] = 'Bearer $accessToken';
              try {
                handler.resolve(await _dio.fetch<dynamic>(options));
                return;
              } on DioException {
                // Orijinal 401 aşağıdaki ortak hata akışına bırakılır.
              }
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  static const _sessionKey = 'auth_session';
  static const _cachedUserKey = 'auth_cached_user';
  static const _legacyAccessTokenKey = 'auth_token';
  static const _retriedKey = 'auth_request_retried';

  static final ApiClient _instance = ApiClient._();

  late final Dio _dio;
  late final Dio _refreshDio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();
  Future<String?>? _refreshFuture;

  static ApiClient get instance => _instance;

  Dio get dio => _dio;

  Stream<void> get sessionExpired => _sessionExpiredController.stream;

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
  }) async {
    final encoded = jsonEncode({
      'access_token': accessToken,
      'refresh_token': refreshToken,
    });
    await _storage.write(key: _sessionKey, value: encoded);
    await _storage.delete(key: _legacyAccessTokenKey);
  }

  Future<AuthSession?> getSession() async {
    final encoded = await _storage.read(key: _sessionKey);
    if (encoded != null && encoded.isNotEmpty) {
      try {
        return AuthSession.fromJson(
          jsonDecode(encoded) as Map<String, dynamic>,
        );
      } on FormatException {
        await clearSession();
      }
    }

    // Önceki uygulama sürümündeki access-token-only kaydını okuyabilmek için.
    final legacy = await _storage.read(key: _legacyAccessTokenKey);
    if (legacy != null && legacy.isNotEmpty) {
      return AuthSession(accessToken: legacy);
    }
    return null;
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
    await _storage.delete(key: _cachedUserKey);
    await _storage.delete(key: _legacyAccessTokenKey);
  }

  /// Son doğrulanan kullanıcıyı cihazda tutar. Böylece geçici bir ağ
  /// probleminde geçerli oturum, kullanıcı veya mekan sahibi için kaybolmaz.
  Future<void> saveCachedUser(AppUser user) async {
    await _storage.write(
      key: _cachedUserKey,
      value: jsonEncode({'id': user.id, ...user.toMap()}),
    );
  }

  Future<AppUser?> getCachedUser() async {
    final encoded = await _storage.read(key: _cachedUserKey);
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final map = jsonDecode(encoded) as Map<String, dynamic>;
      final id = map.remove('id')?.toString();
      if (id == null || id.isEmpty) return null;
      return AppUser.fromMap(id, map);
    } on Object {
      await _storage.delete(key: _cachedUserKey);
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _legacyAccessTokenKey, value: token);
  }

  Future<void> clearToken() => clearSession();

  Future<String?> getToken() async => (await getSession())?.accessToken;

  Future<String?> getRefreshToken() async => (await getSession())?.refreshToken;

  bool _canRefresh(DioException error) {
    if (error.response?.statusCode != 401) return false;
    if (error.requestOptions.extra[_retriedKey] == true) return false;
    final path = error.requestOptions.path;
    return path != '/auth/login' &&
        path != '/auth/register' &&
        path != '/auth/refresh';
  }

  Future<String?> _refreshAccessToken() {
    final activeRefresh = _refreshFuture;
    if (activeRefresh != null) return activeRefresh;

    final future = _performRefresh();
    _refreshFuture = future;
    return future.whenComplete(() {
      if (identical(_refreshFuture, future)) {
        _refreshFuture = null;
      }
    });
  }

  Future<String?> _performRefresh() async {
    final session = await getSession();
    final refreshToken = session?.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      await _expireSession();
      return null;
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data ?? const <String, dynamic>{};
      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;
      if (newAccessToken == null || newRefreshToken == null) {
        await _expireSession();
        return null;
      }
      await saveSession(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      return newAccessToken;
    } on DioException catch (error) {
      // İnternet kesintisi veya geçici sunucu hatası kullanıcıyı hesabından
      // çıkarmamalı. Oturum yalnızca refresh token açıkça reddedildiğinde biter.
      final statusCode = error.response?.statusCode;
      if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
        await _expireSession();
      }
      return null;
    }
  }

  Future<void> _expireSession() async {
    await clearSession();
    _sessionExpiredController.add(null);
  }

  Future<void> saveRememberedCredentials(String email, String password) async {
    await _storage.write(key: 'remember_email', value: email);
    await _storage.write(key: 'remember_password', value: password);
  }

  Future<void> clearRememberedCredentials() async {
    await _storage.delete(key: 'remember_email');
    await _storage.delete(key: 'remember_password');
  }

  Future<Map<String, String?>> getRememberedCredentials() async {
    return {
      'email': await _storage.read(key: 'remember_email'),
      'password': await _storage.read(key: 'remember_password'),
    };
  }
}

class AuthSession {
  final String accessToken;
  final String? refreshToken;

  const AuthSession({required this.accessToken, this.refreshToken});

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String?,
    );
  }
}
