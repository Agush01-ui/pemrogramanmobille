import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos_app_v3.db'); // Versi DB baru
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabel TODOS (Sekarang ada kolom username)
    await db.execute('''
    CREATE TABLE todos (
      id TEXT PRIMARY KEY,
      title TEXT,
      category TEXT,
      deadline TEXT,
      isUrgent INTEGER,
      isCompleted INTEGER,
      username TEXT  -- <--- KOLOM BARU PENANDA PEMILIK
    )
    ''');

    // 2. Tabel USERS
    await db.execute('''
    CREATE TABLE users (
      username TEXT PRIMARY KEY,
      password TEXT
    )
    ''');
  }

  Future<int> create(Todo todo) async {
    final db = await instance.database;
    return await db.insert('todos', todo.toMap());
  }

  // --- FUNGSI PENTING: BACA DATA SPESIFIK USER ---
  Future<List<Todo>> readTodosByUser(String username) async {
    final db = await instance.database;
    // Filter menggunakan WHERE username = ?
    final result = await db.query(
      'todos',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.map((json) => Todo.fromMap(json)).toList();
  }

  Future<int> update(Todo todo) async {
    final db = await instance.database;
    return db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await instance.database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- USER FUNCTIONS ---
  Future<int> registerUser(String username, String password) async {
    final db = await instance.database;
    try {
      return await db
          .insert('users', {'username': username, 'password': password});
    } catch (e) {
      return -1;
    }
  }

  Future<bool> loginUser(String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }
}