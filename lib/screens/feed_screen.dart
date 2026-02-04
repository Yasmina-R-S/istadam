import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/post.dart';
import '../utils/preferences.dart';
import 'add_post_screen.dart';
import 'comments_screen.dart';
import 'login_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Post> posts = [];
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUserAndPosts();
  }

  Future<void> _loadUserAndPosts() async {
    final user = await Preferences.getUser();
    if (user == null) {
      // No hay usuario, volver al login
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    username = user;

    final db = await dbHelper.database;
    final userId = await dbHelper.getUserId(username);

    final result = await db.query(
      'posts',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    posts = result.map((e) => Post.fromMap(e)).toList();

    // Actualizar número de comentarios de cada post
    for (var post in posts) {
      post.commentCount = await dbHelper.getCommentCount(post.id!);
    }

    setState(() {}); // refrescar UI
  }

  void _toggleLike(Post post) async {
    final db = await dbHelper.database;
    setState(() {
      post.likes = post.likes == 0 ? 1 : 0; // Solo tu usuario
    });
    await db.update('posts', {'likes': post.likes},
        where: 'id = ?', whereArgs: [post.id]);
  }

  void _openComments(Post post) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CommentsScreen(post: post)))
        .then((_) => _loadUserAndPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
      ),
      body: posts.isEmpty
          ? const Center(child: Text('No hay posts aún'))
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                        child: Icon(Icons.image, size: 50)),
                  ),
                  const SizedBox(height: 10),
                  Text('Usuario: $username',
                      style:
                      const TextStyle(fontWeight: FontWeight.bold)),
                  Text(post.description),
                  Text('Fecha: ${post.date.split(".")[0]}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                                post.likes > 0
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red),
                            onPressed: () => _toggleLike(post),
                          ),
                          Text('${post.likes} likes'),
                        ],
                      ),
                      TextButton(
                        onPressed: () => _openComments(post),
                        child: Text(
                            'Ver comentarios (${post.commentCount})'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddPostScreen()));
          _loadUserAndPosts(); // recargar feed después de añadir
        },
      ),
    );
  }
}
