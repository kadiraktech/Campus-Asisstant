import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme
  static const String _kThemeModeKey = 'theme_mode';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? themePreference = prefs.getString(_kThemeModeKey);
      if (themePreference != null) {
        if (themePreference == ThemeMode.light.toString()) {
          _themeMode = ThemeMode.light;
        } else if (themePreference == ThemeMode.dark.toString()) {
          _themeMode = ThemeMode.dark;
        } else {
          _themeMode = ThemeMode.system;
        }
      }
    } catch (e) {
      debugPrint("Error loading theme preference: $e");
      _themeMode = ThemeMode.system; // Default to system on error
    }
    notifyListeners();
  }

  Future<void> _saveThemePreference(ThemeMode themeMode) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemeModeKey, themeMode.toString());
    } catch (e) {
      debugPrint("Error saving theme preference: $e");
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _saveThemePreference(mode);
      notifyListeners();
    }
  }

  // Optional: A simple toggle function if you only want to switch between light/dark
  // and not explicitly set system.
  void toggleTheme(BuildContext context) {
    ThemeMode newMode;
    if (_themeMode == ThemeMode.system) {
      // If current mode is system, check the actual platform brightness
      final brightness = MediaQuery.of(context).platformBrightness;
      newMode =
          brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    } else {
      // Otherwise, just toggle between light and dark
      newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    }
    setThemeMode(newMode);
  }
}

final TextTheme appTextTheme = TextTheme(
  headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold),
  titleSmall: GoogleFonts.poppins(),
  bodyMedium: GoogleFonts.poppins(),
  bodySmall: GoogleFonts.poppins(),
);

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  textTheme: appTextTheme,
  useMaterial3: true,
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  textTheme: appTextTheme,
  useMaterial3: true,
);
