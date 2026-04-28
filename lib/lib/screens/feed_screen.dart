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
  /// Si != null, el feed mostra només els posts d'aquest usuari (feed filtrat).
  final int? filterUserId;

  /// Nom d'usuari del propietari del perfil (necessari quan filterUserId != null
  /// per mostrar el nom correcte en lloc del de la sessió activa).
  final String? filterUsername;

  /// Índex del post al qual fer scroll en obrir el feed filtrat.
  final int initialPostIndex;

  const FeedScreen({
    super.key,
    this.filterUserId,
    this.filterUsername,
    this.initialPostIndex = 0,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final ScrollController _scrollController = ScrollController();

  List<Post> posts = [];
  String sessionUsername = ''; // usuari de la sessió activa

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

    sessionUsername = user;
    final db = await dbHelper.database;

    // Feed filtrat per un usuari concret vs. feed de la sessió activa
    final List<Map<String, dynamic>> result;
    if (widget.filterUserId != null) {
      result = await db.query(
        'posts',
        where: 'userId = ?',
        whereArgs: [widget.filterUserId],
        orderBy: 'date DESC',
      );
    } else {
      final userId = await dbHelper.getUserId(sessionUsername);
      result = await db.query(
        'posts',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );
    }

    // Nom que es mostrarà a cada post
    // → feed filtrat: nom del propietari del perfil
    // → feed propi:   nom de la sessió activa
    final displayUsername =
        (widget.filterUserId != null && widget.filterUsername != null)
            ? widget.filterUsername!
            : sessionUsername;

    final loadedPosts = result.map((e) => Post.fromMap(e)).toList();
    for (var post in loadedPosts) {
      post.commentCount = await dbHelper.getCommentCount(post.id!);
      post.username = displayUsername;
    }

    if (!mounted) return;
    setState(() {
      posts = loadedPosts;
      _postKeys
        ..clear()
        ..addAll(List.generate(posts.length, (_) => GlobalKey()));
    });

    // Anunci TalkBack i scroll al post inicial (feed filtrat)
    if (widget.filterUserId != null) {
      SemanticsService.announce(
        'Feed filtrat de $displayUsername. ${posts.length} publicacions.',
        TextDirection.ltr,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(widget.initialPostIndex);
      });
    }
  }

  void _scrollToIndex(int index) {
    if (index <= 0 || !_scrollController.hasClients) return;
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

    final missatge =
        wasLiked ? 'Has tret el m\'agrada' : 'Has donat m\'agrada';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(
            liveRegion: true,
            child: Text(missatge),
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
    final isFiltered = widget.filterUserId != null;
    final displayUsername =
        (isFiltered && widget.filterUsername != null)
            ? widget.filterUsername!
            : sessionUsername;

    final appBarTitle =
        isFiltered ? 'Publicacions de $displayUsername' : 'Feed';

    return Scaffold(
      appBar: AppBar(
        // Label accessible diferent per al feed filtrat
        title: Semantics(
          label: isFiltered
              ? 'Feed filtrat. Publicacions de $displayUsername'
              : 'Feed de publicacions',
          child: Text(appBarTitle),
        ),
        // Botó enrere accessible quan estem al feed filtrat
        leading: isFiltered
            ? Semantics(
                button: true,
                label: 'Tornar al perfil',
                onTapHint: 'Tanca el feed filtrat i torna al perfil',
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
                label: 'Encara no hi ha publicacions',
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
                  username: post.username,
                  onLike: () => _toggleLike(post),
                  onComment: () => _openComments(post),
                );
              },
            ),

      // FAB només al feed principal (el filtrat és de només lectura)
      floatingActionButton: isFiltered
          ? null
          : Semantics(
              label: 'Crear nova publicació',
              button: true,
              child: FloatingActionButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddPostScreen()),
                  );
                  _loadUserAndPosts();
                },
                child: const ExcludeSemantics(child: Icon(Icons.add)),
              ),
            ),
    );
  }
}
