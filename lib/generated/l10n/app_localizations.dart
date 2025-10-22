import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @upcomingCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Courses'**
  String get upcomingCoursesTitle;

  /// No description provided for @pendingTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending Tasks'**
  String get pendingTasksTitle;

  /// No description provided for @todaysWeatherTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Weather'**
  String get todaysWeatherTitle;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @myCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Courses'**
  String get myCoursesTitle;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @myTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasksTitle;

  /// No description provided for @weeklyScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get weeklyScheduleTitle;

  /// No description provided for @weatherSetCityPrompt.
  ///
  /// In en, this message translates to:
  /// **'Set your default city in settings to see weather.'**
  String get weatherSetCityPrompt;

  /// Error message when weather fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load weather for {cityName}: {error}'**
  String weatherLoadError(String cityName, String error);

  /// No description provided for @weatherDataNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Weather data not available.'**
  String get weatherDataNotAvailable;

  /// No description provided for @noUpcomingCourses.
  ///
  /// In en, this message translates to:
  /// **'No upcoming courses in the next 2 days.'**
  String get noUpcomingCourses;

  /// No description provided for @noPendingTasks.
  ///
  /// In en, this message translates to:
  /// **'No pending tasks for today or later.'**
  String get noPendingTasks;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @profileMenuProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileMenuProfile;

  /// No description provided for @profileMenuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileMenuSettings;

  /// No description provided for @profileMenuLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileMenuLogout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmContent;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @logoutAction.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutAction;

  /// No description provided for @languageSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingTitle;

  /// No description provided for @themeSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeSettingTitle;

  /// No description provided for @activeTasksTab.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeTasksTab;

  /// No description provided for @completedTasksTab.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedTasksTab;

  /// No description provided for @editTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTaskTitle;

  /// No description provided for @addTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Task'**
  String get addTaskTitle;

  /// No description provided for @taskNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Task Name'**
  String get taskNameLabel;

  /// No description provided for @taskNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the name of your task'**
  String get taskNameHint;

  /// No description provided for @taskNameValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter the task name.'**
  String get taskNameValidationEmpty;

  /// No description provided for @taskNameValidationLength.
  ///
  /// In en, this message translates to:
  /// **'Task name cannot exceed 100 characters.'**
  String get taskNameValidationLength;

  /// No description provided for @taskDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get taskDescriptionLabel;

  /// No description provided for @taskDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add more details about the task'**
  String get taskDescriptionHint;

  /// No description provided for @taskCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get taskCategoryLabel;

  /// No description provided for @taskCategoryValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please select a category.'**
  String get taskCategoryValidationEmpty;

  /// No description provided for @selectDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Due Date *'**
  String get selectDueDateLabel;

  /// No description provided for @dueDatePrefix.
  ///
  /// In en, this message translates to:
  /// **'Due: '**
  String get dueDatePrefix;

  /// No description provided for @reminderTimePrefix.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time: '**
  String get reminderTimePrefix;

  /// No description provided for @reminderTimeNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get reminderTimeNotSet;

  /// No description provided for @clearReminderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear Reminder'**
  String get clearReminderTooltip;

  /// No description provided for @updateTaskButton.
  ///
  /// In en, this message translates to:
  /// **'Update Task'**
  String get updateTaskButton;

  /// No description provided for @addTaskButton.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTaskButton;

  /// No description provided for @selectDueDateError.
  ///
  /// In en, this message translates to:
  /// **'Please select a due date.'**
  String get selectDueDateError;

  /// No description provided for @reminderBeforeDueError.
  ///
  /// In en, this message translates to:
  /// **'Reminder time must be before the due date.'**
  String get reminderBeforeDueError;

  /// No description provided for @mustBeLoggedInError.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to save tasks.'**
  String get mustBeLoggedInError;

  /// No description provided for @profileNotLoadedError.
  ///
  /// In en, this message translates to:
  /// **'User profile not loaded. Cannot save task reminders.'**
  String get profileNotLoadedError;

  /// No description provided for @taskAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Task added successfully!'**
  String get taskAddedSuccess;

  /// No description provided for @taskUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Task updated successfully!'**
  String get taskUpdatedSuccess;

  /// No description provided for @taskSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save task: {error}'**
  String taskSaveFailed(String error);

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task?'**
  String get confirmDeleteContent;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @taskDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Task deleted successfully!'**
  String get taskDeletedSuccess;

  /// No description provided for @taskDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete task: {error}'**
  String taskDeleteFailed(String error);

  /// No description provided for @timePickerOkText.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get timePickerOkText;

  /// No description provided for @timePickerCancelText.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get timePickerCancelText;

  /// No description provided for @taskCategoryAssignment.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get taskCategoryAssignment;

  /// No description provided for @taskCategoryExam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get taskCategoryExam;

  /// No description provided for @taskCategoryReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get taskCategoryReminder;

  /// No description provided for @taskCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get taskCategoryOther;

  /// No description provided for @taskDeleteConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task?'**
  String get taskDeleteConfirmContent;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @emailValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailValidationEmpty;

  /// No description provided for @emailValidationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailValidationInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @passwordValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordValidationEmpty;

  /// No description provided for @passwordValidationLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordValidationLength;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginWithGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginWithGoogleButton;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountPrompt;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// Error message shown when login fails.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// No description provided for @loginCancelled.
  ///
  /// In en, this message translates to:
  /// **'Login cancelled by user.'**
  String get loginCancelled;

  /// No description provided for @googleSignInError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred during Google sign-in.'**
  String get googleSignInError;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful! Please login.'**
  String get registrationSuccessful;

  /// No description provided for @registrationErrorDefault.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during registration.'**
  String get registrationErrorDefault;

  /// No description provided for @registrationErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password provided is too weak.'**
  String get registrationErrorWeakPassword;

  /// No description provided for @registrationErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'The account already exists for that email.'**
  String get registrationErrorEmailInUse;

  /// Error message shown when Firebase registration fails.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String registrationErrorFirebase(String error);

  /// No description provided for @registrationErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get registrationErrorUnexpected;

  /// No description provided for @createAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Create a new account to start organizing your campus life!'**
  String get createAccountPrompt;

  /// No description provided for @registerEmailValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get registerEmailValidationEmpty;

  /// No description provided for @registerEmailValidationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get registerEmailValidationInvalid;

  /// No description provided for @registerPasswordValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get registerPasswordValidationEmpty;

  /// No description provided for @registerPasswordValidationLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get registerPasswordValidationLength;

  /// No description provided for @registerButtonRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButtonRegister;

  /// No description provided for @alreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccountPrompt;

  /// No description provided for @loginButtonFromRegister.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButtonFromRegister;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get loginWelcomeBack;

  /// No description provided for @loginManageSchedule.
  ///
  /// In en, this message translates to:
  /// **'Login to manage your campus schedule.'**
  String get loginManageSchedule;

  /// No description provided for @loginRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get loginRememberMe;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginOrSeparator.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get loginOrSeparator;

  /// No description provided for @loginLoggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging In...'**
  String get loginLoggingIn;

  /// No description provided for @loginSigningInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Signing In...'**
  String get loginSigningInGoogle;

  /// No description provided for @loginErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found for that email.'**
  String get loginErrorUserNotFound;

  /// No description provided for @loginErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password provided for that user.'**
  String get loginErrorWrongPassword;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials. Please check your email and password.'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during login.'**
  String get loginErrorGeneric;

  /// No description provided for @loginErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get loginErrorUnexpected;

  /// No description provided for @googleSignInErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred with Google Sign-In.'**
  String get googleSignInErrorGeneric;

  /// No description provided for @googleSignInErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected Google Sign-In error occurred.'**
  String get googleSignInErrorUnexpected;

  /// No description provided for @googleSignInProfileError.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile details, but login successful.'**
  String get googleSignInProfileError;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Please check your inbox.'**
  String get forgotPasswordSuccessMessage;

  /// No description provided for @forgotPasswordErrorFailedToSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to send password reset email.'**
  String get forgotPasswordErrorFailedToSend;

  /// No description provided for @forgotPasswordErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found for that email.'**
  String get forgotPasswordErrorUserNotFound;

  /// Error message shown when Firebase password reset email fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to send password reset email: {error}'**
  String forgotPasswordErrorFirebase(String error);

  /// No description provided for @forgotPasswordErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get forgotPasswordErrorUnexpected;

  /// No description provided for @forgotPasswordInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a link to reset your password.'**
  String get forgotPasswordInstruction;

  /// No description provided for @forgotPasswordSendLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get forgotPasswordSendLinkButton;

  /// Format for the title in the daily schedule dialog showing courses.
  ///
  /// In en, this message translates to:
  /// **'{dayName}, {date}'**
  String scheduleDialogTitleFormat(String dayName, String date);

  /// No description provided for @scheduleNoCourses.
  ///
  /// In en, this message translates to:
  /// **'No courses scheduled for this day.'**
  String get scheduleNoCourses;

  /// No description provided for @scheduleCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get scheduleCloseButton;

  /// Indicator showing how many more courses exist for a day beyond the first two shown.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String scheduleMoreCoursesIndicator(int count);

  /// No description provided for @scheduleLoadingErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Schedule'**
  String get scheduleLoadingErrorTitle;

  /// No description provided for @scheduleLoadingErrorRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get scheduleLoadingErrorRetryButton;

  /// No description provided for @addCourseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Course'**
  String get addCourseTitle;

  /// No description provided for @editCourseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Course'**
  String get editCourseTitle;

  /// No description provided for @deleteCourseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Course'**
  String get deleteCourseTooltip;

  /// No description provided for @saveCourseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save Course'**
  String get saveCourseTooltip;

  /// No description provided for @courseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Course Name'**
  String get courseNameLabel;

  /// No description provided for @courseNameValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter the course name'**
  String get courseNameValidationEmpty;

  /// No description provided for @courseTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get courseTimeLabel;

  /// No description provided for @courseTimeHint.
  ///
  /// In en, this message translates to:
  /// **'HH:mm (e.g., 14:30)'**
  String get courseTimeHint;

  /// No description provided for @courseLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location (Optional)'**
  String get courseLocationLabel;

  /// No description provided for @courseLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to set location'**
  String get courseLocationHint;

  /// No description provided for @courseClassroomLabel.
  ///
  /// In en, this message translates to:
  /// **'Classroom (Optional)'**
  String get courseClassroomLabel;

  /// No description provided for @courseInstructorLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructor (Optional)'**
  String get courseInstructorLabel;

  /// No description provided for @courseDayOfWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Day of the Week'**
  String get courseDayOfWeekLabel;

  /// No description provided for @courseDayOfWeekHint.
  ///
  /// In en, this message translates to:
  /// **'Select Day'**
  String get courseDayOfWeekHint;

  /// No description provided for @courseDayOfWeekValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please select a day'**
  String get courseDayOfWeekValidationEmpty;

  /// No description provided for @courseStartTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get courseStartTimeLabel;

  /// No description provided for @courseEndTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get courseEndTimeLabel;

  /// No description provided for @courseSelectTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get courseSelectTimeHint;

  /// No description provided for @courseErrorTimesMissing.
  ///
  /// In en, this message translates to:
  /// **'Please select day, start and end times.'**
  String get courseErrorTimesMissing;

  /// No description provided for @courseErrorEndTimeBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time.'**
  String get courseErrorEndTimeBeforeStart;

  /// No description provided for @courseErrorProfileLoad.
  ///
  /// In en, this message translates to:
  /// **'User profile not loaded. Cannot save course reminders.'**
  String get courseErrorProfileLoad;

  /// No description provided for @courseSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Course saved successfully.'**
  String get courseSaveSuccess;

  /// No description provided for @courseSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save course: {error}'**
  String courseSaveFailed(String error);

  /// No description provided for @courseDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get courseDeleteConfirmTitle;

  /// No description provided for @courseDeleteConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this course? This will also cancel any scheduled reminders.'**
  String get courseDeleteConfirmContent;

  /// No description provided for @courseDeleteConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get courseDeleteConfirmButton;

  /// No description provided for @courseDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Course deleted successfully.'**
  String get courseDeleteSuccess;

  /// No description provided for @courseDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete course: {error}'**
  String courseDeleteFailed(String error);

  /// No description provided for @courseLocationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Location'**
  String get courseLocationDialogTitle;

  /// No description provided for @courseLocationDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a city or location...'**
  String get courseLocationDialogHint;

  /// No description provided for @courseLocationDialogSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get courseLocationDialogSaveButton;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile: {error}'**
  String profileLoadError(String error);

  /// No description provided for @profileNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in.'**
  String get profileNotLoggedIn;

  /// No description provided for @profileDepartmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Department: {department}'**
  String profileDepartmentLabel(String department);

  /// No description provided for @profileStudentIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Student ID: {studentId}'**
  String profileStudentIdLabel(String studentId);

  /// No description provided for @profileEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditButton;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileSaveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get editProfileSaveTooltip;

  /// No description provided for @editProfileLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get editProfileLoadErrorTitle;

  /// No description provided for @editProfileSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get editProfileSuccessTitle;

  /// No description provided for @editProfileEmailUpdateRequiresRelogin.
  ///
  /// In en, this message translates to:
  /// **'Please log out and log back in before changing your email.'**
  String get editProfileEmailUpdateRequiresRelogin;

  /// No description provided for @editProfileEmailUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update email'**
  String get editProfileEmailUpdateFailed;

  /// No description provided for @editProfileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get editProfileUpdateSuccess;

  /// No description provided for @editProfileUpdateFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Failed'**
  String get editProfileUpdateFailedTitle;

  /// No description provided for @editProfileSectionProfileInfo.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get editProfileSectionProfileInfo;

  /// No description provided for @editProfileSectionContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get editProfileSectionContactInfo;

  /// No description provided for @editProfileSectionPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get editProfileSectionPersonalInfo;

  /// No description provided for @editProfileImageSourceDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get editProfileImageSourceDialogTitle;

  /// No description provided for @editProfileImageSourceCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get editProfileImageSourceCamera;

  /// No description provided for @editProfileImageSourceGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get editProfileImageSourceGallery;

  /// No description provided for @editProfileImageSelectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile picture selected. Save profile to keep changes.'**
  String get editProfileImageSelectedSuccess;

  /// No description provided for @editProfileImagePathSaveErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error Saving Path'**
  String get editProfileImagePathSaveErrorTitle;

  /// No description provided for @editProfileImagePathSaveErrorContent.
  ///
  /// In en, this message translates to:
  /// **'Could not save image path locally: {error}'**
  String editProfileImagePathSaveErrorContent(String error);

  /// No description provided for @editProfileUnsavedChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get editProfileUnsavedChangesTitle;

  /// No description provided for @editProfileUnsavedChangesContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save your changes before leaving?'**
  String get editProfileUnsavedChangesContent;

  /// No description provided for @editProfileDiscardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get editProfileDiscardButton;

  /// No description provided for @editProfileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editProfileSaveButton;

  /// No description provided for @editProfileDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get editProfileDisplayNameLabel;

  /// No description provided for @editProfileDisplayNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get editProfileDisplayNameValidation;

  /// No description provided for @editProfileDepartmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get editProfileDepartmentLabel;

  /// No description provided for @editProfileStudentIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get editProfileStudentIdLabel;

  /// No description provided for @editProfilePhoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get editProfilePhoneNumberLabel;

  /// No description provided for @editProfilePhoneNumberValidation.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number (e.g., +1234567890)'**
  String get editProfilePhoneNumberValidation;

  /// No description provided for @editProfileBioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get editProfileBioLabel;

  /// No description provided for @editProfileBioHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a short bio...'**
  String get editProfileBioHint;

  /// No description provided for @editProfileBirthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get editProfileBirthDateLabel;

  /// No description provided for @editProfileBirthDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get editProfileBirthDateHint;

  /// No description provided for @editProfileCompletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Completion'**
  String get editProfileCompletionTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsProfileNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'User profile cannot be saved.'**
  String get settingsProfileNotAvailable;

  /// No description provided for @settingsSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully!'**
  String get settingsSaveSuccess;

  /// No description provided for @settingsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving settings: {error}'**
  String settingsSaveError(String error);

  /// No description provided for @settingsCitySuggestionError.
  ///
  /// In en, this message translates to:
  /// **'Error fetching city suggestions: {statusCode}'**
  String settingsCitySuggestionError(String statusCode);

  /// No description provided for @settingsCitySuggestionNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error fetching city suggestions: {error}'**
  String settingsCitySuggestionNetworkError(String error);

  /// No description provided for @settingsSectionProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get settingsSectionProfile;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsSectionDevice.
  ///
  /// In en, this message translates to:
  /// **'Device Settings'**
  String get settingsSectionDevice;

  /// No description provided for @settingsSectionDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsSectionDeleteAccount;

  /// No description provided for @settingsChangePasswordTile.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePasswordTile;

  /// No description provided for @settingsSetCityDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Default City'**
  String get settingsSetCityDialogTitle;

  /// No description provided for @settingsSetCityDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a city...'**
  String get settingsSetCityDialogHint;

  /// No description provided for @settingsDefaultCityTile.
  ///
  /// In en, this message translates to:
  /// **'Default City for Weather'**
  String get settingsDefaultCityTile;

  /// No description provided for @settingsDefaultCityHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to set city'**
  String get settingsDefaultCityHint;

  /// No description provided for @settingsCourseRemindersSwitch.
  ///
  /// In en, this message translates to:
  /// **'Course Reminders'**
  String get settingsCourseRemindersSwitch;

  /// No description provided for @settingsTaskRemindersSwitch.
  ///
  /// In en, this message translates to:
  /// **'Task Reminders'**
  String get settingsTaskRemindersSwitch;

  /// No description provided for @settingsLeadTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Course Reminder Lead Time (minutes)'**
  String get settingsLeadTimeLabel;

  /// No description provided for @settingsLeadTimeValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a lead time'**
  String get settingsLeadTimeValidationEmpty;

  /// No description provided for @settingsLeadTimeValidationNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get settingsLeadTimeValidationNumber;

  /// No description provided for @settingsLeadTimeValidationNegative.
  ///
  /// In en, this message translates to:
  /// **'Lead time cannot be negative'**
  String get settingsLeadTimeValidationNegative;

  /// No description provided for @settingsDeviceNotificationsTile.
  ///
  /// In en, this message translates to:
  /// **'Device Notification Settings'**
  String get settingsDeviceNotificationsTile;

  /// No description provided for @settingsDeleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Account Deletion'**
  String get settingsDeleteAccountConfirmTitle;

  /// No description provided for @settingsDeleteAccountConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action cannot be undone.'**
  String get settingsDeleteAccountConfirmContent;

  /// No description provided for @settingsDeleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccountButton;

  /// No description provided for @settingsDeletingAccountSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Deleting Account...'**
  String get settingsDeletingAccountSnackbar;

  /// No description provided for @settingsDeleteAccountSuccessSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get settingsDeleteAccountSuccessSnackbar;

  /// No description provided for @settingsDeleteAccountErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account: {error}'**
  String settingsDeleteAccountErrorSnackbar(String error);

  /// No description provided for @settingsDeleteAccountErrorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Deletion Error'**
  String get settingsDeleteAccountErrorDialogTitle;

  /// No description provided for @settingsReauthRequiredDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-authentication Required'**
  String get settingsReauthRequiredDialogTitle;

  /// No description provided for @settingsReauthPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password to delete your account.'**
  String get settingsReauthPasswordPrompt;

  /// No description provided for @settingsReauthCurrentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get settingsReauthCurrentPasswordLabel;

  /// No description provided for @settingsReauthPasswordValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get settingsReauthPasswordValidationEmpty;

  /// No description provided for @settingsReauthIncorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get settingsReauthIncorrectPassword;

  /// No description provided for @settingsReauthVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get settingsReauthVerifyButton;

  /// No description provided for @settingsChangePasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePasswordDialogTitle;

  /// No description provided for @settingsChangePasswordNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get settingsChangePasswordNewLabel;

  /// No description provided for @settingsChangePasswordNewValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get settingsChangePasswordNewValidationEmpty;

  /// No description provided for @settingsChangePasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get settingsChangePasswordConfirmLabel;

  /// No description provided for @settingsChangePasswordConfirmValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get settingsChangePasswordConfirmValidationEmpty;

  /// No description provided for @settingsChangePasswordConfirmValidationMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get settingsChangePasswordConfirmValidationMismatch;

  /// No description provided for @settingsChangePasswordUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get settingsChangePasswordUpdateButton;

  /// No description provided for @settingsChangePasswordSuccessSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get settingsChangePasswordSuccessSnackbar;

  /// No description provided for @settingsChangePasswordFailedDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Change Failed'**
  String get settingsChangePasswordFailedDialogTitle;

  /// No description provided for @settingsErrorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get settingsErrorDialogTitle;

  /// No description provided for @settingsSessionExpiredError.
  ///
  /// In en, this message translates to:
  /// **'User session expired. Please log in again.'**
  String get settingsSessionExpiredError;

  /// No description provided for @fiveDayForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'5-Day Forecast for {city}'**
  String fiveDayForecastTitle(String city);

  /// No description provided for @fiveDayForecastLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load 5-day forecast: {error}'**
  String fiveDayForecastLoadError(String error);

  /// Message shown when no forecast data is available for the filtered hours.
  ///
  /// In en, this message translates to:
  /// **'No forecast data available for the selected times ({times}).'**
  String fiveDayForecastNoData(String times);

  /// Date format for the divider between days in the 5-day forecast (e.g., Monday, May 20).
  ///
  /// In en, this message translates to:
  /// **'EEEE, MMM d'**
  String get fiveDayForecastDayDividerFormat;

  /// No description provided for @editProfileEmailManagedByGoogle.
  ///
  /// In en, this message translates to:
  /// **'Email managed by Google'**
  String get editProfileEmailManagedByGoogle;

  /// No description provided for @editProfileCompletionIndicatorLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile Completion: {percentage}%'**
  String editProfileCompletionIndicatorLabel(String percentage);

  /// No description provided for @calendarUserNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in.'**
  String get calendarUserNotLoggedIn;

  /// No description provided for @calendarDataLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load {sourceType} data: {error}'**
  String calendarDataLoadError(String sourceType, String error);

  /// No description provided for @taskStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskStatusCompleted;

  /// No description provided for @taskStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get taskStatusPending;

  /// No description provided for @weatherConditionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get weatherConditionClear;

  /// No description provided for @weatherConditionClouds.
  ///
  /// In en, this message translates to:
  /// **'Clouds'**
  String get weatherConditionClouds;

  /// No description provided for @weatherConditionRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get weatherConditionRain;

  /// No description provided for @weatherConditionDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get weatherConditionDrizzle;

  /// No description provided for @weatherConditionThunderstorm.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get weatherConditionThunderstorm;

  /// No description provided for @weatherConditionSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get weatherConditionSnow;

  /// No description provided for @weatherConditionMist.
  ///
  /// In en, this message translates to:
  /// **'Mist'**
  String get weatherConditionMist;

  /// No description provided for @weatherConditionFog.
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get weatherConditionFog;

  /// No description provided for @weatherConditionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get weatherConditionUnknown;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get displayNameLabel;

  /// No description provided for @displayNameValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get displayNameValidationEmpty;

  /// No description provided for @deleteCourseDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Course'**
  String get deleteCourseDialogTitle;

  /// No description provided for @deleteCourseDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this course? This action cannot be undone.'**
  String get deleteCourseDialogContent;

  /// Title for an upcoming course notification
  ///
  /// In en, this message translates to:
  /// **'Upcoming Course: {courseName}'**
  String courseNotificationUpcomingTitle(String courseName);

  /// Body for an upcoming course notification
  ///
  /// In en, this message translates to:
  /// **'{courseName} at {courseTime} in {courseLocation}'**
  String courseNotificationUpcomingBody(String courseName, String courseTime, String courseLocation);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
