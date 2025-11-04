import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timebox_provider.dart';

class AddTimeBoxDialog extends ConsumerStatefulWidget {
  const AddTimeBoxDialog({super.key});

  @override
  ConsumerState<AddTimeBoxDialog> createState() => _AddTimeBoxDialogState();
}

class _AddTimeBoxDialogState extends ConsumerState<AddTimeBoxDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '60');

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create TimeBox'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'TimeBox Title',
                hintText: 'e.g., Morning Focus, Afternoon Tasks',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
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
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _saveTimeBox, child: const Text('Create')),
      ],
    );
  }

  void _saveTimeBox() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(timeBoxProvider.notifier)
          .addTimeBox(
            _titleController.text.trim(),
            int.parse(_durationController.text.trim()),
          );
      Navigator.of(context).pop();
    }
  }
}
