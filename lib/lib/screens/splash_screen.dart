import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🔹 Logo (TalkBack dirá "InstaDAM")
            Semantics(
              label: 'InstaDAM',
              child: const Text(
                'InstaDAM',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Estado de carga (TalkBack dirá "Cargando aplicación")
            Semantics(
              label: 'Cargando aplicación',
              liveRegion: true,
              child: const CircularProgressIndicator(),
            ),

            const SizedBox(height: 10),

            const Text('Cargando aplicación...'),
          ],
        ),
      ),
    );
  }
}