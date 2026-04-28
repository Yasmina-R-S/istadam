import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../theme/app_colors.dart';

/// Widget accessible que representa un comentari.
/// Usa MergeSemantics per agrupar autor + text + temps en un sol anunci. ✅
class CommentWidget extends StatelessWidget {
  final Comment comment;

  const CommentWidget({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: ListTile(
        // Avatar decoratiu — exclòs de TalkBack ✅
        leading: ExcludeSemantics(
          child: CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              comment.username.isNotEmpty
                  ? comment.username[0].toUpperCase()
                  : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        title: Text(
          comment.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          comment.text,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        trailing: Text(
          comment.date.split('.')[0],
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ),
    );
  }
}
