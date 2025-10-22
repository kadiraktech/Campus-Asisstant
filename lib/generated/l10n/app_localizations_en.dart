// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get upcomingCoursesTitle => 'Upcoming Courses';

  @override
  String get pendingTasksTitle => 'Pending Tasks';

  @override
  String get todaysWeatherTitle => 'Today\'s Weather';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get myCoursesTitle => 'My Courses';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get myTasksTitle => 'My Tasks';

  @override
  String get weeklyScheduleTitle => 'Weekly Schedule';

  @override
  String get weatherSetCityPrompt => 'Set your default city in settings to see weather.';

  @override
  String weatherLoadError(String cityName, String error) {
    return 'Failed to load weather for $cityName: $error';
  }

  @override
  String get weatherDataNotAvailable => 'Weather data not available.';

  @override
  String get noUpcomingCourses => 'No upcoming courses in the next 2 days.';

  @override
  String get noPendingTasks => 'No pending tasks for today or later.';

  @override
  String get showLess => 'Show Less';

  @override
  String get showMore => 'Show More';

  @override
  String get profileMenuProfile => 'My Profile';

  @override
  String get profileMenuSettings => 'Settings';

  @override
  String get profileMenuLogout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Confirm Logout';

  @override
  String get logoutConfirmContent => 'Are you sure you want to logout?';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get logoutAction => 'Logout';

  @override
  String get languageSettingTitle => 'Language';

  @override
  String get themeSettingTitle => 'Theme';

  @override
  String get activeTasksTab => 'Active';

  @override
  String get completedTasksTab => 'Completed';

  @override
  String get editTaskTitle => 'Edit Task';

  @override
  String get addTaskTitle => 'Add New Task';

  @override
  String get taskNameLabel => 'Task Name';

  @override
  String get taskNameHint => 'Enter the name of your task';

  @override
  String get taskNameValidationEmpty => 'Please enter the task name.';

  @override
  String get taskNameValidationLength => 'Task name cannot exceed 100 characters.';

  @override
  String get taskDescriptionLabel => 'Description (Optional)';

  @override
  String get taskDescriptionHint => 'Add more details about the task';

  @override
  String get taskCategoryLabel => 'Category *';

  @override
  String get taskCategoryValidationEmpty => 'Please select a category.';

  @override
  String get selectDueDateLabel => 'Select Due Date *';

  @override
  String get dueDatePrefix => 'Due: ';

  @override
  String get reminderTimePrefix => 'Reminder Time: ';

  @override
  String get reminderTimeNotSet => 'Not Set';

  @override
  String get clearReminderTooltip => 'Clear Reminder';

  @override
  String get updateTaskButton => 'Update Task';

  @override
  String get addTaskButton => 'Add Task';

  @override
  String get selectDueDateError => 'Please select a due date.';

  @override
  String get reminderBeforeDueError => 'Reminder time must be before the due date.';

  @override
  String get mustBeLoggedInError => 'You must be logged in to save tasks.';

  @override
  String get profileNotLoadedError => 'User profile not loaded. Cannot save task reminders.';

  @override
  String get taskAddedSuccess => 'Task added successfully!';

  @override
  String get taskUpdatedSuccess => 'Task updated successfully!';

  @override
  String taskSaveFailed(String error) {
    return 'Failed to save task: $error';
  }

  @override
  String get confirmDeleteTitle => 'Confirm Delete';

  @override
  String get confirmDeleteContent => 'Are you sure you want to delete this task?';

  @override
  String get deleteAction => 'Delete';

  @override
  String get taskDeletedSuccess => 'Task deleted successfully!';

  @override
  String taskDeleteFailed(String error) {
    return 'Failed to delete task: $error';
  }

  @override
  String get timePickerOkText => 'OK';

  @override
  String get timePickerCancelText => 'Cancel';

  @override
  String get taskCategoryAssignment => 'Assignment';

  @override
  String get taskCategoryExam => 'Exam';

  @override
  String get taskCategoryReminder => 'Reminder';

  @override
  String get taskCategoryOther => 'Other';

  @override
  String get taskDeleteConfirmContent => 'Are you sure you want to delete this task?';

  @override
  String get loginTitle => 'Login';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get emailValidationEmpty => 'Please enter your email';

  @override
  String get emailValidationInvalid => 'Please enter a valid email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordValidationEmpty => 'Please enter your password';

  @override
  String get passwordValidationLength => 'Password must be at least 6 characters';

  @override
  String get loginButton => 'Login';

  @override
  String get loginWithGoogleButton => 'Login with Google';

  @override
  String get noAccountPrompt => 'Don\'t have an account? ';

  @override
  String get registerButton => 'Register';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get loginCancelled => 'Login cancelled by user.';

  @override
  String get googleSignInError => 'An unknown error occurred during Google sign-in.';

  @override
  String get registerTitle => 'Register';

  @override
  String get registrationSuccessful => 'Registration Successful! Please login.';

  @override
  String get registrationErrorDefault => 'An error occurred during registration.';

  @override
  String get registrationErrorWeakPassword => 'The password provided is too weak.';

  @override
  String get registrationErrorEmailInUse => 'The account already exists for that email.';

  @override
  String registrationErrorFirebase(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get registrationErrorUnexpected => 'An unexpected error occurred. Please try again.';

  @override
  String get createAccountPrompt => 'Create a new account to start organizing your campus life!';

  @override
  String get registerEmailValidationEmpty => 'Please enter your email';

  @override
  String get registerEmailValidationInvalid => 'Please enter a valid email address';

  @override
  String get registerPasswordValidationEmpty => 'Please enter your password';

  @override
  String get registerPasswordValidationLength => 'Password must be at least 6 characters long';

  @override
  String get registerButtonRegister => 'Register';

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account? ';

  @override
  String get loginButtonFromRegister => 'Login';

  @override
  String get loginWelcomeBack => 'Welcome Back!';

  @override
  String get loginManageSchedule => 'Login to manage your campus schedule.';

  @override
  String get loginRememberMe => 'Remember Me';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginOrSeparator => 'OR';

  @override
  String get loginLoggingIn => 'Logging In...';

  @override
  String get loginSigningInGoogle => 'Signing In...';

  @override
  String get loginErrorUserNotFound => 'No user found for that email.';

  @override
  String get loginErrorWrongPassword => 'Wrong password provided for that user.';

  @override
  String get loginErrorInvalidCredentials => 'Invalid credentials. Please check your email and password.';

  @override
  String get loginErrorGeneric => 'An error occurred during login.';

  @override
  String get loginErrorUnexpected => 'An unexpected error occurred. Please try again.';

  @override
  String get googleSignInErrorGeneric => 'An error occurred with Google Sign-In.';

  @override
  String get googleSignInErrorUnexpected => 'An unexpected Google Sign-In error occurred.';

  @override
  String get googleSignInProfileError => 'Could not save profile details, but login successful.';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordSuccessMessage => 'Password reset email sent. Please check your inbox.';

  @override
  String get forgotPasswordErrorFailedToSend => 'Failed to send password reset email.';

  @override
  String get forgotPasswordErrorUserNotFound => 'No user found for that email.';

  @override
  String forgotPasswordErrorFirebase(String error) {
    return 'Failed to send password reset email: $error';
  }

  @override
  String get forgotPasswordErrorUnexpected => 'An unexpected error occurred. Please try again.';

  @override
  String get forgotPasswordInstruction => 'Enter your email address and we will send you a link to reset your password.';

  @override
  String get forgotPasswordSendLinkButton => 'Send Reset Link';

  @override
  String scheduleDialogTitleFormat(String dayName, String date) {
    return '$dayName, $date';
  }

  @override
  String get scheduleNoCourses => 'No courses scheduled for this day.';

  @override
  String get scheduleCloseButton => 'Close';

  @override
  String scheduleMoreCoursesIndicator(int count) {
    return '+$count more';
  }

  @override
  String get scheduleLoadingErrorTitle => 'Error Loading Schedule';

  @override
  String get scheduleLoadingErrorRetryButton => 'Retry';

  @override
  String get addCourseTitle => 'Add Course';

  @override
  String get editCourseTitle => 'Edit Course';

  @override
  String get deleteCourseTooltip => 'Delete Course';

  @override
  String get saveCourseTooltip => 'Save Course';

  @override
  String get courseNameLabel => 'Course Name';

  @override
  String get courseNameValidationEmpty => 'Please enter the course name';

  @override
  String get courseTimeLabel => 'Time';

  @override
  String get courseTimeHint => 'HH:mm (e.g., 14:30)';

  @override
  String get courseLocationLabel => 'Location (Optional)';

  @override
  String get courseLocationHint => 'Tap to set location';

  @override
  String get courseClassroomLabel => 'Classroom (Optional)';

  @override
  String get courseInstructorLabel => 'Instructor (Optional)';

  @override
  String get courseDayOfWeekLabel => 'Day of the Week';

  @override
  String get courseDayOfWeekHint => 'Select Day';

  @override
  String get courseDayOfWeekValidationEmpty => 'Please select a day';

  @override
  String get courseStartTimeLabel => 'Start Time';

  @override
  String get courseEndTimeLabel => 'End Time';

  @override
  String get courseSelectTimeHint => 'Select Time';

  @override
  String get courseErrorTimesMissing => 'Please select day, start and end times.';

  @override
  String get courseErrorEndTimeBeforeStart => 'End time must be after start time.';

  @override
  String get courseErrorProfileLoad => 'User profile not loaded. Cannot save course reminders.';

  @override
  String get courseSaveSuccess => 'Course saved successfully.';

  @override
  String courseSaveFailed(String error) {
    return 'Failed to save course: $error';
  }

  @override
  String get courseDeleteConfirmTitle => 'Confirm Delete';

  @override
  String get courseDeleteConfirmContent => 'Are you sure you want to delete this course? This will also cancel any scheduled reminders.';

  @override
  String get courseDeleteConfirmButton => 'Delete';

  @override
  String get courseDeleteSuccess => 'Course deleted successfully.';

  @override
  String courseDeleteFailed(String error) {
    return 'Failed to delete course: $error';
  }

  @override
  String get courseLocationDialogTitle => 'Set Location';

  @override
  String get courseLocationDialogHint => 'Search for a city or location...';

  @override
  String get courseLocationDialogSaveButton => 'Save';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get profileTitle => 'My Profile';

  @override
  String profileLoadError(String error) {
    return 'Failed to load profile: $error';
  }

  @override
  String get profileNotLoggedIn => 'User not logged in.';

  @override
  String profileDepartmentLabel(String department) {
    return 'Department: $department';
  }

  @override
  String profileStudentIdLabel(String studentId) {
    return 'Student ID: $studentId';
  }

  @override
  String get profileEditButton => 'Edit Profile';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get editProfileSaveTooltip => 'Save Profile';

  @override
  String get editProfileLoadErrorTitle => 'Failed to load profile';

  @override
  String get editProfileSuccessTitle => 'Success';

  @override
  String get editProfileEmailUpdateRequiresRelogin => 'Please log out and log back in before changing your email.';

  @override
  String get editProfileEmailUpdateFailed => 'Failed to update email';

  @override
  String get editProfileUpdateSuccess => 'Profile updated successfully!';

  @override
  String get editProfileUpdateFailedTitle => 'Update Failed';

  @override
  String get editProfileSectionProfileInfo => 'Profile Information';

  @override
  String get editProfileSectionContactInfo => 'Contact Information';

  @override
  String get editProfileSectionPersonalInfo => 'Personal Details';

  @override
  String get editProfileImageSourceDialogTitle => 'Select Image Source';

  @override
  String get editProfileImageSourceCamera => 'Camera';

  @override
  String get editProfileImageSourceGallery => 'Gallery';

  @override
  String get editProfileImageSelectedSuccess => 'Profile picture selected. Save profile to keep changes.';

  @override
  String get editProfileImagePathSaveErrorTitle => 'Error Saving Path';

  @override
  String editProfileImagePathSaveErrorContent(String error) {
    return 'Could not save image path locally: $error';
  }

  @override
  String get editProfileUnsavedChangesTitle => 'Unsaved Changes';

  @override
  String get editProfileUnsavedChangesContent => 'Do you want to save your changes before leaving?';

  @override
  String get editProfileDiscardButton => 'Discard';

  @override
  String get editProfileSaveButton => 'Save';

  @override
  String get editProfileDisplayNameLabel => 'Display Name';

  @override
  String get editProfileDisplayNameValidation => 'Please enter your name';

  @override
  String get editProfileDepartmentLabel => 'Department';

  @override
  String get editProfileStudentIdLabel => 'Student ID';

  @override
  String get editProfilePhoneNumberLabel => 'Phone Number';

  @override
  String get editProfilePhoneNumberValidation => 'Invalid phone number (e.g., +1234567890)';

  @override
  String get editProfileBioLabel => 'Bio';

  @override
  String get editProfileBioHint => 'Enter a short bio...';

  @override
  String get editProfileBirthDateLabel => 'Birth Date';

  @override
  String get editProfileBirthDateHint => 'Select Date';

  @override
  String get editProfileCompletionTitle => 'Profile Completion';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfileNotAvailable => 'User profile cannot be saved.';

  @override
  String get settingsSaveSuccess => 'Settings saved successfully!';

  @override
  String settingsSaveError(String error) {
    return 'Error saving settings: $error';
  }

  @override
  String settingsCitySuggestionError(String statusCode) {
    return 'Error fetching city suggestions: $statusCode';
  }

  @override
  String settingsCitySuggestionNetworkError(String error) {
    return 'Network error fetching city suggestions: $error';
  }

  @override
  String get settingsSectionProfile => 'Profile Settings';

  @override
  String get settingsSectionNotifications => 'Notification Settings';

  @override
  String get settingsSectionDevice => 'Device Settings';

  @override
  String get settingsSectionDeleteAccount => 'Delete Account';

  @override
  String get settingsChangePasswordTile => 'Change Password';

  @override
  String get settingsSetCityDialogTitle => 'Set Default City';

  @override
  String get settingsSetCityDialogHint => 'Search for a city...';

  @override
  String get settingsDefaultCityTile => 'Default City for Weather';

  @override
  String get settingsDefaultCityHint => 'Tap to set city';

  @override
  String get settingsCourseRemindersSwitch => 'Course Reminders';

  @override
  String get settingsTaskRemindersSwitch => 'Task Reminders';

  @override
  String get settingsLeadTimeLabel => 'Course Reminder Lead Time (minutes)';

  @override
  String get settingsLeadTimeValidationEmpty => 'Please enter a lead time';

  @override
  String get settingsLeadTimeValidationNumber => 'Please enter a valid number';

  @override
  String get settingsLeadTimeValidationNegative => 'Lead time cannot be negative';

  @override
  String get settingsDeviceNotificationsTile => 'Device Notification Settings';

  @override
  String get settingsDeleteAccountConfirmTitle => 'Confirm Account Deletion';

  @override
  String get settingsDeleteAccountConfirmContent => 'Are you sure you want to permanently delete your account? This action cannot be undone.';

  @override
  String get settingsDeleteAccountButton => 'Delete Account';

  @override
  String get settingsDeletingAccountSnackbar => 'Deleting Account...';

  @override
  String get settingsDeleteAccountSuccessSnackbar => 'Account deleted successfully.';

  @override
  String settingsDeleteAccountErrorSnackbar(String error) {
    return 'Failed to delete account: $error';
  }

  @override
  String get settingsDeleteAccountErrorDialogTitle => 'Account Deletion Error';

  @override
  String get settingsReauthRequiredDialogTitle => 'Re-authentication Required';

  @override
  String get settingsReauthPasswordPrompt => 'Please enter your current password to delete your account.';

  @override
  String get settingsReauthCurrentPasswordLabel => 'Current Password';

  @override
  String get settingsReauthPasswordValidationEmpty => 'Please enter your current password';

  @override
  String get settingsReauthIncorrectPassword => 'Incorrect password.';

  @override
  String get settingsReauthVerifyButton => 'Verify';

  @override
  String get settingsChangePasswordDialogTitle => 'Change Password';

  @override
  String get settingsChangePasswordNewLabel => 'New Password';

  @override
  String get settingsChangePasswordNewValidationEmpty => 'Please enter a new password';

  @override
  String get settingsChangePasswordConfirmLabel => 'Confirm New Password';

  @override
  String get settingsChangePasswordConfirmValidationEmpty => 'Please confirm your password';

  @override
  String get settingsChangePasswordConfirmValidationMismatch => 'Passwords do not match';

  @override
  String get settingsChangePasswordUpdateButton => 'Update Password';

  @override
  String get settingsChangePasswordSuccessSnackbar => 'Password updated successfully!';

  @override
  String get settingsChangePasswordFailedDialogTitle => 'Password Change Failed';

  @override
  String get settingsErrorDialogTitle => 'Error';

  @override
  String get settingsSessionExpiredError => 'User session expired. Please log in again.';

  @override
  String fiveDayForecastTitle(String city) {
    return '5-Day Forecast for $city';
  }

  @override
  String fiveDayForecastLoadError(String error) {
    return 'Failed to load 5-day forecast: $error';
  }

  @override
  String fiveDayForecastNoData(String times) {
    return 'No forecast data available for the selected times ($times).';
  }

  @override
  String get fiveDayForecastDayDividerFormat => 'EEEE, MMM d';

  @override
  String get editProfileEmailManagedByGoogle => 'Email managed by Google';

  @override
  String editProfileCompletionIndicatorLabel(String percentage) {
    return 'Profile Completion: $percentage%';
  }

  @override
  String get calendarUserNotLoggedIn => 'User not logged in.';

  @override
  String calendarDataLoadError(String sourceType, String error) {
    return 'Failed to load $sourceType data: $error';
  }

  @override
  String get taskStatusCompleted => 'Completed';

  @override
  String get taskStatusPending => 'Pending';

  @override
  String get weatherConditionClear => 'Clear';

  @override
  String get weatherConditionClouds => 'Clouds';

  @override
  String get weatherConditionRain => 'Rain';

  @override
  String get weatherConditionDrizzle => 'Drizzle';

  @override
  String get weatherConditionThunderstorm => 'Thunderstorm';

  @override
  String get weatherConditionSnow => 'Snow';

  @override
  String get weatherConditionMist => 'Mist';

  @override
  String get weatherConditionFog => 'Fog';

  @override
  String get weatherConditionUnknown => 'Unknown';

  @override
  String get displayNameLabel => 'Full Name';

  @override
  String get displayNameValidationEmpty => 'Please enter your full name';

  @override
  String get deleteCourseDialogTitle => 'Delete Course';

  @override
  String get deleteCourseDialogContent => 'Are you sure you want to delete this course? This action cannot be undone.';

  @override
  String courseNotificationUpcomingTitle(String courseName) {
    return 'Upcoming Course: $courseName';
  }

  @override
  String courseNotificationUpcomingBody(String courseName, String courseTime, String courseLocation) {
    return '$courseName at $courseTime in $courseLocation';
  }
}
