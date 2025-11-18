import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/task_provider.dart';
import '../providers/timebox_provider.dart';
import '../widgets/calendar_task_card.dart';
import '../widgets/quick_schedule_dialog.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/edit_timebox_dialog.dart';

class CalendarViewScreen extends ConsumerStatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  ConsumerState<CalendarViewScreen> createState() =>
      _CalendarViewScreenState();
}

class _CalendarViewScreenState extends ConsumerState<CalendarViewScreen> {
  DateTime selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  Task? _draggingTask;
  bool _showTimeBoxes = true;

  @override
  void initState() {
    super.initState();
    // Scroll to 8 AM on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(8 * 60.0);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskProvider);
    final timeBoxes = ref.watch(timeBoxProvider);

    // Get tasks scheduled for selected date
    final scheduledTasks = allTasks.where((task) {
      if (task.scheduledDate == null) return false;
      return DateUtils.isSameDay(task.scheduledDate, selectedDate);
    }).toList();

    // Get timeboxed tasks for selected date (from timeboxes)
    final timeboxedTasks = <Task>[];
    for (final timeBox in timeBoxes) {
      for (final taskId in timeBox.taskIds) {
        final task = allTasks.firstWhere(
          (t) => t.id == taskId,
          orElse: () => Task(title: ''),
        );
        if (task.title.isNotEmpty && task.scheduledDate != null) {
          if (DateUtils.isSameDay(task.scheduledDate, selectedDate)) {
            timeboxedTasks.add(task);
          }
        }
      }
    }

    // Combine all tasks for the day
    final allDayTasks = <Task>[];
    final taskIds = <String>{};
    
    for (final task in scheduledTasks) {
      if (!taskIds.contains(task.id)) {
        allDayTasks.add(task);
        taskIds.add(task.id);
      }
    }
    
    for (final task in timeboxedTasks) {
      if (!taskIds.contains(task.id)) {
        allDayTasks.add(task);
        taskIds.add(task.id);
      }
    }

    // Get unscheduled tasks (backlog for this date)
    final unscheduledTasks = allTasks.where((task) {
      return task.status == TaskStatus.backlog || 
             (task.scheduledDate == null && task.status == TaskStatus.timeboxed);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Planner'),
        actions: [
          IconButton(
            icon: Icon(_showTimeBoxes ? Icons.layers : Icons.layers_outlined),
            tooltip: _showTimeBoxes ? 'Hide TimeBoxes' : 'Show TimeBoxes',
            onPressed: () {
              setState(() {
                _showTimeBoxes = !_showTimeBoxes;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Quick Add Task',
            onPressed: () => _showAddTaskDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Go to Today',
            onPressed: () {
              setState(() {
                selectedDate = DateTime.now();
              });
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  8 * 60.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Unscheduled tasks sidebar
          if (MediaQuery.of(context).size.width > 600)
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Unscheduled',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: unscheduledTasks.length,
                      itemBuilder: (context, index) {
                        final task = unscheduledTasks[index];
                        return Draggable<Task>(
                          data: task,
                          feedback: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 200,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: task.category.color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _buildUnscheduledTaskCard(task),
                          ),
                          onDragStarted: () {
                            setState(() {
                              _draggingTask = task;
                            });
                          },
                          onDragEnd: (_) {
                            setState(() {
                              _draggingTask = null;
                            });
                          },
                          child: _buildUnscheduledTaskCard(task),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          
          // Calendar timeline
          Expanded(
            child: Column(
              children: [
                _buildDateSelector(),
                const Divider(height: 1),
                Expanded(
                  child: _buildTimeline(allDayTasks),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }  List<Widget> _buildTimeBoxBackgrounds(List<TimeBox> timeBoxes, double width) {
    final widgets = <Widget>[];
    
    // Calculate cumulative start times for timeboxes
    int cumulativeMinutes = 8 * 60; // Start at 8 AM by default
    
    for (final timeBox in timeBoxes) {
      widgets.add(
        Positioned(
          top: cumulativeMinutes.toDouble(),
          left: 70,
          width: width - 78,
          height: timeBox.durationMinutes.toDouble(),
          child: DragTarget<Task>(
            onWillAcceptWithDetails: (details) => true,
            onAcceptWithDetails: (details) {
              _addTaskToTimeBox(timeBox, details.data);
            },
            builder: (context, candidateData, rejectedData) {
              final isHovering = candidateData.isNotEmpty;
              return GestureDetector(
                onTap: () => _editTimeBox(timeBox),
                onLongPress: () => _showTimeBoxOptions(timeBox),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isHovering 
                        ? _getTimeBoxColor(timeBox).withValues(alpha:0.3)
                        : _getTimeBoxColor(timeBox).withValues(alpha:0.1),
                    border: Border.all(
                      color: isHovering
                          ? _getTimeBoxColor(timeBox).withValues(alpha:0.8)
                          : _getTimeBoxColor(timeBox).withValues(alpha:0.3),
                      width: isHovering ? 3 : 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                timeBox.title,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _getTimeBoxColor(timeBox),
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (timeBox.durationMinutes >= 45) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '${timeBox.durationMinutes} min',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: _getTimeBoxColor(timeBox).withValues(alpha:0.7),
                                      ),
                                ),
                              ],
                              if (isHovering) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Drop task here',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: _getTimeBoxColor(timeBox),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: _getTimeBoxColor(timeBox).withValues(alpha:0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
      
      // Move to next position
      cumulativeMinutes += timeBox.durationMinutes;
    }
    
    return widgets;
  }

  Color _getTimeBoxColor(TimeBox timeBox) {
    // Generate color based on title hash for consistency
    final hash = timeBox.title.hashCode;
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[hash.abs() % colors.length];
  }

  void _editTimeBox(TimeBox timeBox) {
    showDialog(
      context: context,
      builder: (context) => EditTimeBoxDialog(timeBox: timeBox),
    ).then((_) => setState(() {}));
  }

  void _showTimeBoxOptions(TimeBox timeBox) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit TimeBox'),
              onTap: () {
                Navigator.pop(context);
                _editTimeBox(timeBox);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                ref.read(timeBoxProvider.notifier).addTimeBox(
                      '${timeBox.title} (Copy)',
                      timeBox.durationMinutes,
                    );
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete TimeBox'),
              onTap: () {
                Navigator.pop(context);
                _deleteTimeBox(timeBox);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTimeBox(TimeBox timeBox) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete TimeBox?'),
        content: Text(
          'This will remove "${timeBox.title}" and move its tasks back to the backlog.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(timeBoxProvider.notifier).deleteTimeBox(timeBox.id);
      setState(() {});
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddTaskDialog(),
    ).then((_) => setState(() {}));
  }

  Widget _buildUnscheduledTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          decoration: BoxDecoration(
            color: task.category.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: task.timeBoxMinutes != null
            ? Text('${task.timeBoxMinutes} min')
            : null,
        trailing: const Icon(Icons.drag_indicator),
      ),
    );
  }

  Widget _buildDateSelector() {
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                selectedDate = selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEEE').format(selectedDate),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  DateFormat('MMMM d, yyyy').format(selectedDate),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha:0.6),
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                selectedDate = selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }  Widget _buildTimeline(List<Task> scheduledTasks) {
    final timeBoxes = ref.watch(timeBoxProvider);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          child: SizedBox(
            height: 24 * 60, // 24 hours * 60 pixels per hour
            child: Stack(
              children: [
                // Hour lines and labels
                ..._buildHourLines(),
                
                // TimeBox backgrounds (if enabled)
                if (_showTimeBoxes)
                  ..._buildTimeBoxBackgrounds(timeBoxes, constraints.maxWidth),
                
                // Current time indicator
                if (DateUtils.isSameDay(selectedDate, DateTime.now()))
                  _buildCurrentTimeIndicator(),
                
                // Drop zones for each hour (only when timeboxes are hidden)
                if (!_showTimeBoxes)
                  ..._buildDropZones(constraints.maxWidth),
                
                // Scheduled tasks
                ...scheduledTasks.map((task) => _buildTaskBlock(task, constraints.maxWidth)),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildHourLines() {
    return List.generate(24, (hour) {
      return Positioned(
        top: hour * 60.0,
        left: 0,
        right: 0,
        child: Row(
          children: [
            Container(
              width: 70,
              padding: const EdgeInsets.only(right: 8, top: 4),
              child: Text(
                DateFormat('ha').format(
                  DateTime(2000, 1, 1, hour),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha:0.6),
                    ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha:0.2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }  List<Widget> _buildDropZones(double width) {
    return List.generate(24, (hour) {
      return Positioned(
        top: hour * 60.0,
        left: 70,
        width: width - 78,
        height: 60,
        child: DragTarget<Task>(
          onWillAcceptWithDetails: (details) => true,
          onAcceptWithDetails: (details) {
            _scheduleTaskAtTime(details.data, hour);
          },
          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;
            return Container(
              decoration: BoxDecoration(
                color: isHovering
                    ? Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha:0.2)
                    : Colors.transparent,
                border: isHovering
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: isHovering
                  ? Center(
                      child: Text(
                        'Drop here to schedule at ${DateFormat('ha').format(DateTime(2000, 1, 1, hour))}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : null,
            );
          },
        ),
      );
    });
  }

  Widget _buildCurrentTimeIndicator() {
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;

    return Positioned(
      top: minutes.toDouble(),
      left: 70,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskBlock(Task task, double maxWidth) {
    if (task.scheduledTime == null) return const SizedBox.shrink();

    final startMinutes =
        task.scheduledTime!.hour * 60 + task.scheduledTime!.minute;
    final duration = task.timeBoxMinutes ?? 30;

    return Positioned(
      top: startMinutes.toDouble(),
      left: 78,
      width: maxWidth - 86,
      height: duration.toDouble(),
      child: GestureDetector(
        onTap: () {
          _showTaskOptions(task);
        },
        child: Draggable<Task>(
          data: task,
          feedback: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 200,
              height: duration.toDouble(),
              child: CalendarTaskCard(task: task),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: CalendarTaskCard(task: task),
          ),
          onDragStarted: () {
            setState(() {
              _draggingTask = task;
            });
          },
          onDragEnd: (_) {
            setState(() {
              _draggingTask = null;
            });
          },
          child: CalendarTaskCard(task: task),
        ),
      ),
    );
  }

  void _scheduleTaskAtTime(Task task, int hour) {
    showDialog(
      context: context,
      builder: (context) => _ScheduleTaskDialog(
        task: task,
        selectedDate: selectedDate,
        selectedHour: hour,
        onSchedule: (duration) {
          final updatedTask = task.copyWith(
            scheduledDate: selectedDate,
            scheduledTime: TimeOfDay(hour: hour, minute: 0),
            timeBoxMinutes: duration,
            status: TaskStatus.timeboxed,
          );
          ref.read(taskProvider.notifier).updateTask(updatedTask);
          setState(() {});
        },
      ),
    );
  }  void _addTaskToTimeBox(TimeBox timeBox, Task task) {
    showDialog(
      context: context,
      builder: (context) => _AddTaskToTimeBoxDialog(
        timeBox: timeBox,
        task: task,
        onAdd: (duration) {
          // Calculate the start time based on timebox position
          int cumulativeMinutes = 8 * 60; // Start at 8 AM
          final timeBoxes = ref.read(timeBoxProvider);
          
          for (final tb in timeBoxes) {
            if (tb.id == timeBox.id) break;
            cumulativeMinutes += tb.durationMinutes;
          }
          
          final startTime = TimeOfDay(
            hour: cumulativeMinutes ~/ 60,
            minute: cumulativeMinutes % 60,
          );
          
          final updatedTask = task.copyWith(
            scheduledDate: selectedDate,
            scheduledTime: startTime,
            timeBoxMinutes: duration,
            timeBoxId: timeBox.id,
            status: TaskStatus.timeboxed,
          );
          
          ref.read(taskProvider.notifier).updateTask(updatedTask);
          ref.read(timeBoxProvider.notifier).addTaskToTimeBox(
            timeBox.id,
            updatedTask,
            duration,
          );
          setState(() {});
        },
      ),
    );
  }

  void _showTaskOptions(Task task) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                task.status == TaskStatus.completed
                    ? Icons.undo
                    : Icons.check_circle,
              ),
              title: Text(
                task.status == TaskStatus.completed
                    ? 'Mark Incomplete'
                    : 'Mark Complete',
              ),
              onTap: () {
                ref.read(taskProvider.notifier).toggleTaskComplete(task.id);
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Reschedule'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => QuickScheduleDialog(task: task),
                ).then((_) => setState(() {}));
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Remove from Calendar'),
              onTap: () {
                final updatedTask = task.copyWith(
                  scheduledDate: null,
                  scheduledTime: null,
                  status: TaskStatus.backlog,
                );
                ref.read(taskProvider.notifier).updateTask(updatedTask);
                Navigator.pop(context);
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Task'),
              onTap: () {
                ref.read(taskProvider.notifier).deleteTask(task.id);
                Navigator.pop(context);
                setState(() {});
              },
            ),
          ],
        ),
      ),    );
  }
}

class _AddTaskToTimeBoxDialog extends StatefulWidget {
  final TimeBox timeBox;
  final Task task;
  final Function(int duration) onAdd;

  const _AddTaskToTimeBoxDialog({
    required this.timeBox,
    required this.task,
    required this.onAdd,
  });

  @override
  State<_AddTaskToTimeBoxDialog> createState() => _AddTaskToTimeBoxDialogState();
}

class _AddTaskToTimeBoxDialogState extends State<_AddTaskToTimeBoxDialog> {
  late int _duration;

  @override
  void initState() {
    super.initState();
    _duration = widget.task.timeBoxMinutes ?? 30;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add to ${widget.timeBox.title}'),
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
            Text(
              'Duration: $_duration minutes',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _duration.toDouble(),
              min: 15,
              max: widget.timeBox.durationMinutes.toDouble(),
              divisions: ((widget.timeBox.durationMinutes - 15) / 15).floor(),
              label: '$_duration min',
              onChanged: (value) {
                setState(() {
                  _duration = value.toInt();
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              'TimeBox: ${widget.timeBox.durationMinutes} minutes',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
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
          onPressed: () {
            widget.onAdd(_duration);
            Navigator.pop(context);
          },
          child: const Text('Add Task'),
        ),
      ],
    );
  }
}

class _ScheduleTaskDialog extends StatefulWidget {
  final Task task;
  final DateTime selectedDate;
  final int selectedHour;
  final Function(int duration) onSchedule;

  const _ScheduleTaskDialog({
    required this.task,
    required this.selectedDate,
    required this.selectedHour,
    required this.onSchedule,
  });

  @override
  State<_ScheduleTaskDialog> createState() => _ScheduleTaskDialogState();
}

class _ScheduleTaskDialogState extends State<_ScheduleTaskDialog> {
  late int _duration;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _duration = widget.task.timeBoxMinutes ?? 30;
    _minute = 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Task'),
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
            Text(
              'Time: ${DateFormat('ha').format(DateTime(2000, 1, 1, widget.selectedHour, _minute))}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _minute.toDouble(),
              min: 0,
              max: 45,
              divisions: 3,
              label: '$_minute min',
              onChanged: (value) {
                setState(() {
                  _minute = value.toInt();
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Duration: $_duration minutes',
              style: Theme.of(context).textTheme.bodyLarge,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onSchedule(_duration);
            Navigator.pop(context);
          },
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}