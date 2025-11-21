// lib/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'todo_model.dart';
import 'user_model.dart'; // Import UserModel

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB); 
  }
  
  Future _createDB(Database db, int version) async {
    // 1. Tabel USERS
    await db.execute('''
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      username TEXT UNIQUE,
      password TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE todos (
      id TEXT PRIMARY KEY,
      title TEXT,
      category TEXT,
      deadline TEXT,
      isUrgent INTEGER,
      isCompleted INTEGER,
      userId TEXT,
      FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
    )
    ''');
    
    final defaultUserId = 'default_user_123';
    
    final defaultUser = User(
      id: defaultUserId,
      username: 'Guest', 
      password: 'password123',
    );

    await db.insert(
      'users',
      defaultUser.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Tambahkan tugas awal untuk akun default
    final initialTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Selamat datang! Tugas ini milik Guest',
      category: 'Pribadi',
      isUrgent: true,
      isCompleted: false,
      userId: defaultUserId,
    );

    await db.insert('todos', initialTodo.toMap());
  }

  // CREATE USER (Register)
  Future<int> createUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  // READ USER (Login/Auth)
  Future<User?> getUserByUsername(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  // CREATE TODO
  Future<int> create(Todo todo) async {
    final db = await instance.database;
    return await db.insert('todos', todo.toMap());
  }

  // READ ALL TODO
  Future<List<Todo>> readAllTodos(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'todos',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'deadline ASC',
    );
    return result.map((json) => Todo.fromMap(json)).toList();
  }

  // UPDATE
  Future<int> update(Todo todo) async {
    final db = await instance.database;
    return db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // DELETE
  Future<int> delete(String id) async {
    final db = await instance.database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}