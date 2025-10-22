import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String taskId;
  final String userId;
  final String taskName;
  final DateTime dueDate;
  final String category;
  final String? description;
  final DateTime? reminderTime;
  bool isCompleted;

  Task({
    required this.taskId,
    required this.userId,
    required this.taskName,
    required this.dueDate,
    required this.category,
    this.description,
    this.reminderTime,
    this.isCompleted = false,
  });

  // Firestore'dan veri okurken Task nesnesine dönüştürme
  factory Task.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    String id,
  ) {
    final data = snapshot.data();
    return Task(
      taskId: id,
      userId: data?['userId'] as String,
      taskName: data?['taskName'] as String,
      dueDate: (data?['dueDate'] as Timestamp).toDate(),
      category: data?['category'] as String,
      description: data?['description'] as String?,
      reminderTime: (data?['reminderTime'] as Timestamp?)?.toDate(),
      isCompleted: data?['isCompleted'] as bool? ?? false,
    );
  }

  // Task nesnesini Firestore'a yazmak için Map'e dönüştürme
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'taskName': taskName,
      'dueDate': Timestamp.fromDate(dueDate),
      'category': category,
      if (description != null) 'description': description,
      if (reminderTime != null)
        'reminderTime': Timestamp.fromDate(reminderTime!),
      'isCompleted': isCompleted,
    };
  }
}
