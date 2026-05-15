import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../models/goal.dart';
import '../../providers/goal_provider.dart';
import '../../widgets/common/app_bar_custom.dart';
import '../../widgets/goals/goal_form.dart';

class CreateGoalScreen extends ConsumerWidget {
  final Goal? initialGoal;

  const CreateGoalScreen({super.key, this.initialGoal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: initialGoal != null ? AppStrings.editGoal : AppStrings.saveGoal,
      ),
      body: GoalForm(
        initialGoal: initialGoal,
        onSave: (goal) async {
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(initialGoal?.title == '' ? 'Create Goal?' : 'Update Goal?'),
              content: Text('Are you sure you want to save this goal?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Save'),
                ),
              ],
            ),
          );

          if (confirmed != true) return;

          try {
            if (initialGoal?.title != '') {
              await ref.read(createGoalProvider.notifier).updateGoal(goal);
            } else {
              await ref.read(createGoalProvider.notifier).createGoal(goal);
            }
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    initialGoal?.title != ''
                        ? 'Goal updated successfully'
                        : 'Goal created successfully',
                  ),
                ),
              );

              // Post-creation prompt for milestones
              if (initialGoal?.title == '' && (goal.type == 'Goal' || goal.type == 'Study')) {
                final addMilestone = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add Milestone?'),
                    content: Text('Would you like to add your first milestone to "${goal.title}" now?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Later'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Yes, Add'),
                      ),
                    ],
                  ),
                );

                if (addMilestone == true) {
                  context.pushReplacementNamed('goalDetail', pathParameters: {'goalId': goal.goalId});
                  // TODO: On goal detail screen, open a dialog to add a milestone
                } else {
                  context.goNamed('goals');
                }
              } else {
                context.goNamed('goals');
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        },
      ),
    );
  }
}
