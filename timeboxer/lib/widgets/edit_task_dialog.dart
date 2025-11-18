import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/task_provider.dart';

class EditTaskDialog extends ConsumerStatefulWidget {
  final Task task;

  const EditTaskDialog({super.key, required this.task});

  @override
  ConsumerState<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends ConsumerState<EditTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskCategory _selectedCategory;
  late int _duration;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _selectedCategory = widget.task.category;
    _duration = widget.task.timeBoxMinutes ?? 30;
    _scheduledDate = widget.task.scheduledDate;
    _scheduledTime = widget.task.scheduledTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.task),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskCategory>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: TaskCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(category.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Scheduled Date'),
              subtitle: Text(
                _scheduledDate != null
                    ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                    : 'Not scheduled',
              ),
              trailing: _scheduledDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _scheduledDate = null;
                          _scheduledTime = null;
                        });
                      },
                    )
                  : null,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _scheduledDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _scheduledDate = date;
                  });
                }
              },
            ),
            if (_scheduledDate != null) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: const Text('Scheduled Time'),
                subtitle: Text(
                  _scheduledTime != null
                      ? _scheduledTime!.format(context)
                      : 'Tap to set time',
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _scheduledTime ?? TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _scheduledTime = time;
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Duration: $_duration minutes',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Slider(
              value: _duration.toDouble(),
              min: 15,
              max: 240,
              divisions: 15,
              label: '$_duration min',
              onChanged: (value) {
                setState(() {
                  _duration = value.toInt();
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final updatedTask = Task(
      id: widget.task.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      status: widget.task.status,
      createdAt: widget.task.createdAt,
      category: _selectedCategory,
      timeBoxMinutes: _duration,
      scheduledDate: _scheduledDate,
      scheduledTime: _scheduledTime,
      actualTimeSpent: widget.task.actualTimeSpent,
      timeBoxId: widget.task.timeBoxId,
      orderIndex: widget.task.orderIndex,
    );

    ref.read(taskProvider.notifier).updateTask(updatedTask);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task updated'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}