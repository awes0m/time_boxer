import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';

class TaskNotifier extends StateNotifier<List<Task>> {
  final Box<Task> _taskBox;
  final Ref ref;

  TaskNotifier(this._taskBox, this.ref) : super([]) {
    _loadTasks();
  }

  void _loadTasks() {
    state = _taskBox.values.toList();
  }

  Future<void> addTask(
    String title, {
    String? description,
    TaskCategory category = TaskCategory.other,
  }) async {
    final task = Task(
      title: title,
      description: description,
      status: TaskStatus.backlog,
      category: category,
    );
    
    // Save to local
    await _taskBox.put(task.id, task);
    _loadTasks();
    
    // Sync to cloud if enabled
    await _syncToCloud(task);
  }

  Future<void> updateTask(Task updatedTask) async {
    // Update local
    await _taskBox.put(updatedTask.id, updatedTask);
    _loadTasks();
    
    // Sync to cloud if enabled
    await _syncToCloud(updatedTask);
  }

  Future<void> deleteTask(String taskId) async {
    // Delete from local
    await _taskBox.delete(taskId);
    _loadTasks();
    
    // Delete from cloud if enabled
    final syncMode = ref.read(syncModeProvider);
    if (syncMode == SyncMode.cloudSync) {
      final userId = ref.read(userIdProvider);
      if (userId != null) {
        final firestoreService = ref.read(firestoreServiceProvider);
        await firestoreService.deleteTask(userId, taskId);
      }
    }
  }

  Future<void> moveTaskToBacklog(String taskId) async {
    final task = _taskBox.get(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(
        status: TaskStatus.backlog,
        timeBoxMinutes: null,
        orderIndex: null,
        timeBoxId: null,
      );
      await updateTask(updatedTask);
    }
  }

  Future<void> toggleTaskComplete(String taskId) async {
    final task = _taskBox.get(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(
        status: task.status == TaskStatus.completed
            ? TaskStatus.timeboxed
            : TaskStatus.completed,
      );
      await updateTask(updatedTask);
    }
  }

  Future<void> _syncToCloud(Task task) async {
    final syncMode = ref.read(syncModeProvider);
    if (syncMode == SyncMode.cloudSync) {
      final userId = ref.read(userIdProvider);
      if (userId != null) {
        final firestoreService = ref.read(firestoreServiceProvider);
        await firestoreService.addTask(userId, task);
      }
    }
  }

  // Load tasks from Firestore
  Future<void> loadFromFirestore(String userId) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final stream = firestoreService.getTasks(userId);
    
    await for (final tasks in stream.take(1)) {
      // Clear local and add cloud tasks
      await _taskBox.clear();
      for (final task in tasks) {
        await _taskBox.put(task.id, task);
      }
      _loadTasks();
      break;
    }
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  final taskBox = Hive.box<Task>('tasks');
  return TaskNotifier(taskBox, ref);
});

final backlogTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((task) => task.status == TaskStatus.backlog).toList();
});

final timeboxedTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((task) => task.status == TaskStatus.timeboxed).toList();
});