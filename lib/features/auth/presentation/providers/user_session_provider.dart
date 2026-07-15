import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_auth_service.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../core/network/api_client.dart';

/// Uygulama kullanıcı tipi.
/// Normal kullanıcı keşif akışına, mekan sahibi ise mekan paneline yönlenir.
enum UserType {
  normalUser,
  venueOwner,
}

// ---------------------------------------------------------------------------
// Service Provider
// ---------------------------------------------------------------------------

/// ApiAuthService provider'ı.
final apiAuthServiceProvider = Provider<ApiAuthService>((ref) {
  return ApiAuthService();
});

// ---------------------------------------------------------------------------
// State Providers
// ---------------------------------------------------------------------------

/// Aktif kullanıcı nesnesini tutan notifier.
class CurrentUserNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  void setUser(AppUser? user) {
    state = user;
  }
}

/// Aktif kullanıcı provider'ı.
final currentUserProvider =
    NotifierProvider<CurrentUserNotifier, AppUser?>(CurrentUserNotifier.new);

/// Kullanıcı tipi (Normal/Mekan Sahibi) state'ini yöneten Notifier.
class UserTypeNotifier extends Notifier<UserType?> {
  @override
  UserType? build() => null;

  void setUserType(UserType? type) {
    state = type;
  }
}

/// Aktif kullanıcı tipi provider'ı.
final userTypeProvider =
    NotifierProvider<UserTypeNotifier, UserType?>(UserTypeNotifier.new);

/// Giriş yapılmış mı?
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Normal kullanıcı mı?
final isNormalUserProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return !user.roles.contains('venue_owner');
});

/// Mekan sahibi mi?
final isVenueOwnerProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return user.roles.contains('venue_owner');
});

// ---------------------------------------------------------------------------
// Auth Controller — Session işlemleri
// ---------------------------------------------------------------------------

/// Oturum işlemlerini yöneten notifier.
class UserSessionNotifier extends AsyncNotifier<void> {
  ApiAuthService get _authService => ref.read(apiAuthServiceProvider);

  @override
  Future<void> build() async {
    // Uygulama açılışında kayıtlı oturum kontrolü
    await checkSavedSession();
  }

  /// Kayıtlı token kontrolü yapıp oturumu yükler.
  Future<void> checkSavedSession() async {
    try {
      final token = await ApiClient.instance.getToken();
      if (token != null && token.isNotEmpty) {
        if (token == 'mock_user_token') {
          _loadMockUserSession();
          return;
        } else if (token == 'mock_owner_token') {
          _loadMockOwnerSession();
          return;
        }

        // Gerçek backend'den kullanıcı profil bilgilerini çek
        final user = await _authService.fetchCurrentUser();
        ref.read(currentUserProvider.notifier).setUser(user);
        
        final type = user.roles.contains('venue_owner')
            ? UserType.venueOwner
            : UserType.normalUser;
        ref.read(userTypeProvider.notifier).setUserType(type);
      }
    } catch (e) {
      debugPrint('Kayıtlı oturum yüklenirken hata oluştu: $e');
      await ApiClient.instance.clearToken();
    }
  }

  void _loadMockUserSession() {
    final mockUser = AppUser(
      id: 'mock_user',
      displayName: 'Misafir Kullanıcı',
      email: 'misafir@bicikalim.com',
      roles: const ['user'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    ref.read(currentUserProvider.notifier).setUser(mockUser);
    ref.read(userTypeProvider.notifier).setUserType(UserType.normalUser);
  }

  void _loadMockOwnerSession() {
    final mockOwner = AppUser(
      id: 'mock_owner',
      displayName: 'Mekan Sahibi',
      email: 'owner@bicikalim.com',
      roles: const ['venue_owner'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    ref.read(currentUserProvider.notifier).setUser(mockOwner);
    ref.read(userTypeProvider.notifier).setUserType(UserType.venueOwner);
  }

  /// Kullanıcı girişi yap.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _authService.login(email: email, password: password);
      
      // Giriş başarılı olduysa kullanıcı profil bilgilerini backend'den çek
      final user = await _authService.fetchCurrentUser();
      
      ref.read(currentUserProvider.notifier).setUser(user);
      
      final type = user.roles.contains('venue_owner')
          ? UserType.venueOwner
          : UserType.normalUser;
      ref.read(userTypeProvider.notifier).setUserType(type);
      
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Yeni kullanıcı kaydı oluştur.
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    state = const AsyncLoading();
    try {
      // Backend'e kayıt isteği at
      await _authService.register(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
      );

      // Kayıt başarılıysa otomatik giriş yap
      await signIn(email: email, password: password);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Normal kullanıcı olarak (Misafir/Mock) devam et.
  Future<void> signInAsMockUser() async {
    state = const AsyncLoading();
    // API olmadan hızlı geçiş için geçici token
    await ApiClient.instance.saveToken('mock_user_token');
    _loadMockUserSession();
    state = const AsyncData(null);
  }

  /// Mekan sahibi olarak (Mock) devam et.
  Future<void> signInAsMockVenueOwner() async {
    state = const AsyncLoading();
    await ApiClient.instance.saveToken('mock_owner_token');
    _loadMockOwnerSession();
    state = const AsyncData(null);
  }

  /// Oturumu kapat.
  Future<void> signOut() async {
    state = const AsyncLoading();
    await _authService.logout();
    ref.read(currentUserProvider.notifier).setUser(null);
    ref.read(userTypeProvider.notifier).setUserType(null);
    state = const AsyncData(null);
  }
}

/// UserSessionNotifier provider'ı.
final userSessionProvider =
    AsyncNotifierProvider<UserSessionNotifier, void>(UserSessionNotifier.new);
