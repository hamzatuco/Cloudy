import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const _keyHasOnboarded = 'has_onboarded';
  static const _keyFavoriteCity = 'favorite_city';

  static Future<bool> getHasOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasOnboarded) ?? false;
  }

  static Future<void> setHasOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasOnboarded, value);
  }

  static Future<String?> getFavoriteCity() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyFavoriteCity);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  static Future<void> setFavoriteCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFavoriteCity, city.trim());
  }
}

