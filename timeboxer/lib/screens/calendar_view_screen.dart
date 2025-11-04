import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/task_provider.dart';
// import '../providers/timebox_provider.dart';
import '../widgets/calendar_task_card.dart';

class CalendarViewScreen extends ConsumerStatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  ConsumerState<CalendarViewScreen> createState() =>
      _CalendarViewScreenState();
}

class _CalendarViewScreenState extends ConsumerState<CalendarViewScreen> {
  DateTime selectedDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to 8 AM on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(8 * 60.0); // 8 hours * 60 pixels per hour
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

    // Get tasks scheduled for selected date
    final scheduledTasks = allTasks.where((task) {
      if (task.scheduledDate == null) return false;
      return DateUtils.isSameDay(task.scheduledDate, selectedDate);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Go to Today',
            onPressed: () {
              setState(() {
                selectedDate = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector
          _buildDateSelector(),
          const Divider(height: 1),
          // Timeline
          Expanded(
            child: _buildTimeline(scheduledTasks),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
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
          Column(
            children: [
              Text(
                DateFormat('EEEE').format(selectedDate),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                DateFormat('MMMM d, yyyy').format(selectedDate),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
            ],
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
  }

  Widget _buildTimeline(List<Task> scheduledTasks) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: SizedBox(
        height: 24 * 60, // 24 hours * 60 pixels per hour
        child: Stack(
          children: [
            // Hour lines and labels
            ..._buildHourLines(),
            // Current time indicator
            if (DateUtils.isSameDay(selectedDate, DateTime.now()))
              _buildCurrentTimeIndicator(),
            // Scheduled tasks
            ...scheduledTasks.map((task) => _buildTaskBlock(task)),
          ],
        ),
      ),
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
              width: 60,
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                DateFormat('ha').format(
                  DateTime(2000, 1, 1, hour),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
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
                          .withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCurrentTimeIndicator() {
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;

    return Positioned(
      top: minutes.toDouble(),
      left: 60,
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

  Widget _buildTaskBlock(Task task) {
    if (task.scheduledTime == null) return const SizedBox.shrink();

    final startMinutes = task.scheduledTime!.hour * 60 + task.scheduledTime!.minute;
    final duration = task.timeBoxMinutes ?? 30;

    return Positioned(
      top: startMinutes.toDouble(),
      left: 68,
      right: 8,
      height: duration.toDouble(),
      child: CalendarTaskCard(task: task),
    );
  }
}