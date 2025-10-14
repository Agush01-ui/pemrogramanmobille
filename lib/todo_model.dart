// todo_model.dart

class Todo {
  String id;
  String title;
  String category;
  DateTime? deadline;
  bool isUrgent;
  bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    required this.category,
    this.deadline,
    this.isUrgent = false,
    this.isCompleted = false,
  });
}
