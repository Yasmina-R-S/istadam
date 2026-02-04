import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const InstaDAMApp());
}
class InstaDAMApp extends StatelessWidget {
  const InstaDAMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InstaDAM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const LoginScreen(),
    );
  }
}