import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/mock_auth_service.dart';

export '../../data/services/mock_auth_service.dart' show UserType;

// ---------------------------------------------------------------------------
// Service Provider
// ---------------------------------------------------------------------------

/// MockAuthService singleton provider'ı.
final mockAuthServiceProvider = Provider<MockAuthService>((ref) {
  return MockAuthService();
});

// ---------------------------------------------------------------------------
// Session State — Notifier (Riverpod 3.x compatible)
// ---------------------------------------------------------------------------

/// Kullanıcı tipi state'ini yöneten Notifier.
/// Riverpod 3.x'te StateProvider legacy API'ye taşındı,
/// bu nedenle Notifier pattern kullanılıyor.
class UserTypeNotifier extends Notifier<UserType?> {
  @override
  UserType? build() => null;

  void setUserType(UserType? type) {
    state = type;
  }
}

/// Aktif kullanıcı tipi provider'ı.
/// null = oturum yok, UserType.normalUser / UserType.venueOwner = oturum var.
final userTypeProvider =
    NotifierProvider<UserTypeNotifier, UserType?>(UserTypeNotifier.new);

/// Giriş yapılmış mı?
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(userTypeProvider) != null;
});

/// Normal kullanıcı mı?
final isNormalUserProvider = Provider<bool>((ref) {
  return ref.watch(userTypeProvider) == UserType.normalUser;
});

/// Mekan sahibi mi?
final isVenueOwnerProvider = Provider<bool>((ref) {
  return ref.watch(userTypeProvider) == UserType.venueOwner;
});

// ---------------------------------------------------------------------------
// Auth Controller — Session işlemleri
// ---------------------------------------------------------------------------

/// Oturum işlemlerini yöneten notifier.
class UserSessionNotifier extends AsyncNotifier<void> {
  MockAuthService get _service => ref.read(mockAuthServiceProvider);

  @override
  Future<void> build() async {}

  /// Normal kullanıcı olarak giriş yap.
  Future<void> signInAsUser() async {
    state = const AsyncLoading();
    await _service.signInAsUser();
    ref.read(userTypeProvider.notifier).setUserType(UserType.normalUser);
    state = const AsyncData(null);
  }

  /// Mekan sahibi olarak giriş yap.
  Future<void> signInAsVenueOwner() async {
    state = const AsyncLoading();
    await _service.signInAsVenueOwner();
    ref.read(userTypeProvider.notifier).setUserType(UserType.venueOwner);
    state = const AsyncData(null);
  }

  /// Oturumu kapat.
  Future<void> signOut() async {
    state = const AsyncLoading();
    await _service.signOut();
    ref.read(userTypeProvider.notifier).setUserType(null);
    state = const AsyncData(null);
  }
}

/// UserSessionNotifier provider'ı.
final userSessionProvider =
    AsyncNotifierProvider<UserSessionNotifier, void>(UserSessionNotifier.new);
