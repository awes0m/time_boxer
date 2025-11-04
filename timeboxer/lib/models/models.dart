import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'models.g.dart';

const _uuid = Uuid();

@HiveType(typeId: 0)
enum TaskStatus {
  @HiveField(0)
  backlog,
  @HiveField(1)
  timeboxed,
  @HiveField(2)
  completed,
}

@HiveType(typeId: 3)
enum TaskCategory {
  @HiveField(0)
  work,
  @HiveField(1)
  personal,
  @HiveField(2)
  health,
  @HiveField(3)
  learning,
  @HiveField(4)
  other,
}

extension TaskCategoryExtension on TaskCategory {
  Color get color {
    switch (this) {
      case TaskCategory.work:
        return Colors.blue;
      case TaskCategory.personal:
        return Colors.purple;
      case TaskCategory.health:
        return Colors.green;
      case TaskCategory.learning:
        return Colors.orange;
      case TaskCategory.other:
        return Colors.grey;
    }
  }

  String get displayName {
    switch (this) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.learning:
        return 'Learning';
      case TaskCategory.other:
        return 'Other';
    }
  }
}

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late TaskStatus status;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  int? timeBoxMinutes;

  @HiveField(6)
  int? orderIndex;

  @HiveField(7)
  String? timeBoxId;

  @HiveField(8)
  late TaskCategory category;

  @HiveField(9)
  int? actualTimeSpent;

  @HiveField(10)
  DateTime? scheduledDate;

  @HiveField(11)
  TimeOfDay? scheduledTime;

  Task({
    String? id,
    required this.title,
    this.description,
    this.status = TaskStatus.backlog,
    DateTime? createdAt,
    this.timeBoxMinutes,
    this.orderIndex,
    this.timeBoxId,
    this.category = TaskCategory.other,
    this.actualTimeSpent,
    this.scheduledDate,
    this.scheduledTime,
  }) {
    this.id = id ?? _uuid.v4();
    this.createdAt = createdAt ?? DateTime.now();
  }

  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    int? timeBoxMinutes,
    int? orderIndex,
    String? timeBoxId,
    TaskCategory? category,
    int? actualTimeSpent,
    DateTime? scheduledDate,
    TimeOfDay? scheduledTime,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt,
      timeBoxMinutes: timeBoxMinutes ?? this.timeBoxMinutes,
      orderIndex: orderIndex ?? this.orderIndex,
      timeBoxId: timeBoxId ?? this.timeBoxId,
      category: category ?? this.category,
      actualTimeSpent: actualTimeSpent ?? this.actualTimeSpent,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }
}

@HiveType(typeId: 2)
class TimeBox extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late int durationMinutes;

  @HiveField(3)
  late List<String> taskIds;

  @HiveField(4)
  late int orderIndex;

  TimeBox({
    String? id,
    required this.title,
    required this.durationMinutes,
    List<String>? taskIds,
    required this.orderIndex,
  }) {
    this.id = id ?? _uuid.v4();
    this.taskIds = taskIds ?? [];
  }

  TimeBox copyWith({
    String? title,
    int? durationMinutes,
    List<String>? taskIds,
    int? orderIndex,
  }) {
    return TimeBox(
      id: id,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      taskIds: taskIds ?? this.taskIds,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  int getTotalTaskTime(List<Task> allTasks) {
    return taskIds.fold(0, (sum, taskId) {
      final task = allTasks.firstWhere(
        (t) => t.id == taskId,
        orElse: () => Task(title: ''),
      );
      return sum + (task.timeBoxMinutes ?? 0);
    });
  }

  bool isOverAllocated(List<Task> allTasks) =>
      getTotalTaskTime(allTasks) > durationMinutes;

  List<Task> getTasks(List<Task> allTasks) {
    return taskIds
        .map(
          (id) => allTasks.firstWhere(
            (t) => t.id == id,
            orElse: () => Task(title: ''),
          ),
        )
        .where((t) => t.title.isNotEmpty)
        .toList();
  }
}
