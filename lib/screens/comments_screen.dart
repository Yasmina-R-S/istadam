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
  // FocusNode per gestionar l'ordre de focus ✅
  final FocusNode _textFieldFocus = FocusNode();

  List<Comment> comments = [];
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

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
    // Tornar el focus al camp de text per facilitar l'ús amb TalkBack ✅
    _textFieldFocus.requestFocus();
    await _loadData();

    // SnackBar amb liveRegion per anunciar immediatament el nou comentari ✅
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Semantics(
            liveRegion: true,
            label: 'Comentario añadido correctamente',
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

          // LLISTA DE COMENTARIS
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

          // FORMULARI D'AFEGIR COMENTARI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [

                // Camp amb etiqueta VISIBLE (labelText, no només placeholder) ✅
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _textFieldFocus,
                    decoration: const InputDecoration(
                      labelText: 'Escribe un comentario',   // etiqueta visible ✅
                      hintText: 'Escribe aquí…',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _addComment(),
                  ),
                ),

                const SizedBox(width: 6),

                // Botó Enviar amb Semantics label clar ✅
                Semantics(
                  button: true,
                  label: 'Enviar comentari',
                  onTapHint: 'Publicar aquest comentari',
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
