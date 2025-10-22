import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In
import 'package:icons_plus/icons_plus.dart'; // Import icons_plus
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:projectv1/src/features/auth/presentation/screens/registration_screen.dart';
import 'package:projectv1/src/features/auth/presentation/screens/forgot_password_screen.dart'; // Import ForgotPasswordScreen
import 'package:projectv1/src/features/home/presentation/screens/home_screen.dart'; // Import HomeScreen
// import 'package:projectv1/src/features/home/presentation/screens/home_screen.dart'; // Placeholder for HomeScreen
// Import UserProfileService to create initial profile
import 'package:projectv1/src/features/user_profile/domain/services/user_profile_service.dart';
import 'package:projectv1/generated/l10n/app_localizations.dart'; // Import localizations

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoadingEmail = false;
  bool _isLoadingGoogle = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false; // State for Remember Me checkbox

  // Instantiate UserProfileService
  final UserProfileService _userProfileService = UserProfileService();

  static const String _kRememberMeKey = 'remember_me';
  static const String _kEmailKey = 'saved_email';

  @override
  void initState() {
    super.initState();
    _loadUserEmailPreference();
  }

  Future<void> _loadUserEmailPreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool rememberMe = prefs.getBool(_kRememberMeKey) ?? false;
      if (rememberMe) {
        final String? savedEmail = prefs.getString(_kEmailKey);
        if (savedEmail != null) {
          _emailController.text = savedEmail;
        }
        setState(() {
          _rememberMe = true;
        });
      }
    } catch (e) {
      // Handle error, e.g., log it or show a generic message
      debugPrint("Error loading preferences: $e");
    }
  }

  Future<void> _saveUserEmailPreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setBool(_kRememberMeKey, true);
        await prefs.setString(_kEmailKey, _emailController.text.trim());
      } else {
        await prefs.setBool(_kRememberMeKey, false);
        await prefs.remove(_kEmailKey);
      }
    } catch (e) {
      debugPrint("Error saving preferences: $e");
    }
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoadingEmail = true;
      });
      final localizations = AppLocalizations.of(context)!; // Get localizations
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
        if (mounted && userCredential.user != null) {
          await _saveUserEmailPreference(); // Save preference on successful login
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        // Use localized error messages
        String errorMessage = localizations.loginErrorGeneric;
        if (e.code == 'user-not-found') {
          errorMessage = localizations.loginErrorUserNotFound;
        } else if (e.code == 'wrong-password') {
          errorMessage = localizations.loginErrorWrongPassword;
        } else if (e.code == 'invalid-credential') {
          errorMessage = localizations.loginErrorInvalidCredentials;
        } else {
          // Fallback using the code or generic message
          errorMessage = localizations.loginFailed(e.message ?? e.code);
        }
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.loginErrorUnexpected,
              ), // Use localization key
            ),
          );
        }
      }
      if (mounted) {
        setState(() {
          _isLoadingEmail = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoadingGoogle = true;
    });
    final localizations = AppLocalizations.of(context)!; // Get localizations
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoadingGoogle = false);
        // Optionally show login cancelled message?
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.loginCancelled)));
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // --- START: Create initial profile after Google Sign-In ---
      if (mounted && userCredential.user != null) {
        try {
          await _userProfileService.createInitialUserProfile(
            userCredential.user!,
          );
        } catch (profileError) {
          debugPrint(
            "Error creating/updating Firestore profile after Google Sign-In: $profileError",
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  localizations.googleSignInProfileError,
                ), // Use localization key
              ),
            );
          }
        }
        // --- END: Create initial profile ---

        // Proceed with navigation
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Use localized error messages
      String errorMessage = localizations.googleSignInErrorGeneric;
      if (e.code == 'cancelled' || e.code == 'popup_closed_by_user') {
        errorMessage = localizations.loginCancelled;
      } else {
        errorMessage =
            localizations
                .googleSignInErrorGeneric; // Keep generic for other Firebase errors
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.googleSignInErrorUnexpected,
            ), // Use localization key
          ),
        );
      }
    }
    if (mounted) {
      setState(() {
        _isLoadingGoogle = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final localizations =
        AppLocalizations.of(context)!; // Get localizations instance

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.loginTitle), // Use localization key
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double maxCardWidth = 400;
                double availableWidth = constraints.maxWidth;
                double cardWidth =
                    availableWidth < maxCardWidth + 32
                        ? availableWidth - 8
                        : maxCardWidth;
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: cardWidth),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: cardWidth < 350 ? 12.0 : 24.0,
                        vertical: cardWidth < 350 ? 16.0 : 28.0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 100,
                              ),
                            ),
                            Text(
                              localizations
                                  .loginWelcomeBack, // Use localization key
                              textAlign: TextAlign.center,
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localizations
                                  .loginManageSchedule, // Use localization key
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText:
                                    localizations
                                        .emailLabel, // Use localization key
                                hintText:
                                    localizations
                                        .emailHint, // Use localization key
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: colorScheme.surface,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return localizations
                                      .emailValidationEmpty; // Use localization key
                                }
                                if (!value.contains('@') ||
                                    !value.contains('.')) {
                                  return localizations
                                      .emailValidationInvalid; // Use localization key
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText:
                                    localizations
                                        .passwordLabel, // Use localization key
                                hintText:
                                    localizations
                                        .passwordHint, // Use localization key
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                  onPressed:
                                      () => setState(
                                        () =>
                                            _isPasswordVisible =
                                                !_isPasswordVisible,
                                      ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: colorScheme.surface,
                              ),
                              obscureText: !_isPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return localizations
                                      .passwordValidationEmpty; // Use localization key
                                }
                                if (value.length < 6) {
                                  return localizations
                                      .passwordValidationLength; // Use localization key
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        visualDensity: VisualDensity.compact,
                                        value: _rememberMe,
                                        onChanged: (bool? value) {
                                          if (value != null) {
                                            setState(() {
                                              _rememberMe = value;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Text(
                                      localizations
                                          .loginRememberMe, // Use localization key
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    localizations
                                        .loginForgotPassword, // Use localization key
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _isLoadingEmail
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : ElevatedButton(
                                  onPressed: _loginUser,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    textStyle:
                                        Theme.of(context).textTheme.labelLarge,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  child: Text(
                                    localizations
                                        .loginButton, // Use localization key
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                            const SizedBox(height: 16),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Divider(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    localizations
                                        .loginOrSeparator, // Use localization key
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _isLoadingGoogle
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : ElevatedButton.icon(
                                  icon: Icon(
                                    Bootstrap.google,
                                    size: 20.0,
                                    color:
                                        colorScheme.brightness ==
                                                Brightness.light
                                            ? Colors.black87
                                            : Colors.white,
                                  ),
                                  label: Text(
                                    localizations
                                        .loginWithGoogleButton, // Use localization key
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          colorScheme.brightness ==
                                                  Brightness.light
                                              ? Colors.black87
                                              : Colors.white,
                                    ),
                                  ),
                                  onPressed: _signInWithGoogle,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    foregroundColor:
                                        colorScheme.brightness ==
                                                Brightness.light
                                            ? Colors.black87
                                            : Colors.white,
                                    backgroundColor:
                                        colorScheme.brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : colorScheme
                                                .surfaceContainerHighest,
                                    side: BorderSide(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                    elevation: 1,
                                  ),
                                ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  localizations
                                      .noAccountPrompt, // Use localization key
                                  style: textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const RegistrationScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    localizations
                                        .registerButton, // Use localization key
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
