import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/preferences.dart';

void main() {
  runApp(const InstaDAMApp());
}

class InstaDAMApp extends StatefulWidget {
  const InstaDAMApp({super.key});

  static _InstaDAMAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_InstaDAMAppState>();

  @override
  State<InstaDAMApp> createState() => _InstaDAMAppState();
}

class _InstaDAMAppState extends State<InstaDAMApp> {
  String get currentLanguage => language;
  bool isDarkMode = false;
  String language = 'Español';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    isDarkMode = await Preferences.getTheme() ?? false;
    language = await Preferences.getLanguage() ?? 'Español';
    setState(() {});
  }

  void setDarkMode(bool value) async {
    await Preferences.setTheme(value);
    setState(() => isDarkMode = value);
  }

  void setLanguage(String value) async {
    await Preferences.setLanguage(value);
    setState(() => language = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InstaDAM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B7FFF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
