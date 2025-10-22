import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:projectv1/src/features/settings/presentation/screens/settings_screen.dart'; // Import PopResult
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectv1/src/features/user_profile/domain/models/user_profile_model.dart';
import 'package:projectv1/src/features/user_profile/domain/services/user_profile_service.dart';
import 'package:projectv1/generated/l10n/app_localizations.dart'; // Import localizations

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final UserProfileService _userProfileService = UserProfileService();

  late TextEditingController _nameController;
  late TextEditingController _departmentController;
  late TextEditingController _studentIdController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;

  bool _isLoading = false;
  bool _isFetchingProfile =
      true; // To show loading indicator while fetching profile
  bool _hasChanges = false; // Track if user made changes
  UserProfile? _userProfile; // To store fetched profile data
  DateTime? _selectedDate;
  double _profileCompletionPercentage = 0.0; // For profile completion
  String? _localProfileImagePath; // State variable for local image path
  final ImagePicker _picker = ImagePicker(); // Keep image picker instance

  // New state variable to track auth provider
  bool _isGoogleUser = false;

  static const String _kProfileImagePathKey =
      'profile_image_path'; // Key for SharedPreferences

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _departmentController = TextEditingController();
    _studentIdController = TextEditingController();
    _bioController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _birthDateController = TextEditingController();

    _checkAuthProvider(); // Check provider on init

    // Add listeners to track changes and update completion
    _nameController.addListener(_onFieldChangedAndRecalculateCompletion);
    _departmentController.addListener(_onFieldChangedAndRecalculateCompletion);
    _studentIdController.addListener(_onFieldChangedAndRecalculateCompletion);
    _bioController.addListener(_onFieldChangedAndRecalculateCompletion);
    _emailController.addListener(_onFieldChangedAndRecalculateCompletion);
    _phoneController.addListener(_onFieldChangedAndRecalculateCompletion);
    _birthDateController.addListener(_onFieldChangedAndRecalculateCompletion);

    if (_currentUser != null) {
      _fetchUserProfile();
      _loadLocalProfileImagePath(); // Load local image path on init
    } else {
      setState(() {
        _isFetchingProfile = false;
        _calculateProfileCompletion(); // Calculate even if no user
      });
    }
  }

  // New method to check the authentication provider
  void _checkAuthProvider() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _isGoogleUser = user.providerData.any(
        (info) => info.providerId == GoogleAuthProvider.PROVIDER_ID,
      );
    }
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _onFieldChangedAndRecalculateCompletion() {
    _onFieldChanged();
    _calculateProfileCompletion();
  }

  void _calculateProfileCompletion() {
    if (_currentUser == null) {
      setState(() {
        _profileCompletionPercentage = 0.0;
      });
      return;
    }

    int filledFields = 0;
    const int totalOptionalFields =
        5; // department, studentId, bio, phone, birthDate (REMOVED defaultCity)

    if (_departmentController.text.trim().isNotEmpty) filledFields++;
    if (_studentIdController.text.trim().isNotEmpty) filledFields++;
    if (_bioController.text.trim().isNotEmpty) filledFields++;
    if (_emailController.text.trim().isNotEmpty) filledFields++;
    if (_phoneController.text.trim().isNotEmpty) filledFields++;
    if (_birthDateController.text.trim().isNotEmpty) filledFields++;
    // Email and Display Name are considered mandatory for a basic profile,
    // so they are not part of optional completion calculation here.
    // We can adjust this logic if needed.

    setState(() {
      _profileCompletionPercentage =
          totalOptionalFields > 0 ? (filledFields / totalOptionalFields) : 1.0;
    });
  }

  Future<void> _fetchUserProfile() async {
    if (_currentUser == null) return;
    setState(() {
      _isFetchingProfile = true;
    });
    try {
      _userProfile = await _userProfileService.getUserProfile(_currentUser.uid);
      if (_userProfile != null) {
        _nameController.text = _userProfile!.displayName;
        _departmentController.text = _userProfile!.department ?? '';
        _studentIdController.text = _userProfile!.studentId ?? '';
        _bioController.text = _userProfile!.bio ?? '';
        _emailController.text = _currentUser.email ?? '';
        _phoneController.text = _userProfile!.phone ?? '';

        if (_userProfile!.birthDate != null) {
          _selectedDate = _userProfile!.birthDate;
          _birthDateController.text = DateFormat(
            'yyyy-MM-dd',
          ).format(_userProfile!.birthDate!);
        }
      } else {
        // No profile in Firestore yet, use Auth display name if available
        _nameController.text = _currentUser.displayName ?? '';
        _emailController.text = _currentUser.email ?? '';
      }

      // Reset changes flag after loading data
      _hasChanges = false;
      _calculateProfileCompletion(); // Recalculate after fetching
    } catch (e) {
      if (context.mounted) {
        final localizations = AppLocalizations.of(context)!;
        _showErrorDialog(
          localizations.editProfileLoadErrorTitle,
          e.toString(),
        ); // Use localization
        // Fallback to Auth display name on error
        _nameController.text = _currentUser.displayName ?? '';
        _emailController.text = _currentUser.email ?? '';
      }
    } finally {
      if (context.mounted) {
        setState(() {
          _isFetchingProfile = false;
        });
        // Ensure completion is calculated even if fetch fails or user is new
        if (!_isFetchingProfile) _calculateProfileCompletion();
      }
    }
  }

  // --- Start: Load local image path ---
  Future<void> _loadLocalProfileImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _localProfileImagePath = prefs.getString(_kProfileImagePathKey);
      });
    } catch (e) {
      // Handle error loading path if necessary
      // print("Error loading profile image path: $e");
    }
  }
  // --- End: Load local image path ---

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChangedAndRecalculateCompletion);
    _departmentController.removeListener(
      _onFieldChangedAndRecalculateCompletion,
    );
    _studentIdController.removeListener(
      _onFieldChangedAndRecalculateCompletion,
    );
    _bioController.removeListener(_onFieldChangedAndRecalculateCompletion);
    _emailController.removeListener(_onFieldChangedAndRecalculateCompletion);
    _phoneController.removeListener(_onFieldChangedAndRecalculateCompletion);
    _birthDateController.removeListener(
      _onFieldChangedAndRecalculateCompletion,
    );

    _nameController.dispose();
    _departmentController.dispose();
    _studentIdController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // Show date picker for birth date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        // _hasChanges = true; // This is now handled by _onFieldChangedAndRecalculateCompletion
      });
      _onFieldChangedAndRecalculateCompletion(); // Manually call here as controller's listener might not fire immediately
    }
  }

  // Show error dialog with detailed message
  void _showErrorDialog(String title, String message) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              title,
            ), // Title is passed in, could be localized before calling
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.timePickerOkText), // Re-use OK text
              ),
            ],
          ),
    );
  }

  // Show success dialog
  void _showSuccessDialog(String message) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              localizations.editProfileSuccessTitle,
            ), // Use localization
            content: Text(
              message,
            ), // Message is passed in, localize before calling if needed
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.timePickerOkText), // Re-use OK text
              ),
            ],
          ),
    );
  }

  // Update email in Firebase Auth
  Future<void> _updateEmail(String newEmail) async {
    final localizations = AppLocalizations.of(context)!;
    if (_currentUser == null || newEmail == _currentUser.email) return;

    try {
      await _currentUser.verifyBeforeUpdateEmail(newEmail);
      return;
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'requires-recent-login') {
          throw localizations
              .editProfileEmailUpdateRequiresRelogin; // Use localization
        } else {
          throw e.message ??
              localizations.editProfileEmailUpdateFailed; // Use localization
        }
      }
      rethrow;
    }
  }

  // Update profile information
  Future<bool> _updateProfile() async {
    final localizations = AppLocalizations.of(context)!;
    if (_currentUser == null) return false;

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      bool success = false;

      try {
        // First try to update email if changed and user is not Google user
        final String newEmail = _emailController.text.trim();
        if (!_isGoogleUser && newEmail != _currentUser.email) {
          await _updateEmail(newEmail);
        }

        // Then update profile in Firestore
        await _userProfileService.updateUserProfile(
          uid: _currentUser.uid,
          email:
              newEmail, // Save the validated email (even if it's the same for Google user)
          displayName: _nameController.text.trim(),
          department:
              _departmentController.text.trim().isNotEmpty
                  ? _departmentController.text.trim()
                  : null,
          studentId:
              _studentIdController.text.trim().isNotEmpty
                  ? _studentIdController.text.trim()
                  : null,
          bio:
              _bioController.text.trim().isNotEmpty
                  ? _bioController.text.trim()
                  : null,
          birthDate: _selectedDate,
          phone:
              _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : null,
        );

        // Refresh profile data locally after update
        await _fetchUserProfile(); // This will also recalculate completion and reset _hasChanges

        if (context.mounted) {
          _showSuccessDialog(
            localizations.editProfileUpdateSuccess,
          ); // Use localization
        }
        success = true;
      } catch (e) {
        if (context.mounted) {
          _showErrorDialog(
            localizations.editProfileUpdateFailedTitle,
            e.toString(),
          ); // Use localization
        }
        success = false;
      } finally {
        if (context.mounted) {
          setState(() => _isLoading = false);
        }
      }
      return success;
    } else {
      return false; // Form validation failed
    }
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Start: Profile Picture Handling (Local) ----
  Future<void> _pickAndSaveProfilePictureLocally() async {
    final localizations = AppLocalizations.of(context)!;
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              localizations.editProfileImageSourceDialogTitle,
            ), // Use localization
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                child: Text(
                  localizations.editProfileImageSourceCamera,
                ), // Use localization
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                child: Text(
                  localizations.editProfileImageSourceGallery,
                ), // Use localization
              ),
            ],
          ),
    );

    if (source == null) return;

    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      try {
        // Save the path locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kProfileImagePathKey, pickedFile.path);

        // Update the state to reflect the change immediately
        setState(() {
          _localProfileImagePath = pickedFile.path;
          _hasChanges = true; // Indicate change if needed, or handle separately
        });

        if (context.mounted) {
          _showSuccessDialog(
            localizations.editProfileImageSelectedSuccess,
          ); // Use localization
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorDialog(
            localizations
                .editProfileImagePathSaveErrorTitle, // Use localization
            localizations.editProfileImagePathSaveErrorContent(
              e.toString(),
            ), // Use localization
          );
        }
      }
    }
  }
  // ---- End: Profile Picture Handling (Local) ----

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (_hasChanges) {
          final result = await showDialog<PopResult>(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => AlertDialog(
                  title: Text(
                    localizations.editProfileUnsavedChangesTitle,
                  ), // Use localization
                  content: Text(
                    localizations.editProfileUnsavedChangesContent,
                  ), // Use localization
                  actions: [
                    TextButton(
                      onPressed:
                          () => Navigator.of(context).pop(PopResult.cancel),
                      child: Text(
                        localizations.cancelAction,
                      ), // Use localization
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed:
                          () => Navigator.of(context).pop(PopResult.discard),
                      child: Text(
                        localizations.editProfileDiscardButton,
                      ), // Use localization
                    ),
                    TextButton(
                      onPressed:
                          () => Navigator.of(context).pop(PopResult.save),
                      child: Text(
                        localizations.editProfileSaveButton,
                      ), // Use localization
                    ),
                  ],
                ),
          );

          if (!mounted) return;

          if (result == PopResult.save) {
            // Attempt to save
            await _updateProfile(); // Wait for save attempt
            if (mounted) {
              // Pop regardless of save success/failure, pass true if save was successful
              // (though the return value true/false isn't strictly used by caller in this new logic)
              Navigator.pop(context, true); // Or false, doesn't matter much now
            }
          } else if (result == PopResult.discard) {
            // Pop without saving, pass false
            Navigator.pop(context, false);
          } else {}
        } else {
          Navigator.pop(context, false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.editProfileTitle), // Use localization
          actions: [
            if (_hasChanges)
              IconButton(
                icon: const Icon(Icons.save_alt_outlined),
                tooltip:
                    localizations.editProfileSaveTooltip, // Use localization
                onPressed: _isLoading ? null : _updateProfile,
              ),
          ],
        ),
        body:
            _isFetchingProfile
                ? const Center(child: CircularProgressIndicator())
                : _currentUser == null
                ? const Center(child: Text('User not logged in.'))
                : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      // Profile Picture Section
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              backgroundImage:
                                  _localProfileImagePath != null
                                      ? FileImage(File(_localProfileImagePath!))
                                      : null,
                              child:
                                  _localProfileImagePath == null
                                      ? const Icon(Icons.person, size: 60)
                                      : null,
                            ),
                            Material(
                              color: theme.colorScheme.primary,
                              shape: const CircleBorder(),
                              elevation: 2,
                              child: InkWell(
                                onTap: _pickAndSaveProfilePictureLocally,
                                customBorder: const CircleBorder(),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Profile Completion Indicator
                      _buildProfileCompletionIndicator(theme, localizations),
                      const SizedBox(height: 24),

                      // --- Profile Information Section ---
                      _buildSectionTitle(
                        localizations.editProfileSectionProfileInfo,
                        Icons.person_outline,
                      ),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: localizations.editProfileDisplayNameLabel,
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations
                                .editProfileDisplayNameValidation;
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _departmentController,
                        decoration: InputDecoration(
                          labelText: localizations.editProfileDepartmentLabel,
                          prefixIcon: const Icon(Icons.school_outlined),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _studentIdController,
                        decoration: InputDecoration(
                          labelText: localizations.editProfileStudentIdLabel,
                          prefixIcon: const Icon(Icons.perm_identity),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const Divider(height: 32),

                      // --- Contact Information Section ---
                      _buildSectionTitle(
                        localizations.editProfileSectionContactInfo,
                        Icons.contact_mail_outlined,
                      ),
                      TextFormField(
                        controller: _emailController,
                        enabled: !_isGoogleUser,
                        decoration: InputDecoration(
                          labelText: localizations.emailLabel,
                          prefixIcon: const Icon(Icons.email_outlined),
                          suffixIcon:
                              _isGoogleUser
                                  ? const Icon(Icons.lock_outline, size: 18)
                                  : null,
                          filled: _isGoogleUser,
                          fillColor:
                              _isGoogleUser
                                  ? theme.disabledColor.withOpacity(0.1)
                                  : null,
                          helperText:
                              _isGoogleUser
                                  ? localizations
                                      .editProfileEmailManagedByGoogle // Use localization
                                  : null,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        readOnly: _isGoogleUser,
                        style: TextStyle(
                          color: _isGoogleUser ? theme.disabledColor : null,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations.emailValidationEmpty;
                          }
                          if (!value.contains('@')) {
                            return localizations.emailValidationInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: localizations.editProfilePhoneNumberLabel,
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 10) {
                            return localizations
                                .editProfilePhoneNumberValidation;
                          }
                          return null;
                        },
                      ),
                      const Divider(height: 32),

                      // --- Personal Details Section ---
                      _buildSectionTitle(
                        localizations.editProfileSectionPersonalInfo,
                        Icons.cake_outlined,
                      ),
                      TextFormField(
                        controller: _bioController,
                        decoration: InputDecoration(
                          labelText: localizations.editProfileBioLabel,
                          hintText: localizations.editProfileBioHint,
                          prefixIcon: const Icon(Icons.notes_outlined),
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _birthDateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          labelText: localizations.editProfileBirthDateLabel,
                          hintText: localizations.editProfileBirthDateHint,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
      ),
    );
  }

  // Helper to build the completion indicator
  Widget _buildProfileCompletionIndicator(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.editProfileCompletionIndicatorLabel(
            (_profileCompletionPercentage * 100).toStringAsFixed(0),
          ), // Use localization
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: _profileCompletionPercentage,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
