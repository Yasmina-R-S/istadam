import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../utils/preferences.dart';
import '../widgets/comment_widget.dart';

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
    _loadData();
  }

  // Cargar usuario + comentarios
  Future<void> _loadData() async {
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

  // Añadir comentario
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
    await _loadData();

    // SnackBar accesible
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Semantics(
            liveRegion: true,
            label: 'Comentario añadido',
            child: const Text('Comentario añadido'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentarios'),
      ),

      body: Column(
        children: [
          // LISTA DE COMENTARIOS
          Expanded(
            child: comments.isEmpty
                ? Center(
              child: Semantics(
                label: 'No hay comentarios todavía',
                child: const Text('No hay comentarios todavía'),
              ),
            )
                : ListView.builder(
              reverse: true,
              itemCount: comments.length,
              itemBuilder: (context, index) =>
                  CommentWidget(comment: comments[index]),
            ),
          ),

          // CAJA PARA ESCRIBIR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                // Campo accesible
                Expanded(
                  child: Semantics(
                    label: 'Escribir un comentario',
                    textField: true,
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un comentario…',
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // Botón enviar accesible
                Semantics(
                  button: true,
                  label: 'Enviar comentario',
                  onTapHint: 'Publicar este comentario',
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _addComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}