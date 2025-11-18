import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../services/local_storage_service.dart';
import 'task_provider.dart';

class TimeBoxNotifier extends StateNotifier<List<TimeBox>> {
  final Box<TimeBox> _timeBoxBox;
  final LocalStorageService _localStorageService;
  final Ref ref;

  TimeBoxNotifier(this._timeBoxBox, this._localStorageService, this.ref) : super([]) {
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

    await _timeBoxBox.put(timeBox.id, timeBox);
    await _localStorageService.addTimeBox(timeBox);
    _loadTimeBoxes();
  }

  Future<void> updateTimeBox(TimeBox updatedTimeBox) async {
    await _timeBoxBox.put(updatedTimeBox.id, updatedTimeBox);
    await _localStorageService.updateTimeBox(updatedTimeBox);
    _loadTimeBoxes();
  }

  Future<void> deleteTimeBox(String timeBoxId) async {
    final timeBox = _timeBoxBox.get(timeBoxId);
    if (timeBox != null) {
      final taskNotifier = ref.read(taskProvider.notifier);
      for (final taskId in timeBox.taskIds) {
        await taskNotifier.moveTaskToBacklog(taskId);
      }
    }

    await _timeBoxBox.delete(timeBoxId);
    await _localStorageService.deleteTimeBox(timeBoxId);
    _loadTimeBoxes();
  }

  Future<void> addTaskToTimeBox(
    String timeBoxId,
    Task task,
    int timeMinutes,
  ) async {
    final timeBox = _timeBoxBox.get(timeBoxId);
    if (timeBox != null) {
      final updatedTask = task.copyWith(
        timeBoxMinutes: timeMinutes,
        timeBoxId: timeBoxId,
      );

      await ref.read(taskProvider.notifier).updateTask(updatedTask);

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

    for (int i = 0; i < boxes.length; i++) {
      final updatedBox = boxes[i].copyWith(orderIndex: i);
      await _timeBoxBox.put(updatedBox.id, updatedBox);
      await _localStorageService.updateTimeBox(updatedBox);
    }
    _loadTimeBoxes();
  }

  Future<void> reorderTasksInTimeBox(
    String timeBoxId,
    int oldIndex,
    int newIndex,
  ) async {
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
}

final timeBoxProvider = StateNotifierProvider<TimeBoxNotifier, List<TimeBox>>((
  ref,
) {
  final timeBoxBox = Hive.box<TimeBox>('timeboxes');
  final localStorageService = ref.watch(localStorageServiceProvider);
  return TimeBoxNotifier(timeBoxBox, localStorageService, ref);
});
