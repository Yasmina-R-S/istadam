import 'package:flutter/material.dart';
import '../utils/preferences.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  String language = 'Español';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final theme = await Preferences.getTheme();
    final lang = await Preferences.getLanguage();
    final notif = await Preferences.getNotifications();
    setState(() {
      isDarkMode = theme ?? false;
      language = lang ?? 'Español';
      notificationsEnabled = notif ?? true;
    });
  }

  void _toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
    Preferences.setTheme(value);
  }

  void _toggleNotifications(bool value) {
    setState(() {
      notificationsEnabled = value;
    });
    Preferences.setNotifications(value);
  }

  void _changeLanguage(String? value) {
    if (value == null) return;
    setState(() {
      language = value;
    });
    Preferences.setLanguage(value);
  }

  void _logout() async {
    await Preferences.clearUser();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Tema oscuro'),
              value: isDarkMode,
              onChanged: _toggleTheme,
            ),
            SwitchListTile(
              title: const Text('Notificaciones'),
              value: notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            const SizedBox(height: 20),
            const Text('Idioma'),
            DropdownButton<String>(
              value: language,
              items: const [
                DropdownMenuItem(value: 'Español', child: Text('Español')),
                DropdownMenuItem(value: 'English', child: Text('English')),
              ],
              onChanged: _changeLanguage,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Cerrar sesión'),
            )
          ],
        ),
      ),
    );
  }
}
