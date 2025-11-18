import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/task_provider.dart';
import 'edit_task_dialog.dart';

class CalendarTaskCard extends ConsumerWidget {
  final Task task;
  final VoidCallback? onTap;

  const CalendarTaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = task.status == TaskStatus.completed;
    final isSmallBlock = task.timeBoxMinutes != null && task.timeBoxMinutes! < 45;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
      color: task.category.color.withValues(alpha:isCompleted ? 0.3 : 0.9),
      elevation: 2,
      child: InkWell(
        onTap: onTap ?? () {
          _showTaskOptions(context, ref);
        },
        onLongPress: () => _showTaskOptions(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isSmallBlock ? 4 : 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      ref.read(taskProvider.notifier).toggleTaskComplete(task.id);
                    },
                    child: Icon(
                      isCompleted ? Icons.check_circle : Icons.circle_outlined,
                      size: isSmallBlock ? 14 : 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallBlock ? 11 : 13,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: isSmallBlock ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.more_vert,
                    size: 16,
                    color: Colors.white.withValues(alpha:0.7),
                  ),
                ],
              ),
              if (!isSmallBlock) ...[
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.9),
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (task.scheduledTime != null) ...[
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.white.withValues(alpha:0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.scheduledTime!.format(context),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha:0.8),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (task.timeBoxMinutes != null) ...[
                      Icon(
                        Icons.timer,
                        size: 12,
                        color: Colors.white.withValues(alpha:0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task.timeBoxMinutes} min',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha:0.8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ] else ...[
                const SizedBox(height: 2),
                Text(
                  '${task.timeBoxMinutes ?? 0} min',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.8),
                    fontSize: 9,
                  ),
                ),
              ],
              if (task.category != TaskCategory.other && !isSmallBlock) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.category.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                task.status == TaskStatus.completed
                    ? Icons.undo
                    : Icons.check_circle,
              ),
              title: Text(
                task.status == TaskStatus.completed
                    ? 'Mark Incomplete'
                    : 'Mark Complete',
              ),
              onTap: () {
                ref.read(taskProvider.notifier).toggleTaskComplete(task.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Task'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => EditTaskDialog(task: task),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Start Focus Timer'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to focus timer
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Remove from Calendar'),
              onTap: () {
                final updatedTask = Task(
                  id: task.id,
                  title: task.title,
                  description: task.description,
                  status: TaskStatus.backlog,
                  createdAt: task.createdAt,
                  category: task.category,
                );
                ref.read(taskProvider.notifier).updateTask(updatedTask);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Task'),
              onTap: () {
                Navigator.pop(context);
                _deleteTask(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTask(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(taskProvider.notifier).deleteTask(task.id);
    }
  }
}