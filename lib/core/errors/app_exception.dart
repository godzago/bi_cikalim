/// Uygulama genelinde kullanılan özel exception sınıfları.

/// Auth işlemlerinde fırlatılan exception.
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException({required this.message, this.code});

  @override
  String toString() => 'AuthException($code): $message';
}

/// Firestore işlemlerinde fırlatılan exception.
class FirestoreException implements Exception {
  final String message;
  final String? code;

  const FirestoreException({required this.message, this.code});

  @override
  String toString() => 'FirestoreException($code): $message';
}

/// Firebase Auth hata kodlarını Türkçe mesajlara dönüştürür.
String mapFirebaseAuthError(String code) {
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
