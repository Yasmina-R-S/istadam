import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'feed_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> posts;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.posts,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _avatarFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _statsFocus = FocusNode();
  final _editFocus = FocusNode();
  final _gridFocus = FocusNode();

  @override
  void dispose() {
    _avatarFocus.dispose();
    _nameFocus.dispose();
    _statsFocus.dispose();
    _editFocus.dispose();
    _gridFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user['username']),
      ),
      body: Column(
        children: [
          _header(context),
          _editButton(),
          const Divider(),
          Expanded(child: _grid(context)),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Focus(
            focusNode: _avatarFocus,
            child: Semantics(
              label: 'Foto de perfil de ${widget.user['username']}',
              image: true,
              onDidGainAccessibilityFocus: () {
                FocusScope.of(context).requestFocus(_avatarFocus);
              },
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person,
                    size: 40, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Focus(
                  focusNode: _nameFocus,
                  child: Semantics(
                    header: true,
                    label: widget.user['username'],
                    onDidGainAccessibilityFocus: () {
                      FocusScope.of(context).requestFocus(_nameFocus);
                    },
                    child: Text(
                      widget.user['username'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Focus(
                  focusNode: _statsFocus,
                  child: Semantics(
                    label:
                    '${widget.user['posts']} publicaciones, ${widget.user['followers']} seguidores, ${widget.user['following']} siguiendo',
                    onDidGainAccessibilityFocus: () {
                      FocusScope.of(context).requestFocus(_statsFocus);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat(widget.user['posts'] ?? 0, 'Posts'),
                        _stat(widget.user['followers'] ?? 0, 'Seguidores'),
                        _stat(widget.user['following'] ?? 0, 'Siguiendo'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(int number, String label) {
    return Column(
      children: [
        Text('$number',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _editButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Focus(
        focusNode: _editFocus,
        child: Semantics(
          button: true,
          label: 'Editar perfil',
          onDidGainAccessibilityFocus: () {
            FocusScope.of(context).requestFocus(_editFocus);
          },
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: OutlinedButton(
                onPressed: () async {
                  final updatedUser = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(user: widget.user),
                    ),
                  );

                  if (updatedUser != null) {
                    setState(() {
                      widget.user.addAll(updatedUser);
                    });
                  }
                },

  Widget _grid(BuildContext context) {
    if (widget.posts.isEmpty) {
      return const Center(
        child: Text('No hay publicaciones todavía'),
      );
    }

    return Focus(
      focusNode: _gridFocus,
      child: Semantics(
        label:
        'Grid de publicaciones, ${widget.posts.length} elementos',
        onDidGainAccessibilityFocus: () {
          FocusScope.of(context).requestFocus(_gridFocus);
        },
        child: GridView.builder(
          itemCount: widget.posts.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemBuilder: (context, index) {
            final post = widget.posts[index];
            final description =
                (post['description'] as String?) ?? 'Sin descripción';
            final likes = (post['likes'] as int?) ?? 0;

            return Semantics(
              label:
              'Publicación ${index + 1} de ${widget.posts.length}. $description. $likes me gusta',
              button: true,
              onTapHint: 'Ver publicación',
              child: GestureDetector(
                onTap: () => _openUserFeed(context, index),
                child: Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image,
                      size: 40, color: Colors.white),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openUserFeed(BuildContext context, int index) {
    SemanticsService.announce(
      'Abriendo feed de ${widget.user['username']}',
      TextDirection.ltr,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedScreen(
          filterUserId: widget.user['id'] as int?,
          initialPostIndex: index,
        ),
      ),
    );
  }
}