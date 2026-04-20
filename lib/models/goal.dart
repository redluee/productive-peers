import 'package:isar/isar.dart';

part 'goal.g.dart';

@Collection()
class Goal {
  Id id = Isar.autoIncrement;

  late String goalId; // UUID for sync
  late String title;
  String? description;
  late String type; // 'Habit', 'Study', 'Goal'
  String? frequency; // e.g., "2 times/week"
  DateTime? endDate;
  double progress = 0.0; // 0.0 to 100.0
  bool isPublic = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  // Statistics
  int sessionsCompleted = 0;
  int totalMinutes = 0;

  Goal({
    required this.goalId,
    required this.title,
    this.description,
    required this.type,
    this.frequency,
    this.endDate,
    this.progress = 0.0,
    this.isPublic = false,
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
