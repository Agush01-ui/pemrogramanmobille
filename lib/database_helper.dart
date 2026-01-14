import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todos_app_v5.db'); // Naikkan versi ke v5
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // Naikkan versi ke 4
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onDowngrade: _onDowngrade,
    );
  }

  Future _createDB(Database db, int version) async {
    // PERBAIKAN: Tambah koma setelah longitude REAL
    await db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        title TEXT,
        category TEXT,
        deadline TEXT,
        time TEXT,
        isUrgent INTEGER,
        isCompleted INTEGER,
        username TEXT,
        latitude REAL,
        longitude REAL,
        location_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        username TEXT PRIMARY KEY,
        password TEXT
      )
    ''');
  }

  // TAMBAHAN: Fungsi untuk downgrade (jika perlu)
  Future _onDowngrade(Database db, int oldVersion, int newVersion) async {
    // Untuk downgrade, hapus database dan buat ulang
    await db.execute('DROP TABLE IF EXISTS todos');
    await db.execute('DROP TABLE IF EXISTS users');
    await _createDB(db, newVersion);
  }

  // PERBAIKAN: Upgrade database dengan benar
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    // Versi 1 -> 2: Tambah kolom time
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE todos ADD COLUMN time TEXT');
        print('Added time column');
      } catch (e) {
        print('Error adding time column: $e');
      }
    }

    // Versi 2 -> 3: Tambah kolom latitude dan longitude
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE todos ADD COLUMN latitude REAL');
        await db.execute('ALTER TABLE todos ADD COLUMN longitude REAL');
        print('Added latitude and longitude columns');
      } catch (e) {
        print('Error adding location columns: $e');
      }
    }

    // Versi 3 -> 4: Tambah kolom location_name
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE todos ADD COLUMN location_name TEXT');
        print('Added location_name column');
      } catch (e) {
        print('Error adding location_name column: $e');
      }
    }
  }

  Future<int> create(Todo todo) async {
    try {
      final db = await instance.database;
      return await db.insert('todos', todo.toMap());
    } catch (e) {
      print('Error creating todo: $e');
      return -1;
    }
  }

  Future<List<Todo>> readTodosByUser(String username) async {
    try {
      final db = await instance.database;
      final result = await db.query(
        'todos',
        where: 'username = ?',
        whereArgs: [username],
        orderBy:
            'isCompleted ASC, deadline ASC', // Urutkan berdasarkan status dan deadline
      );

      print('Found ${result.length} todos for user: $username');
      return result.map((json) => Todo.fromMap(json)).toList();
    } catch (e) {
      print('Error reading todos: $e');
      return [];
    }
  }

  Future<int> update(Todo todo) async {
    try {
      final db = await instance.database;
      return await db.update(
        'todos',
        todo.toMap(),
        where: 'id = ?',
        whereArgs: [todo.id],
      );
    } catch (e) {
      print('Error updating todo: $e');
      return -1;
    }
  }

  Future<int> delete(String id) async {
    try {
      final db = await instance.database;
      return await db.delete(
        'todos',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting todo: $e');
      return -1;
    }
  }

  // =============================
  // METODE BARU UNTUK LOKASI
  // =============================

  Future<List<Todo>> getTodosWithLocation(String username) async {
    try {
      final db = await instance.database;
      final result = await db.query(
        'todos',
        where:
            'username = ? AND latitude IS NOT NULL AND longitude IS NOT NULL',
        whereArgs: [username],
      );
      return result.map((json) => Todo.fromMap(json)).toList();
    } catch (e) {
      print('Error getting todos with location: $e');
      return [];
    }
  }

  Future<int> updateTodoLocation({
    required String todoId,
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    try {
      final db = await instance.database;
      return await db.update(
        'todos',
        {
          'latitude': latitude,
          'longitude': longitude,
          'location_name': locationName,
        },
        where: 'id = ?',
        whereArgs: [todoId],
      );
    } catch (e) {
      print('Error updating todo location: $e');
      return -1;
    }
  }

  Future<int> clearTodoLocation(String todoId) async {
    try {
      final db = await instance.database;
      return await db.update(
        'todos',
        {
          'latitude': null,
          'longitude': null,
          'location_name': null,
        },
        where: 'id = ?',
        whereArgs: [todoId],
      );
    } catch (e) {
      print('Error clearing todo location: $e');
      return -1;
    }
  }

  Future<int> registerUser(String username, String password) async {
    try {
      final db = await instance.database;
      return await db.insert(
        'users',
        {'username': username, 'password': password},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error registering user: $e');
      return -1;
    }
  }

  Future<bool> loginUser(String username, String password) async {
    try {
      final db = await instance.database;
      final result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error logging in user: $e');
      return false;
    }
  }

  Future<bool> userExists(String username) async {
    try {
      final db = await instance.database;
      final result = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking user: $e');
      return false;
    }
  }

  // =============================
  // METODE UNTUK DEBUGGING
  // =============================

  Future<void> printAllTodos() async {
    try {
      final db = await instance.database;
      final result = await db.query('todos');
      print('=== ALL TODOS IN DATABASE ===');
      for (var todo in result) {
        print('ID: ${todo['id']}');
        print('Title: ${todo['title']}');
        print('Category: ${todo['category']}');
        print('Location Name: ${todo['location_name']}');
        print('Latitude: ${todo['latitude']}');
        print('Longitude: ${todo['longitude']}');
        print('---');
      }
    } catch (e) {
      print('Error printing todos: $e');
    }
  }

  Future<void> printTableSchema() async {
    try {
      final db = await instance.database;
      final tableInfo = await db.rawQuery('PRAGMA table_info(todos)');
      print('=== TODOS TABLE SCHEMA ===');
      for (var column in tableInfo) {
        print('Column: ${column['name']}, Type: ${column['type']}');
      }
    } catch (e) {
      print('Error printing schema: $e');
    }
  }

  // PERBAIKAN: Fix deleteDatabase method
  Future<void> resetDatabase() async {
    try {
      // Tutup database yang sedang terbuka
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Hapus file database
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'todos_app_v5.db');

      // Gunakan function deleteDatabase dari package sqflite
      await deleteDatabase(path);

      print('Database berhasil dihapus');
    } catch (e) {
      print('Error deleting database: $e');
    }
  }

  // Alternatif: Method untuk drop dan recreate database
  Future<void> recreateDatabase() async {
    try {
      final db = await database;
      await db.execute('DROP TABLE IF EXISTS todos');
      await db.execute('DROP TABLE IF EXISTS users');
      await _createDB(db, 4);
      print('Database berhasil di-recreate');
    } catch (e) {
      print('Error recreating database: $e');
    }
  }
}
