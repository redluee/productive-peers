import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import 'package:productive_peers/widgets/goals/goal_type_selection_dialog.dart';
import 'package:productive_peers/widgets/common/app_bar_custom.dart';
import 'package:productive_peers/widgets/goals/goal_card.dart';

import '../../models/goal.dart';
import '../../providers/goal_provider.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.goalsTitle),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    AppStrings.noGoalsMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.md),
                child: GoalCard(
                  goal: goal,
                  onTap: () {
                    context.pushNamed(
                      'goalDetail',
                      pathParameters: {'goalId': goal.goalId},
                    );
                  },
                  onLongPress: () {
                    // Show edit/delete context menu
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit),
                              title: const Text('Edit Goal'),
                              onTap: () {
                                Navigator.pop(context);
                                context.pushNamed('createGoal', extra: goal);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete, color: Colors.red),
                              title: const Text('Delete Goal', style: TextStyle(color: Colors.red)),
                              onTap: () async {
                                Navigator.pop(context);
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Goal?'),
                                    content: const Text('This action cannot be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  try {
                                    await ref.read(createGoalProvider.notifier).deleteGoal(goal.goalId);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Goal deleted')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: AppSizes.md),
              Text('Error: $err'),
            ],
          ),
        ),
      ),
      floatingActionButton: Tooltip(
        message: AppStrings.createGoalButton,
        child: Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment(0.94, -0.34),
              end: Alignment(-0.94, 0.34),
              colors: [Color(0xFF00E3A4), Color(0xFF036E50)],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () async {
                final selectedType = await showDialog<String>(
                  context: context,
                  builder: (context) => const GoalTypeSelectionDialog(),
                );
                if (selectedType != null && context.mounted) {
                  context.pushNamed('createGoal', extra: Goal(
                    goalId: '', // Temporary
                    title: '',
                    type: selectedType,
                  ));
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
