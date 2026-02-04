import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const String keyRememberUser = 'remember_user';
  static const String keyUsername = 'username';
  static const String keyTheme = 'isDark';
  static const String keyLanguage = 'language';
  static const String keyNotifications = 'notifications';

  // Guardar usuario (login)
  static Future<void> saveUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUsername, username);
    await prefs.setBool(keyRememberUser, true);
  }

  // Leer usuario
  static Future<String?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(keyRememberUser) ?? false;
    if (remember) {
      return prefs.getString(keyUsername);
    }
    return null;
  }

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyUsername);
    await prefs.setBool(keyRememberUser, false);
  }

  // ---------------------------
  // Tema
  static Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyTheme, isDark);
  }

  static Future<bool?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyTheme);
  }

  // Idioma
  static Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLanguage, lang);
  }

  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLanguage);
  }

  // Notificaciones (simulación)
  static Future<void> setNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotifications, enabled);
  }

  static Future<bool?> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyNotifications);
  }
}
