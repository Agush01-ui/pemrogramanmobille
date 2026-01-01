class Todo {
  String id;
  String title;
  String category;
  DateTime? deadline;
  bool isUrgent;
  bool isCompleted;
  String username; // <--- PROPERTI BARU (PEMILIK TUGAS)

  Todo({
    required this.id,
    required this.title,
    required this.category,
    this.deadline,
    this.isUrgent = false,
    this.isCompleted = false,
    required this.username, // <--- WAJIB DIISI
  });

  // Konversi dari Database ke Object
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      deadline:
          map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      isUrgent: map['isUrgent'] == 1,
      isCompleted: map['isCompleted'] == 1,
      username: map['username'] ?? 'Pengguna', // <--- AMBIL DARI DB
    );
  }

  // Konversi dari Object ke Database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'deadline': deadline?.toIso8601String(),
      'isUrgent': isUrgent ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
      'username': username, // <--- SIMPAN KE DB
    };
  }
}