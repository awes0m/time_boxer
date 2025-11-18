import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/task_provider.dart';

class FocusTimerScreen extends ConsumerStatefulWidget {
  final Task task;

  const FocusTimerScreen({super.key, required this.task});

  @override
  ConsumerState<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends ConsumerState<FocusTimerScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _totalSeconds = (widget.task.timeBoxMinutes ?? 25) * 60;
    _remainingSeconds = _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _elapsedSeconds++;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _showCompletionDialog();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
      _elapsedSeconds = 0;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Time\'s Up!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Great work on "${widget.task.title}"!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveAndExit();
            },
            child: const Text('Mark Complete'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetTimer();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _saveAndExit() {
    final updatedTask = widget.task.copyWith(
      status: TaskStatus.completed,
      actualTimeSpent: _elapsedSeconds ~/ 60,
    );
    ref.read(taskProvider.notifier).updateTask(updatedTask);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0
        ? (_totalSeconds - _remainingSeconds) / _totalSeconds
        : 0.0;
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Mark Complete',
            onPressed: () {
              _timer?.cancel();
              _saveAndExit();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Task info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.task.category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.task.category.color,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.task.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.task.description != null &&
                        widget.task.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.task.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Timer display
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.task.category.color,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 64,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRunning ? 'Focus Time' : 'Paused',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh),
                    iconSize: 32,
                    tooltip: 'Reset',
                  ),
                  const SizedBox(width: 24),
                  IconButton.filledTonal(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    iconSize: 48,
                    tooltip: _isRunning ? 'Pause' : 'Start',
                  ),
                  const SizedBox(width: 24),
                  IconButton.filled(
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.stop),
                    iconSize: 32,
                    tooltip: 'Stop',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Elapsed time
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Elapsed: ${_elapsedSeconds ~/ 60} min',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
