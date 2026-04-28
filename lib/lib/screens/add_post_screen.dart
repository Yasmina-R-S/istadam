import 'package:flutter/semantics.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../db/database_helper.dart';
import '../models/post.dart';
import '../utils/preferences.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  // --- Estat del formulari ---
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  int _userId = 0;
  String? _imagePath;   // null = cap imatge seleccionada
  bool _isLoading = false;

  // ------------------------------------------------------------------ //
  //  INICIALITZACIÓ
  // ------------------------------------------------------------------ //

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await Preferences.getUser();
    if (user != null) {
      final db = DatabaseHelper();
      final id = await db.getUserId(user);
      setState(() {
        _userId = id;
      });
    }
  }

  // ------------------------------------------------------------------ //
  //  SELECCIÓ D'IMATGE
  // ------------------------------------------------------------------ //

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagePath = picked.path);

      // Anunciem el canvi d'estat a TalkBack via SemanticsService
      // (alternativa lleugera sense dependència extra)
      SemanticsService.announce(
        'Imatge seleccionada correctament',
        TextDirection.ltr,
      );
    }
  }

  // ------------------------------------------------------------------ //
  //  PUBLICACIÓ
  // ------------------------------------------------------------------ //

  Future<void> _publishPost() async {
    // 1. Valida el formulari (activa errorText accessible)
    if (!_formKey.currentState!.validate()) return;

    // 2. Bloqueja el botó per evitar doble enviament
    setState(() => _isLoading = true);

    // 3. Anuncia l'inici de la càrrega
    SemanticsService.announce('Publicant, espera un moment', TextDirection.ltr);

    try {
      final newPost = Post(
        userId: _userId,
        image: _imagePath ?? '',
        description: _descriptionController.text.trim(),
        date: DateTime.now().toString(),
        likes: 0,
      );

      final db = DatabaseHelper();
      await db.insertPost(newPost);

      if (!mounted) return;

      // 4. Confirmació accessible via SnackBar amb liveRegion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(
            liveRegion: true,
            label: 'Publicació creada correctament',
            child: const Text('Publicació creada correctament'),
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
        ),
      );

      // 5. Tornar al feed (el post ja és a la BD)
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Semantics(
            liveRegion: true,
            label: 'Error en publicar. Torna-ho a intentar.',
            child: const Text('Error en publicar. Torna-ho a intentar.'),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ------------------------------------------------------------------ //
  //  UI
  // ------------------------------------------------------------------ //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Etiqueta accessible de la pantalla
        title: Semantics(
          header: true,
          child: const Text('Crear publicació'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Selector d'imatge ─────────────────────────────────
              _buildImageSelector(),

              const SizedBox(height: 24),

              // ── 2. Camp de descripció ────────────────────────────────
              _buildDescriptionField(),

              const SizedBox(height: 32),

              // ── 3. Botó Publicar ─────────────────────────────────────
              _buildPublishButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget: selector d'imatge lllll──────────────────────────────────────────

  Widget _buildImageSelector() {
    // L'etiqueta semàntica canvia dinàmicament
    final semanticLabel = _imagePath == null
        ? 'Cap imatge seleccionada. Botó. Toca per seleccionar una imatge de la galeria'
        : 'Imatge seleccionada. Botó. Toca per canviar la imatge';

    return Semantics(
      label: semanticLabel,
      button: true,
      // explicitChildNodes: false per evitar que TalkBack llegeixi
      // els fills per separat (la imatge i el text de l'estat)
      explicitChildNodes: false,
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          clipBehavior: Clip.antiAlias,
          child: _imagePath != null
              ? Stack(
            fit: StackFit.expand,
            children: [
              Image.file(File(_imagePath!), fit: BoxFit.cover),
              // Overlay accessible que no desapareix amb TalkBack
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Text(
                    'Imatge seleccionada — toca per canviar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_photo_alternate_outlined,
                  size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Selecciona una imatge',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget: camp de descripció ─────────────────────────────────────────

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta VISIBLE fora del TextField (requisit d'accessibilitat)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            'Descripció *',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        Semantics(
          label: 'Descripció del post, camp de text obligatori',
          textField: true,
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Escriu aquí la descripció…',
              border: OutlineInputBorder(),
              // errorText es llegeix automàticament per TalkBack
            ),
            // Validació: l'errorText apareix i és llegit per TalkBack
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La descripció és obligatòria';
              }
              if (value.trim().length < 3) {
                return 'La descripció ha de tenir almenys 3 caràcters';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  // ── Widget: botó publicar ──────────────────────────────────────────────

  Widget _buildPublishButton() {
    // El label semàntic del botó canvia depenent de l'estat
    final buttonLabel = _isLoading ? 'Publicant, espera' : 'Publicar post';

    return Semantics(
      label: buttonLabel,
      button: true,
      enabled: !_isLoading,
      child: SizedBox(
        height: 48, // Mida mínima WCAG 2.5.5 (48dp)
        child: ElevatedButton(
          // onPressed = null bloqueja el botó i impedeix doble enviament
          onPressed: _isLoading ? null : _publishPost,
          style: ElevatedButton.styleFrom(
            // Assegurem mida mínima tàctil
            minimumSize: const Size.fromHeight(48),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
          child: _isLoading
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Publicant…'),
            ],
          )
              : const Text('Publicar'),
        ),
      ),
    );
  }
}