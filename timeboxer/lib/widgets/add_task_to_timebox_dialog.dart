import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/timebox_provider.dart';
import '../providers/task_provider.dart';

class AddTaskToTimeBoxDialog extends ConsumerStatefulWidget {
  final Task task;
  final TimeBox timeBox;

  const AddTaskToTimeBoxDialog({
    super.key,
    required this.task,
    required this.timeBox,
  });

  @override
  ConsumerState<AddTaskToTimeBoxDialog> createState() =>
      _AddTaskToTimeBoxDialogState();
}

class _AddTaskToTimeBoxDialogState
    extends ConsumerState<AddTaskToTimeBoxDialog> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController(text: '30');

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskProvider);
    final totalTaskTime = widget.timeBox.getTotalTaskTime(allTasks);
    final remainingTime = widget.timeBox.durationMinutes - totalTaskTime;

    return AlertDialog(
      title: const Text('Add Task to TimeBox'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task: ${widget.task.title}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'TimeBox: ${widget.timeBox.title}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: remainingTime > 0
                    ? Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha:0.5)
                    : Theme.of(context)
                        .colorScheme
                        .errorContainer
                        .withValues(alpha:0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    remainingTime > 0 ? Icons.info_outline : Icons.warning,
                    color: remainingTime > 0
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      remainingTime > 0
                          ? 'Remaining: $remainingTime minutes'
                          : 'TimeBox is already full!',
                      style: TextStyle(
                        color: remainingTime > 0
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Estimated Duration',
                hintText: 'Enter duration',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
                suffixText: 'min',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a duration';
                }
                final duration = int.tryParse(value);
                if (duration == null || duration <= 0) {
                  return 'Please enter a valid duration';
                }
                return null;
              },
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _addTask,
          child: const Text('Add to TimeBox'),
        ),
      ],
    );
  }

  void _addTask() {
    if (_formKey.currentState!.validate()) {
      final duration = int.parse(_durationController.text.trim());

      // Update task status
      ref.read(taskProvider.notifier).updateTask(
            widget.task.copyWith(
              status: TaskStatus.timeboxed,
              timeBoxMinutes: duration,
            ),
          );

      // Add task to timebox
      ref.read(timeBoxProvider.notifier).addTaskToTimeBox(
            widget.timeBox.id,
            widget.task.copyWith(
              status: TaskStatus.timeboxed,
              timeBoxMinutes: duration,
            ),
            duration,
          );

      Navigator.of(context).pop();
    }
  }
}