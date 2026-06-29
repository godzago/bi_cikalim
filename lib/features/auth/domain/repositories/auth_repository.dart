import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/models/user_model.dart';

/// Auth işlemleri için soyut repository arayüzü.
/// Data katmanından bağımsız, domain katmanına ait.
abstract class AuthRepository {
  /// Firebase Auth stream'i — oturum açma/kapama durumunu takip eder.
  Stream<User?> get authStateChanges;

  /// Şu an oturum açmış Firebase kullanıcısını döndürür.
  User? getCurrentUser();

  /// Email ve şifre ile giriş yap.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Email ve şifre ile kayıt ol.
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Google hesabı ile giriş yap (altyapı hazır, SHA-1 gerektirir).
  Future<UserCredential?> signInWithGoogle();

  /// Oturumu kapat.
  Future<void> signOut();

  /// Şifre sıfırlama e-postası gönder.
  Future<void> resetPassword(String email);

  /// Firestore'da kullanıcı profili oluştur.
  Future<void> createUserProfile(AppUser user);

  /// Firestore'dan kullanıcı profilini getir.
  Future<AppUser?> getUserProfile(String uid);

  /// Kullanıcının şehrini güncelle.
  Future<void> updateUserCity(String uid, String city);

  /// Kullanıcı profilini güncelle.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data);
}
