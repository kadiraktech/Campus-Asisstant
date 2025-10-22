import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart'
    as tz_data; // Import for timezone data
import 'package:projectv1/src/features/course_schedule/domain/models/course_model.dart';
import 'package:projectv1/src/features/task_management/domain/models/task_model.dart';
import 'package:flutter/material.dart'; // For debugPrint
import 'package:intl/intl.dart'; // Added for DateFormat

// Added imports for FCM
import 'package:firebase_core/firebase_core.dart'; // Ensure Firebase Core is imported for background handler
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectv1/firebase_options.dart'; // Required for background handler initializeApp

// --- Background Message Handler (Top-level function) ---
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // It's crucial to initialize Firebase app only once per app instance, even for background isolates.
  // Checking if apps are already initialized can prevent errors.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    // Use the default app if already initialized
    Firebase.app();
  }
  debugPrint("Handling a background message: ${message.messageId}");
  debugPrint("Background message data: ${message.data}");

  if (message.notification != null) {
    debugPrint(
      "Background message also contained a notification: ${message.notification?.title} - ${message.notification?.body}",
    );
    // If you want to display a local notification for background messages:
    // final notificationService = NotificationService();
    // await notificationService.init(); // Ensure plugin is initialized if calling methods that use it
    // await notificationService.showSimpleLocalNotification(
    //   id: message.hashCode, // A simple way to generate an ID
    //   title: message.notification?.title ?? 'Notification',
    //   body: message.notification?.body ?? 'You have a new message',
    //   payload: message.data.toString(), // Or a specific payload string from data
    // );
  }
}

class NotificationService {
  // Make _notificationsPlugin late and nullable or initialize in init
  late final FlutterLocalNotificationsPlugin _notificationsPlugin;

