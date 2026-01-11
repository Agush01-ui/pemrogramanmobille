import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(
        'todos_app_v4.db'); // TAMBAHAN: Versi database ditingkatkan
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path,
        version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    // TAMBAHAN: Tabel todos dengan kolom time
    await db.execute('''
    CREATE TABLE todos (
      id TEXT PRIMARY KEY,
      title TEXT,
      category TEXT,
      deadline TEXT,
      time TEXT, -- TAMBAHAN: Kolom untuk waktu spesifik
      isUrgent INTEGER,
      isCompleted INTEGER,
      username TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE users (
      username TEXT PRIMARY KEY,
      password TEXT
    )
    ''');
  }

  // TAMBAHAN: Fungsi untuk upgrade database (menambah kolom time jika belum ada)
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Tambah kolom time ke tabel todos
      await db.execute('ALTER TABLE todos ADD COLUMN time TEXT');
    }
  }

  Future<int> create(Todo todo) async {
    final db = await instance.database;
    return await db.insert('todos', todo.toMap());
  }

  Future<List<Todo>> readTodosByUser(String username) async {
    final db = await instance.database;
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
