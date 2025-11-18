import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class LocalStorageService {
  static const String _dataFileName = 'timeboxer_data.json';

  Future<Directory> _getAppDataDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  Future<File> _getDataFile() async {
    final dir = await _getAppDataDirectory();
    return File('${dir.path}/$_dataFileName');
  }

  Future<Map<String, dynamic>> _readDataFile() async {
    try {
      final file = await _getDataFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        return jsonDecode(contents) as Map<String, dynamic>;
      }
      return {'tasks': [], 'timeboxes': []};
    } catch (e) {
      return {'tasks': [], 'timeboxes': []};
    }
  }

  Future<void> _writeDataFile(Map<String, dynamic> data) async {
    final file = await _getDataFile();
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> addTask(Task task) async {
    final data = await _readDataFile();
    final tasks = data['tasks'] as List? ?? [];
    tasks.add(_taskToMap(task));
    data['tasks'] = tasks;
    await _writeDataFile(data);
  }

  Future<void> updateTask(Task task) async {
    final data = await _readDataFile();
    final tasks = data['tasks'] as List? ?? [];
    final index = tasks.indexWhere((t) => t['id'] == task.id);
    if (index != -1) {
      tasks[index] = _taskToMap(task);
    }
    data['tasks'] = tasks;
    await _writeDataFile(data);
  }

  Future<void> deleteTask(String taskId) async {
    final data = await _readDataFile();
    final tasks = data['tasks'] as List? ?? [];
    tasks.removeWhere((t) => t['id'] == taskId);
    data['tasks'] = tasks;
    await _writeDataFile(data);
  }

  Future<List<Task>> getTasks() async {
    final data = await _readDataFile();
    final tasks = data['tasks'] as List? ?? [];
    return tasks.map((task) => _taskFromMap(task)).toList();
  }

  Future<void> addTimeBox(TimeBox timeBox) async {
    final data = await _readDataFile();
    final timeboxes = data['timeboxes'] as List? ?? [];
    timeboxes.add(_timeBoxToMap(timeBox));
    data['timeboxes'] = timeboxes;
    await _writeDataFile(data);
  }

  Future<void> updateTimeBox(TimeBox timeBox) async {
    final data = await _readDataFile();
    final timeboxes = data['timeboxes'] as List? ?? [];
    final index = timeboxes.indexWhere((tb) => tb['id'] == timeBox.id);
    if (index != -1) {
      timeboxes[index] = _timeBoxToMap(timeBox);
    }
    data['timeboxes'] = timeboxes;
    await _writeDataFile(data);
  }

  Future<void> deleteTimeBox(String timeBoxId) async {
    final data = await _readDataFile();
    final timeboxes = data['timeboxes'] as List? ?? [];
    timeboxes.removeWhere((tb) => tb['id'] == timeBoxId);
    data['timeboxes'] = timeboxes;
    await _writeDataFile(data);
  }

  Future<List<TimeBox>> getTimeBoxes() async {
    final data = await _readDataFile();
    final timeboxes = data['timeboxes'] as List? ?? [];
    return timeboxes.map((tb) => _timeBoxFromMap(tb)).toList();
  }

  Future<void> batchUpdateTasks(List<Task> tasks) async {
    final data = await _readDataFile();
    data['tasks'] = tasks.map((task) => _taskToMap(task)).toList();
    await _writeDataFile(data);
  }

  Future<void> batchUpdateTimeBoxes(List<TimeBox> timeBoxes) async {
    final data = await _readDataFile();
    data['timeboxes'] = timeBoxes.map((tb) => _timeBoxToMap(tb)).toList();
    await _writeDataFile(data);
  }

  Future<void> clearAllData() async {
    await _writeDataFile({'tasks': [], 'timeboxes': []});
  }

  Future<String> exportData() async {
    final data = await _readDataFile();
    return jsonEncode(data);
  }

  Future<void> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      await _writeDataFile(data);
      await _loadDataToHive(data);
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  Future<File> exportDataToFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final exportFile = File('${dir.path}/timeboxer_export_$timestamp.json');
    final data = await _readDataFile();
    await exportFile.writeAsString(jsonEncode(data));
    return exportFile;
  }

  Future<void> importDataFromFile(File file) async {
    try {
      final contents = await file.readAsString();
      final data = jsonDecode(contents) as Map<String, dynamic>;
      await _writeDataFile(data);
      await _loadDataToHive(data);
    } catch (e) {
      throw Exception('Failed to import data from file: $e');
    }
  }

  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'status': task.status.index,
      'createdAt': task.createdAt.toIso8601String(),
      'timeBoxMinutes': task.timeBoxMinutes,
      'orderIndex': task.orderIndex,
      'timeBoxId': task.timeBoxId,
      'category': task.category.index,
      'actualTimeSpent': task.actualTimeSpent,
      'scheduledDate': task.scheduledDate?.toIso8601String(),
      'scheduledTimeHour': task.scheduledTime?.hour,
      'scheduledTimeMinute': task.scheduledTime?.minute,
    };
  }

  Task _taskFromMap(Map<String, dynamic> map) {
    TimeOfDay? scheduledTime;
    if (map['scheduledTimeHour'] != null && map['scheduledTimeMinute'] != null) {
      scheduledTime = TimeOfDay(
        hour: map['scheduledTimeHour'] as int,
        minute: map['scheduledTimeMinute'] as int,
      );
    }

    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      status: TaskStatus.values[map['status'] as int? ?? 0],
      createdAt: DateTime.parse(map['createdAt'] as String),
      timeBoxMinutes: map['timeBoxMinutes'] as int?,
      orderIndex: map['orderIndex'] as int?,
      timeBoxId: map['timeBoxId'] as String?,
      category: TaskCategory.values[map['category'] as int? ?? 4],
      actualTimeSpent: map['actualTimeSpent'] as int?,
      scheduledDate: map['scheduledDate'] != null
          ? DateTime.parse(map['scheduledDate'] as String)
          : null,
      scheduledTime: scheduledTime,
    );
  }

  Map<String, dynamic> _timeBoxToMap(TimeBox timeBox) {
    return {
      'id': timeBox.id,
      'title': timeBox.title,
      'durationMinutes': timeBox.durationMinutes,
      'taskIds': timeBox.taskIds,
      'orderIndex': timeBox.orderIndex,
    };
  }

  TimeBox _timeBoxFromMap(Map<String, dynamic> map) {
    return TimeBox(
      id: map['id'] as String,
      title: map['title'] as String,
      durationMinutes: map['durationMinutes'] as int,
      taskIds: List<String>.from(map['taskIds'] as List? ?? []),
      orderIndex: map['orderIndex'] as int,
    );
  }

  Future<void> _loadDataToHive(Map<String, dynamic> data) async {
    try {
      if (!Hive.isBoxOpen('tasks')) {
        await Hive.openBox<Task>('tasks');
      }
      if (!Hive.isBoxOpen('timeboxes')) {
        await Hive.openBox<TimeBox>('timeboxes');
      }

      final taskBox = Hive.box<Task>('tasks');
      final timeboxBox = Hive.box<TimeBox>('timeboxes');

      await taskBox.clear();
      await timeboxBox.clear();

      final tasks = data['tasks'] as List? ?? [];
      for (final taskData in tasks) {
        final task = _taskFromMap(taskData as Map<String, dynamic>);
        await taskBox.put(task.id, task);
      }

      final timeboxes = data['timeboxes'] as List? ?? [];
      for (final timeboxData in timeboxes) {
        final timebox = _timeBoxFromMap(timeboxData as Map<String, dynamic>);
        await timeboxBox.put(timebox.id, timebox);
      }
    } catch (e) {
      throw Exception('Failed to load data to Hive: $e');
    }
  }
}
