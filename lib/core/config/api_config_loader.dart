import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// API yapılandırmasını `api_config.json` dosyasından yükleyen sınıf.
class ApiConfigLoader {
  ApiConfigLoader._();

  static String _baseUrl = 'https://api.169.58.108.163.sslip.io/api/v1';
  static String _environment = 'local';

  /// Uygulamanın kullandığı API base URL'i.
  static String get baseUrl => _baseUrl;
  static String get environment => _environment;

  /// Yapılandırmayı JSON dosyasından yükler.
  static Future<void> initialize() async {
    try {
      final jsonString = await rootBundle.loadString('api_config.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      _environment = const String.fromEnvironment('API_ENV', defaultValue: '');
      if (_environment.isEmpty) {
        _environment = data['environment'] as String? ?? 'local';
      }

      final environments =
          data['environments'] as Map<String, dynamic>? ?? const {};
      final environmentConfig =
          environments[_environment] as Map<String, dynamic>? ?? data;

      if (kIsWeb) {
        _baseUrl = environmentConfig['base_url'] as String? ?? _baseUrl;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        _baseUrl =
            environmentConfig['base_url_android'] as String? ??
            environmentConfig['base_url'] as String? ??
            _baseUrl;
      } else {
        _baseUrl = environmentConfig['base_url'] as String? ?? _baseUrl;
      }
      const overrideUrl = String.fromEnvironment('API_BASE_URL');
      if (overrideUrl.isNotEmpty) {
        _baseUrl = overrideUrl;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'api_config.json yüklenirken hata oluştu, varsayılan değer kullanılıyor: $e',
        );
      }
    }
  }
}
