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

  const ServiceException({required this.message, this.code});

  @override
  String toString() => 'ServiceException($code): $message';
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
