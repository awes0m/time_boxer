import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../services/local_storage_service.dart';

class TaskNotifier extends StateNotifier<List<Task>> {
  final Box<Task> _taskBox;
  final LocalStorageService _localStorageService;
  final Ref ref;

  TaskNotifier(this._taskBox, this._localStorageService, this.ref) : super([]) {
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

    await _taskBox.put(task.id, task);
    await _localStorageService.addTask(task);
    _loadTasks();
  }

  Future<void> updateTask(Task updatedTask) async {
    await _taskBox.put(updatedTask.id, updatedTask);
    await _localStorageService.updateTask(updatedTask);
    _loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await _taskBox.delete(taskId);
    await _localStorageService.deleteTask(taskId);
    _loadTasks();
  }

  Future<void> moveTaskToBacklog(String taskId) async {
    final task = _taskBox.get(taskId);
    if (task != null) {
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        status: TaskStatus.backlog,
        createdAt: task.createdAt,
        timeBoxMinutes: null,
        orderIndex: null,
        timeBoxId: null,
        category: task.category,
        actualTimeSpent: task.actualTimeSpent,
        scheduledDate: null,
        scheduledTime: null,
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
}

final localStorageServiceProvider = 
    Provider<LocalStorageService>((ref) => LocalStorageService());

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  final taskBox = Hive.box<Task>('tasks');
  final localStorageService = ref.watch(localStorageServiceProvider);
  return TaskNotifier(taskBox, localStorageService, ref);
});

final backlogTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((task) => task.status == TaskStatus.backlog).toList();
});

final timeboxedTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((task) => task.status == TaskStatus.timeboxed).toList();
});
