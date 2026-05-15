import 'package:isar/isar.dart';
import 'package:productive_peers/models/milestone.dart';

part 'goal.g.dart';

@Collection()
class Goal {
  Id id = Isar.autoIncrement;

  late String goalId; // UUID for sync
  late String title;
  String? description;
  late String type; // 'Habit', 'Study', 'Goal'
  String? frequency; // e.g., "2 times/week"
  List<String>? frequencyDays; // For weekly/monthly habits
  DateTime? endDate;
  double progress = 0.0; // 0.0 to 100.0
  double targetPercentage = 100.0;
  bool isPublic = true;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  // For Habits: to track completions
  List<DateTime> completions = [];

  // For Goals and Studies: to track milestones
  List<Milestone> milestones = [];

  // For Habits: to track streaks
  int streak = 0;

  // For Study goals
  DateTime? startDate;

  // Statistics
  int sessionsCompleted = 0;
  int totalMinutes = 0;

  Goal({
    required this.goalId,
    required this.title,
    this.description,
    required this.type,
    this.frequency,
    this.frequencyDays,
    this.endDate,
    this.progress = 0.0,
    this.targetPercentage = 100.0,
    this.isPublic = true,
    this.startDate,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  String get typeColor {
    switch (type) {
      case 'Habit':
        return '9C27B0'; // Purple
      case 'Study':
        return '2196F3'; // Blue
      case 'Goal':
        return 'FF9800'; // Orange
      default:
        return '00e3a4'; // Mint
    }
  }
}
