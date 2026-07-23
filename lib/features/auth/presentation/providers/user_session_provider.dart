import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_auth_service.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_providers.dart';

/// Uygulama kullanıcı tipi.
/// Normal kullanıcı keşif akışına, mekan sahibi ise mekan paneline yönlenir.
enum UserType { normalUser, venueOwner }

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
final currentUserProvider = NotifierProvider<CurrentUserNotifier, AppUser?>(
  CurrentUserNotifier.new,
);

/// Kullanıcı tipi (Normal/Mekan Sahibi) state'ini yöneten Notifier.
class UserTypeNotifier extends Notifier<UserType?> {
  @override
  UserType? build() => null;

  void setUserType(UserType? type) {
    state = type;
  }
}

/// Aktif kullanıcı tipi provider'ı.
final userTypeProvider = NotifierProvider<UserTypeNotifier, UserType?>(
  UserTypeNotifier.new,
);

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
    final subscription = ApiClient.instance.sessionExpired.listen((_) {
      ref.read(currentUserProvider.notifier).setUser(null);
      ref.read(userTypeProvider.notifier).setUserType(null);
    });
    ref.onDispose(() => unawaited(subscription.cancel()));

    // Uygulama açılışında kayıtlı oturum kontrolü
    await checkSavedSession();
  }

  /// Kayıtlı token kontrolü yapıp oturumu yükler.
  Future<void> checkSavedSession() async {
    try {
      final token = await ApiClient.instance.getToken();
      if (token != null && token.isNotEmpty) {
        var user = await _authService.fetchCurrentUser();
        final selectedCity = await ref.read(selectedCityProvider.future);
        if (selectedCity != null && user.selectedCityId != selectedCity.id) {
          user = await ref
              .read(userApiServiceProvider)
              .updateSelectedCity(selectedCity.id);
        }
        ref.read(currentUserProvider.notifier).setUser(user);

        final type = user.roles.contains('venue_owner')
            ? UserType.venueOwner
            : UserType.normalUser;
        ref.read(userTypeProvider.notifier).setUserType(type);
      }
    } catch (e) {
      debugPrint('Kayıtlı oturum yüklenirken hata oluştu: $e');
      await ApiClient.instance.clearSession();
      ref.read(currentUserProvider.notifier).setUser(null);
      ref.read(userTypeProvider.notifier).setUserType(null);
    }
  }

  /// Kullanıcı girişi yap.
  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await _authService.login(email: email, password: password);

      // Giriş başarılı olduysa kullanıcı profil bilgilerini backend'den çek
      var user = await _authService.fetchCurrentUser();
      final selectedCity = await ref.read(selectedCityProvider.future);
      if (selectedCity != null && user.selectedCityId != selectedCity.id) {
        user = await ref
            .read(userApiServiceProvider)
            .updateSelectedCity(selectedCity.id);
      }

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

  /// Public API akışına oturumsuz devam et.
  Future<void> continueAsGuest() async {
    state = const AsyncLoading();
    await ApiClient.instance.clearSession();
    ref.read(currentUserProvider.notifier).setUser(null);
    ref.read(userTypeProvider.notifier).setUserType(null);
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
final userSessionProvider = AsyncNotifierProvider<UserSessionNotifier, void>(
  UserSessionNotifier.new,
);
