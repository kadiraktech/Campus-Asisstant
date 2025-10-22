import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projectv1/src/features/auth/presentation/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectv1/src/features/user_profile/domain/models/user_profile_model.dart';
import 'package:projectv1/src/features/user_profile/domain/services/user_profile_service.dart';
import 'package:projectv1/src/core/config/api_keys.dart';
import 'package:app_settings/app_settings.dart'
    as app_settings_package; // Alias to avoid conflict
import 'package:projectv1/src/core/providers/default_city_provider.dart';
import 'package:google_sign_in/google_sign_in.dart'; // For Google re-authentication
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projectv1/src/core/theme/theme_provider.dart';
import 'package:projectv1/src/core/providers/locale_provider.dart';
import 'package:projectv1/generated/l10n/app_localizations.dart';
import 'dart:io'; // For SocketException

/// Uygulama ayarları ekranı. Kullanıcı profilini, bildirim ve genel ayarları yönetir.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

enum PopResult { save, discard, cancel }

class _SettingsScreenState extends State<SettingsScreen> {
  final UserProfileService _userProfileService = UserProfileService();
  UserProfile? _userProfile;
  late TextEditingController _cityController;
  late TextEditingController _leadTimeController;
  final GlobalKey _cityFieldKey = GlobalKey();
  // Add controllers for other editable profile fields if needed
  // late TextEditingController _nameController;
  // late TextEditingController _studentIdController;
  // late TextEditingController _departmentController;

  bool _isLoadingProfile = true;
  bool _didSettingsChange = false;
  final _formKey = GlobalKey<FormState>();

  Timer? _debounce;
  List<String> _citySuggestions = [];
  bool _isFetchingSuggestions = false;
  String? _selectedCityFromSuggestion;

  final bool _courseRemindersEnabled = true;
  final bool _taskRemindersEnabled = true;
  final bool _isLoading = false; // For general loading state
  bool _isDeletingAccount = false; // Specifically for account deletion

  // New state variable to track auth provider
  bool _isGoogleUser = false;

