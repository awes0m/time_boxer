import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/timebox_provider.dart';

class EditTimeBoxDialog extends ConsumerStatefulWidget {
  final TimeBox timeBox;

  const EditTimeBoxDialog({super.key, required this.timeBox});

  @override
  ConsumerState<EditTimeBoxDialog> createState() => _EditTimeBoxDialogState();
}

class _EditTimeBoxDialogState extends ConsumerState<EditTimeBoxDialog> {
  late TextEditingController _titleController;
  late int _duration;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.timeBox.title);
    _duration = widget.timeBox.durationMinutes;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit TimeBox'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'TimeBox Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Duration: $_duration minutes',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'TimeBoxes help organize your day into focused blocks',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
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
          content: Text('Please enter a name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final updatedTimeBox = widget.timeBox.copyWith(
      title: _titleController.text.trim(),
      durationMinutes: _duration,
    );

    ref.read(timeBoxProvider.notifier).updateTimeBox(updatedTimeBox);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('TimeBox updated'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}