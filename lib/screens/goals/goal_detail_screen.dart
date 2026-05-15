import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/goal.dart';
import '../../models/milestone.dart';
import 'package:productive_peers/providers/goal_provider.dart';
import 'package:productive_peers/widgets/common/app_bar_custom.dart';
import 'package:productive_peers/widgets/goals/details/goal_details.dart';
import 'package:productive_peers/widgets/goals/details/habit_details.dart';
import 'package:productive_peers/widgets/goals/details/study_details.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalProvider(goalId));

    return goalAsync.when(
      data: (goal) {
        if (goal == null) {
          return const Scaffold(
            body: Center(child: Text('Goal not found')),
          );
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: goal.title,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    // TODO: Navigate to edit screen
                  } else if (value == 'delete') {
                    _showDeleteConfirmationDialog(context, goal, ref);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (goal.description != null && goal.description!.isNotEmpty) ...[
                  Text(goal.description!, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: AppSizes.lg),
                ],
                _buildGoalTypeDetails(goal, ref),
              ],
            ),
          ),
          floatingActionButton: (goal.type == 'Goal' || goal.type == 'Study')
              ? FloatingActionButton(
                  onPressed: () => _showAddMilestoneDialog(context, goal, ref),
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildGoalTypeDetails(Goal goal, WidgetRef ref) {
    final onUpdate = (Goal updatedGoal) {
      ref.read(createGoalProvider.notifier).updateGoal(updatedGoal);
    };

    switch (goal.type) {
      case 'Habit':
        return HabitDetails(goal: goal, onUpdate: onUpdate);
      case 'Goal':
        return GoalDetails(goal: goal, onUpdate: onUpdate);
      case 'Study':
        return StudyDetails(goal: goal, onUpdate: onUpdate);
      default:
        return const Text('Unknown goal type');
    }
  }

  void _showAddMilestoneDialog(BuildContext context, Goal goal, WidgetRef ref) {
    final descriptionController = TextEditingController();
    final percentageController = TextEditingController();
    DateTime? targetDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Milestone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              if (goal.type == 'Goal')
                TextField(
                  controller: percentageController,
                  decoration: const InputDecoration(labelText: 'Percentage'),
                  keyboardType: TextInputType.number,
                ),
              if (goal.type == 'Study')
                ListTile(
                  title: const Text('Target Date'),
                  subtitle: Text(targetDate.toString().split(' ')[0]),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: targetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      // This requires a stateful dialog or a state management solution
                      // to update the UI of the dialog. For simplicity, we are not implementing this here.
                    }
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final milestone = Milestone()
                  ..description = descriptionController.text
                  ..percentage = double.tryParse(percentageController.text)
                  ..targetDate = targetDate;

                goal.milestones.add(milestone);
                ref.read(createGoalProvider.notifier).updateGoal(goal);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Goal goal, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Goal'),
          content: const Text('Are you sure you want to delete this goal?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(createGoalProvider.notifier).deleteGoal(goal.goalId);
                Navigator.of(context).pop();
                context.goNamed('goals');
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
