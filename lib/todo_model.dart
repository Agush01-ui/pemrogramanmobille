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

  // Konversi dari Map (Database) ke Object Todo
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      deadline:
          map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      // SQLite menyimpan bool sebagai integer (0 atau 1)
      isUrgent: map['isUrgent'] == 1,
      isCompleted: map['isCompleted'] == 1,
    );
  }

  // Konversi dari Object Todo ke Map (Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'deadline': deadline?.toIso8601String(),
      'isUrgent': isUrgent ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}
