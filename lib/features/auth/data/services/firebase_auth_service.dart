import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/app_exception.dart';

/// Firebase Authentication işlemlerini yöneten servis sınıfı.
class FirebaseAuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Firebase Auth oturum stream'i.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Şu an oturum açmış kullanıcı.
  User? getCurrentUser() => _auth.currentUser;

  /// Email/şifre ile giriş yap.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: mapFirebaseAuthError(e.code),
        code: e.code,
      );
    } catch (e) {
      throw const AuthException(
        message: 'Giriş sırasında beklenmedik bir hata oluştu.',
      );
    }
  }

  /// Email/şifre ile kayıt ol.
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: mapFirebaseAuthError(e.code),
        code: e.code,
      );
    } catch (e) {
      throw const AuthException(
        message: 'Kayıt sırasında beklenmedik bir hata oluştu.',
      );
    }
  }

  /// Google hesabı ile giriş yap.
  /// Not: SHA-1 fingerprint Firebase Console'a eklenmeden çalışmaz.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Kullanıcı iptal etti

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: mapFirebaseAuthError(e.code),
        code: e.code,
      );
    } catch (e) {
      throw const AuthException(
        message: 'Google ile giriş sırasında bir hata oluştu.',
      );
    }
  }

  /// Oturumu kapat.
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw const AuthException(message: 'Çıkış yapılırken bir hata oluştu.');
    }
  }

  /// Şifre sıfırlama e-postası gönder.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: mapFirebaseAuthError(e.code),
        code: e.code,
      );
    } catch (e) {
      throw const AuthException(
        message: 'Şifre sıfırlama e-postası gönderilirken bir hata oluştu.',
      );
    }
  }
}
