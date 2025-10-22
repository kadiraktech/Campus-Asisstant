import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectv1/src/features/user_profile/presentation/screens/edit_profile_screen.dart';
import 'package:projectv1/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:projectv1/src/features/auth/presentation/screens/login_screen.dart';
import 'package:projectv1/src/features/user_profile/domain/models/user_profile_model.dart';
import 'package:projectv1/src/features/user_profile/domain/services/user_profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:projectv1/generated/l10n/app_localizations.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final UserProfileService _userProfileService = UserProfileService();
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _settingsChanged = false;
  String? _localProfileImagePath;

  static const String _kProfileImagePathKey = 'profile_image_path';

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      _fetchUserProfile();
      _loadLocalProfileImagePath();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUserProfile() async {
    if (_currentUser == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      _userProfile = await _userProfileService.getUserProfile(_currentUser.uid);
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.profileLoadError(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadLocalProfileImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _localProfileImagePath = prefs.getString(_kProfileImagePathKey);
        });
      }
    } catch (e) {
      if (mounted) {
        // Potentially set loading false here too in case of error
        // setState(() => _isLoading = false);
      }
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    List<String> names = name.split(' ');
    String initials = '';
    if (names.isNotEmpty) {
      initials += names[0][0];
      if (names.length > 1) {
        initials += names[names.length - 1][0];
      }
    }
    return initials.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.profileTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _settingsChanged);
            },
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.profileTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _settingsChanged);
            },
          ),
        ),
        body: Center(child: Text(localizations.profileNotLoggedIn)),
      );
    }

    String displayName =
        _userProfile?.displayName ?? _currentUser.displayName ?? 'User';
    String email = _currentUser.email ?? 'No email';
    String initials = _getInitials(displayName);

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _settingsChanged);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.profileTitle),
          elevation: 0.5,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          iconTheme: IconThemeData(color: theme.colorScheme.primary),
        ),
        body: RefreshIndicator(
          onRefresh: _fetchUserProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 16.0,
                  ),
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        backgroundImage:
                            _localProfileImagePath != null
                                ? FileImage(File(_localProfileImagePath!))
                                : null,
                        child:
                            _localProfileImagePath == null &&
                                    _userProfile != null
                                ? Text(
                                  _userProfile!.displayName.isNotEmpty
                                      ? _userProfile!.displayName[0]
                                          .toUpperCase()
                                      : '?',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineLarge?.copyWith(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                )
                                : _localProfileImagePath == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        displayName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_userProfile?.department != null &&
                          _userProfile!.department!.isNotEmpty) ...[
                        const SizedBox(height: 8.0),
                        Text(
                          localizations.profileDepartmentLabel(
                            _userProfile!.department!,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (_userProfile?.studentId != null &&
                          _userProfile!.studentId!.isNotEmpty) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          localizations.profileStudentIdLabel(
                            _userProfile!.studentId!,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      // Add Phone Number display
                      if (_userProfile?.phone != null &&
                          _userProfile!.phone!.isNotEmpty) ...[
                        const SizedBox(height: 4.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _userProfile!.phone!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24.0),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(localizations.profileEditButton),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          ).then((_) {
                            _fetchUserProfile();
                            _loadLocalProfileImagePath();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildProfileMenuList(context, theme, localizations),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenuList(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildMenuCard(
            theme,
            icon: Icons.settings_outlined,
            text: localizations.profileMenuSettings,
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              if (result == true) {
                setState(() {
                  _settingsChanged = true;
                });
                _fetchUserProfile();
              }
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: Text(localizations.profileMenuLogout),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final confirmLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(localizations.logoutConfirmTitle),
                      content: Text(localizations.logoutConfirmContent),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(localizations.cancelAction),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(localizations.logoutAction),
                        ),
                      ],
                    );
                  },
                );
                if (confirmLogout == true) {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    ThemeData theme, {
    required IconData icon,
    required String text,
    required VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0.2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary, size: 24),
        title: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
