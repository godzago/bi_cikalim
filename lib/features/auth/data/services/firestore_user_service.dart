import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/models/user_model.dart';

/// Firestore `users` collection CRUD işlemlerini yöneten servis sınıfı.
class FirestoreUserService {
  final FirebaseFirestore _firestore;

  FirestoreUserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  /// Firestore'da yeni kullanıcı profili oluşturur.
  /// Eğer doküman zaten varsa `SetOptions(merge: true)` ile birleştirir.
  Future<void> createUserProfile(AppUser user) async {
    try {
      await _usersRef.doc(user.id).set(
            user.toMap(),
            SetOptions(merge: true),
          );
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Kullanıcı profili oluşturulamadı.',
        code: e.code,
      );
    } catch (e) {
      throw const FirestoreException(
        message: 'Profil kaydedilirken beklenmedik bir hata oluştu.',
      );
    }
  }

  /// UID'ye göre kullanıcı profilini getirir.
  /// Doküman yoksa `null` döndürür.
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.id, doc.data()!);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Kullanıcı profili getirilemedi.',
        code: e.code,
      );
    } catch (e) {
      throw const FirestoreException(
        message: 'Profil okunurken beklenmedik bir hata oluştu.',
      );
    }
  }

  /// Kullanıcının şehrini günceller.
  Future<void> updateUserCity(String uid, String city) async {
    try {
      await _usersRef.doc(uid).update({
        'city': city,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Şehir güncellenemedi.',
        code: e.code,
      );
    } catch (e) {
      throw const FirestoreException(
        message: 'Şehir güncellenirken beklenmedik bir hata oluştu.',
      );
    }
  }

  /// Kullanıcı profilini kısmen günceller.
  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _usersRef.doc(uid).update({
        ...data,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Profil güncellenemedi.',
        code: e.code,
      );
    } catch (e) {
      throw const FirestoreException(
        message: 'Profil güncellenirken beklenmedik bir hata oluştu.',
      );
    }
  }
}
