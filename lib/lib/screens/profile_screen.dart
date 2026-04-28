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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          label: 'Perfil de ${widget.user['username']}',
          child: Text(widget.user['username'] ?? ''),
        ),
      ),
      body: Column(
        children: [
          _buildProfileHeader(context),
          _buildEditButton(context),
          const Divider(),
          Expanded(child: _buildPostsGrid(context)),
        ],
      ),
    );
  }

  // ─── CAPÇALERA ────────────────────────────────────────────────────────────

  Widget _buildProfileHeader(BuildContext context) {
    final username = widget.user['username'] ?? '';
    final bio = (widget.user['bio'] as String?)?.isNotEmpty == true
        ? widget.user['bio'] as String
        : null;
    final posts    = widget.user['posts']     ?? 0;
    final followers = widget.user['followers'] ?? 0;
    final following = widget.user['following'] ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Foto de perfil amb label semàntic + image: true ─────
              // Requisit 1: foto de perfil amb Semantics label + image: true
              Semantics(
                label: 'Foto de perfil de $username',
                image: true,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: const ExcludeSemantics(
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // ── Estadístiques agrupades amb MergeSemantics ──────────
              // Requisit 1: estadístiques agrupades amb MergeSemantics
              Expanded(
                child: MergeSemantics(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(posts,     'Publicacions'),
                      _buildStat(followers, 'Seguidors'),
                      _buildStat(following, 'Seguint'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Nom d'usuari llegible per TalkBack ──────────────────────
          // Requisit 1: nom d'usuari i bio llegibles amb TalkBack
          Semantics(
            header: true,
            label: username,
            child: Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          // ── Bio (si existeix) ───────────────────────────────────────
          if (bio != null) ...[
            const SizedBox(height: 4),
            Semantics(
              label: 'Biografia: $bio',
              child: Text(
                bio,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            Semantics(
              label: 'Sense biografia',
              child: const Text(
                'Sense biografia',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(int number, String label) {
    // ExcludeSemantics: MergeSemantics del pare ja genera el label agregat
    return Column(
      children: [
        ExcludeSemantics(
          child: Text(
            '$number',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ExcludeSemantics(
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  // ─── BOTÓ EDITAR PERFIL ───────────────────────────────────────────────────

  Widget _buildEditButton(BuildContext context) {
    // Requisit 3: mida mínima 48dp + Semantics label clar + accionable TalkBack
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Semantics(
        button: true,
        label: 'Editar perfil',
        onTapHint: 'Obre la pantalla per editar el teu perfil',
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () async {
              final updatedUser = await Navigator.push<Map<String, dynamic>>(
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
            child: const Text('Editar Perfil'),
          ),
        ),
      ),
    );
  }

  // ─── GRID DE POSTS ────────────────────────────────────────────────────────

  Widget _buildPostsGrid(BuildContext context) {
    if (widget.posts.isEmpty) {
      return Center(
        child: Semantics(
          label: 'Encara no hi ha publicacions',
          child: const Text('No hay publicaciones todavía'),
        ),
      );
    }

    final total = widget.posts.length;

    // Requisit 2: grid accessible amb navegació coherent amb TalkBack
    return Semantics(
      label: 'Galeria de publicacions. $total publicacions en total.',
      child: GridView.builder(
        itemCount: total,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (context, index) =>
            _buildGridItem(context, index, total),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, int index, int total) {
    final post = widget.posts[index];
    final description = (post['description'] as String?)?.isNotEmpty == true
        ? post['description'] as String
        : 'Sense descripció';
    final likes = (post['likes'] as int?) ?? 0;

    // Requisit 2: posició + descripció + likes + accionable + onTapHint
    return Semantics(
      label:
          'Publicació ${index + 1} de $total. $description. $likes m\'agrada.',
      button: true,
      onTapHint: 'Obre el feed d\'aquesta publicació',
      child: GestureDetector(
        onTap: () => _openUserFeed(context, index),
        child: Container(
          color: Colors.grey[300],
          child: const ExcludeSemantics(
            child: Icon(Icons.image, size: 40, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ─── NAVEGACIÓ AL FEED FILTRAT ────────────────────────────────────────────

  void _openUserFeed(BuildContext context, int index) {
    final username = widget.user['username'] ?? '';

    // Anunci accessible a TalkBack
    SemanticsService.announce(
      'Obrint feed de $username',
      TextDirection.ltr,
    );

    // Requisit 4: feed filtrat per usuari, passa el username del propietari
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedScreen(
          filterUserId: widget.user['id'] as int?,
          filterUsername: username,
          initialPostIndex: index,
        ),
      ),
    );
  }
}