  // Added Firebase instances
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Update constructor or remove if plugin is initialized in init
  NotificationService() {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  static Future<void> initializeTimezones() async {
    tz_data.initializeTimeZones();
    // Optional: Set a default local location if needed, e.g., tz.setLocalLocation(tz.getLocation('America/New_York'));
    // It's often better to rely on the device's current timezone.
  }

  Future<void> init() async {
    await initializeTimezones(); // Call the static timezone initializer

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ); // Replace with your app icon

    const DarwinInitializationSettings
    initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: onDidReceiveLocalNotification, // Optional: for older iOS versions
    );

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          linux: initializationSettingsLinux,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      // onDidReceiveNotificationResponse: onDidReceiveNotificationResponse, // Handle notification tap
    );

    // Request permissions for Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImplementation?.requestNotificationsPermission();
    // For iOS, permissions are requested via DarwinInitializationSettings,
    // but you can explicitly request again if needed or check status.
    // final IOSFlutterLocalNotificationsPlugin? iosImplementation =
    //     _notificationsPlugin.resolvePlatformSpecificImplementation<
    //         IOSFlutterLocalNotificationsPlugin>();
    // await iosImplementation?.requestPermissions(alert: true, badge: true, sound: true);

    debugPrint("NotificationService initialized and permissions requested.");
  }

  // Optional: Callback for when a notification is tapped
  // void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
  //   final String? payload = notificationResponse.payload;
  //   if (notificationResponse.payload != null) {
  //     debugPrint('notification payload: $payload');
  //   }
  //   // Example: Navigate to a specific screen based on payload
  //   // if (payload == 'some_payload') {
  //   //   // Navigator.push(context, MaterialPageRoute(builder: (context) => SecondScreen()));
  //   // }
  // }

  // Optional: For older iOS versions
  // static void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
  //   // display a dialog with the notification details, navigating ...
  // }

  Future<void> _showNotification(
    int id,
    String title,
    String body,
    tz.TZDateTime scheduledDateTime,
    String? payload,
  ) async {
    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'campus_assistant_channel_id', // Channel ID
      'Campus Assistant Notifications', // Channel Name
      channelDescription: 'Notifications for courses, tasks, and reminders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      // sound: RawResourceAndroidNotificationSound('notification_sound'), // if you have a custom sound
      // actions: <AndroidNotificationAction>[
      //   AndroidNotificationAction('snooze_action', 'Snooze'),
      // ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      // sound: 'custom_sound.caf', // if you have a custom sound
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDateTime,
        platformDetails,
        payload: payload,
        androidScheduleMode:
            AndroidScheduleMode.exactAllowWhileIdle, // For more precise timing
      );
      debugPrint(
        "Notification scheduled: ID $id, Time $scheduledDateTime, Title $title",
      );
    } catch (e) {
      debugPrint("Error scheduling notification ID $id: $e");
    }
  }

  // --- FCM Specific Methods ---

  Future<void> requestFcmPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );
      debugPrint(
        'User granted FCM permission: ${settings.authorizationStatus}',
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }
    } catch (e) {
      debugPrint("Error requesting FCM permission: $e");
    }
  }

  Future<String?> getFcmToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint("FCM Token: $token");
      return token;
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
      return null;
    }
  }

  Future<void> saveFcmTokenToFirestore(String? token) async {
    if (token == null) {
      debugPrint("FCM token is null, not saving to Firestore.");
      return;
    }
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        // Store token in a 'fcmTokens' field, which could be a list or a map if handling multiple devices.
        // For simplicity, let's assume a single token for now, overwriting if it changes.
        await _firestore.collection('users').doc(currentUser.uid).set(
          {
            'fcmTokens': FieldValue.arrayUnion([
              token,
            ]), // Using arrayUnion to add token if not present or create list
            'lastLogin':
                FieldValue.serverTimestamp(), // Optionally update last login or similar field
          },
          SetOptions(merge: true), // Merge with existing document data
        );
        debugPrint("FCM token saved to Firestore for user ${currentUser.uid}");
      } catch (e) {
        debugPrint("Error saving FCM token to Firestore: $e");
      }
    } else {
      debugPrint("No current user to save FCM token for.");
    }
  }

  // --- FCM Initialization and Listeners ---
  Future<void> initFcm() async {
    debugPrint("Initializing FCM...");
    await requestFcmPermission();
    String? token = await getFcmToken();
    await saveFcmTokenToFirestore(token);
    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen(saveFcmTokenToFirestore);
    await setupFcmListeners();
    debugPrint("FCM Initialized.");
  }

  Future<void> setupFcmListeners() async {
    // Handler for messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received:');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification?.title} - ${message.notification?.body}',
        );
        // Display a local notification for foreground messages
        showSimpleLocalNotification(
          id: message.hashCode, // Or a more robust ID generation
          title: message.notification?.title ?? 'Notification',
          body: message.notification?.body ?? 'You have a message.',
          payload: message.data.toString(), // Pass data as payload
        );
      }
    });

    // Handler for messages that open the app from a background state (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message clicked to open app from background:');
      debugPrint('Message data: ${message.data}');
      // You can navigate to a specific screen based on message.data
      // For example: if (message.data['screen'] == 'course_detail') { ... }
    });

    // Handler for messages that open the app from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        debugPrint('Message clicked to open app from terminated state:');
        debugPrint('Message data: ${message.data}');
        // You can navigate to a specific screen based on message.data
      }
    });

    // Set the background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint("FCM listeners set up.");
  }

  // Helper to show a simple local notification (can be expanded)
  Future<void> showSimpleLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'fcm_foreground_channel_id', // Different channel ID for FCM foreground messages
      'FCM Foreground Notifications',
      channelDescription:
          'Notifications received when the app is in the foreground.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
    debugPrint("Foreground local notification shown: ID $id, Title $title");
  }

  // --- Course Notifications ---
  Future<void> scheduleCourseReminder({
    required Course course,
    required bool remindersEnabled,
    required int leadTimeMinutes,
  }) async {
    if (course.id == null) {
      debugPrint(
        "Course ID is null, cannot schedule notification for ${course.name}",
      );
      return;
    }

    // Generate a consistent ID for the course notification based on course ID.
    // This allows us to cancel it reliably even if times change.
    // Note: Hashing can have collisions, though unlikely for typical numbers of courses.
    // A more robust system might involve storing notification IDs with the course in Firestore.
    final int notificationId = "course_${course.id}".hashCode;

    if (!remindersEnabled) {
      debugPrint(
        "Course reminders are disabled. Cancelling notification for ${course.name} (ID: $notificationId).",
      );
      await cancelNotification(notificationId);
      return;
    }

    tz.TZDateTime? nextOccurrence = _calculateNextCourseOccurrence(
      course.dayOfWeek,
      course.startTime,
    );
    if (nextOccurrence == null) {
      debugPrint(
        "Could not calculate next occurrence for course ${course.name}",
      );
      return;
    }

    final Duration remindBefore = Duration(minutes: leadTimeMinutes);
    final tz.TZDateTime notificationTime = nextOccurrence.subtract(
      remindBefore,
    );

    if (notificationTime.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint(
        "Course notification time for ${course.name} (${notificationTime.toIso8601String()}) is in the past. Cancelling any existing and skipping new.",
      );
      // Cancel any potentially existing notification if the new time is in the past
      await cancelNotification(notificationId);
      return;
    }

    // Cancel any existing notification with the same ID before scheduling a new one.
    // This handles updates to course time or lead time.
    await cancelNotification(notificationId);

    await _showNotification(
      notificationId,
      'Upcoming Course: ${course.name}',
      'Starts at ${course.startTime} in ${course.location.isNotEmpty ? course.location : 'N/A'} in $leadTimeMinutes minutes.',
      notificationTime,
      'course_${course.id}', // Payload
    );
  }

  tz.TZDateTime? _calculateNextCourseOccurrence(
    String dayOfWeek,
    String startTimeStr,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    int currentDayOfWeek = now.weekday;

    Map<String, int> dayMapping = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
      'Saturday': DateTime.saturday,
      'Sunday': DateTime.sunday,
    };

    int targetDay = dayMapping[dayOfWeek] ?? -1;
    if (targetDay == -1) {
      debugPrint("Invalid dayOfWeek: $dayOfWeek");
      return null;
    }

    int daysToAdd = targetDay - currentDayOfWeek;

    List<String> timeParts = startTimeStr.split(':');
    if (timeParts.length != 2) {
      debugPrint("Invalid startTime format: $startTimeStr");
      return null;
    }
    int hour = int.tryParse(timeParts[0]) ?? 0;
    int minute = int.tryParse(timeParts[1]) ?? 0;

    tz.TZDateTime potentialNextCourseDay = tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If daysToAdd is negative, it means the target day is earlier in the week than today, so add 7 to go to next week.
    // If daysToAdd is 0 (today), check if the time has already passed. If so, schedule for next week.
    if (daysToAdd < 0 ||
        (daysToAdd == 0 && potentialNextCourseDay.isBefore(now))) {
      daysToAdd += 7;
    }

    return tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day + daysToAdd,
      hour,
      minute,
    );
  }

  // Helper to calculate the next occurrence of a course DateTime
  tz.TZDateTime? _getNextCourseDateTime(Course course) {
    final now = tz.TZDateTime.now(tz.local);
    final dayOfWeekMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };

    final int targetWeekday = dayOfWeekMap[course.dayOfWeek] ?? -1;
    if (targetWeekday == -1) {
      debugPrint("Invalid day of week for course: ${course.dayOfWeek}");
      return null;
    }

    List<String> timeParts = course.startTime.split(':');
    if (timeParts.length != 2) {
      debugPrint("Invalid start time format for course: ${course.startTime}");
      return null;
    }
    final int hour = int.tryParse(timeParts[0]) ?? 0;
    final int minute = int.tryParse(timeParts[1]) ?? 0;

    // Start with today's date and the course's time
    tz.TZDateTime nextOccurrence = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If this time is in the past today, or if it's not the correct day of the week,
    // advance to the next suitable day.
    while (nextOccurrence.weekday != targetWeekday ||
        nextOccurrence.isBefore(now)) {
      nextOccurrence = nextOccurrence.add(const Duration(days: 1));
      // Ensure the time part is reset if we just rolled over a day for a past time
      if (nextOccurrence.weekday == targetWeekday &&
          nextOccurrence.isBefore(now)) {
        nextOccurrence = tz.TZDateTime(
          tz.local,
          nextOccurrence.year,
          nextOccurrence.month,
          nextOccurrence.day,
          hour,
          minute,
        );
      }
    }
    return nextOccurrence;
  }

  Future<void> scheduleCourseNotification(
    Course course,
    Duration beforeDuration, // e.g., Duration(minutes: 10)
    String notificationTitle,
    String notificationBody,
  ) async {
    if (course.id == null) {
      debugPrint(
        "Course ID is null. Cannot schedule notification for course: ${course.name}",
      );
      return;
    }

    tz.TZDateTime? courseDateTime = _getNextCourseDateTime(course);

    if (courseDateTime == null) {
      debugPrint(
        "Could not determine next occurrence for course ${course.name}. Notification not scheduled.",
      );
      return;
    }

    // This is the actual start time of the course event
    tz.TZDateTime actualCourseStartTime = courseDateTime;

    // Calculate the time the notification should be shown
    final tz.TZDateTime scheduledNotificationDateTime = actualCourseStartTime
        .subtract(beforeDuration);

    // If the calculated notification time is in the past, do not schedule it.
    // (Unless it's acceptable to notify immediately for overdue reminders, which is not the case here)
    if (scheduledNotificationDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint(
        "Calculated notification time for course ${course.name} is in the past (${DateFormat.yMd().add_Hms().format(scheduledNotificationDateTime)}). No notification scheduled.",
      );
      return;
    }

    final notificationId = _generateCourseNotificationId(course.id!);

    await _showNotification(
      notificationId,
      notificationTitle,
      notificationBody,
      scheduledNotificationDateTime,
      'course_${course.id}', // Payload
    );
  }

  int _generateCourseNotificationId(String courseId) {
    return (courseId.hashCode % 1000000000).abs() + 100000;
  }

  // Method to cancel a specific notification
  Future<void> cancelSpecificNotification(int notificationId) async {
    try {
      await _notificationsPlugin.cancel(notificationId);
      debugPrint("Cancelled notification with ID: $notificationId");
    } catch (e) {
      debugPrint("Error cancelling notification ID $notificationId: $e");
    }
  }

  // Updated to use a more specific name for clarity
  Future<void> cancelCourseNotification(String? courseId) async {
    if (courseId == null) {
      debugPrint("Course ID is null. Cannot cancel notification.");
      return;
    }
    final notificationId = _generateCourseNotificationId(courseId);
    await _notificationsPlugin.cancel(notificationId);
    debugPrint(
      "Cancelled notification for course ID $courseId (Notification ID: $notificationId)",
    );
  }

  // --- Task Notifications ---
  Future<void> scheduleTaskReminder({
    required Task task,
    required bool remindersEnabled,
  }) async {
    if (task.taskId.isEmpty) {
      debugPrint(
        "Task ID is null or empty, cannot schedule notification for ${task.taskName}",
      );
      return;
    }

    final int notificationId = "task_${task.taskId}".hashCode;

    if (!remindersEnabled) {
      debugPrint(
        "Task reminders are disabled. Cancelling notification for ${task.taskName} (ID: $notificationId).",
      );
      await cancelNotification(notificationId);
      return;
    }

    if (task.reminderTime == null) {
      debugPrint(
        "Task reminderTime is null for ${task.taskName}. Cannot schedule reminder.",
      );
      // Optionally, cancel any existing notification if reminderTime was removed
      // await cancelNotification(notificationId);
      return;
    }

    // task.reminderTime is already a DateTime?, use it directly as tz.TZDateTime
    final tz.TZDateTime notificationTime = tz.TZDateTime.from(
      task.reminderTime!, // Null checked by the condition above
      tz.local,
    );

    if (notificationTime.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint(
        "Task notification time for ${task.taskName} (${notificationTime.toIso8601String()}) is in the past. Cancelling any existing and skipping new.",
      );
      await cancelNotification(notificationId);
      return;
    }

    await cancelNotification(notificationId);

    await _showNotification(
      notificationId,
      'Task Reminder: ${task.taskName}',
      'Due on ${DateFormat.yMMMd().add_jm().format(task.dueDate)}. Category: ${task.category}.',
      notificationTime,
      'task_${task.taskId}', // Changed from task.id to task.taskId
    );
  }

  Future<void> cancelTaskReminder(Task task) async {
    if (task.taskId.isEmpty) return;
    final int notificationId = "task_${task.taskId}".hashCode;
    await cancelNotification(notificationId);
    debugPrint(
      "Cancelled task reminder for ${task.taskName} with ID $notificationId",
    );
  }

  // --- General ---
  Future<void> cancelNotification(int notificationId) async {
    await _notificationsPlugin.cancel(notificationId);
    debugPrint("Cancelled notification ID: $notificationId");
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint("Cancelled all notifications");
  }
}
