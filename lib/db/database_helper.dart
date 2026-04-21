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
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        password TEXT
      )
    ''');

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

  // ---------- USUARIOS ----------
  Future<bool> userExists(String username) async {
    final db = await database;
    final result =
    await db.query('users', where: 'username = ?', whereArgs: [username]);
    return result.isNotEmpty;
  }

  Future<int> registerUser(String username, String password) async {
    final db = await database;
    return await db.insert('users', {
      'username': username,
      'password': password,
    });
  }

  Future<bool> login(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  Future<int> getUserId(String username) async {
    final db = await database;
    final result =
    await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (result.isNotEmpty) return result.first['id'] as int;
    return 0;
  }

  // ---------- POSTS ----------
  Future<int> insertPost(Post post) async {
    final db = await database;
    return await db.insert('posts', post.toMap());
  }

  Future<List<Post>> getAllPosts() async {
    final db = await database;
    final result = await db.query('posts', orderBy: 'date DESC');
    List<Post> posts = result.map((e) => Post.fromMap(e)).toList();

    for (var post in posts) {
      post.username = await getUsernameById(post.userId);
      post.commentCount = await getCommentCount(post.id!);
    }
    return posts;
  }

  Future<String> getUsernameById(int userId) async {
    final db = await database;
    final result =
        await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (result.isNotEmpty) return result.first['username'] as String;
    return 'Desconocido';
  }

  // ---------- COMMENTS ----------
  Future<int> insertComment(Comment comment) async {
    final db = await database;
    return await db.insert('comments', comment.toMap());
  }

  Future<int> getCommentCount(int postId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM comments WHERE postId = ?', [postId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }
}
