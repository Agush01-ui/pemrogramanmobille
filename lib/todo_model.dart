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
    this.locationName, // Tambahkan di constructor
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
  // FORMAT LOKASI SINGKAT
  // ===============================

  String get shortLocation {
    if (locationName == null) return "Tanpa Lokasi";
    if (locationName!.length > 30) {
      return locationName!.substring(0, 27) + "...";
    }
    return locationName!;
  }

  // ===============================
  // STATUS WAKTU
  // ===============================

  String get timeStatus {
    final now = DateTime.now();
    final fullDateTime = this.fullDateTime;

    if (fullDateTime == null) return "Tidak ada batas waktu";

    final difference = fullDateTime.difference(now);

    if (difference.isNegative) {
      return "Terlambat ${DateFormat('dd MMM').format(fullDateTime)}";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} hari lagi";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} jam lagi";
    } else {
      return "Kurang dari 1 jam";
    }
  }

  // ===============================
  // WARN STATUS BERDASARKAN WAKTU
  // ===============================

  Color get statusColor {
    final now = DateTime.now();
    final fullDateTime = this.fullDateTime;

    if (fullDateTime == null) return Colors.grey;

    final difference = fullDateTime.difference(now);

    if (difference.isNegative) {
      return Colors.red;
    } else if (difference.inHours < 24) {
      return Colors.orange;
    } else if (difference.inDays < 3) {
      return Colors.yellow[700]!;
    } else {
      return Colors.green;
    }
  }

  // ===============================
  // FROM MAP (DATABASE)
  // ===============================

  factory Todo.fromMap(Map<String, dynamic> map) {
    TimeOfDay? parsedTime;

    // Parse waktu dari format "HH:mm"
    if (map['time'] != null && map['time'].toString().isNotEmpty) {
      final timeString = map['time'].toString();
      if (timeString.contains(':')) {
        final parts = timeString.split(':');
        if (parts.length == 2) {
          try {
            parsedTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          } catch (e) {
            print("Error parsing time: $e");
          }
        }
      }
    }

    // Parse tanggal deadline
    DateTime? parsedDeadline;
    if (map['deadline'] != null && map['deadline'].toString().isNotEmpty) {
      try {
        parsedDeadline = DateTime.parse(map['deadline'].toString());
      } catch (e) {
        print("Error parsing deadline: $e");
      }
    }

    // Parse lokasi - PERBAIKAN DI SINI
    double? parsedLat;
    double? parsedLng;
    if (map['latitude'] != null) {
      parsedLat = double.tryParse(map['latitude'].toString());
    }
    if (map['longitude'] != null) {
      parsedLng = double.tryParse(map['longitude'].toString());
    }

    return Todo(
      id: map['id'].toString(),
      title: map['title'].toString(),
      category: map['category'].toString(),
      deadline: parsedDeadline,
      time: parsedTime,
      isUrgent: map['isUrgent'] == 1 || map['isUrgent'] == true,
      isCompleted: map['isCompleted'] == 1 || map['isCompleted'] == true,
      username: map['username']?.toString() ?? 'Pengguna',

      // 🔹 LOKASI - PERBAIKAN
      latitude: parsedLat,
      longitude: parsedLng,
      locationName:
          map['location_name']?.toString(), // BENAR: String, bukan double
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
      'time': time != null
          ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
          : null,
      'isUrgent': isUrgent ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
      'username': username,

      // 🔹 LOKASI
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
    };
  }

  // ===============================
  // COPY WITH (UNTUK UPDATE)
  // ===============================

  Todo copyWith({
    String? id,
    String? title,
    String? category,
    String? locationName,
    DateTime? deadline,
    TimeOfDay? time,
    bool? isUrgent,
    bool? isCompleted,
    String? username,
    double? latitude,
    double? longitude,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      time: time ?? this.time,
      isUrgent: isUrgent ?? this.isUrgent,
      isCompleted: isCompleted ?? this.isCompleted,
      username: username ?? this.username,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
    );
  }

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, category: $category, location: ${locationName ?? "none"}, deadline: $deadline, time: $time, urgent: $isUrgent, completed: $isCompleted, lat: $latitude, lng: $longitude)';
  }
}
