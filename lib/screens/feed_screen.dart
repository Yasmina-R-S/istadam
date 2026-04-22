import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../db/database_helper.dart';
import '../models/post.dart';
import '../utils/preferences.dart';
import '../widgets/post_widget.dart';
import 'add_post_screen.dart';
import 'comments_screen.dart';
import 'login_screen.dart';

class FeedScreen extends StatefulWidget {
  // 🔊 7. Parámetros opcionales para mostrar el feed filtrado por usuario
  //        (se pasan desde ProfileScreen al pulsar un post del grid)
  final int? filterUserId;
  final int initialPostIndex;

  const FeedScreen({
    super.key,
    this.filterUserId,
    this.initialPostIndex = 0,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final ScrollController _scrollController = ScrollController();

  List<Post> posts = [];
  String username = '';

  // Clave global para forzar el scroll semántico al post inicial
  final List<GlobalKey> _postKeys = [];

  @override
  void initState() {
    super.initState();
    _loadUserAndPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndPosts() async {
    final user = await Preferences.getUser();
    if (user == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    username = user;
    final db = await dbHelper.database;

    // 🔊 7. Si filterUserId != null, mostramos solo los posts de ese usuario
    final List<Map<String, dynamic>> result;
    if (widget.filterUserId != null) {
      result = await db.query(
        'posts',
        where: 'userId = ?',
        whereArgs: [widget.filterUserId],
        orderBy: 'date DESC',
      );
    } else {
      final userId = await dbHelper.getUserId(username);
      result = await db.query(
        'posts',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );
    }

    final loadedPosts = result.map((e) => Post.fromMap(e)).toList();

    for (var post in loadedPosts) {
      post.commentCount = await dbHelper.getCommentCount(post.id!);
      post.username = username;
    }

    if (!mounted) return;
    setState(() {
      posts = loadedPosts;
      // Preparar una GlobalKey por post para poder hacer scroll al índice inicial
      _postKeys
        ..clear()
        ..addAll(List.generate(posts.length, (_) => GlobalKey()));
    });

    // 🔊 7. Anunciar que el feed está filtrado y hacer scroll al post pulsado
    if (widget.filterUserId != null) {
      SemanticsService.announce(
        'Feed filtrado por usuario. ${posts.length} publicaciones',
        TextDirection.ltr,
      );

      // Scroll al post inicial tras el primer frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(widget.initialPostIndex);
      });
    }
  }

  /// Hace scroll hasta el post en la posición [index] de la lista.
  void _scrollToIndex(int index) {
    if (index <= 0 || !_scrollController.hasClients) return;
    // Estimación de altura de cada PostWidget (~300dp aprox)
    const estimatedItemHeight = 300.0;
    _scrollController.animateTo(
      index * estimatedItemHeight,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
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
    // 🔊 7. Título diferente si estamos en el feed filtrado
    final appBarTitle = widget.filterUserId != null
        ? 'Publicaciones de $username'
        : 'Feed';

    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          label: widget.filterUserId != null
              ? 'Feed filtrado. Publicaciones de $username'
              : 'Feed de publicaciones',
          child: Text(appBarTitle),
        ),
        // 🔊 7. Botón atrás nativo — TalkBack lo lee como "Volver"
        leading: widget.filterUserId != null
            ? Semantics(
          button: true,
          label: 'Volver al perfil',
          onTapHint: 'Cerrar el feed filtrado y volver al perfil',
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        )
            : null,
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
        controller: _scrollController,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostWidget(
            key: _postKeys.isNotEmpty ? _postKeys[index] : null,
            post: post,
            username: username,
            onLike: () => _toggleLike(post),
            onComment: () => _openComments(post),
          );
        },
      ),

      // Ocultar el FAB cuando estamos en el feed filtrado (es de solo lectura)
      floatingActionButton: widget.filterUserId != null
          ? null
          : Semantics(
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