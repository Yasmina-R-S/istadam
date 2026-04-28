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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // CABECERA — decorativa, no la llegeix TalkBack
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

            // IMAGEN DEL POST amb alt text accessible
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

            // DESCRIPCIÓ — decorativa (ja inclosa a la imatge)
            ExcludeSemantics(
              child: Text(
                post.description,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),

            const SizedBox(height: 8.0),

            // BOTONS D'INTERACCIÓ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // ❤️ BOTÓ LIKE — label + toggled + onTapHint + icona canvia + liveRegion
                Semantics(
                  button: true,
                  toggled: liked,
                  label: liked
                      ? 'Me gusta activo. ${post.likes} me gusta'
                      : 'Me gusta. ${post.likes} me gusta',
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
                          // Icona diferent segons estat (no només color) ✅
                          ExcludeSemantics(
                            child: Icon(
                              liked ? Icons.favorite : Icons.favorite_border,
                              color: liked ? AppColors.primary : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // liveRegion al text per anunciar el canvi ✅
                          Semantics(
                            liveRegion: true,
                            label: '${post.likes} me gusta',
                            child: Text(
                              '${post.likes} likes',
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

                // 💬 BOTÓ COMENTARIS
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
    );
  }
}
