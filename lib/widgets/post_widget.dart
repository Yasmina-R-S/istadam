import 'package:flutter/material.dart';
import '../models/post.dart';
import '../theme/app_colors.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  final String username;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const PostWidget({
    super.key,
    required this.post,
    required this.username,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    final bool liked = post.likes > 0;

    /// Resumen accesible completo para TalkBack
    final String postSummary =
        'Publicación de $username. '
        'Descripción: ${post.description}. '
        '${post.likes} me gusta. '
        '${post.commentCount} comentarios. '
        'Publicado el ${post.date.split('.')[0]}.';

    return Semantics(
      label: postSummary,
      container: true,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // CABECERA — decorativa
              ExcludeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      post.date.split('.')[0],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8.0),

              // IMAGEN DEL POST con ALT TEXT
              Semantics(
                image: true,
                label: 'Imagen del post. ${post.description}',
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(
                    child: ExcludeSemantics(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8.0),

              // DESCRIPCIÓN — decorativa (ya incluida en el resumen)
              ExcludeSemantics(
                child: Text(
                  post.description,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),

              const SizedBox(height: 8.0),

              // BOTONES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // 👍 LIKE ACCESIBLE
                  Semantics(
                    button: true,
                    toggled: liked,
                    label: liked ? 'Quitar me gusta' : 'Dar me gusta',
                    value: '${post.likes} me gusta',
                    onTapHint: liked
                        ? 'Quitar me gusta a esta publicación'
                        : 'Dar me gusta a esta publicación',
                    child: InkWell(
                      onTap: onLike,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            ExcludeSemantics(
                              child: Icon(
                                liked ? Icons.favorite : Icons.favorite_border,
                                color: liked ? AppColors.primary : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 4),

                            Semantics(
                              liveRegion: true,
                              child: ExcludeSemantics(
                                child: Text(
                                  '${post.likes} likes',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 💬 COMENTARIOS ACCESIBLE
                  Semantics(
                    button: true,
                    label: 'Ver comentarios. ${post.commentCount} comentarios',
                    onTapHint: 'Abrir pantalla de comentarios',
                    child: InkWell(
                      onTap: onComment,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            const ExcludeSemantics(
                              child: Icon(
                                Icons.comment,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            ExcludeSemantics(
                              child: Text(
                                'Comentarios (${post.commentCount})',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}