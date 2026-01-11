import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Todo {
  String id;
  String title;
  String category;
  DateTime? deadline;
  TimeOfDay? time; // TAMBAHAN: Field waktu spesifik
  bool isUrgent;
  bool isCompleted;
  String username;

  Todo({
    required this.id,
    required this.title,
    required this.category,
    this.deadline,
    this.time, // TAMBAHAN: Waktu spesifik task
    this.isUrgent = false,
    this.isCompleted = false,
    required this.username,
  });

  // TAMBAHAN: Getter untuk format waktu
  String get formattedTime {
    if (time == null) return "";
    return "${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}";
  }

  // TAMBAHAN: Getter untuk display jam besar
  String get hourDisplay {
    if (time == null) return "--";
    return time!.hour.toString().padLeft(2, '0');
  }

  // TAMBAHAN: Getter untuk display menit
  String get minuteDisplay {
    if (time == null) return "--";
    return time!.minute.toString().padLeft(2, '0');
  }

  // TAMBAHAN: Gabungan DateTime dari deadline dan time
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
      time: parsedTime, // TAMBAHAN: Parse waktu dari string
      isUrgent: map['isUrgent'] == 1,
      isCompleted: map['isCompleted'] == 1,
      username: map['username'] ?? 'Pengguna',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'deadline': deadline?.toIso8601String(),
      'time': time != null
          ? '${time!.hour}:${time!.minute}'
          : null, // TAMBAHAN: Simpan waktu
      'isUrgent': isUrgent ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
      'username': username,
    };
  }
}
