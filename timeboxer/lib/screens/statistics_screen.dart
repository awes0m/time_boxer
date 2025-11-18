import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import '../providers/task_provider.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(taskProvider);
    final completedTasks = allTasks
        .where((t) => t.status == TaskStatus.completed)
        .toList();

    // Calculate statistics
    final totalTasks = allTasks.length;
    final activeTasks = allTasks
        .where((t) => t.status != TaskStatus.completed)
        .length;
    final completedCount = completedTasks.length;
    final completionRate = totalTasks > 0
        ? (completedCount / totalTasks * 100).toStringAsFixed(1)
        : '0';

    // Category breakdown (completed tasks only)
    final categoryStats = <TaskCategory, int>{};
    for (var category in TaskCategory.values) {
      categoryStats[category] = completedTasks
          .where((t) => t.category == category)
          .length;
    }

    // Time statistics (only for completed tasks with time data)
    final tasksWithTime = completedTasks
        .where((t) => t.timeBoxMinutes != null && t.actualTimeSpent != null)
        .toList();

    final totalPlannedTime = tasksWithTime.fold<int>(
      0,
      (sum, task) => sum + (task.timeBoxMinutes ?? 0),
    );

    final totalActualTime = tasksWithTime.fold<int>(
      0,
      (sum, task) => sum + (task.actualTimeSpent ?? 0),
    );

    // Tasks completed per day (last 7 days)
    final tasksPerDay = <DateTime, int>{};
    final now = DateTime.now();
    for (var i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      tasksPerDay[dateKey] = completedTasks
          .where((t) => DateUtils.isSameDay(t.createdAt, dateKey))
          .length;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              // Force rebuild
              ref.invalidate(taskProvider);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overview Cards
          _buildOverviewCards(
            context,
            totalTasks,
            completedCount,
            activeTasks,
            completionRate,
          ),
          const SizedBox(height: 24),

          // Today's Summary
          _buildSectionTitle(context, 'Today\'s Progress'),
          const SizedBox(height: 16),
          _buildTodaySummary(context, allTasks),
          const SizedBox(height: 24),

          // Category Breakdown
          _buildSectionTitle(context, 'Tasks by Category'),
          const SizedBox(height: 16),
          _buildCategoryChart(context, categoryStats),
          const SizedBox(height: 24),

          // Completion Trend
          _buildSectionTitle(context, 'Completion Trend (Last 7 Days)'),
          const SizedBox(height: 16),
          _buildCompletionTrendChart(context, tasksPerDay),
          const SizedBox(height: 24),

          // Time Accuracy
          if (totalActualTime > 0) ...[
            _buildSectionTitle(context, 'Time Estimation Accuracy'),
            const SizedBox(height: 16),
            _buildTimeAccuracyCard(context, totalPlannedTime, totalActualTime),
          ],
        ],
      ),
    );
  }

  Widget _buildTodaySummary(BuildContext context, List<Task> allTasks) {
    final today = DateTime.now();
    final todayTasks = allTasks
        .where(
          (t) =>
              t.scheduledDate != null &&
              DateUtils.isSameDay(t.scheduledDate, today),
        )
        .toList();
    final todayCompleted = todayTasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    final todayTotal = todayTasks.length;
    final todayProgress = todayTotal > 0 ? (todayCompleted / todayTotal) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$todayCompleted of $todayTotal tasks completed',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${(todayProgress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: todayProgress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            if (todayTasks.isEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'No tasks scheduled for today. Open Calendar View to plan your day!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(
    BuildContext context,
    int total,
    int completed,
    int active,
    String rate,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Tasks',
                total.toString(),
                Icons.task_alt,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Active',
                active.toString(),
                Icons.pending_actions,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Completed',
                completed.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Completion',
                '$rate%',
                Icons.trending_up,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategoryChart(
    BuildContext context,
    Map<TaskCategory, int> categoryStats,
  ) {
    final totalCount = categoryStats.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );

    if (totalCount == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No completed tasks yet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: categoryStats.entries.map((entry) {
            final percentage = (entry.value / totalCount * 100).toStringAsFixed(
              1,
            );
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: entry.key.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(entry.key.displayName)),
                  Text(
                    '${entry.value} ($percentage%)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCompletionTrendChart(
    BuildContext context,
    Map<DateTime, int> tasksPerDay,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final dates = tasksPerDay.keys.toList()..sort();
                      if (value.toInt() >= 0 && value.toInt() < dates.length) {
                        final date = dates[value.toInt()];
                        return Text(
                          DateFormat('E').format(date),
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: tasksPerDay.entries.toList().asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.value.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeAccuracyCard(BuildContext context, int planned, int actual) {
    final accuracy = ((planned / actual) * 100).toStringAsFixed(1);
    final difference = planned - actual;
    final isUnder = difference < 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Planned',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${planned ~/ 60}h ${planned % 60}m',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Actual',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${actual ~/ 60}h ${actual % 60}m',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isUnder ? Colors.orange : Colors.green).withValues(alpha: 
                  0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isUnder ? Icons.trending_down : Icons.trending_up,
                    color: isUnder ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isUnder
                        ? 'Underestimated by ${difference.abs()} min'
                        : 'Overestimated by ${difference.abs()} min',
                    style: TextStyle(
                      color: isUnder ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
