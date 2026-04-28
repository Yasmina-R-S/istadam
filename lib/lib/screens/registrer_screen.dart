import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final DatabaseHelper db = DatabaseHelper();

  Future<void> _register() async {
    final username = _userController.text.trim();
    final password = _passController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rellena todos los campos')),
      );
      return;
    }

    final exists = await db.getUserId(username);
    if (!mounted) return;

    if (exists != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El usuario ya existe')),
      );
      return;
    }

    await db.insertUser(
      User(username: username, password: password),
    );
    if (!mounted) return;

    Navigator.pop(context); // ← vuelve al LOGIN
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        automaticallyImplyLeading: true, // ✅ botón atrás
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
