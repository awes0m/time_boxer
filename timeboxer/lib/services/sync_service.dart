import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import 'firestore_service.dart';

enum SyncMode { localOnly, cloudSync }

class SyncService {
  final FirestoreService _firestoreService;
  SyncMode _syncMode = SyncMode.localOnly;

  SyncService(this._firestoreService);

  SyncMode get syncMode => _syncMode;

  // Enable cloud sync
  void enableCloudSync() {
    _syncMode = SyncMode.cloudSync;
  }

  // Disable cloud sync (use local only)
  void disableCloudSync() {
    _syncMode = SyncMode.localOnly;
  }

  // Sync local Hive data to Firestore
  Future<void> syncLocalToCloud(String userId) async {
    final taskBox = Hive.box<Task>('tasks');
    final timeBoxBox = Hive.box<TimeBox>('timeboxes');

    final tasks = taskBox.values.toList();
    final timeBoxes = timeBoxBox.values.toList();

    await _firestoreService.syncToFirestore(userId, tasks, timeBoxes);
  }

  // Sync Firestore data to local Hive
  Future<void> syncCloudToLocal(
    String userId,
    List<Task> cloudTasks,
    List<TimeBox> cloudTimeBoxes,
  ) async {
    final taskBox = Hive.box<Task>('tasks');
    final timeBoxBox = Hive.box<TimeBox>('timeboxes');

    // Clear local data
    await taskBox.clear();
    await timeBoxBox.clear();

    // Add cloud data to local
    for (final task in cloudTasks) {
      await taskBox.put(task.id, task);
    }

    for (final timeBox in cloudTimeBoxes) {
      await timeBoxBox.put(timeBox.id, timeBox);
    }
  }

  // Clear all local data
  Future<void> clearLocalData() async {
    final taskBox = Hive.box<Task>('tasks');
    final timeBoxBox = Hive.box<TimeBox>('timeboxes');

    await taskBox.clear();
    await timeBoxBox.clear();
  }

  // Check if local data exists
  bool hasLocalData() {
    final taskBox = Hive.box<Task>('tasks');
    final timeBoxBox = Hive.box<TimeBox>('timeboxes');

    return taskBox.isNotEmpty || timeBoxBox.isNotEmpty;
  }
}

// Provider for FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Provider for SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return SyncService(firestoreService);
});

// Provider for sync mode
final syncModeProvider = StateProvider<SyncMode>((ref) {
  return SyncMode.localOnly;
});