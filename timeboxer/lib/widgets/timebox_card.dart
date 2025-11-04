import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/timebox_provider.dart';
import '../providers/task_provider.dart';
import 'task_card.dart';
import 'add_task_to_timebox_dialog.dart';

class TimeBoxCard extends ConsumerWidget {
  final TimeBox timeBox;

  const TimeBoxCard({
    super.key,
    required this.timeBox,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(taskProvider);
    final tasks = timeBox.getTasks(allTasks);
    final totalTaskTime = timeBox.getTotalTaskTime(allTasks);
    final isOverAllocated = timeBox.isOverAllocated(allTasks);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isOverAllocated
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: isOverAllocated
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeBox.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isOverAllocated
                                  ? Theme.of(context).colorScheme.onErrorContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalTaskTime/${timeBox.durationMinutes} minutes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isOverAllocated
                                  ? Theme.of(context).colorScheme.onErrorContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isOverAllocated)
                  Tooltip(
                    message: 'Time allocation exceeds box duration',
                    child: Icon(
                      Icons.warning,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    ref.read(timeBoxProvider.notifier).deleteTimeBox(timeBox.id);
                  },
                  color: isOverAllocated
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ),
          // Progress bar
          LinearProgressIndicator(
            value: timeBox.durationMinutes > 0
                ? (totalTaskTime / timeBox.durationMinutes).clamp(0.0, 1.0)
                : 0,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            color: isOverAllocated
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
          ),
          // Task drop zone
          DragTarget<Task>(
            onWillAcceptWithDetails: (details) {
              return details.data.status == TaskStatus.backlog;
            },
            onAcceptWithDetails: (details) {
              _showAddTaskToTimeBoxDialog(context, ref, details.data);
            },
            builder: (context, candidateData, rejectedData) {
              final isDragOver = candidateData.isNotEmpty;
              return Container(
                decoration: BoxDecoration(
                  color: isDragOver
                      ? Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.3)
                      : null,
                  border: isDragOver
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                constraints: const BoxConstraints(minHeight: 100),
                child: tasks.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            isDragOver
                                ? 'Drop task here'
                                : 'Drag tasks here to add them',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                                ),
                          ),
                        ),
                      )
                    : ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        itemCount: tasks.length,
                        onReorder: (oldIndex, newIndex) {
                          ref
                              .read(timeBoxProvider.notifier)
                              .reorderTasksInTimeBox(
                                timeBox.id,
                                oldIndex,
                                newIndex,
                              );
                        },
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskCard(
                            key: ValueKey(task.id),
                            task: task,
                            showCheckbox: true,
                            onDelete: () {
                              ref
                                  .read(timeBoxProvider.notifier)
                                  .removeTaskFromTimeBox(timeBox.id, task.id);
                              ref
                                  .read(taskProvider.notifier)
                                  .moveTaskToBacklog(task.id);
                            },
                          );
                        },
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddTaskToTimeBoxDialog(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddTaskToTimeBoxDialog(
        task: task,
        timeBox: timeBox,
      ),
    );
  }
}