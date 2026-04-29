import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const InstaDAMApp());
}

class InstaDAMApp extends StatefulWidget {
  const InstaDAMApp({super.key});

  // Permet canviar el tema des de qualsevol pantalla fent:
  // InstaDAMApp.of(context)?.setDarkMode(value)
  static _InstaDAMAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_InstaDAMAppState>();

  @override
  State<InstaDAMApp> createState() => _InstaDAMAppState();
}

class _InstaDAMAppState extends State<InstaDAMApp> {
  bool isDarkMode = false;

  void setDarkMode(bool value) {
    setState(() => isDarkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InstaDAM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}