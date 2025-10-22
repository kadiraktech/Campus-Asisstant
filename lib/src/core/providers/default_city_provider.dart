import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DefaultCityProvider extends ChangeNotifier {
  String? _defaultCity;
  static const String _kDefaultCityKey = 'default_city';

  String? get defaultCity => _defaultCity;

  // Method to load the city preference
  Future<void> loadCity() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _defaultCity = prefs.getString(_kDefaultCityKey);
    } catch (e) {
      debugPrint("Error loading default city preference: $e");
      _defaultCity = null; // Default to null on error
    }
    // No notifyListeners() here initially, let the first build handle it
    // or notify after explicitly setting it if needed elsewhere.
  }

  Future<void> _saveCityPreference(String? city) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (city != null) {
        await prefs.setString(_kDefaultCityKey, city);
      } else {
        await prefs.remove(_kDefaultCityKey); // Remove if city is null
      }
    } catch (e) {
      debugPrint("Error saving default city preference: $e");
    }
  }

  void updateDefaultCity(String? city) {
    if (_defaultCity != city) {
      _defaultCity = city;
      notifyListeners();
    }
  }
}
