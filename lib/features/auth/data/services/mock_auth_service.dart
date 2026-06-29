/// Uygulama kullanıcı tipi.
/// Normal kullanıcı keşif akışına, mekan sahibi ise mekan paneline yönlenir.
enum UserType {
  normalUser,
  venueOwner,
}

/// Mock oturum yönetim servisi.
/// Gerçek backend hazır olduğunda bu sınıf FastAPI auth servisine bağlanacak.
class MockAuthService {
  UserType? _currentUserType;

  /// Şu an oturum açmış kullanıcı tipi.
  UserType? get currentUserType => _currentUserType;

  /// Giriş yapılmış mı?
  bool get isLoggedIn => _currentUserType != null;

  /// Normal kullanıcı olarak devam et.
  Future<void> signInAsUser() async {
    // Backend hazır olunca buraya API çağrısı gelecek.
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUserType = UserType.normalUser;
  }

  /// Mekan sahibi olarak devam et.
  Future<void> signInAsVenueOwner() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUserType = UserType.venueOwner;
  }

  /// Oturumu kapat.
  Future<void> signOut() async {
    _currentUserType = null;
  }
}
