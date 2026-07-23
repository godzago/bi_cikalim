/// Uygulama kullanıcı modeli.
/// Firestore bağımlılığı kaldırıldı — artık pure Dart.
/// İleride FastAPI backend'inden gelecek response'a göre güncellenecek.
class AppUser {
  final String id;
  final String username;
  final String displayName;
  final String email;
  final String? phone;
  final String? selectedCityId;
  final String? avatarUrl;
  final List<String> roles;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.id,
    this.username = '',
    required this.displayName,
    required this.email,
    this.phone,
    this.selectedCityId,
    this.avatarUrl,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Map'i AppUser'a dönüştürür (API response için).
  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      username: (map['username'] ?? map['displayName']) as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      selectedCityId: (map['selected_city_id'] ?? map['city'])?.toString(),
      avatarUrl: map['avatarUrl'] as String?,
      roles: List<String>.from(map['roles'] as List? ?? ['user']),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// AppUser'ı API'ye gönderilebilir Map'e dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'username': username,
      'email': email,
      'phone': phone,
      'selected_city_id': selectedCityId,
      'avatarUrl': avatarUrl,
      'roles': roles,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Kopyalama (immutable güncelleme için).
  AppUser copyWith({
    String? username,
    String? displayName,
    String? email,
    String? phone,
    String? selectedCityId,
    String? avatarUrl,
    List<String>? roles,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      selectedCityId: selectedCityId ?? this.selectedCityId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roles: roles ?? this.roles,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
