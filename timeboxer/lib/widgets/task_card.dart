import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/task_provider.dart';

class TaskCard extends ConsumerWidget {
  final Task task;
  final bool isDragging;
  final bool showCheckbox;
  final VoidCallback? onDelete;
  final bool showScheduleButton;

  const TaskCard({
    super.key,
    required this.task,
    this.isDragging = false,
    this.showCheckbox = false,
    this.onDelete,
    this.showScheduleButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = task.status == TaskStatus.completed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      elevation: isDragging ? 8 : 1,
      child: InkWell(
        onTap: showCheckbox
            ? () => ref.read(taskProvider.notifier).toggleTaskComplete(task.id)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: task.category.color,
                width: 4,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
            children: [
              if (showCheckbox)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Checkbox(
                    value: isCompleted,
                    onChanged: (_) => ref
                        .read(taskProvider.notifier)
                        .toggleTaskComplete(task.id),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.drag_indicator,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5)
                                : null,
                          ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (task.timeBoxMinutes != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.timeBoxMinutes} min',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onDelete,
                  color:
                      Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
                ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}