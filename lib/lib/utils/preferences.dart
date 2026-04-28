import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  // ---------- USER ----------
  static const String _userKey = 'username';
  static const String _rememberKey = 'remember';

  static Future<void> saveUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, username);
    await prefs.setBool(_rememberKey, true);
  }

  static Future<String?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberKey) ?? false;
    if (remember) {
      return prefs.getString(_userKey);
    }
    return null;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_rememberKey, false);
  }

  // ---------- THEME ----------
  static const String _themeKey = 'dark_theme';

  static Future<void> setTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  static Future<bool?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey);
  }

  // ---------- LANGUAGE ----------
  static const String _languageKey = 'language';

  static Future<void> setLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
  }

  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  // ---------- NOTIFICATIONS ----------
  static const String _notifKey = 'notifications';

  static Future<void> setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, value);
  }

  static Future<bool?> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notifKey);
  }
}