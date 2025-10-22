import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  static const String _selectedLocaleKey = 'selected_locale';

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_selectedLocaleKey);
    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else {
      // If no preference is saved, leave _locale as null.
      // MaterialApp will then use its default behavior to match the system locale.
      _locale = null;
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLocaleKey, locale.languageCode);
    notifyListeners();
  }

  void clearLocale() async {
    _locale = null; // Or set to a default, e.g., Locale('en')
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedLocaleKey);
    notifyListeners();
  }
}
