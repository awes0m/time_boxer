import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timebox_provider.dart';
import 'timebox_card.dart';

class TimeBoxSection extends ConsumerWidget {
  const TimeBoxSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeBoxes = ref.watch(timeBoxProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'TimeBoxes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${timeBoxes.length}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: timeBoxes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha:0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No timeboxes created',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha:0.5),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a timebox to organize tasks',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha:0.4),
                              ),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: timeBoxes.length,
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(timeBoxProvider.notifier)
                          .reorderTimeBoxes(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final timeBox = timeBoxes[index];
                      return TimeBoxCard(
                        key: ValueKey(timeBox.id),
                        timeBox: timeBox,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}