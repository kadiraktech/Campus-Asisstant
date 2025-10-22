import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Uncommented for registration logic
import 'package:projectv1/src/features/user_profile/domain/services/user_profile_service.dart'; // Import UserProfileService
import 'package:projectv1/generated/l10n/app_localizations.dart'; // Import localizations

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController =
      TextEditingController(); // New controller for display name
  // final TextEditingController _confirmPasswordController = TextEditingController(); // Optional: for password confirmation

  bool _isLoading = false; // To show a loading indicator
  // bool _isPasswordVisible = false; // To toggle password visibility

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final localizations =
          AppLocalizations.of(context)!; // Get localizations instance
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // Kullanıcı başarıyla oluşturulduktan sonra Firestore\'a profil kaydı
        if (userCredential.user != null) {
          // Update Firebase Auth display name
          await userCredential.user!.updateDisplayName(
            _displayNameController.text.trim(),
          );

          UserProfileService userProfileService = UserProfileService();
          // Pass the display name from the form to the service
          await userProfileService.createInitialUserProfile(
            userCredential.user!,
            displayName: _displayNameController.text.trim(),
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.registrationSuccessful,
              ), // Use localization key
            ),
          );
          Navigator.of(context).pop(); // Go back to LoginScreen
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage =
            localizations.registrationErrorDefault; // Use localization key
        if (e.code == 'weak-password') {
          errorMessage =
              localizations
                  .registrationErrorWeakPassword; // Use localization key
        } else if (e.code == 'email-already-in-use') {
          errorMessage =
              localizations.registrationErrorEmailInUse; // Use localization key
        } else {
          // Use the more generic Firebase error key if available
          errorMessage = localizations.registrationErrorFirebase(
            e.message ?? localizations.registrationErrorDefault,
          ); // Use localization key with placeholder
        }
        // print('Registration Error: ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        // print('Unexpected Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.registrationErrorUnexpected,
              ), // Use localization key
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
      if (mounted) {
        // Ensure widget is still mounted before calling setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose(); // Dispose the new controller
    // _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations =
        AppLocalizations.of(context)!; // Get localizations instance
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.registerTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ), // Use localization key
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      localizations.createAccountPrompt, // Use localization key
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText:
                            localizations.emailLabel, // Re-use from login
                        prefixIcon: Icon(
                          Icons.email,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.18),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations
                              .registerEmailValidationEmpty; // Use localization key
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return localizations
                              .registerEmailValidationInvalid; // Use localization key
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _displayNameController,
                      decoration: InputDecoration(
                        labelText:
                            localizations.displayNameLabel, // localization key
                        prefixIcon: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.25),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.18),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations
                              .displayNameValidationEmpty; // localization key
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText:
                            localizations.passwordLabel, // Re-use from login
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.18),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations
                              .registerPasswordValidationEmpty; // Use localization key
                        }
                        if (value.length < 6) {
                          return localizations
                              .registerPasswordValidationLength; // Use localization key
                        }
                        return null;
                      },
                    ),
                    // const SizedBox(height: 20),
                    // TextFormField(
                    //   controller: _confirmPasswordController,
                    //   decoration: const InputDecoration(
                    //     labelText: 'Confirm Password',
                    //     border: OutlineInputBorder(),
                    //     prefixIcon: Icon(Icons.lock_outline),
                    //   ),
                    //   obscureText: true,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Please confirm your password';
                    //     }
                    //     if (value != _passwordController.text) {
                    //       return 'Passwords do not match';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            localizations
                                .registerButtonRegister, // Use localization key
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                    const SizedBox(height: 16),
                    Center(
                      child: Wrap(
                        // Use Wrap for better handling on small screens
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        spacing: 4.0, // Adjust spacing as needed
                        runSpacing: 0,
                        children: <Widget>[
                          Text(
                            localizations.alreadyHaveAccountPrompt,
                          ), // Use localization key
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed:
                                () => Navigator.of(context).pop(), // Go back
                            child: Text(
                              localizations
                                  .loginButtonFromRegister, // Use localization key
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
