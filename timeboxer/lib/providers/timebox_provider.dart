import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import 'task_provider.dart';

class TimeBoxNotifier extends StateNotifier<List<TimeBox>> {
  final Box<TimeBox> _timeBoxBox;
  final Ref ref;

  TimeBoxNotifier(this._timeBoxBox, this.ref) : super([]) {
    _loadTimeBoxes();
  }

  void _loadTimeBoxes() {
    final boxes = _timeBoxBox.values.toList();
    boxes.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    state = boxes;
  }

  Future<void> addTimeBox(String title, int durationMinutes) async {
    final timeBox = TimeBox(
      title: title,
      durationMinutes: durationMinutes,
      orderIndex: _timeBoxBox.length,
    );
    
    // Save to local
    await _timeBoxBox.put(timeBox.id, timeBox);
    _loadTimeBoxes();
    
    // Sync to cloud
    await _syncToCloud(timeBox);
  }

  Future<void> updateTimeBox(TimeBox updatedTimeBox) async {
    // Update local
    await _timeBoxBox.put(updatedTimeBox.id, updatedTimeBox);
    _loadTimeBoxes();
    
    // Sync to cloud
    await _syncToCloud(updatedTimeBox);
  }

  Future<void> deleteTimeBox(String timeBoxId) async {
    final timeBox = _timeBoxBox.get(timeBoxId);
    if (timeBox != null) {
      // Move all tasks back to backlog
      final taskNotifier = ref.read(taskProvider.notifier);
      for (final taskId in timeBox.taskIds) {
        await taskNotifier.moveTaskToBacklog(taskId);
      }
    }
    
    // Delete from local
    await _timeBoxBox.delete(timeBoxId);
    _loadTimeBoxes();
    
    // Delete from cloud
    final syncMode = ref.read(syncModeProvider);
    if (syncMode == SyncMode.cloudSync) {
      final userId = ref.read(userIdProvider);
      if (userId != null) {
        final firestoreService = ref.read(firestoreServiceProvider);
        await firestoreService.deleteTimeBox(userId, timeBoxId);
      }
    }
  }

  Future<void> addTaskToTimeBox(
      String timeBoxId, Task task, int timeMinutes) async {
    final timeBox = _timeBoxBox.get(timeBoxId);
    if (timeBox != null) {
      final updatedTask = task.copyWith(
        timeBoxMinutes: timeMinutes,
        timeBoxId: timeBoxId,
      );
      
      // Update task
      await ref.read(taskProvider.notifier).updateTask(updatedTask);
      
      // Update timebox
      final updatedTimeBox = timeBox.copyWith(
        taskIds: [...timeBox.taskIds, task.id],
      );
      await updateTimeBox(updatedTimeBox);
    }
  }

  Future<void> removeTaskFromTimeBox(String timeBoxId, String taskId) async {
    final timeBox = _timeBoxBox.get(timeBoxId);
    if (timeBox != null) {
      final updatedTimeBox = timeBox.copyWith(
        taskIds: timeBox.taskIds.where((id) => id != taskId).toList(),
      );
      await updateTimeBox(updatedTimeBox);
    }
  }

  Future<void> reorderTimeBoxes(int oldIndex, int newIndex) async {
    final boxes = [...state];
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = boxes.removeAt(oldIndex);
    boxes.insert(newIndex, item);

    // Update order indices
    for (int i = 0; i < boxes.length; i++) {
      final updatedBox = boxes[i].copyWith(orderIndex: i);
      await _timeBoxBox.put(updatedBox.id, updatedBox);
      
      // Sync to cloud
      await _syncToCloud(updatedBox);
    }
    _loadTimeBoxes();
  }

  Future<void> reorderTasksInTimeBox(
      String timeBoxId, int oldIndex, int newIndex) async {
    final timeBox = _timeBoxBox.get(timeBoxId);
    if (timeBox != null) {
      final taskIds = [...timeBox.taskIds];
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final taskId = taskIds.removeAt(oldIndex);
      taskIds.insert(newIndex, taskId);

      final updatedTimeBox = timeBox.copyWith(taskIds: taskIds);
      await updateTimeBox(updatedTimeBox);
    }
  }

  Future<void> _syncToCloud(TimeBox timeBox) async {
    final syncMode = ref.read(syncModeProvider);
    if (syncMode == SyncMode.cloudSync) {
      final userId = ref.read(userIdProvider);
      if (userId != null) {
        final firestoreService = ref.read(firestoreServiceProvider);
        await firestoreService.addTimeBox(userId, timeBox);
      }
    }
  }

  // Load timeboxes from Firestore
  Future<void> loadFromFirestore(String userId) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final stream = firestoreService.getTimeBoxes(userId);
    
    await for (final timeBoxes in stream.take(1)) {
      // Clear local and add cloud timeboxes
      await _timeBoxBox.clear();
      for (final timeBox in timeBoxes) {
        await _timeBoxBox.put(timeBox.id, timeBox);
      }
      _loadTimeBoxes();
      break;
    }
  }
}

final timeBoxProvider =
    StateNotifierProvider<TimeBoxNotifier, List<TimeBox>>((ref) {
  final timeBoxBox = Hive.box<TimeBox>('timeboxes');
  return TimeBoxNotifier(timeBoxBox, ref);
});