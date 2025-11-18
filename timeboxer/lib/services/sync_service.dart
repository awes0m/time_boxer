import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

enum SyncMode { localOnly }

class SyncService {
  final SyncMode _syncMode = SyncMode.localOnly;

  SyncService();

  SyncMode get syncMode => _syncMode;

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

  // Get local data count
  Map<String, int> getLocalDataCount() {
    final taskBox = Hive.box<Task>('tasks');
    final timeBoxBox = Hive.box<TimeBox>('timeboxes');

    return {
      'tasks': taskBox.length,
      'timeboxes': timeBoxBox.length,
    };
  }
}

// Provider for SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});

// Provider for sync mode
final syncModeProvider = Provider<SyncMode>((ref) {
  return SyncMode.localOnly;
});
