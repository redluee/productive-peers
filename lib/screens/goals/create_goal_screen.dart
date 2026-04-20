import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/goal_provider.dart';
import '../../widgets/common/app_bar_custom.dart';
import '../../widgets/goals/goal_form.dart';

class CreateGoalScreen extends ConsumerWidget {
  const CreateGoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.saveGoal),
      body: GoalForm(
        onSave: (goal) async {
          try {
            await ref.read(createGoalProvider.notifier).createGoal(goal);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Goal created successfully')),
              );
              context.go('/');
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
