import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/task_provider.dart';

class CalendarTaskCard extends ConsumerWidget {
  final Task task;

  const CalendarTaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = task.status == TaskStatus.completed;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
      color: task.category.color.withOpacity(isCompleted ? 0.3 : 0.8),
      child: InkWell(
        onTap: () {
          ref.read(taskProvider.notifier).toggleTaskComplete(task.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (isCompleted)
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.white,
                    )
                  else
                    const Icon(
                      Icons.circle_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (task.description != null &&
                  task.description!.isNotEmpty &&
                  task.timeBoxMinutes != null &&
                  task.timeBoxMinutes! >= 60) ...[
                const SizedBox(height: 4),
                Text(
                  task.description!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (task.timeBoxMinutes != null) ...[
                const SizedBox(height: 2),
                Text(
                  '${task.timeBoxMinutes} min',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}