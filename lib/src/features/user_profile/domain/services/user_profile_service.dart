import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectv1/src/features/user_profile/domain/models/user_profile_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Firestore'daki kullanıcılar koleksiyonuna referans
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  // Mevcut kullanıcının profilini Firestore'dan getirir
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot docSnapshot = await _usersCollection.doc(uid).get();
      if (docSnapshot.exists) {
        return UserProfile.fromFirestore(
          docSnapshot as DocumentSnapshot<Map<String, dynamic>>,
        );
      } else {
        // print('UserProfileService: No profile found for user $uid. Returning null.'); // Commented out
        return null; // Or throw an exception, or create a default one
      }
    } catch (e) {
      // print('UserProfileService: Error getting user profile for $uid: $e');
      // Consider how to handle this error. Maybe rethrow or return a default UserProfile.
      rethrow;
    }
  }

  // Kullanıcı profilini Firestore'da oluşturur veya günceller
  // Bu metot hem Firebase Auth displayName'i hem de Firestore dokümanını günceller.
  Future<void> updateUserProfile({
    required String uid,
    required String email,
    required String displayName,
    String? department,
    String? studentId,
    String? bio,
    String? defaultCity,
    String? phone,
    DateTime? birthDate,
    bool? notificationsCourseRemindersEnabled,
    bool? notificationsTaskRemindersEnabled,
    int? notificationsCourseLeadTimeMinutes,
  }) async {
    try {
      // 1. Update Firebase Auth displayName (eğer değiştiyse)
      User? currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        if (currentUser.displayName != displayName) {
          await currentUser.updateDisplayName(displayName);
        }
      } else {
        // Bu durumun oluşmaması gerekir, çünkü UID mevcut kullanıcıya ait olmalı
        // print(
        //   "Error: Current user mismatch or not found for updating Auth display name.",
        // );
      }

      // 2. Create or Update Firestore document
      final userProfile = UserProfile(
        uid: uid,
        email: email,
        displayName: displayName,
        department: department,
        studentId: studentId,
        bio: bio,
        defaultCity: defaultCity,
        phone: phone,
        birthDate: birthDate,
        notificationsCourseRemindersEnabled:
            notificationsCourseRemindersEnabled ?? true,
        notificationsTaskRemindersEnabled:
            notificationsTaskRemindersEnabled ?? true,
        notificationsCourseLeadTimeMinutes:
            notificationsCourseLeadTimeMinutes ?? 10,
      );
      // .set() metodu, doküman yoksa oluşturur, varsa üzerine yazar (merge:true ile birleştirilebilir)
      await _usersCollection
          .doc(uid)
          .set(userProfile.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      // print('Error updating user profile: $e');
      // Hata yönetimi, örneğin özel bir exception fırlatılabilir
      rethrow; // Calling code can handle this
    }
  }

  // Sadece Firestore dokümanını güncelleyen yardımcı bir metot (Auth displayName hariç)
  // Daha granüler güncellemeler için kullanılabilir.
  Future<void> updateFirestoreUserProfileData(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _usersCollection.doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      // print('Error updating specific user profile data in Firestore: $e');
      rethrow;
    }
  }

  // Method to delete user data from Firestore
  Future<void> deleteUserProfileData(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      // print('Error deleting user profile data from Firestore: $e');
      rethrow; // Propagate the error to be handled by the caller
    }
  }

  // Kullanıcı ilk kayıt olduğunda temel profil dokümanını oluşturmak için bir metot.
  // RegistrationScreen'den çağrılabilir.
  Future<void> createInitialUserProfile(
    User user, {
    String? displayName,
    String? defaultCity,
    String? phone,
    DateTime? birthDate,
  }) async {
    if (user.email == null) {
      // print("Cannot create initial profile without user email.");
      return;
    }
    final initialProfile = UserProfile(
      uid: user.uid,
      email: user.email!,
      displayName:
          displayName ??
          user.displayName ??
          user.email!.split(
            '@',
          )[0], // Use provided name, auth display name, or part of email
      defaultCity: defaultCity ?? 'izmir', // Set default city to 'izmir'
      phone: phone,
      birthDate: birthDate,
    );
    try {
      await _usersCollection
          .doc(user.uid)
          .set(initialProfile.toFirestore(), SetOptions(merge: true));
      // merge:true ensures we don't overwrite if a document somehow already exists (e.g. from Google Sign in then email register)
    } catch (e) {
      // print("Error creating initial user profile: $e");
      // Handle error appropriately
    }
  }
}
