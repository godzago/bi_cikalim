/// Uygulama genelinde kullanılan özel exception sınıfları.
library;

/// Auth işlemlerinde fırlatılan exception.
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({required this.message, this.code});

  @override
  String toString() => 'AuthException($code): $message';
}

/// Servis/API işlemlerinde fırlatılan exception.
class ServiceException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final String? requestId;
  final dynamic details;

  const ServiceException({
    required this.message,
    this.code,
    this.statusCode,
    this.requestId,
    this.details,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidationError => statusCode == 422;
  bool get isRateLimited => statusCode == 429;

  @override
  String toString() => message;
}

/// Hata mesajı çevirisi (ileride backend hata kodları için).
String mapAuthError(String code) {
  switch (code) {
    case 'user-not-found':
      return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.';
    case 'wrong-password':
      return 'Şifre hatalı. Lütfen tekrar deneyin.';
    case 'invalid-credential':
      return 'E-posta veya şifre hatalı. Lütfen kontrol edin.';
    case 'email-already-in-use':
      return 'Bu e-posta adresi zaten kullanımda.';
    case 'weak-password':
      return 'Şifre çok zayıf. En az 6 karakter kullanın.';
    case 'invalid-email':
      return 'Geçersiz e-posta adresi.';
    case 'too-many-requests':
      return 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
    case 'network-request-failed':
      return 'İnternet bağlantınızı kontrol edin.';
    case 'user-disabled':
      return 'Bu hesap devre dışı bırakılmıştır.';
    default:
      return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }
}
