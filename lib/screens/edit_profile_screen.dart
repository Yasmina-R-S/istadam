import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _bioController;

  String? _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.user['username'] ?? '');
    _bioController =
        TextEditingController(text: widget.user['bio'] ?? '');
    _imagePath = widget.user['image'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _imagePath = picked.path);

      SemanticsService.announce(
        'Foto de perfil actualizada',
        TextDirection.ltr,
      );
    }
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    SemanticsService.announce(
      'Guardando perfil',
      TextDirection.ltr,
    );

    Future.delayed(const Duration(seconds: 1), () {
      final updatedUser = {
        ...widget.user,
        'username': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'image': _imagePath,
      };

      Navigator.pop(context, updatedUser);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Semantics(
                label: 'Cambiar foto de perfil',
                button: true,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imagePath != null
                        ? FileImage(File(_imagePath!))
                        : null,
                    child: _imagePath == null
                        ? const Icon(Icons.camera_alt, size: 30)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                label: 'Campo nombre de usuario',
                textField: true,
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Campo biografía',
                textField: true,
                child: TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Biografía',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Semantics(
                label: _isSaving ? 'Guardando perfil' : 'Guardar cambios',
                button: true,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Guardar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}