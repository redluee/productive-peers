import 'package:isar/isar.dart';

part 'session.g.dart';

@Collection()
class Session {
  Id id = Isar.autoIncrement;

  late String sessionId; // UUID for sync
  late String goalId; // Reference to Goal
  DateTime startTime = DateTime.now();
  DateTime? endTime;
  int durationMinutes = 0;
  String? notes;
  late String status; // 'Active', 'Paused', 'Completed'
  DateTime createdAt = DateTime.now();

  Session({
    required this.sessionId,
    required this.goalId,
    this.status = 'Active',
  }) {
    startTime = DateTime.now();
    createdAt = DateTime.now();
  }

  // Calculate duration in minutes
  int get calculatedDuration {
    if (endTime != null) {
      return endTime!.difference(startTime).inMinutes;
    }
    return DateTime.now().difference(startTime).inMinutes;
  }
}
