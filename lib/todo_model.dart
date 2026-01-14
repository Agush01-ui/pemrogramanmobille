import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Todo {
  String id;
  String title;
  String category;
  String? locationName;
  DateTime? deadline;
  TimeOfDay? time;
  bool isUrgent;
  bool isCompleted;
  String username;

  // 🔹 TAMBAHAN LOKASI
  double? latitude;
  double? longitude;

  Todo({
    required this.id,
    required this.title,
    required this.category,
    this.deadline,
    this.time,
    this.isUrgent = false,
    this.isCompleted = false,
    required this.username,
    this.latitude,
    this.longitude,
  });

  // ===============================
  // FORMAT WAKTU
  // ===============================

  String get formattedTime {
    if (time == null) return "";
    return "${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}";
  }

  String get hourDisplay {
    if (time == null) return "--";
    return time!.hour.toString().padLeft(2, '0');
  }

  String get minuteDisplay {
    if (time == null) return "--";
    return time!.minute.toString().padLeft(2, '0');
  }

  // ===============================
  // GABUNGAN DATE + TIME
  // ===============================

  DateTime? get fullDateTime {
    if (deadline == null || time == null) return deadline;
    return DateTime(
      deadline!.year,
      deadline!.month,
      deadline!.day,
      time!.hour,
      time!.minute,
    );
  }

  // ===============================
  // FORMAT DEADLINE
  // ===============================

  String get formattedDeadline {
    if (deadline == null) return "";
    return DateFormat('dd MMM yyyy').format(deadline!);
  }

  // ===============================
  // FROM MAP (DATABASE)
  // ===============================

  factory Todo.fromMap(Map<String, dynamic> map) {
    TimeOfDay? parsedTime;
    if (map['time'] != null && map['time'].toString().isNotEmpty) {
      final parts = map['time'].toString().split(':');
      if (parts.length == 2) {
        parsedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    return Todo(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      deadline:
          map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      time: parsedTime,
      isUrgent: map['isUrgent'] == 1,
      isCompleted: map['isCompleted'] == 1,
      username: map['username'] ?? 'Pengguna',

      // 🔹 LOKASI
      latitude: map['latitude'] != null ? map['latitude'] as double : null,
      longitude: map['longitude'] != null ? map['longitude'] as double : null,
    );
  }

  // ===============================
  // TO MAP (DATABASE)
  // ===============================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'deadline': deadline?.toIso8601String(),
      'time': time != null ? '${time!.hour}:${time!.minute}' : null,
      'isUrgent': isUrgent ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
      'username': username,

      // 🔹 LOKASI
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
