import 'package:isar/isar.dart';
import '../../models/goal.dart';

class GoalRepository {
  final Isar isar;

  GoalRepository(this.isar);

  // Create a new goal
  Future<Goal> createGoal(Goal goal) async {
    await isar.writeTxn(() async {
      await isar.goals.put(goal);
    });
    return goal;
  }

  // Get all goals
  Future<List<Goal>> getAllGoals() async {
    return await isar.goals.where().findAll();
  }

  // Get goal by ID
  Future<Goal?> getGoalById(String goalId) async {
    final goals = await isar.goals.where().findAll();
    return goals.firstWhere(
          (goal) => goal.goalId == goalId,
          orElse: () => throw 'Goal not found',
        )
        as Goal?;
  }

  // Update a goal
  Future<void> updateGoal(Goal goal) async {
    goal.updatedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.goals.put(goal);
    });
  }

  // Delete a goal
  Future<void> deleteGoal(String goalId) async {
    final goals = await isar.goals.where().findAll();
    final goal = goals.firstWhere(
      (g) => g.goalId == goalId,
      orElse: () => throw 'Goal not found',
    );
    await isar.writeTxn(() async {
      await isar.goals.delete(goal.id);
    });
  }

  // Get goals by type
  Future<List<Goal>> getGoalsByType(String type) async {
    final goals = await isar.goals.where().findAll();
    return goals.where((goal) => goal.type == type).toList();
  }

  // Get public goals
  Future<List<Goal>> getPublicGoals() async {
    final goals = await isar.goals.where().findAll();
    return goals.where((goal) => goal.isPublic).toList();
  }

  // Update goal progress
  Future<void> updateGoalProgress(String goalId, double progress) async {
    try {
      final goals = await isar.goals.where().findAll();
      final goal = goals.firstWhere((g) => g.goalId == goalId);
      goal.progress = progress.clamp(0.0, 100.0);
      goal.updatedAt = DateTime.now();
      await updateGoal(goal);
    } catch (e) {
      // Goal not found
    }
  }

  // Increment sessions completed
  Future<void> incrementSessionsCompleted(String goalId) async {
    try {
      final goals = await isar.goals.where().findAll();
      final goal = goals.firstWhere((g) => g.goalId == goalId);
      goal.sessionsCompleted++;
      goal.updatedAt = DateTime.now();
      await updateGoal(goal);
    } catch (e) {
      // Goal not found
    }
  }

  // Add minutes to total
  Future<void> addMinutes(String goalId, int minutes) async {
    try {
      final goals = await isar.goals.where().findAll();
      final goal = goals.firstWhere((g) => g.goalId == goalId);
      goal.totalMinutes += minutes;
      goal.updatedAt = DateTime.now();
      await updateGoal(goal);
    } catch (e) {
      // Goal not found
    }
  }

  // Clear all goals (for testing)
  Future<void> clearAllGoals() async {
    await isar.writeTxn(() async {
      await isar.goals.clear();
    });
  }
}
