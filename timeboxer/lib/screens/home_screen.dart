import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/backlog_section.dart';
import '../widgets/timebox_section.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/add_timebox_dialog.dart';
import 'calendar_view_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeBox Task Manager'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Calendar View',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarViewScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Statistics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Add Task to Backlog',
            onPressed: () => _showAddTaskDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Add TimeBox',
            onPressed: () => _showAddTimeBoxDialog(context, ref),
          ),
        ],
      ),
      body: isWideScreen
          ? const Row(
              children: [
                SizedBox(
                  width: 350,
                  child: BacklogSection(),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  child: TimeBoxSection(),
                ),
              ],
            )
          : const Column(
              children: [
                Expanded(
                  flex: 2,
                  child: BacklogSection(),
                ),
                Divider(height: 1),
                Expanded(
                  flex: 3,
                  child: TimeBoxSection(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );
  }

  void _showAddTimeBoxDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddTimeBoxDialog(),
    );
  }
}