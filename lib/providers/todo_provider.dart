import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/database_helper.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> todos = [];
  bool isLoading = false;

  // Load semua todo untuk user tertentu
  Future<void> loadTodos(String username) async {
    isLoading = true;
    notifyListeners();

    todos = await DatabaseHelper.instance.readTodosByUser(username);

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async {
    await DatabaseHelper.instance.create(todo);
    todos.add(todo);
    notifyListeners();
  }

  Future<void> updateTodo(Todo todo) async {
    await DatabaseHelper.instance.update(todo);
    int index = todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      todos[index] = todo;
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    await DatabaseHelper.instance.delete(id);
    todos.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  List<Todo> filteredTodos(String selectedFilter) {
    List<Todo> list = selectedFilter == 'Semua'
        ? todos
        : todos.where((todo) => todo.category == selectedFilter).toList();

    list.sort((a, b) {
      if (a.isUrgent && !b.isUrgent) return -1;
      if (!a.isUrgent && b.isUrgent) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;
      if (a.isCompleted && !b.isCompleted) return 1;
      if (a.deadline != null && b.deadline != null) {
        return a.deadline!.compareTo(b.deadline!);
      }
      return 0;
    });
    return list;
  }
}
