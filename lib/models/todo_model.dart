class Todo {
  final int id;
  final String title;
  final String category;
  final DateTime deadline;
  final bool isUrgent;
  bool completed;
  final String username;

  Todo({
    required this.id,
    required this.title,
    required this.category,
    required this.deadline,
    required this.isUrgent,
    this.completed = false,
    required this.username,
  });

  Todo copyWith({
    int? id,
    String? title,
    String? category,
    DateTime? deadline,
    bool? isUrgent,
    bool? completed,
    String? username,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      isUrgent: isUrgent ?? this.isUrgent,
      completed: completed ?? this.completed,
      username: username ?? this.username,
    );
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      deadline: DateTime.parse(map['deadline']),
      isUrgent: map['isUrgent'] == 1,
      completed: map['completed'] == 1,
      username: map['username'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'deadline': deadline.toIso8601String(),
      'isUrgent': isUrgent ? 1 : 0,
      'completed': completed ? 1 : 0,
      'username': username,
    };
  }
}
