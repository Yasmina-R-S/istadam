import 'package:flutter/material.dart';
import '../main.dart';
import 'login_screen.dart';

/// Pantalla de configuració accessible per InstaDAM
/// Compleix tots els requisits d'accessibilitat amb TalkBack
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Català';

  final List<String> _languages = ['Català', 'Español', 'English'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Llegim el tema actual de l'app
    _isDarkMode = InstaDAMApp.of(context)?.isDarkMode ?? false;
  }

  // SnackBar accessible amb liveRegion (TalkBack el llegeix automàticament)
  void _showAccessibleSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Semantics(
          liveRegion: true,
          child: Text(message),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Canvi de tema
  void _onThemeToggle(bool value) {
    setState(() => _isDarkMode = value);
    InstaDAMApp.of(context)?.setDarkMode(value);
    _showAccessibleSnackBar(value ? 'Tema fosc activat' : 'Tema clar activat');
  }

  // Canvi de notificacions
  void _onNotificationsToggle(bool value) {
    setState(() => _notificationsEnabled = value);
    _showAccessibleSnackBar(
      value ? 'Notificacions activades' : 'Notificacions desactivades',
    );
  }

  // Diàleg de confirmació per tancar sessió
  Future<void> _showLogoutDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Semantics(
            header: true,
            child: const Text('Tancar sessió'),
          ),
          content: const Text(
            'Estàs segur que vols tancar la sessió? Hauràs de tornar a iniciar sessió per accedir al teu compte.',
          ),
          actions: [
            Semantics(
              button: true,
              label: 'Cancel·lar, tornar a la configuració',
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel·lar'),
              ),
            ),
            Semantics(
              button: true,
              label: 'Confirmar tancament de sessió',
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Tancar sessió'),
              ),
            ),
          ],
        );
      },
    );

    // Només navega si confirma
    if (confirmed == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: const Text('Configuració'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Aparença'),
          _buildThemeSwitch(),
          const Divider(),

          _buildSectionHeader('Idioma'),
          _buildLanguageSelector(),
          const Divider(),

          _buildSectionHeader('Notificacions'),
          _buildNotificationsSwitch(),
          const Divider(),

          _buildSectionHeader('Compte'),
          _buildLogoutButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  // Switch tema clar/fosc — Semantics amb toggled per TalkBack
  Widget _buildThemeSwitch() {
    return Semantics(
      toggled: _isDarkMode,
      label: 'Tema fosc',
      hint: _isDarkMode
          ? 'Doble toc per activar el tema clar'
          : 'Doble toc per activar el tema fosc',
      excludeSemantics: true,
      child: SwitchListTile(
        secondary: Icon(
          _isDarkMode ? Icons.dark_mode : Icons.light_mode,
          semanticLabel: _isDarkMode ? 'Icona lluna' : 'Icona sol',
        ),
        title: const Text('Tema fosc'),
        subtitle: Text(_isDarkMode ? 'Activat' : 'Desactivat'),
        value: _isDarkMode,
        onChanged: _onThemeToggle,
      ),
    );
  }

  // Selector d'idioma amb label visible
  Widget _buildLanguageSelector() {
    return Semantics(
      label: 'Selector d\'idioma. Idioma actual: $_selectedLanguage',
      hint: 'Doble toc per obrir el menú d\'idiomes',
      child: ListTile(
        leading: const Icon(Icons.language, semanticLabel: 'Icona idioma'),
        title: const Text('Idioma'),
        subtitle: Text(_selectedLanguage),
        trailing: const Icon(Icons.arrow_drop_down, semanticLabel: 'Obrir opcions'),
        onTap: _showLanguageDialog,
      ),
    );
  }

  Future<void> _showLanguageDialog() async {
    final String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Semantics(
            header: true,
            child: const Text('Selecciona l\'idioma'),
          ),
          children: _languages.map((String lang) {
            final bool isSelected = lang == _selectedLanguage;
            return Semantics(
              button: true,
              selected: isSelected,
              label: isSelected ? '$lang, seleccionat' : lang,
              child: SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(lang),
                child: Row(
                  children: [
                    if (isSelected)
                      const Icon(Icons.check, semanticLabel: 'Opció seleccionada')
                    else
                      const SizedBox(width: 24),
                    const SizedBox(width: 8),
                    Text(
                      lang,
                      style: isSelected
                          ? const TextStyle(fontWeight: FontWeight.bold)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );

    if (selected != null && selected != _selectedLanguage) {
      setState(() => _selectedLanguage = selected);
      _showAccessibleSnackBar('Idioma canviat a $selected');
    }
  }

  // Switch notificacions — Semantics amb toggled
  Widget _buildNotificationsSwitch() {
    return Semantics(
      toggled: _notificationsEnabled,
      label: 'Notificacions',
      hint: _notificationsEnabled
          ? 'Doble toc per desactivar les notificacions'
          : 'Doble toc per activar les notificacions',
      excludeSemantics: true,
      child: SwitchListTile(
        secondary: Icon(
          _notificationsEnabled
              ? Icons.notifications_active
              : Icons.notifications_off,
          semanticLabel: _notificationsEnabled
              ? 'Notificacions activades'
              : 'Notificacions desactivades',
        ),
        title: const Text('Notificacions'),
        subtitle: Text(_notificationsEnabled ? 'Activades' : 'Desactivades'),
        value: _notificationsEnabled,
        onChanged: _onNotificationsToggle,
      ),
    );
  }

  // Botó tancar sessió accessible
  Widget _buildLogoutButton() {
    return Semantics(
      button: true,
      label: 'Tancar sessió',
      hint: 'Doble toc per mostrar el diàleg de confirmació',
      child: ListTile(
        leading: const Icon(
          Icons.logout,
          color: Colors.red,
          semanticLabel: 'Icona tancar sessió',
        ),
        title: const Text(
          'Tancar sessió',
          style: TextStyle(color: Colors.red),
        ),
        onTap: _showLogoutDialog,
      ),
    );
  }
}