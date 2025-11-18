import 'package:flutter/material.dart';

class TimeBoxTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<TimeBoxSlot> slots;

  TimeBoxTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.slots,
  });
}

class TimeBoxSlot {
  final String name;
  final TimeOfDay startTime;
  final int durationMinutes;
  final Color? color;

  TimeBoxSlot({
    required this.name,
    required this.startTime,
    required this.durationMinutes,
    this.color,
  });

  TimeOfDay get endTime {
    final totalMinutes = startTime.hour * 60 + startTime.minute + durationMinutes;
    return TimeOfDay(
      hour: totalMinutes ~/ 60,
      minute: totalMinutes % 60,
    );
  }
}

// Predefined templates
class TimeBoxTemplates {
  static final List<TimeBoxTemplate> templates = [
    // Standard Work Day
    TimeBoxTemplate(
      id: 'standard_work',
      name: 'Standard Work Day',
      description: '9-5 work schedule with breaks',
      icon: Icons.business_center,
      slots: [
        TimeBoxSlot(
          name: 'Morning Routine',
          startTime: const TimeOfDay(hour: 7, minute: 0),
          durationMinutes: 60,
          color: Colors.orange,
        ),
        TimeBoxSlot(
          name: 'Deep Work',
          startTime: const TimeOfDay(hour: 9, minute: 0),
          durationMinutes: 120,
          color: Colors.blue,
        ),
        TimeBoxSlot(
          name: 'Lunch Break',
          startTime: const TimeOfDay(hour: 12, minute: 0),
          durationMinutes: 60,
          color: Colors.green,
        ),
        TimeBoxSlot(
          name: 'Meetings & Collaboration',
          startTime: const TimeOfDay(hour: 13, minute: 0),
          durationMinutes: 120,
          color: Colors.purple,
        ),
        TimeBoxSlot(
          name: 'Administrative Tasks',
          startTime: const TimeOfDay(hour: 15, minute: 0),
          durationMinutes: 90,
          color: Colors.teal,
        ),
        TimeBoxSlot(
          name: 'Planning & Review',
          startTime: const TimeOfDay(hour: 16, minute: 30),
          durationMinutes: 30,
          color: Colors.indigo,
        ),
        TimeBoxSlot(
          name: 'Evening Routine',
          startTime: const TimeOfDay(hour: 18, minute: 0),
          durationMinutes: 60,
          color: Colors.orange,
        ),
      ],
    ),

    // Maker's Schedule (Deep Work)
    TimeBoxTemplate(
      id: 'maker_schedule',
      name: 'Maker\'s Schedule',
      description: 'Large blocks for deep creative work',
      icon: Icons.construction,
      slots: [
        TimeBoxSlot(
          name: 'Morning Setup',
          startTime: const TimeOfDay(hour: 8, minute: 0),
          durationMinutes: 30,
          color: Colors.orange,
        ),
        TimeBoxSlot(
          name: 'Deep Work Block 1',
          startTime: const TimeOfDay(hour: 8, minute: 30),
          durationMinutes: 180,
          color: Colors.blue,
        ),
        TimeBoxSlot(
          name: 'Lunch & Walk',
          startTime: const TimeOfDay(hour: 11, minute: 30),
          durationMinutes: 90,
          color: Colors.green,
        ),
        TimeBoxSlot(
          name: 'Deep Work Block 2',
          startTime: const TimeOfDay(hour: 13, minute: 0),
          durationMinutes: 180,
          color: Colors.blue,
        ),
        TimeBoxSlot(
          name: 'Review & Admin',
          startTime: const TimeOfDay(hour: 16, minute: 0),
          durationMinutes: 60,
          color: Colors.teal,
        ),
      ],
    ),

    // Student Schedule
    TimeBoxTemplate(
      id: 'student',
      name: 'Student Schedule',
      description: 'Balanced study with breaks',
      icon: Icons.school,
      slots: [
        TimeBoxSlot(
          name: 'Morning Study',
          startTime: const TimeOfDay(hour: 8, minute: 0),
          durationMinutes: 90,
          color: Colors.blue,
        ),
        TimeBoxSlot(
          name: 'Class/Lecture',
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationMinutes: 120,
          color: Colors.purple,
        ),
        TimeBoxSlot(
          name: 'Lunch Break',
          startTime: const TimeOfDay(hour: 12, minute: 0),
          durationMinutes: 60,
          color: Colors.green,
        ),
        TimeBoxSlot(
          name: 'Afternoon Study',
          startTime: const TimeOfDay(hour: 13, minute: 0),
          durationMinutes: 120,
          color: Colors.blue,
        ),
        TimeBoxSlot(
          name: 'Exercise',
          startTime: const TimeOfDay(hour: 15, minute: 0),
          durationMinutes: 60,
          color: Colors.orange,
        ),
        TimeBoxSlot(
          name: 'Project Work',
          startTime: const TimeOfDay(hour: 16, minute: 30),
          durationMinutes: 90,
          color: Colors.indigo,
        ),
        TimeBoxSlot(
          name: 'Review & Planning',
          startTime: const TimeOfDay(hour: 18, minute: 0),
          durationMinutes: 30,
          color: Colors.teal,
        ),
      ],
    ),

    // Entrepreneur Schedule
    TimeBoxTemplate(
      id: 'entrepreneur',
      name: 'Entrepreneur',
      description: 'Flexible schedule for business owners',
      icon: Icons.rocket_launch,
      slots: [
        TimeBoxSlot(
          name: 'Morning Routine & Planning',
          startTime: const TimeOfDay(hour: 6, minute: 0),
          durationMinutes: 90,
          color: Colors.orange,
        ),
        TimeBoxSlot(
          name: 'Strategic Work',
          startTime: const TimeOfDay(hour: 8, minute: 0),
          durationMinutes: 120,
          color: Colors.blue,
        ),
        TimeBoxSlot(
          name: 'Client Meetings',
          startTime: const TimeOfDay(hour: 10, minute: 30),
          durationMinutes: 90,
          color: Colors.purple,
        ),
        TimeBoxSlot(
          name: 'Lunch & Exercise',
          startTime: const TimeOfDay(hour: 12, minute: 0),
          durationMinutes: 60,
          color: Colors.green,
        ),
        TimeBoxSlot(
          name: 'Business Development',
          startTime: const TimeOfDay(hour: 13, minute: 0),
          durationMinutes: 120,
          color: Colors.indigo,
        ),
        TimeBoxSlot(
          name: 'Admin & Finance',
          startTime: const TimeOfDay(hour: 15, minute: 0),
          durationMinutes: 60,
          color: Colors.teal,
        ),
        TimeBoxSlot(
          name: 'Learning & Growth',
          startTime: const TimeOfDay(hour: 16, minute: 0),
          durationMinutes: 60,
          color: Colors.amber,
        ),
      ],
    ),

    // Early Bird
    TimeBoxTemplate(
      id: 'early_bird',
      name: 'Early Bird',
      description: 'Start early, finish early',
      icon: Icons.wb_sunny,
      slots: [
        TimeBoxSlot(
          name: 'Morning Routine',
          startTime: const TimeOfDay(hour: 5, minute: 30),
          durationMinutes: 60,
          color: Colors.orange,
        ),
        TimeBoxSlot(
          name: 'Deep Work Session 1',
          startTime: const TimeOfDay(hour: 6, minute: 30),
          durationMinutes: 150,
          color: Colors.blue,
        ),
        TimeBoxSlot(
          name: 'Breakfast Break',
          startTime: const TimeOfDay(hour: 9, minute: 0),
          durationMinutes: 30,
          color: Colors.green,
        ),
        TimeBoxSlot(
          name: 'Meetings & Calls',
          startTime: const TimeOfDay(hour: 9, minute: 30),
          durationMinutes: 120,
          color: Colors.purple,
        ),
        TimeBoxSlot(
          name: 'Lunch',
          startTime: const TimeOfDay(hour: 11, minute: 30),
          durationMinutes: 60,
          color: Colors.green,
        ),
        TimeBoxSlot(
          name: 'Afternoon Tasks',
          startTime: const TimeOfDay(hour: 12, minute: 30),
          durationMinutes: 120,
          color: Colors.teal,
        ),
        TimeBoxSlot(
          name: 'Wrap Up',
          startTime: const TimeOfDay(hour: 14, minute: 30),
          durationMinutes: 30,
          color: Colors.indigo,
        ),
      ],
    ),

    // Night Owl
    TimeBoxTemplate(
      id: 'night_owl',
      name: 'Night Owl',
      description: 'Peak productivity in evening',
      icon: Icons.nightlight,
      slots: [
        TimeBoxSlot(
          name: 'Morning Routine',
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationMinutes: 60,
          color: Colors.orange,
        ),
        TimeBoxSlot(
          name: 'Warm Up Tasks',
          startTime: const TimeOfDay(hour: 11, minute: 0),
          durationMinutes: 90,
          color: Colors.teal,
        ),
        TimeBoxSlot(
          name: 'Lunch Break',
          startTime: const TimeOfDay(hour: 12, minute: 30),
          durationMinutes: 60,
          color: Colors.green,
        ),
        TimeBoxSlot(
          name: 'Meetings & Collaboration',
          startTime: const TimeOfDay(hour: 13, minute: 30),
          durationMinutes: 120,
          color: Colors.purple,
        ),
        TimeBoxSlot(
          name: 'Peak Productivity Block',
          startTime: const TimeOfDay(hour: 16, minute: 0),
          durationMinutes: 180,
          color: Colors.blue,
        ),
        TimeBoxSlot(
          name: 'Dinner Break',
          startTime: const TimeOfDay(hour: 19, minute: 0),
          durationMinutes: 60,
          color: Colors.green,
        ),
        TimeBoxSlot(
          name: 'Deep Work Evening',
          startTime: const TimeOfDay(hour: 20, minute: 0),
          durationMinutes: 120,
          color: Colors.blue,
        ),
      ],
    ),

    // Pomodoro Intensive
    TimeBoxTemplate(
      id: 'pomodoro',
      name: 'Pomodoro Intensive',
      description: '25min work + 5min break cycles',
      icon: Icons.timer,
      slots: [
        TimeBoxSlot(
          name: 'Pomodoro 1',
          startTime: const TimeOfDay(hour: 9, minute: 0),
          durationMinutes: 25,
          color: Colors.red,
        ),
        TimeBoxSlot(
          name: 'Break',
          startTime: const TimeOfDay(hour: 9, minute: 25),
          durationMinutes: 5,
          color: Colors.green,
        ),
        TimeBoxSlot(
          name: 'Pomodoro 2',
          startTime: const TimeOfDay(hour: 9, minute: 30),
          durationMinutes: 25,
          color: Colors.red,
        ),
        TimeBoxSlot(
          name: 'Break',
          startTime: const TimeOfDay(hour: 9, minute: 55),
          durationMinutes: 5,
          color: Colors.green,
        ),
        TimeBoxSlot(
          name: 'Pomodoro 3',
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationMinutes: 25,
          color: Colors.red,
        ),
        TimeBoxSlot(
          name: 'Break',
          startTime: const TimeOfDay(hour: 10, minute: 25),
          durationMinutes: 5,
          color: Colors.green,
        ),
        TimeBoxSlot(
          name: 'Pomodoro 4',
          startTime: const TimeOfDay(hour: 10, minute: 30),
          durationMinutes: 25,
          color: Colors.red,
        ),
        TimeBoxSlot(
          name: 'Long Break',
          startTime: const TimeOfDay(hour: 10, minute: 55),
          durationMinutes: 30,
          color: Colors.lightGreen,
        ),
        TimeBoxSlot(
          name: 'Lunch',
          startTime: const TimeOfDay(hour: 12, minute: 0),
          durationMinutes: 60,
          color: Colors.green,
        ),
        // Afternoon session
        TimeBoxSlot(
          name: 'Pomodoro 5',
          startTime: const TimeOfDay(hour: 13, minute: 0),
          durationMinutes: 25,
          color: Colors.red,
        ),
        TimeBoxSlot(
          name: 'Break',
          startTime: const TimeOfDay(hour: 13, minute: 25),
          durationMinutes: 5,
          color: Colors.green,
        ),
        TimeBoxSlot(
          name: 'Pomodoro 6',
          startTime: const TimeOfDay(hour: 13, minute: 30),
          durationMinutes: 25,
          color: Colors.red,
        ),
        TimeBoxSlot(
          name: 'Break',
          startTime: const TimeOfDay(hour: 13, minute: 55),
          durationMinutes: 5,
          color: Colors.green,
        ),
      ],
    ),

    // Freelancer Flexible
    TimeBoxTemplate(
      id: 'freelancer',
      name: 'Freelancer Flexible',
      description: 'Balance client work and personal projects',
      icon: Icons.laptop,
      slots: [
        TimeBoxSlot(
          name: 'Email & Planning',
          startTime: const TimeOfDay(hour: 8, minute: 0),
          durationMinutes: 30,
          color: Colors.teal,
        ),
        TimeBoxSlot(
          name: 'Client Project A',
          startTime: const TimeOfDay(hour: 8, minute: 30),
          durationMinutes: 120,
          color: Colors.blue,
        ),
        TimeBoxSlot(
          name: 'Break',
          startTime: const TimeOfDay(hour: 10, minute: 30),
          durationMinutes: 15,
          color: Colors.green,
        ),
        TimeBoxSlot(
          name: 'Client Project B',
          startTime: const TimeOfDay(hour: 10, minute: 45),
          durationMinutes: 90,
          color: Colors.purple,
        ),
        TimeBoxSlot(
          name: 'Lunch',
          startTime: const TimeOfDay(hour: 12, minute: 15),
          durationMinutes: 45,
          color: Colors.green,
        ),
        TimeBoxSlot(
          name: 'Personal Project',
          startTime: const TimeOfDay(hour: 13, minute: 0),
          durationMinutes: 120,
          color: Colors.indigo,
        ),
        TimeBoxSlot(
          name: 'Admin & Invoicing',
          startTime: const TimeOfDay(hour: 15, minute: 0),
          durationMinutes: 60,
          color: Colors.orange,
        ),
        TimeBoxSlot(
          name: 'Skill Development',
          startTime: const TimeOfDay(hour: 16, minute: 0),
          durationMinutes: 60,
          color: Colors.amber,
        ),
      ],
    ),
  ];

  static TimeBoxTemplate? getTemplate(String id) {
    try {
      return templates.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}