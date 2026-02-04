import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../utils/preferences.dart';

class CommentsScreen extends StatefulWidget {
  final Post post;
  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController _commentController = TextEditingController();
  List<Comment> comments = [];
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final user = await Preferences.getUser();
    if (user != null) username = user;

    final db = await dbHelper.database;
    final result = await db.query(
      'comments',
      where: 'postId = ?',
      whereArgs: [widget.post.id],
      orderBy: 'id DESC',
    );

    setState(() {
      comments = result.map((e) => Comment.fromMap(e)).toList();
    });
  }

  void _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final newComment = Comment(
      postId: widget.post.id!,
      username: username,
      text: text,
      date: DateTime.now().toString(),
    );

    await dbHelper.insertComment(newComment);
    _commentController.clear();
    _loadComments(); // Actualizar lista inmediatamente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comentarios')),
      body: Column(
        children: [
          Expanded(
            child: comments.isEmpty
                ? const Center(child: Text('No hay comentarios aún'))
                : ListView.builder(
              reverse: true,
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return ListTile(
                  title: Text(comment.username),
                  subtitle: Text(comment.text),
                  trailing: Text(
                    comment.date.split('.')[0], // Fecha simplificada
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                        hintText: 'Escribe un comentario...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

