class AppTexts {
  static String tr(String lang, String key) {
    const texts = {
      'Español': {
        'login': 'Iniciar sesión',
        'feed': 'Feed',
        'settings': 'Configuración',
        'language': 'Idioma',
      },
      'English': {
        'login': 'Login',
        'feed': 'Feed',
        'settings': 'Settings',
        'language': 'Language',
      },
      'Català': {
        'login': 'Iniciar sessió',
        'feed': 'Feed',
        'settings': 'Configuració',
        'language': 'Idioma',
      },
    };
    return texts[lang]?[key] ?? key;
  }
}
