import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/database_helper.dart';

class TodoProvider extends ChangeNotifier {
  final List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  final db = DatabaseHelper.instance;

  Future<void> loadTodos(String username) async {
    final database = await db.database;
    final data = await database.query(
      'todos',
      where: 'username = ?',
      whereArgs: [username],
    );

    _todos
      ..clear()
      ..addAll(data.map((e) => Todo.fromMap(e)));

    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async {
    final database = await db.database;
    final id = await database.insert('todos', todo.toMap());
    _todos.add(todo.copyWith(id: id));
    notifyListeners();
  }

  Future<void> toggleStatus(Todo todo) async {
    final updated = todo.copyWith(completed: !todo.completed);
    final database = await db.database;

    await database.update(
      'todos',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );

    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) _todos[index] = updated;
    notifyListeners();
  }

  Future<void> updateTodo(Todo todo) async {
    final database = await db.database;
    await database.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );

    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) _todos[index] = todo;
    notifyListeners();
  }
}
