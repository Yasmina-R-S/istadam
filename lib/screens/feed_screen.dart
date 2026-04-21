import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/post.dart';
import '../utils/preferences.dart';
import '../widgets/post_widget.dart';
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    username = user;

    final db = await dbHelper.database;
    final userId = await dbHelper.getUserId(username);

    final result = await db.query(
      'posts',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    posts = result.map((e) => Post.fromMap(e)).toList();

    for (var post in posts) {
      post.commentCount = await dbHelper.getCommentCount(post.id!);
      post.username = username;
    }

    setState(() {});
  }

  void _toggleLike(Post post) async {
    final db = await dbHelper.database;
    final bool wasLiked = post.likes > 0;

    setState(() {
      post.likes = wasLiked ? 0 : 1;
    });

    await db.update(
      'posts',
      {'likes': post.likes},
      where: 'id = ?',
      whereArgs: [post.id],
    );

    final mensaje = wasLiked ? 'Has quitado el me gusta' : 'Has dado me gusta';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(
            liveRegion: true,
            child: Text(mensaje),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openComments(Post post) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CommentsScreen(post: post)),
    );

    _loadUserAndPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: 'Feed de publicaciones',
          child: const Text('Feed'),
        ),
      ),

      body: posts.isEmpty
          ? Center(
        child: Semantics(
          label: 'Todavía no hay publicaciones',
          child: const Text(
            'No hay publicaciones todavía',
            style: TextStyle(fontSize: 16),
          ),
        ),
      )
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostWidget(
            post: post,
            username: username,
            onLike: () => _toggleLike(post),
            onComment: () => _openComments(post),
          );
        },
      ),

      floatingActionButton: Semantics(
        label: 'Crear nueva publicación',
        button: true,
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPostScreen()),
            );
            _loadUserAndPosts();
          },
          child: const ExcludeSemantics(child: Icon(Icons.add)),
        ),
      ),
    );
  }
}