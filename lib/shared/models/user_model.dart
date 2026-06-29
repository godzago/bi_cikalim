import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore `users` collection document modeli.
class AppUser {
  final String id;
  final String displayName;
  final String email;
  final String? phone;
  final String? city;
  final String? avatarUrl;
  final List<String> roles;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    this.phone,
    this.city,
    this.avatarUrl,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore'dan gelen Map'i AppUser'a dönüştürür.
  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      city: map['city'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      roles: List<String>.from(map['roles'] as List? ?? ['user']),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// AppUser'ı Firestore'a yazılabilir Map'e dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'city': city,
      'avatarUrl': avatarUrl,
      'roles': roles,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Kopyalama (immutable güncelleme için).
  AppUser copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? city,
    String? avatarUrl,
    List<String>? roles,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roles: roles ?? this.roles,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
