import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';

/// Bildirim izni tanıtımını ve sistem iznini tek seferlik yönetir.
class NotificationPermissionService {
  NotificationPermissionService._();

  static const _promptedKey = 'notification_permission_prompted_v1';
  static const _storage = FlutterSecureStorage();

  static bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Future<bool> shouldShowPrompt() async {
    if (!_isMobile) return false;

    final hasPrompted = await _storage.read(key: _promptedKey) == 'true';
    if (hasPrompted) return false;

    final status = await Permission.notification.status;
    if (status.isGranted || status.isLimited || status.isProvisional) {
      await _markPrompted();
      return false;
    }
    return true;
  }

  static Future<PermissionStatus> request() async {
    // Önce işaretlemek, sistem penceresi açıkken uygulama kapanırsa aynı isteğin
    // sonraki açılışta yeniden gösterilmesini önler.
    await _markPrompted();
    return Permission.notification.request();
  }

  static Future<void> dismiss() => _markPrompted();

  static Future<void> _markPrompted() {
    return _storage.write(key: _promptedKey, value: 'true');
  }
}
