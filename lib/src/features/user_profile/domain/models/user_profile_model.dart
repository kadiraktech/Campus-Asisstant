import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid; // Firebase Auth User ID
  final String email; // User's email
  String displayName; // User's display name
  String? department; // Optional: User's department
  String? studentId; // Optional: User's student ID
  String? bio; // Optional: User's short biography
  String? defaultCity; // Optional: User's default city for weather
  String? phone; // Optional: User's phone number
  DateTime? birthDate; // Optional: User's birth date
  String? profilePictureUrl; // Optional: URL of the profile picture
  bool
  notificationsCourseRemindersEnabled; // User preference for course reminders
  bool notificationsTaskRemindersEnabled; // User preference for task reminders
  int
  notificationsCourseLeadTimeMinutes; // User preference for course reminder lead time (in minutes)
  // Add any other profile fields you need

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.department,
    this.studentId,
    this.bio,
    this.defaultCity,
    this.phone,
    this.birthDate,
    this.profilePictureUrl,
    this.notificationsCourseRemindersEnabled = true, // Default to true
    this.notificationsTaskRemindersEnabled = true, // Default to true
    this.notificationsCourseLeadTimeMinutes = 10, // Default to 10 minutes
  });

  // Factory constructor to create a UserProfile from a Firestore document
  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return UserProfile(
      uid: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      department: data['department'] as String?,
      studentId: data['studentId'] as String?,
      bio: data['bio'] as String?,
      defaultCity: data['defaultCity'] as String?,
      phone: data['phone'] as String?,
      birthDate:
          data['birthDate'] != null
              ? (data['birthDate'] as Timestamp).toDate()
              : null,
      profilePictureUrl: data['profilePictureUrl'] as String?,
      notificationsCourseRemindersEnabled:
          data['notificationsCourseRemindersEnabled'] ?? true,
      notificationsTaskRemindersEnabled:
          data['notificationsTaskRemindersEnabled'] ?? true,
      notificationsCourseLeadTimeMinutes:
          data['notificationsCourseLeadTimeMinutes'] ?? 10,
    );
  }

  // Method to convert a UserProfile instance to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      // uid is not stored in the document data itself, it's the document ID
      'email': email,
      'displayName': displayName,
      if (department != null) 'department': department,
      if (studentId != null) 'studentId': studentId,
      if (bio != null) 'bio': bio,
      if (defaultCity != null) 'defaultCity': defaultCity,
      if (phone != null) 'phone': phone,
      if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate!),
      if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      'notificationsCourseRemindersEnabled':
          notificationsCourseRemindersEnabled,
      'notificationsTaskRemindersEnabled': notificationsTaskRemindersEnabled,
      'notificationsCourseLeadTimeMinutes': notificationsCourseLeadTimeMinutes,
    };
  }

  // Method to create a new UserProfile instance with updated fields
  UserProfile copyWith({
    String? displayName,
    String? department,
    String? studentId,
    String? bio,
    String? defaultCity,
    String? phone,
    DateTime? birthDate,
    String? profilePictureUrl,
    bool? notificationsCourseRemindersEnabled,
    bool? notificationsTaskRemindersEnabled,
    int? notificationsCourseLeadTimeMinutes,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      department: department ?? this.department,
      studentId: studentId ?? this.studentId,
      bio: bio ?? this.bio,
      defaultCity: defaultCity ?? this.defaultCity,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      notificationsCourseRemindersEnabled:
          notificationsCourseRemindersEnabled ??
          this.notificationsCourseRemindersEnabled,
      notificationsTaskRemindersEnabled:
          notificationsTaskRemindersEnabled ??
          this.notificationsTaskRemindersEnabled,
      notificationsCourseLeadTimeMinutes:
          notificationsCourseLeadTimeMinutes ??
          this.notificationsCourseLeadTimeMinutes,
    );
  }
}
