import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Localhost API yapılandırmasını `api_config.json` dosyasından yükleyen sınıf.
class ApiConfigLoader {
  ApiConfigLoader._();

  static String _baseUrl = 'http://localhost:8000/api/v1';

  /// Platforma göre otomatik belirlenmiş base URL (Android için 10.0.2.2, diğerleri için localhost).
  static String get baseUrl => _baseUrl;

  /// Yapılandırmayı JSON dosyasından yükler.
  static Future<void> initialize() async {
    try {
      final jsonString = await rootBundle.loadString('api_config.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;

      if (kIsWeb) {
        _baseUrl = data['base_url'] as String? ?? _baseUrl;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        _baseUrl = data['base_url_android'] as String? ?? _baseUrl;
      } else {
        _baseUrl = data['base_url'] as String? ?? _baseUrl;
      }
    } catch (e) {
      debugPrint('api_config.json yüklenirken hata oluştu, varsayılan değer kullanılıyor: $e');
    }
  }
}
