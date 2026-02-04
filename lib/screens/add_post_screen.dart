import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/post.dart';
import '../utils/preferences.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String username = '';
  int userId = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await Preferences.getUser();
    if (user != null) {
      username = user;
      final db = DatabaseHelper();
      userId = await db.getUserId(username);
      setState(() {});
    }
  }

  void _savePost() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Escribe una descripción')));
      return;
    }

    final newPost = Post(
      userId: userId,
      image: '', // Placeholder, luego podemos usar picker de imágenes
      description: description,
      date: DateTime.now().toString(),
      likes: 0,
    );

    final db = DatabaseHelper();
    await db.insertPost(newPost);

    Navigator.pop(context); // Volvemos al feed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePost,
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}
