import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'instadam.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla usuarios
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        password TEXT
      )
    ''');

    // Tabla posts
    await db.execute('''
      CREATE TABLE posts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        image TEXT,
        description TEXT,
        date TEXT,
        likes INTEGER
      )
    ''');

    // Tabla comentarios
    await db.execute('''
      CREATE TABLE comments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER,
        username TEXT,
        text TEXT,
        date TEXT
      )
    ''');
  }

  // Ejemplo: Insertar usuario
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  // Ejemplo: Obtener todos los usuarios
  Future<List<User>> getUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((json) => User.fromMap(json)).toList();
  }

// Insertar un post
  Future<int> insertPost(Post post) async {
    final db = await database;
    return await db.insert('posts', post.toMap());
  }

// Obtener todos los posts
  Future<List<Post>> getPostsByUser(int userId) async {
    final db = await database;
    final result = await db.query('posts', where: 'userId = ?', whereArgs: [userId]);
    return result.map((e) => Post.fromMap(e)).toList();
  }

// Función para obtener userId por username (la podemos mover aquí)
  Future<int> getUserId(String username) async {
    final db = await database;
    final result = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (result.isNotEmpty) return result.first['id'] as int;
    return 0;
  }

  // Insertar un comentario
  Future<int> insertComment(Comment comment) async {
    final db = await database;
    return await db.insert('comments', comment.toMap());
  }

// Contar comentarios de un post
  Future<int> getCommentCount(int postId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM comments WHERE postId = ?', [postId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
