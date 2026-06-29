import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_user_service.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../core/constants/app_constants.dart';

/// [AuthRepository] arayüzünün Firebase tabanlı implementasyonu.
/// Firebase Auth ve Firestore servislerini koordine eder.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreUserService _userService;

  AuthRepositoryImpl({
    required FirebaseAuthService authService,
    required FirestoreUserService userService,
  })  : _authService = authService,
        _userService = userService;

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  @override
  User? getCurrentUser() => _authService.getCurrentUser();

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential?> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return _authService.signOut();
  }

  @override
  Future<void> resetPassword(String email) {
    return _authService.resetPassword(email);
  }

  @override
  Future<void> createUserProfile(AppUser user) {
    return _userService.createUserProfile(user);
  }

  @override
  Future<AppUser?> getUserProfile(String uid) {
    return _userService.getUserProfile(uid);
  }

  @override
  Future<void> updateUserCity(String uid, String city) {
    return _userService.updateUserCity(uid, city);
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    return _userService.updateUserProfile(uid, data);
  }

  /// Giriş sonrası Firestore'da kullanıcı profilini kontrol eder.
  /// Profil yoksa otomatik oluşturur, varsa mevcut profili döndürür.
  Future<AppUser> ensureUserProfile({
    required User firebaseUser,
    String? displayName,
  }) async {
    AppUser? existingProfile = await _userService.getUserProfile(firebaseUser.uid);

    if (existingProfile == null) {
      final newUser = AppUser(
        id: firebaseUser.uid,
        displayName: displayName ?? firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        roles: [AppConstants.roleUser],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _userService.createUserProfile(newUser);
      return newUser;
    }

    return existingProfile;
  }
}

/// Firestore Timestamp'i DateTime'e çevirme yardımcısı.
extension TimestampExt on Map<String, dynamic> {
  DateTime? getDateTime(String key) {
    final value = this[key];
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
