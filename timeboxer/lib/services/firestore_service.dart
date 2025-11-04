import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tasks collection reference for a user
  CollectionReference _tasksCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // TimeBoxes collection reference for a user
  CollectionReference _timeBoxesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('timeboxes');
  }

  // ============ TASK OPERATIONS ============

  // Get all tasks for a user
  Stream<List<Task>> getTasks(String userId) {
    return _tasksCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return _taskFromFirestore(doc);
      }).toList();
    });
  }

  // Add task
  Future<void> addTask(String userId, Task task) async {
    await _tasksCollection(userId).doc(task.id).set(_taskToMap(task));
  }

  // Update task
  Future<void> updateTask(String userId, Task task) async {
    await _tasksCollection(userId).doc(task.id).update(_taskToMap(task));
  }

  // Delete task
  Future<void> deleteTask(String userId, String taskId) async {
    await _tasksCollection(userId).doc(taskId).delete();
  }

  // Batch update tasks
  Future<void> batchUpdateTasks(String userId, List<Task> tasks) async {
    final batch = _firestore.batch();
    for (final task in tasks) {
      batch.set(
        _tasksCollection(userId).doc(task.id),
        _taskToMap(task),
      );
    }
    await batch.commit();
  }

  // ============ TIMEBOX OPERATIONS ============

  // Get all timeboxes for a user
  Stream<List<TimeBox>> getTimeBoxes(String userId) {
    return _timeBoxesCollection(userId)
        .orderBy('orderIndex')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return _timeBoxFromFirestore(doc);
      }).toList();
    });
  }

  // Add timebox
  Future<void> addTimeBox(String userId, TimeBox timeBox) async {
    await _timeBoxesCollection(userId)
        .doc(timeBox.id)
        .set(_timeBoxToMap(timeBox));
  }

  // Update timebox
  Future<void> updateTimeBox(String userId, TimeBox timeBox) async {
    await _timeBoxesCollection(userId)
        .doc(timeBox.id)
        .update(_timeBoxToMap(timeBox));
  }

  // Delete timebox
  Future<void> deleteTimeBox(String userId, String timeBoxId) async {
    await _timeBoxesCollection(userId).doc(timeBoxId).delete();
  }

  // Batch update timeboxes
  Future<void> batchUpdateTimeBoxes(
      String userId, List<TimeBox> timeBoxes) async {
    final batch = _firestore.batch();
    for (final timeBox in timeBoxes) {
      batch.set(
        _timeBoxesCollection(userId).doc(timeBox.id),
        _timeBoxToMap(timeBox),
      );
    }
    await batch.commit();
  }

  // ============ SYNC OPERATIONS ============

  // Sync local data to Firestore
  Future<void> syncToFirestore(
    String userId,
    List<Task> tasks,
    List<TimeBox> timeBoxes,
  ) async {
    await batchUpdateTasks(userId, tasks);
    await batchUpdateTimeBoxes(userId, timeBoxes);
  }

  // Clear all user data
  Future<void> clearUserData(String userId) async {
    final batch = _firestore.batch();

    // Delete all tasks
    final tasks = await _tasksCollection(userId).get();
    for (final doc in tasks.docs) {
      batch.delete(doc.reference);
    }

    // Delete all timeboxes
    final timeBoxes = await _timeBoxesCollection(userId).get();
    for (final doc in timeBoxes.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // ============ CONVERSION HELPERS ============

  Task _taskFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    TimeOfDay? scheduledTime;
    if (data['scheduledTimeHour'] != null && 
        data['scheduledTimeMinute'] != null) {
      scheduledTime = TimeOfDay(
        hour: data['scheduledTimeHour'] as int,
        minute: data['scheduledTimeMinute'] as int,
      );
    }

    return Task(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String?,
      status: TaskStatus.values[data['status'] as int],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      timeBoxMinutes: data['timeBoxMinutes'] as int?,
      orderIndex: data['orderIndex'] as int?,
      timeBoxId: data['timeBoxId'] as String?,
      category: TaskCategory.values[data['category'] as int? ?? 4],
      actualTimeSpent: data['actualTimeSpent'] as int?,
      scheduledDate: data['scheduledDate'] != null
          ? (data['scheduledDate'] as Timestamp).toDate()
          : null,
      scheduledTime: scheduledTime,
    );
  }

  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'title': task.title,
      'description': task.description,
      'status': task.status.index,
      'createdAt': Timestamp.fromDate(task.createdAt),
      'timeBoxMinutes': task.timeBoxMinutes,
      'orderIndex': task.orderIndex,
      'timeBoxId': task.timeBoxId,
      'category': task.category.index,
      'actualTimeSpent': task.actualTimeSpent,
      'scheduledDate': task.scheduledDate != null
          ? Timestamp.fromDate(task.scheduledDate!)
          : null,
      'scheduledTimeHour': task.scheduledTime?.hour,
      'scheduledTimeMinute': task.scheduledTime?.minute,
    };
  }

  TimeBox _timeBoxFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimeBox(
      id: doc.id,
      title: data['title'] as String,
      durationMinutes: data['durationMinutes'] as int,
      taskIds: List<String>.from(data['taskIds'] as List),
      orderIndex: data['orderIndex'] as int,
    );
  }

  Map<String, dynamic> _timeBoxToMap(TimeBox timeBox) {
    return {
      'title': timeBox.title,
      'durationMinutes': timeBox.durationMinutes,
      'taskIds': timeBox.taskIds,
      'orderIndex': timeBox.orderIndex,
    };
  }
}