  static const String _kProfileImagePathKey =
      'profile_image_path'; // From ViewProfileScreen

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController();
    _leadTimeController = TextEditingController();
    // Initialize other controllers here if they exist
    // _nameController = TextEditingController();
    _checkAuthProvider(); // Check provider on init
    _loadUserProfile();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _leadTimeController.dispose();
    // Dispose other controllers here
    // _nameController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Kullanıcı profilini Firestore'dan yükler ve formu doldurur.
  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProfile = true;
    });
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final profile = await _userProfileService.getUserProfile(userId);
        if (mounted && profile != null) {
          setState(() {
            _userProfile = profile;
            _cityController.text = profile.defaultCity ?? '';
            _leadTimeController.text =
                profile.notificationsCourseLeadTimeMinutes.toString();
            // Update other controllers
            // _nameController.text = profile.displayName;
          });
        } else if (mounted) {
          // Profil yoksa varsayılan bir profil oluştur
          _userProfile = UserProfile(
            uid: userId,
            email: FirebaseAuth.instance.currentUser?.email ?? '',
            displayName:
                FirebaseAuth.instance.currentUser?.displayName ?? 'User',
          );
          // Set default values for controllers
          _cityController.text = _userProfile?.defaultCity ?? '';
          _leadTimeController.text =
              _userProfile!.notificationsCourseLeadTimeMinutes.toString();
          // _nameController.text = _userProfile!.displayName;
        }
      }
    } catch (e) {
      if (mounted) {
        // Hata durumunda dummy profil oluştur
        _userProfile = UserProfile(
          uid: FirebaseAuth.instance.currentUser?.uid ?? 'error_uid',
          email: FirebaseAuth.instance.currentUser?.email ?? 'error_email',
          displayName:
              FirebaseAuth.instance.currentUser?.displayName ?? 'User Error',
        );
        _cityController.text = '';
        _leadTimeController.text = '10';
      }
      debugPrint('Error loading user profile: $e');
    }
    if (mounted) {
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  /// Formdaki değişiklikleri Firestore'a kaydeder.
  Future<bool> _saveUpdatedUserProfile() async {
    final localizations = AppLocalizations.of(context)!;
    if (_userProfile == null ||
        FirebaseAuth.instance.currentUser?.uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.settingsProfileNotAvailable)),
        );
      }
      return false;
    }

    _formKey.currentState!.save();
    setState(() => _isLoadingProfile = true);

    final String? newCity =
        _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null;
    final int newLeadTime =
        int.tryParse(_leadTimeController.text) ??
        _userProfile!.notificationsCourseLeadTimeMinutes;

    // Eğer displayName gibi diğer alanlar da formda düzenlenebiliyorsa, onların değerlerini de burada alın:
    // final String newDisplayName = _nameController.text.trim();
    // UserProfileService.updateUserProfile çağrısında ve _userProfile.copyWith içinde bu değerleri kullanın.

    try {
      await _userProfileService.updateUserProfile(
        uid: _userProfile!.uid,
        email: _userProfile!.email,
        displayName: _userProfile!.displayName,
        department: _userProfile!.department,
        studentId: _userProfile!.studentId,
        bio: _userProfile!.bio,
        defaultCity: newCity,
        notificationsCourseRemindersEnabled:
            _userProfile!.notificationsCourseRemindersEnabled,
        notificationsTaskRemindersEnabled:
            _userProfile!.notificationsTaskRemindersEnabled,
        notificationsCourseLeadTimeMinutes: newLeadTime,
      );

      // Yerel state'i güncelle
      final updatedProfileLocally = _userProfile!.copyWith(
        // displayName: newDisplayName, // Eğer güncellendiyse
        defaultCity: newCity,
        notificationsCourseLeadTimeMinutes: newLeadTime,
        // notificationsCourseRemindersEnabled: newValueFromSwitch // Eğer güncellendiyse
        // notificationsTaskRemindersEnabled: newValueFromSwitch // Eğer güncellendiyse
        // Diğer güncellenen alanlar...
      );

      if (mounted) {
        _userProfile = updatedProfileLocally;
        Provider.of<DefaultCityProvider>(
          context,
          listen: false,
        ).updateDefaultCity(updatedProfileLocally.defaultCity);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.settingsSaveSuccess)),
        );
        setState(() {
          _didSettingsChange = false;
          _isLoadingProfile = false;
        });
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.settingsSaveError(e.toString())),
          ),
        );
      }
      debugPrint('Error saving user profile: $e');
      return false;
    } finally {
      // Ensure loading state is always turned off
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  /// Şehir ismine göre OpenWeatherMap API'den şehir önerilerini çeker.
  Future<void> _fetchCitySuggestions(String query) async {
    final localizations = AppLocalizations.of(context)!;
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _citySuggestions = [];
          _isFetchingSuggestions = false;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
        _isFetchingSuggestions = true;
      });
    }

    final Uri uri = Uri.parse(
      'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$openWeatherApiKey',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (mounted) {
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            _citySuggestions =
                data
                    .map((item) {
                      final name = item['name'] as String?;
                      final country = item['country'] as String?;
                      final state = item['state'] as String?;
                      String suggestion = name ?? '';
                      if (state != null && state.isNotEmpty) {
                        suggestion += ', $state';
                      }
                      if (country != null && country.isNotEmpty) {
                        suggestion += ', $country';
                      }
                      return suggestion;
                    })
                    .where((s) => s.isNotEmpty)
                    .toList();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.settingsCitySuggestionError(
                  response.statusCode.toString(),
                ),
              ),
            ),
          );
          setState(() {
            _citySuggestions = [];
          });
        }
      }
    } on SocketException catch (e) {
      // Correctly typed now
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.settingsCitySuggestionNetworkError(e.message),
            ),
          ),
        );
        setState(() {
          _citySuggestions = [];
        });
      }
    } catch (e) {
      debugPrint('Unexpected error fetching city suggestions: $e');
      if (mounted) {
        setState(() {
          _citySuggestions = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingSuggestions = false;
        });
      }
    }
  }

  /// Şehir seçimi için diyalog açar ve autocomplete ile öneri sunar.
  void _showSetDefaultCityDialog() {
    final localizations = AppLocalizations.of(context)!;
    _selectedCityFromSuggestion = null;
    _citySuggestions = [];
    final TextEditingController dialogCityController = TextEditingController(
      text: _cityController.text,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(localizations.settingsSetCityDialogTitle),
              content: Autocomplete<String>(
                key: _cityFieldKey,
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  _onCityChangedDebounced(textEditingValue.text);
                  return _citySuggestions;
                },
                displayStringForOption: (String option) => option,
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  dialogCityController.value = fieldTextEditingController.value;
                  return TextFormField(
                    controller: dialogCityController,
                    focusNode: focusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: localizations.settingsSetCityDialogHint,
                      suffixIcon:
                          _isFetchingSuggestions
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                              : null,
                    ),
                  );
                },
                optionsViewBuilder: (
                  BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options,
                ) {
                  final theme = Theme.of(context);
                  // Calculate width based on the field
                  double fieldWidth = 320; // Default or fallback width
                  final currentContext = _cityFieldKey.currentContext;
                  if (currentContext != null) {
                    final box = currentContext.findRenderObject();
                    if (box is RenderBox) {
                      fieldWidth = box.size.width;
                    }
                  }
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 300,
                          minWidth: fieldWidth, // Use calculated width
                          maxWidth: fieldWidth,
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder:
                              (_, __) => Divider(
                                height: 1,
                                color: theme.dividerColor.withOpacity(0.08),
                              ),
                          itemBuilder: (context, index) {
                            final String option = options.elementAt(index);
                            return InkWell(
                              onTap: () {
                                onSelected(option);
                              },
                              hoverColor: theme.colorScheme.primary.withOpacity(
                                0.08,
                              ),
                              splashColor: theme.colorScheme.primary
                                  .withOpacity(0.12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Text(
                                  option,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                onSelected: (String selection) {
                  setDialogState(() {
                    _cityController.text = selection;
                    _selectedCityFromSuggestion = selection;
                    _citySuggestions = [];
                    _isFetchingSuggestions = false;
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(localizations.cancelAction),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(localizations.editProfileSaveButton),
                  onPressed: () {
                    setState(() {
                      _cityController.text =
                          _selectedCityFromSuggestion ??
                          dialogCityController.text.trim();
                      _didSettingsChange = true;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Kullanıcıyı çıkış yaptırır ve giriş ekranına yönlendirir.
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  /// Çıkış işlemi için onay diyalogu gösterir.
  Future<void> _showLogoutConfirmationDialog() async {
    if (!mounted) return;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await _handleLogout();
    }
  }

  /// Hesap silme işlemini simüle eder. Gerçek silme için ilgili satırları açın.
  Future<void> _handleDeleteAccount() async {
    final localizations = AppLocalizations.of(context)!;
    setState(() => _isDeletingAccount = true);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showErrorDialog(
        localizations.settingsErrorDialogTitle,
        localizations.settingsSessionExpiredError,
      );
      setState(() => _isDeletingAccount = false);
      return;
    }

    try {
      // Ask for confirmation first
      final confirmDelete = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(localizations.settingsDeleteAccountConfirmTitle),
            content: Text(localizations.settingsDeleteAccountConfirmContent),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(localizations.cancelAction),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(localizations.settingsDeleteAccountButton),
              ),
            ],
          );
        },
      );

      if (confirmDelete != true) {
        setState(() => _isDeletingAccount = false);
        return;
      }

      // Check provider
      AuthCredential? credential;
      if (_isGoogleUser) {
        // Re-authenticate Google user
        final GoogleSignInAccount? googleUser =
            await GoogleSignIn().signInSilently() ??
            await GoogleSignIn().signIn();
        if (googleUser == null)
          throw Exception('Google re-authentication failed.');
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      } else {
        // Re-authenticate Email/Password user
        final password = await _promptForPassword();
        if (password == null)
          throw Exception('Password entry cancelled.'); // User cancelled
        if (currentUser.email == null)
          throw Exception('User email is missing.');
        credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: password,
        );
      }

      // Re-authenticate before deleting
      await currentUser.reauthenticateWithCredential(credential);

      // Now delete the account
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.settingsDeletingAccountSnackbar),
          ),
        );
      }
      await currentUser.delete();

      // Delete associated profile data (optional, depends on your rules)
      // Consider doing this via Cloud Functions triggered by auth deletion
      // await _userProfileService.deleteUserProfile(currentUser.uid);

      // Clear local data (like saved profile pic path)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kProfileImagePathKey);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.settingsDeleteAccountSuccessSnackbar),
          ),
        );
        // Navigate to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showErrorDialog(
          localizations.settingsDeleteAccountErrorDialogTitle,
          e.message ?? 'An error occurred during deletion.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
          localizations.settingsDeleteAccountErrorDialogTitle,
          e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
      }
    }
  }

  Future<String?> _promptForPassword() async {
    final localizations = AppLocalizations.of(context)!;
    final TextEditingController passwordController = TextEditingController();
    final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();
    bool incorrectPassword = false;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(localizations.settingsReauthRequiredDialogTitle),
              content: Form(
                key: passwordFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(localizations.settingsReauthPasswordPrompt),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText:
                            localizations.settingsReauthCurrentPasswordLabel,
                        errorText:
                            incorrectPassword
                                ? localizations.settingsReauthIncorrectPassword
                                : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations
                              .settingsReauthPasswordValidationEmpty;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(localizations.cancelAction),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (passwordFormKey.currentState!.validate()) {
                      setDialogState(() {
                        incorrectPassword = false;
                      });
                      Navigator.of(context).pop(passwordController.text);
                    } else {
                      // Optionally set incorrectPassword state here if needed, though validation handles empty
                    }
                  },
                  child: Text(localizations.settingsReauthVerifyButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.cancelAction),
              ),
            ],
          ),
    );
  }

  // New method to confirm account deletion
  void _confirmAccountDeletion(BuildContext context) {
    // Implementation of _confirmAccountDeletion method
    // Call the main delete account handler which includes re-authentication
    _handleDeleteAccount();
  }

  // New method to build city input card
  Widget _buildCityInputCard(ThemeData theme) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_city_outlined),
        title: Text(localizations.settingsDefaultCityTile), // Use localization
        subtitle: Text(
          _cityController.text.isEmpty
              ? localizations
                  .settingsDefaultCityHint // Use localization
              : _cityController.text,
        ),
        trailing: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
        onTap: _showSetDefaultCityDialog,
      ),
    );
  }

  // New method to build notification settings card
  Widget _buildNotificationSettingsCard(ThemeData theme) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                localizations.settingsCourseRemindersSwitch,
              ), // Use localization
              value: _userProfile?.notificationsCourseRemindersEnabled ?? false,
              onChanged: (bool value) {
                if (mounted) {
                  setState(() {
                    _userProfile = _userProfile?.copyWith(
                      notificationsCourseRemindersEnabled: value,
                    );
                    _didSettingsChange = true;
                  });
                }
              },
            ),
            SwitchListTile(
              title: Text(
                localizations.settingsTaskRemindersSwitch,
              ), // Use localization
              value: _userProfile?.notificationsTaskRemindersEnabled ?? false,
              onChanged: (bool value) {
                if (mounted) {
                  setState(() {
                    _userProfile = _userProfile?.copyWith(
                      notificationsTaskRemindersEnabled: value,
                    );
                    _didSettingsChange = true;
                  });
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextFormField(
                controller: _leadTimeController,
                decoration: InputDecoration(
                  labelText:
                      localizations.settingsLeadTimeLabel, // Use localization
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations
                        .settingsLeadTimeValidationEmpty; // Use localization
                  }
                  final int? leadTime = int.tryParse(value);
                  if (leadTime == null) {
                    return localizations
                        .settingsLeadTimeValidationNumber; // Use localization
                  }
                  if (leadTime < 0) {
                    return localizations
                        .settingsLeadTimeValidationNegative; // Use localization
                  }
                  return null;
                },
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      _didSettingsChange = true;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method to build device settings card
  Widget _buildDeviceSettingsCard(ThemeData theme) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(
              localizations.settingsDeviceNotificationsTile,
            ), // Use localization
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              app_settings_package.AppSettings.openAppSettings(
                type: app_settings_package.AppSettingsType.notification,
              );
            },
          ),
        ],
      ),
    );
  }

  // Debounce method for city suggestions (Restored)
  void _onCityChangedDebounced(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted && query == _cityController.text) {
        _fetchCitySuggestions(query);
      }
    });
  }

  // Method to check auth provider (Restored)
  void _checkAuthProvider() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isGoogleUser = user.providerData.any(
          (info) => info.providerId == GoogleAuthProvider.PROVIDER_ID,
        );
      });
    }
  }

  // --- Start: Change Password Dialog ---
  Future<void> _showChangePasswordDialog() async {
    final localizations = AppLocalizations.of(context)!;
    if (_isGoogleUser) return; // Cannot change password for Google users

    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final GlobalKey<FormState> changePasswordFormKey = GlobalKey<FormState>();
    bool isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(localizations.settingsChangePasswordDialogTitle),
              content: Form(
                key: changePasswordFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText:
                              localizations.settingsReauthCurrentPasswordLabel,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations
                                .settingsReauthPasswordValidationEmpty;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText:
                              localizations.settingsChangePasswordNewLabel,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations
                                .settingsChangePasswordNewValidationEmpty;
                          }
                          if (value.length < 6) {
                            return localizations
                                .passwordValidationLength; // Reuse from login/register
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText:
                              localizations.settingsChangePasswordConfirmLabel,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations
                                .settingsChangePasswordConfirmValidationEmpty;
                          }
                          if (value != newPasswordController.text) {
                            return localizations
                                .settingsChangePasswordConfirmValidationMismatch;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text(localizations.cancelAction),
                ),
                ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            if (changePasswordFormKey.currentState!
                                .validate()) {
                              setDialogState(() => isLoading = true);
                              try {
                                final user = FirebaseAuth.instance.currentUser!;
                                final credential = EmailAuthProvider.credential(
                                  email: user.email!,
                                  password: currentPasswordController.text,
                                );

                                // Re-authenticate
                                await user.reauthenticateWithCredential(
                                  credential,
                                );

                                // Update password
                                await user.updatePassword(
                                  newPasswordController.text,
                                );

                                if (mounted) {
                                  Navigator.of(context).pop(); // Close dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        localizations
                                            .settingsChangePasswordSuccessSnackbar,
                                      ),
                                    ),
                                  );
                                }
                              } on FirebaseAuthException catch (e) {
                                if (mounted) {
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close dialog on error too
                                  _showErrorDialog(
                                    localizations
                                        .settingsChangePasswordFailedDialogTitle,
                                    e.message ?? 'An error occurred.',
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close dialog on error too
                                  _showErrorDialog(
                                    localizations
                                        .settingsChangePasswordFailedDialogTitle,
                                    e.toString(),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setDialogState(() => isLoading = false);
                                }
                              }
                            }
                          },
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            localizations.settingsChangePasswordUpdateButton,
                          ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // --- End: Change Password Dialog ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return PopScope(
      canPop: !_didSettingsChange,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (_didSettingsChange) {
          final result = await showDialog<PopResult>(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => AlertDialog(
                  title: Text(
                    localizations.editProfileUnsavedChangesTitle,
                  ), // Reuse from edit profile
                  content: Text(
                    localizations.editProfileUnsavedChangesContent,
                  ), // Reuse from edit profile
                  actions: [
                    TextButton(
                      onPressed:
                          () => Navigator.of(context).pop(PopResult.cancel),
                      child: Text(localizations.cancelAction),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      onPressed:
                          () => Navigator.of(context).pop(PopResult.discard),
                      child: Text(
                        localizations.editProfileDiscardButton,
                      ), // Reuse from edit profile
                    ),
                    TextButton(
                      onPressed:
                          () => Navigator.of(context).pop(PopResult.save),
                      child: Text(
                        localizations.editProfileSaveButton,
                      ), // Reuse from edit profile
                    ),
                  ],
                ),
          );

          if (!mounted) return;

          if (result == PopResult.save) {
            await _saveUpdatedUserProfile();
            if (mounted) {
              Navigator.pop(context);
            }
          } else if (result == PopResult.discard) {
            Navigator.pop(context);
          }
          // If result is cancel, do nothing
        } else {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.settingsTitle),
          actions: [
            if (_didSettingsChange && !_isLoadingProfile)
              IconButton(
                icon: const Icon(Icons.save_alt_outlined),
                tooltip:
                    localizations
                        .editProfileSaveTooltip, // Reuse from edit profile
                onPressed: _saveUpdatedUserProfile,
              ),
          ],
        ),
        body:
            _isLoadingProfile || _userProfile == null
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Profile Settings Section (e.g., Display Name if editable)
                      // Text(localizations.settingsSectionProfile, style: theme.textTheme.titleLarge),
                      // TextFormField(..._nameController...),
                      // const SizedBox(height: 16),
                      // _buildSectionTitle(localizations.settingsSectionProfile, Icons.person_outline), // Example helper
                      // Divider(height: 32),

                      // Weather City Setting
                      _buildSectionTitle(
                        localizations.settingsSectionProfile,
                        Icons.wb_sunny_outlined,
                      ), // Combine with profile or separate
                      _buildCityInputCard(theme),
                      const Divider(height: 32),

                      // Notification Settings
                      _buildSectionTitle(
                        localizations.settingsSectionNotifications,
                        Icons.notifications_active_outlined,
                      ),
                      _buildNotificationSettingsCard(theme),
                      const Divider(height: 32),

                      // Device/General Settings (Theme, Language)
                      _buildSectionTitle(
                        localizations.settingsSectionDevice,
                        Icons.settings_outlined,
                      ),
                      _buildLanguageSettingCard(
                        theme,
                        localizations,
                        localeProvider,
                      ),
                      _buildThemeSettingCard(
                        theme,
                        localizations,
                        themeProvider,
                      ),
                      _buildDeviceSettingsCard(theme),
                      const Divider(height: 32),

                      // Account Actions
                      _buildSectionTitle(
                        localizations.settingsSectionDeleteAccount,
                        Icons.account_circle_outlined,
                      ),
                      _buildAccountActionsCard(theme, localizations),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettingCard(
    ThemeData theme,
    AppLocalizations localizations,
    LocaleProvider localeProvider,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.language_outlined),
        title: Text(localizations.languageSettingTitle),
        trailing: DropdownButton<Locale>(
          value:
              localeProvider.locale ??
              Localizations.localeOf(context), // Default to current if null
          underline: const SizedBox.shrink(), // Remove underline
          icon: const Icon(Icons.arrow_drop_down),
          items:
              AppLocalizations.supportedLocales.map((Locale locale) {
                String langName =
                    locale.languageCode == 'en' ? 'English' : 'Türkçe';
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(langName),
                );
              }).toList(),
          onChanged: (Locale? newLocale) {
            if (newLocale != null) {
              localeProvider.setLocale(newLocale);
              setState(() {
                _didSettingsChange =
                    true; // Or handle differently if language isn't 'saved' via profile
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildThemeSettingCard(
    ThemeData theme,
    AppLocalizations localizations,
    ThemeProvider themeProvider,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.brightness_6_outlined),
        title: Text(localizations.themeSettingTitle),
        trailing: DropdownButton<ThemeMode>(
          value: themeProvider.themeMode,
          underline: const SizedBox.shrink(),
          icon: const Icon(Icons.arrow_drop_down),
          items: const [
            DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
            DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
            DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
          ],
          onChanged: (ThemeMode? newMode) {
            if (newMode != null) {
              themeProvider.setThemeMode(newMode);
              setState(() {
                _didSettingsChange = true; // Or handle differently
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildAccountActionsCard(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.secondary),
            title: Text(localizations.profileMenuLogout),
            onTap: _showLogoutConfirmationDialog,
          ),
          if (!_isGoogleUser)
            ListTile(
              leading: Icon(
                Icons.password_outlined,
                color: theme.colorScheme.secondary,
              ),
              title: Text(localizations.settingsChangePasswordTile),
              onTap: _showChangePasswordDialog,
            ),
          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: theme.colorScheme.error,
            ),
            title: Text(
              localizations.settingsDeleteAccountButton,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap:
                _isDeletingAccount
                    ? null
                    : () => _confirmAccountDeletion(context),
            trailing:
                _isDeletingAccount
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : null,
          ),
        ],
      ),
    );
  }
}
