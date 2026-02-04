import 'package:flutter/material.dart';
import '../utils/preferences.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import 'feed_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkRememberedUser();
  }

  Future<void> _checkRememberedUser() async {
    final username = await Preferences.getUser();
    if (username != null) {
      // Ir directo al feed si ya había sesión
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => FeedScreen()));
    }
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rellena todos los campos')));
      return;
    }

    final dbHelper = DatabaseHelper();
    final users = await dbHelper.getUsers();

    // Buscar usuario en la base de datos
    final user = users.firstWhere(
          (u) => u.username == username && u.password == password,
      orElse: () => User(id: -1, username: '', password: ''),
    );

    if (user.id == -1) {
      // Usuario no existe, creamos uno nuevo automáticamente
      final newUser = User(username: username, password: password);
      await dbHelper.insertUser(newUser);
    }

    // Guardar en SharedPreferences si recordamos usuario
    if (_rememberMe) {
      await Preferences.saveUser(username);
    }

    // Ir al feed
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => FeedScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                    value: _rememberMe,
                    onChanged: (val) {
                      setState(() {
                        _rememberMe = val ?? false;
                      });
                    }),
                const Text('Recordar usuario')
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _login, child: const Text('Iniciar sesión')),
          ],
        ),
      ),
    );
  }
}
