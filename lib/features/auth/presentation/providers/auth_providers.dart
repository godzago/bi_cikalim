import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../data/services/firestore_user_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../core/constants/app_constants.dart';

// ---------------------------------------------------------------------------
// Service Providers
// ---------------------------------------------------------------------------

/// Firebase Auth servisi provider'ı.
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Firestore kullanıcı servisi provider'ı.
final firestoreUserServiceProvider = Provider<FirestoreUserService>((ref) {
  return FirestoreUserService();
});

// ---------------------------------------------------------------------------
// Repository Provider
// ---------------------------------------------------------------------------

/// AuthRepository provider'ı.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authService: ref.watch(firebaseAuthServiceProvider),
    userService: ref.watch(firestoreUserServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// Auth State Providers
// ---------------------------------------------------------------------------

/// Firebase Auth oturum durumu stream'i.
/// null: oturum kapalı, User: oturum açık.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Şu an giriş yapmış kullanıcının Firestore profilini getirir.
/// AuthState'e göre otomatik yenilenir.
final currentUserProfileProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      final repo = ref.read(authRepositoryProvider) as AuthRepositoryImpl;
      return repo.getUserProfile(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// ---------------------------------------------------------------------------
// Auth Controller — Sign In / Sign Up / Sign Out Actions
// ---------------------------------------------------------------------------

/// Auth işlemlerini yöneten AsyncNotifier.
/// UI katmanı bu provider üzerinden auth aksiyonlarını tetikler.
class AuthController extends AsyncNotifier<void> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<void> build() async {}

  /// Email ve şifre ile giriş yap.
  /// Başarılı olursa [AppUser] döndürür, hata olursa exception fırlatır.
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final credential = await _repo.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    state = const AsyncData(null);

    // Firestore profilini oku veya oluştur
    final repo = _repo as AuthRepositoryImpl;
    final appUser = await repo.ensureUserProfile(
      firebaseUser: credential.user!,
    );
    return appUser;
  }

  /// Email ve şifre ile kayıt ol.
  /// Kayıt sonrası Firestore'da kullanıcı profili oluşturur.
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    final credential = await _repo.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Firebase Auth display name güncelle
    await credential.user?.updateDisplayName(displayName);

    // Firestore'da kullanıcı profili oluştur
    final newUser = AppUser(
      id: credential.user!.uid,
      displayName: displayName,
      email: email,
      roles: [AppConstants.roleUser],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repo.createUserProfile(newUser);
    state = const AsyncData(null);
    return newUser;
  }

  /// Google ile giriş yap (SHA-1 gerektirir).
  Future<AppUser?> signInWithGoogle() async {
    state = const AsyncLoading();
    final credential = await _repo.signInWithGoogle();
    if (credential == null) {
      state = const AsyncData(null);
      return null;
    }

    final repo = _repo as AuthRepositoryImpl;
    final appUser = await repo.ensureUserProfile(
      firebaseUser: credential.user!,
    );
    state = const AsyncData(null);
    return appUser;
  }

  /// Oturumu kapat.
  Future<void> signOut() async {
    state = const AsyncLoading();
    await _repo.signOut();
    state = const AsyncData(null);
  }

  /// Şifre sıfırlama e-postası gönder.
  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();
    await _repo.resetPassword(email);
    state = const AsyncData(null);
  }

  /// Kullanıcının şehrini güncelle.
  Future<void> updateCity(String uid, String city) async {
    await _repo.updateUserCity(uid, city);
    // Profil cache'ini yenile
    ref.invalidate(currentUserProfileProvider);
  }
}

/// AuthController provider'ı.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
