import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/task_provider.dart';

class QuickScheduleDialog extends ConsumerStatefulWidget {
  final Task task;

  const QuickScheduleDialog({super.key, required this.task});

  @override
  ConsumerState<QuickScheduleDialog> createState() =>
      _QuickScheduleDialogState();
}

class _QuickScheduleDialogState extends ConsumerState<QuickScheduleDialog> {
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  late int _duration;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _duration = widget.task.timeBoxMinutes ?? 30;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quick Schedule'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            // Date picker
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
            
            // Time picker
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Time'),
              subtitle: Text(
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Tap to select',
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    _selectedTime = time;
                  });
                }
              },
            ),
            
            // Duration selector
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Duration'),
              subtitle: Slider(
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
            ),
            Center(
              child: Text(
                '$_duration minutes',
                style: Theme.of(context).textTheme.titleSmall,
              ),
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
          onPressed: _selectedTime != null ? _scheduleTask : null,
          child: const Text('Schedule'),
        ),
      ],
    );
  }

  void _scheduleTask() {
    final updatedTask = widget.task.copyWith(
      scheduledDate: _selectedDate,
      scheduledTime: _selectedTime,
      timeBoxMinutes: _duration,
      status: TaskStatus.timeboxed,
    );
    ref.read(taskProvider.notifier).updateTask(updatedTask);
    Navigator.of(context).pop();
  }
}