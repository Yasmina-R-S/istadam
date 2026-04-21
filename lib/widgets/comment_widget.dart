import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../theme/app_colors.dart';

/// Widget accesible que representa un comentario.
/// Todo se lee como una única unidad semántica.
class CommentWidget extends StatelessWidget {
  final Comment comment;

  const CommentWidget({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    /// 🔊 Resumen completo para TalkBack
    final String commentSummary =
        'Comentario de ${comment.username}. '
        '${comment.text}. '
        'Publicado el ${comment.date.split('.')[0]}.';

    return Semantics(
      label: commentSummary,
      container: true,
      child: ListTile(
        title: ExcludeSemantics(
          child: Text(
            comment.username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        subtitle: ExcludeSemantics(
          child: Text(
            comment.text,
            style: const TextStyle(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        trailing: ExcludeSemantics(
          child: Text(
            comment.date.split('.')[0],
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}