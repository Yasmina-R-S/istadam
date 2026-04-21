import 'package:flutter/material.dart';
import '../models/post.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Text(
          'Perfil del usuario',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// Feed filtrado
class FeedScreenFiltered extends StatelessWidget {
  final List<Post> posts;
  final String username;

  const FeedScreenFiltered({
    super.key,
    required this.posts,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$username - Posts'),
        backgroundColor: Colors.red,
      ),
      body: posts.isEmpty
          ? const Center(child: Text('No hay posts'))
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
                      child: Icon(Icons.image, size: 50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Usuario: $username',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(post.description),
                  Text(
                    'Fecha: ${post.date.split(".")[0]}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red),
                      const SizedBox(width: 5),
                      Text('${post.likes} likes'),
                    ],
                  ),
                  Text('Comentarios: ${post.commentCount}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}