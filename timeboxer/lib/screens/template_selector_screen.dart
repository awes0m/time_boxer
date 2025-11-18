import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/timebox_template.dart';
import '../models/models.dart';
import '../providers/timebox_provider.dart';

class TemplateSelectorScreen extends ConsumerStatefulWidget {
  const TemplateSelectorScreen({super.key});

  @override
  ConsumerState<TemplateSelectorScreen> createState() =>
      _TemplateSelectorScreenState();
}

class _TemplateSelectorScreenState
    extends ConsumerState<TemplateSelectorScreen> {
  TimeBoxTemplate? _selectedTemplate;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Blocking Templates'),
      ),
      body: Column(
        children: [
          // Date selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                const Text('Apply template to:'),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      DateFormat('EEEE, MMM d').format(_selectedDate),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Template list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: TimeBoxTemplates.templates.length,
              itemBuilder: (context, index) {
                final template = TimeBoxTemplates.templates[index];
                final isSelected = _selectedTemplate?.id == template.id;

                return Card(
                  elevation: isSelected ? 4 : 1,
                  margin: const EdgeInsets.only(bottom: 16),
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.5)
                      : null,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTemplate = template;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  template.icon,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      template.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      template.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${template.slots.length} time blocks',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: template.slots.take(5).map((slot) {
                              return Chip(
                                label: Text(
                                  slot.name,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () => _showTemplatePreview(template),
                              icon: const Icon(Icons.visibility, size: 18),
                              label: const Text('Preview Schedule'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedTemplate != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _applyTemplate(false),
                        child: const Text('Apply & Keep Existing'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _applyTemplate(true),
                        child: const Text('Apply & Replace All'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showTemplatePreview(TimeBoxTemplate template) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(template.icon),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        template.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: template.slots.length,
                  itemBuilder: (context, index) {
                    final slot = template.slots[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: slot.color ?? Colors.blue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        title: Text(slot.name),
                        subtitle: Text(
                          '${slot.startTime.format(context)} - ${slot.endTime.format(context)}',
                        ),
                        trailing: Text(
                          '${slot.durationMinutes} min',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyTemplate(bool replaceExisting) async {
    if (_selectedTemplate == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          replaceExisting
              ? 'Replace All TimeBoxes?'
              : 'Add Template TimeBoxes?',
        ),
        content: Text(
          replaceExisting
              ? 'This will delete all existing timeboxes for ${DateFormat('MMM d').format(_selectedDate)} and create new ones from the template.'
              : 'This will add template timeboxes to your existing schedule for ${DateFormat('MMM d').format(_selectedDate)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      final timeBoxNotifier = ref.read(timeBoxProvider.notifier);

      if (replaceExisting) {
        // Delete existing timeboxes for this date
        final existingBoxes = ref.read(timeBoxProvider);
        for (final box in existingBoxes) {
          await timeBoxNotifier.deleteTimeBox(box.id);
        }
      }

      // Create timeboxes from template
      int orderIndex = replaceExisting ? 0 : ref.read(timeBoxProvider).length;
      for (final slot in _selectedTemplate!.slots) {
        final timeBox = TimeBox(
          title: slot.name,
          durationMinutes: slot.durationMinutes,
          orderIndex: orderIndex++,
        );
        await timeBoxNotifier.addTimeBox(timeBox.title, timeBox.durationMinutes);
      }

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close template selector
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Applied "${_selectedTemplate!.name}" template',
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Already on calendar view
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error applying template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}