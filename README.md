**Descripción del proyecto**

InstaDAM es una aplicación móvil desarrollada con Flutter, inspirada en Instagram.
Permite a los usuarios registrarse, iniciar sesión, crear publicaciones, dar likes, comentar posts y gestionar su perfil y configuración.

El objetivo principal del proyecto es practicar el uso combinado de SharedPreferences y SQFlite, gestionando correctamente la persistencia de datos, la navegación entre pantallas y el ciclo de vida de los widgets en Flutter.

**Instalación**

Clonar el repositorio:

git clone https://github.com/tu_usuario/instadam.git


Acceder al proyecto:

cd instadam


Instalar dependencias:

flutter pub get


Ejecutar la aplicación:

flutter run

**Estructura del proyecto
lib/**
│
├── db/
│   └── database_helper.dart
│
├── models/
│   ├── post.dart
│   ├── comment.dart
│   └── user.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── registrer_screen.dart
│   ├── feed_screen.dart
│   ├── add_post_screen.dart
│   ├── comments_screen.dart
│   ├── profile_screen.dart
│   └── settings_screen.dart
│
├── utils/
│   └── preferences.dart
│
└── main.dart

Funcionalidades implementadas
Login / Registro

Pantalla de inicio de sesión con usuario y contraseña.

Pantalla de registro para nuevos usuarios.

Opción “Recordar usuario” usando SharedPreferences.

Si el usuario ya ha iniciado sesión, la app entra directamente al feed.

Feed principal

Muestra las publicaciones guardadas en SQFlite del usuario logueado.

Cada post incluye:

Imagen (placeholder).

Nombre del usuario.

**Descripción.**

Fecha de publicación.

Número de likes.

Número de comentarios.

El feed se actualiza automáticamente al:

Crear un nuevo post.

Dar o quitar like.

Añadir comentarios.

Likes

Se puede dar y quitar like a cualquier publicación.

**Los likes:**

Se actualizan en la UI.

Se guardan en la base de datos.

Solo afectan al usuario actual.

Crear nuevos posts

Pantalla para crear publicaciones.

**Permite:**

Escribir una descripción.

Usar una imagen placeholder.

Los posts se guardan en SQFlite.

Aparecen inmediatamente en el feed del usuario.

**Comentarios**

Cada post tiene su propio sistema de comentarios.

Los comentarios:

Se guardan en una tabla independiente en SQFlite.

**Incluyen:**

ID

ID del post

Usuario

Texto

Fecha

Pantalla específica para ver comentarios.

Se pueden añadir comentarios nuevos.

El número de comentarios se muestra en el feed y se actualiza al momento.

Perfil del usuario

Pantalla de perfil con:

Nombre de usuario.

Foto (opcional).

Número total de posts.

Datos del perfil guardados con SharedPreferences.

Al pulsar en el número de posts:

Se muestra un feed filtrado con solo los posts del usuario.

Configuración / Settings

Todas las opciones se guardan con SharedPreferences:

Tema claro / oscuro.

Activar / desactivar notificaciones (simulación).

Selección de idioma (Español / Inglés).

Cerrar sesión (borra datos guardados).
